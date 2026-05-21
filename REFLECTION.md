# REFLECTION — Architecture of TheGoodCorner

## 1. Global architectural choices

TheGoodCorner is an iOS application written in **Swift / SwiftUI** (entry point `@main` in `TheGoodCornerApp`). The codebase is organized around a **layered, Clean-Architecture-inspired** structure, where each folder corresponds to a clear responsibility and depends only on the layers below it.

### Layer breakdown

```
TheGoodCorner/
├── Core/            # App entry point and cross-cutting concerns
├── Data/            # I/O: network, DTOs, (later) persistence, repositories
└── Presentation/    # SwiftUI views, design system, router, view models
```

Three principles drive this layout.

**Separation of concerns.** The UI layer must never know how data is fetched, and the data layer must never know how data is displayed. The two layers communicate through types (`Decodable` DTOs, typed errors) rather than through implementation details. This makes it possible to swap, for example, `URLSession` for a different transport without touching any view.

**Protocol-oriented design.** Every non-trivial collaborator in the `Data` layer is described by a protocol first (`Networker`, `NetworkerService`, `RequestBuilderProtocol`, `ReportableError`). Concrete classes (`NetworkerServiceImpl`, `RequestBuilder`) are `final` and depend on protocol abstractions through constructor injection. This unlocks two things at once: easy unit testing via spies/fakes, and the ability to introduce new implementations (a mock backend, an offline-first decorator, a logging wrapper) without modifying call sites.

**Modern Swift concurrency.** The whole networking surface is `async/await`-based, and the public protocols are marked `Sendable` so the code is ready for Swift 6 strict concurrency checking. There is no callback-based or Combine-based API to maintain.

### Testing strategy

Tests live in `TheGoodCornerTests/` and **mirror the production folder structure** (`Data/Network/...` ↔ `Tests/Data/...`). They are written with the new **Swift Testing** framework (`@Suite`, `@Test`, `#expect`, `Issue.record`) rather than XCTest. Two test-double patterns are in place:

- **Spies** (`NetworkerSpy`, `RequestBuilderSpy`) capture call flags (`isNetworkerCalled`, `buildRequestCalled`) and let tests inject either a canned response or an error.
- **Mock factories** (`Endpoint+Mock`) expose ready-made fixtures such as `Endpoint.mocked()`.

The `NetworkerServiceImpl` is covered on the happy path and on every failure branch (build error, transport error, 3xx/4xx/5xx status codes, DTO mismatch, 2xx success), with status codes parameterized through `@Test(arguments:)`. The view-model tests reuse the same parameterized-arguments style to validate locale-aware behaviours without duplicating logic.

---

## 2. The Networking layer

The networking stack is the most developed part of the codebase and illustrates the architectural principles described above. It is split into four cooperating pieces, each behind a protocol.

### `Networker` — the transport abstraction

`Networker` is a tiny `Sendable` protocol with a single method:

```swift
func loadData(from request: URLRequest) async throws -> (Data, URLResponse)
```

Its only job is to perform the raw HTTP call. `URLSession` is conformed to this protocol through an extension, which means production code uses the real `URLSession` while tests inject a `NetworkerSpy` — without ever subclassing or monkey-patching `URLSession`. This is the single seam through which fake network behaviour is introduced in tests.

A companion `NetworkerSession` exposes a shared `URLSession` configured with a custom `SessionDelegate`, ready to be wired in production.

### `RequestBuilder` — turning an `Endpoint` into a `URLRequest`

`RequestBuilder` (and its protocol `RequestBuilderProtocol`) is responsible for assembling a fully formed `URLRequest` from a `baseURL` and an `Endpoint`. It handles:

- **Path composition.** `EndpointPath` separates an `absolute` format string from its `components` (`CVarArg`), so parameterized paths like `"/items/%@"` can be built in a type-safe way via `String(format:arguments:)`.
- **Query parameters.** Items are sorted (for stable URLs / easier testing) and arrays are expanded into repeated query items.
- **Body parameters.** Non-empty body dictionaries are JSON-serialized with `.sortedKeys`.
- **Headers, HTTP method, and cache policy.** Applied straight from the `Endpoint`.

Isolating this logic in its own type means request shaping can evolve (signed requests, auth tokens, custom encoders) without touching the service that consumes it.

### `NetworkerService` — orchestration and decoding

`NetworkerServiceImpl` is the high-level entry point used by the rest of the app. It composes `RequestBuilder` and `Networker` and exposes a generic method:

```swift
func request<T: Decodable>(baseURL: URL, endpoint: Endpoint) async throws -> T
```

