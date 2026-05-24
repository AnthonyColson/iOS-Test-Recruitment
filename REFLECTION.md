# Technical Documentation

## API Logic

We have two APIs:

- **`/categories`**: lists all categories, each composed of an `id` and a `name`.
- **`/listing`**: lists the app items page by page. Each item is represented by a title, a description, two image URLs, etc.

### Category ↔ Item Mapping

One point of attention: an item from the `/listing` API contains a **category id** that matches a category from the `/categories` API.

To display an item's category name, I therefore transform the returned category list into a **`[Id: Name]` dictionary**, in order to match the category id (contained in the item) to its `name` in **O(1)**.

### Filtering by Category

I was asked to allow filtering by category, which also impacts the **ViewModel** since it adds logic.

**Why?** The `/listing` API doesn't directly offer a category filter. There is a query filter, but it isn't reliable: if we filter with the query `'House'`, we get both houses for sale (real estate) and doll houses.

To solve this, we filter the returned items by the **id of the selected category**.

### Pagination

Another mechanism to handle: pagination. We define a minimum number of items to display per page (as long as there are pages left to load). If this minimum isn't reached, we load the next page.

> A `while` loop mechanism with a safety case to avoid infinite loops.

---

## Architecture Logic

I decided to go with **Clean Architecture**, splitting the application into three layers.

### Data Layer

Contains everything related to the interface / server contract:

- Networker
- Request builder
- Endpoints
- DTOs
- Cache services repository

> Uses `async/await` in the simplest way possible, with *strict concurrency*.

### Domain Layer

- Contains the **entities** created from the DTOs, with formats dates and URLs.
- Sends them to the presentation layer via the **interactors**.
- Provide usefull functions (usecases) to handle the buisness logic

### Presentation Layer

Handles view logic and business logic. It contains:

- The **flows** (View / ViewModel)
- The **design system** (atomic + components)
- The **router** (here a `NavigationPath`, since iOS 16+)
- Helpers
- The ViewModel **factory** that inject all dependencies

---

## Testing Strategy

I decided to use **Swift Testing**, the most readable, simple, and concise option.

Since the app uses a **dependency injection** approach, we can create **spies** to test each object independently.

Tests cover:

- The networker
- The router
- The ViewModels
- The repository
- The interactor

---

## AI Usage

Used **Claude Code** for specific, trivial requests:

- Creating the atomic elements of the design system
- Creating localized text
- Mocks

### A More Complex Example

I asked Claude to create an item's detail page with the following prompt:

> *Create an iOS detail page using MVVM and the design system, make it accessible.*

**Issues encountered:**

- Claude declared the ViewModel as `Observable`, even though it isn't **reactive**: it takes an already-loaded object. So we could use a `struct` instead.
- The view reuses part of the design system, but also contains **hardcoded typography sizes and text**.

**How to avoid this?** We could have defined **skills** describing how to handle accessibility, how to code views with the design system, etc. But that wasn't in the scope of this project.
