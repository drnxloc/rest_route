---
title: "Effortless API Routing in Flutter: Type-Safe, Scalable, and Clean"
date: "2025-03-19"
tags: ["flutter"]
draft: false
summary: Learn how to manage API routes in Flutter efficiently with RestRoute<T> and NestedRoute<P, T>, ensuring type safety, cleaner code, and easier maintenance for RESTful APIs.
---

## RestRoute Utility Explained

A simple way to manage API routes in your app with type safety and proper inheritance.

## What It Does

`RestRoute<T>` is a base class that helps you create API routes flexibly, allowing you to concatenate paths and add parameters easily. `NestedRoute<P, T>` is used to create child routes, such as "stories/13/comments/5", while maintaining type safety.

When working with APIs, we often need to construct various URL paths dynamically. Managing these routes manually can lead to errors, inconsistencies, and difficult-to-maintain code.

This utility helps you build API URLs in a structured, type-safe way. Instead of manually writing strings like `"users/123/comments"`, you can use method chains that are checked by the compiler.

### Key Improvements in the New Version

The updated implementation addresses several key issues:

1. **Proper Type Safety**: Routes now correctly return their concrete types through a `copyWithImpl` method that each subclass must implement
2. **More Flexible Inheritance**: `NestedRoute` now accepts any `BaseRoute` as a parent, not just `RestRoute`
3. **Improved Mixin Support**: The `RestfulMixin` now works with any `BaseRoute`, making it more versatile

## Basic Usage

### Creating a Simple Route

```dart
// Define your route class
class UserRoute extends RestRoute<UserRoute> {
  UserRoute([String routePath = '']) : super('users', routePath);

  // Required implementation
  @override
  UserRoute copyWithImpl(String newPath) {
    return UserRoute(newPath);
  }

  // Add custom endpoints as needed
  String get profile => join('profile');
}

// Create and use your route
final userRoute = UserRoute();
final profileUrl = userRoute.profile;     // Result: "users/profile"
final userWithIdUrl = userRoute.id(123);  // Result: "users/123"
```

### The copyWithImpl Method

In the new implementation, every subclass of `RestRoute` and `NestedRoute` must implement a `copyWithImpl` method. This ensures proper type safety when creating new instances with different paths:

```dart
@override
UserRoute copyWithImpl(String newPath) {
  return UserRoute(newPath);
}
```

This method replaces the previous internal `_copyWith` method and fixes the casting issue in the original implementation.

### Main Features

-   **Adding IDs**: `route.id(123)` gives `"resource/123"`
-   **Joining paths**: `route.join("something")` gives `"resource/something"`
-   **Adding query parameters**: `route.withQueryParams({"sort": "asc"})` gives `"resource?sort=asc"`

### Working with IDs

There are multiple ways to add an ID:

```dart
// These all do the same thing:
userRoute.withId(10).path;  // "users/10"
userRoute(10).path;         // "users/10"

// Short-hand syntax, which doesn't require calling .path
userRoute.id(10);           // "users/10"

// Get just the base path without the ID
userRoute(10).basePath;     // "users"
```

### Adding Query Parameters

```dart
// Helper method example
String getUsersFiltered({String? role, int? page}) {
  final params = <String, dynamic>{};
  if (role != null) params['role'] = role;
  if (page != null) params['page'] = page;
  return userRoute.withQueryParams(params);  // Result: "users?role=admin&page=1"
}
```

## Nested Routes

For URLs with multiple segments like `"users/13/posts/5/comments"`:

```dart
// Parent route
class UserRoute extends RestRoute<UserRoute> {
  UserRoute([String routePath = '']) : super('users', routePath);

  // Define nested routes
  late final posts = PostsRoute(this);

  @override
  UserRoute copyWithImpl(String newPath) {
    return UserRoute(newPath);
  }
}

// Define the nested route
class PostsRoute extends NestedRoute<UserRoute, PostsRoute> {
  PostsRoute(this.parent, [String routePath = ''])
      : super(parent, 'posts', routePath);

  final UserRoute parent;

  // Define deeper nested routes
  late final comments = CommentsRoute(this);

  @override
  PostsRoute copyWithImpl(String newPath) {
    return PostsRoute(parent, newPath);
  }
}

class CommentsRoute extends NestedRoute<PostsRoute, CommentsRoute> {
  CommentsRoute(this.parent, [String routePath = ''])
      : super(parent, 'comments', routePath);

  final PostsRoute parent;

  String get featured => join('featured');

  @override
  CommentsRoute copyWithImpl(String newPath) {
    return CommentsRoute(parent, newPath);
  }
}

// Using the nested routes
final users = UserRoute();

// Create nested paths
users(13).path                       // "users/13"
users(13).posts.path                 // "users/13/posts"
users(13).posts(5).path              // "users/13/posts/5"
users(13).posts(5).comments.path     // "users/13/posts/5/comments"
users(13).posts(5).comments.featured // "users/13/posts/5/comments/featured"
```

## Standard REST Methods

Add standard CRUD operations with the `RestfulMixin`:

```dart
class UserRoute extends RestRoute<UserRoute> with RestfulMixin {
  UserRoute([String routePath = '']) : super('users', routePath);

  @override
  UserRoute copyWithImpl(String newPath) {
    return UserRoute(newPath);
  }
}

final users = UserRoute();
users.list;         // "users" (GET - for listing all)
users.create;       // "users" (POST - for creating new)
users.get(123);     // "users/123" (GET - for getting one)
users.update(123);  // "users/123" (PUT - for updating)
users.delete(123);  // "users/123" (DELETE - for removing)
```

### RestfulMixin for All Routes

The updated `RestfulMixin` can be applied to any class that extends `BaseRoute`, making it more versatile:

```dart
// Works with both RestRoute and NestedRoute
mixin RestfulMixin on BaseRoute {
  // RESTful API methods
  String get(dynamic id) => BaseRoute.joinPaths(path, id.toString());
  String get create => basePath;
  String get list => basePath;
  String update(dynamic id) => BaseRoute.joinPaths(path, id.toString());
  String delete(dynamic id) => BaseRoute.joinPaths(path, id.toString());
}
```

## Complete Example

```dart
// Define all your routes in one place
abstract class ApiRoutes {
  static final users = UserRoute();
}

// Multi-level nested route example
class UserRoute extends RestRoute<UserRoute> with RestfulMixin {
  UserRoute([String routePath = '']) : super('users', routePath);

  late final posts = PostsRoute(this);
  late final settings = SimpleNestedRoute(this, 'settings');

  @override
  UserRoute copyWithImpl(String newPath) {
    return UserRoute(newPath);
  }
}

class PostsRoute extends NestedRoute<UserRoute, PostsRoute> with RestfulMixin {
  PostsRoute(this.parent, [String routePath = ''])
      : super(parent, 'posts', routePath);

  final UserRoute parent;

  late final comments = CommentsRoute(this);

  @override
  PostsRoute copyWithImpl(String newPath) {
    return PostsRoute(parent, newPath);
  }
}

class CommentsRoute extends NestedRoute<PostsRoute, CommentsRoute>
    with RestfulMixin {
  CommentsRoute(this.parent, [String routePath = ''])
      : super(parent, 'comments', routePath);

  final PostsRoute parent;

  String get featured => join('featured');
  String get report => join('report');

  @override
  CommentsRoute copyWithImpl(String newPath) {
    return CommentsRoute(parent, newPath);
  }
}

// Using in your code
void apiCalls() async {
  final dio = Dio(); // Your HTTP client

  // User endpoints with RestfulMixin
  await dio.get(ApiRoutes.users.list);             // "users"
  await dio.post(ApiRoutes.users.create);          // "users"
  await dio.get(ApiRoutes.users.get(123));         // "users/123"

  // Nested routes
  await dio.get(ApiRoutes.users(123).posts.list);  // "users/123/posts"
  await dio.get(ApiRoutes.users(123).posts(5).comments.featured);  // "users/123/posts/5/comments/featured"

  // Using SimpleNestedRoute
  await dio.get(ApiRoutes.users(123).settings.path);  // "users/123/settings"

  // With query parameters
  await dio.get(ApiRoutes.users.withQueryParams({
    "role": "admin",
    "page": 1
  }));  // "users?role=admin&page=1"
}
```

## Enhanced Types and Flexibility

### SimpleRoute and SimpleNestedRoute

The library provides ready-to-use implementations for simpler use cases:

```dart
// Create a simple route without defining a class
final simple = SimpleRoute('products');
simple.path;  // "products"
simple(5).path;  // "products/5"

// Create a simple nested route
final user = UserRoute(1);
final settings = SimpleNestedRoute(user, 'settings');
settings.path;  // "users/1/settings"
settings('profile').path;  // "users/1/settings/profile"
```

Both implement the required `copyWithImpl` method, so you don't need to implement it yourself.

## Testing

The library supports easy testing of your routes:

```dart
test('should handle deep nesting correctly', () {
  final users = UserRoute();

  // Basic path tests
  expect(users.path, 'users');
  expect(users.posts.path, 'users/posts');
  expect(users.posts.comments.path, 'users/posts/comments');

  // With IDs
  expect(users(1).path, 'users/1');
  expect(users(1).posts.path, 'users/1/posts');
  expect(users(1).posts(2).path, 'users/1/posts/2');
  expect(users(1).posts(2).comments.path, 'users/1/posts/2/comments');
  expect(users(1).posts(2).comments(3).path, 'users/1/posts/2/comments/3');

  // Custom endpoints
  expect(
    users(1).posts(2).comments.featured,
    'users/1/posts/2/comments/featured',
  );
});
```

## Tips for Good Implementation

1. **Always implement `copyWithImpl`**: This is required for type safety
2. **Store the parent in nested routes**: This makes it easier to create the `copyWithImpl` method
3. **Use `late final` for nested routes**: This prevents recreating them every time they're accessed
4. **Group related endpoints by resource**: Keep your API routes organized
5. **Use `RestfulMixin` for standard CRUD operations**: Minimize boilerplate code
6. **Create a centralized place for all routes**: Like the `ApiRoutes` class in the example