Its responsibility is the full request lifecycle:

1. Ask the `RequestBuilder` for a `URLRequest`; on failure, throw `NetworkError.APIRequest.couldNotCreateRequest`.
2. Hand the request to the `Networker` and `await` the result.
3. Validate that the response is an `HTTPURLResponse` (otherwise `NetworkError.APIResponse.unexpected`).
4. Reject any status code in `300..<600` with `NetworkError.APIResponse.statusCodeError(code:)`.
5. Decode the `Data` into the generic `T` via `JSONDecoder`; any decoding failure surfaces as `NetworkError.APIResponse.dtoMismatch`.

The generic signature means callers describe *what* they expect back (the DTO type) and the service handles the rest. For endpoints that return no payload, the project provides `EmptyDTO`, a `Codable` empty struct reused across both production and tests.

### `Endpoint` and `APIEndpoints` — describing the API surface

`Endpoint` is an immutable value type that describes a single API call: path, HTTP method, query/header/body parameters, and cache policy. `HTTPMethodType` enumerates the standard verbs. `APIEndpoints` is the single place where the API `baseURL` lives (currently pointing at `http://localhost:8080`); this is the natural location for future per-environment configuration.

### `NetworkError` — structured, observable errors

Errors are not just `Error` values: they conform to a custom `ReportableError` protocol that exposes `domain`, `name`, and `code`. They are organized into nested namespaces — `NetworkError.APIResponse`, `NetworkError.APIRequest`, `NetworkError.Network` — so callers can pattern-match on a small, meaningful set of cases. This shape is designed with **observability** in mind: the `domain` / `name` / `code` triplet maps cleanly to logging and crash-reporting pipelines.

---

## 3. Atomic elements (design tokens)

The `Presentation/DesignSystem/AtomicElements/` folder hosts the lowest-level building blocks of the UI: `Spacing` (a 4-pt-based scale), `BorderRadius` and `BorderWidth`, `AppColor` (color tokens with **built-in dark-mode support** via `UIColor`'s `dynamicProvider`), and `Typo` (font sizes, weights and ready-to-use `Font` presets). Centralizing these tokens means a view never hard-codes a hex value, a padding number or a font size — every visual decision flows through the design system, which keeps the app visually consistent and makes a future theme swap or rebranding mostly a one-file change. A `DesignSystemShowcaseView` (reachable from a debug-only toolbar button on the main screen) renders every token in light and dark mode, doubling as a living style guide. I also verified the contrast and labels of these tokens with the **Accessibility Inspector** to make sure the color pairs (text on background, badge text on error color, etc.) pass WCAG contrast checks and that VoiceOver reads what it should.

---

## 4. The Router

The `Presentation/Router/` folder centralizes navigation. A `Route` protocol describes any destination (an `id`, plus a `@ViewBuilder var view`), `NavigationMode` enumerates how it is shown (`push`, `sheet`, `fullCover`), and a generic `Router<R: Route>` (`ObservableObject` for iOS 16 compatibility) holds a `NavigationPath`, the currently presented sheet and the currently presented full-screen cover. `RouterView` is the container that wires everything: it binds the path to a `NavigationStack`, attaches `.sheet(item:)` and `.fullScreenCover(item:)`, and injects the router into the environment via `.environmentObject`. The benefit is that **views don't own navigation logic** — any descendant can declare `@EnvironmentObject private var router: Router<AppRoute>` and call `router.navigate(to: .detail(...), mode: .sheet)`, while flow-level decisions (which screen comes next, whether it pushes or presents) stay in one testable place.

---

## 5. Components

The `Presentation/DesignSystem/Components/` folder hosts reusable molecules built on top of the atomic tokens. `ImageComponent` wraps `AsyncImage` and handles its three phases (loading / success / failure) with design-system-styled placeholders and a retry button that re-triggers the load by changing an internal `@State` `UUID` used as `.id(...)`. `ListingCardView` is a vertical card sized to fit two-up in a `LazyVGrid`, composing `ImageComponent` (with the `URGENT` badge as a `.overlay(alignment: .topLeading)` so it doesn't affect layout flow), the title (capped at two lines with a hidden two-line placeholder reserving the height so every card stays the same size), the price and the date. All formatting logic lives in `ListingCardViewModel`, which takes an injectable `Locale` and exposes `formattedPrice`, `formattedDate` and `accessibilityDescription` — that separation makes the view a pure layout description and lets the formatting be unit-tested across multiple locales with `@Test(arguments:)`.

