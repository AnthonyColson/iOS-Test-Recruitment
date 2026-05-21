# REFLECTION — Architecture of TheGoodCorner

## 1. Global architectural choices

I am going to develop TheGoodCorner app that is an iOS application written in **Swift / SwiftUI** (entry point `@main` in `TheGoodCornerApp`). The codebase is organized around a **layered, Clean-Architecture** structure, where each folder corresponds to a clear responsibility and depends only on the layers below it. I will use MVVM inside the Presentation layer to handle logic between the view and the buiness logic

### Layer breakdown

```
TheGoodCorner/
├── Data/            # I/O: network, DTOs, (later) persistence, repositories
└── Presentation/    # SwiftUI views, assets, (later) view and view models
└── Domain/          # (later) models from DTO to pass to the Presentation layer
```

Three principles drive this layout.

**Separation of concerns.** The UI layer must never know how data is fetched, and the data layer must never know how data is displayed. The layers will communicate through types (`Decodable` DTOs, typed errors) rather than through implementation details. This makes it possible to swap, for example, `URLSession` for a different transport without touching any view.

**Protocol-oriented design.** Every non-trivial collaborator in the `Data` layer is described by a protocol first (`Networker`, `NetworkerService`, `RequestBuilderProtocol`, `ReportableError`). Concrete classes (`NetworkerServiceImpl`, `RequestBuilder`) are `final` and depend on protocol abstractions through constructor injection. This unlocks two things at once: easy unit testing via spies/fakes, and the ability to introduce new implementations (a mock backend, an offline-first decorator, a logging wrapper) without modifying call sites.

**Modern Swift concurrency.** The whole networking surface is Swift 5.5 `async/await`-based, and the public protocols are marked `Sendable` so the code is ready for Swift 6 strict concurrency checking. There is no callback-based or Combine-based API to maintain.

### Testing strategy

Tests live in `TheGoodCornerTests/` and **mirror the production folder structure** (`Data/Network/...` ↔ `Tests/Data/...`). They are written with the new **Swift Testing** framework (`@Suite`, `@Test`, `#expect`, `Issue.record`) rather than XCTest. Two test-double patterns are in place:

- **Spies** (`NetworkerSpy`, `RequestBuilderSpy`) capture call flags (`isNetworkerCalled`, `buildRequestCalled`) and let tests inject either a canned response or an error.
- **Mock factories** (`Endpoint+Mock`) expose ready-made fixtures such as `Endpoint.mocked()`.

The `NetworkerServiceImpl` is covered on the happy path and on every failure branch (build error, transport error, 3xx/4xx/5xx status codes, DTO mismatch, 2xx success), with status codes parameterized through `@Test(arguments:)`.
I will not implements other tests for the Data components to save some time

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

The generic signature means callers describe *what* they expect back (the DTO type) and the service handles the rest.

### `Endpoint` and `APIEndpoints` — describing the API surface

`Endpoint` is an immutable value type that describes a single API call: path, HTTP method, query/header/body parameters, and cache policy. `HTTPMethodType` enumerates the standard verbs. `APIEndpoints` is the single place where the API `baseURL` lives (currently pointing at `http://localhost:8080`); this is the natural location for future per-environment configuration.
