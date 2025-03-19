// Define all your routes in one place
import 'package:rest_route/rest_route.dart';

class FakeDio {
  Future<void> get(String path) async {}
  Future<void> post(String path) async {}
}

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
  final dio = FakeDio(); // Your HTTP client

  // User endpoints with RestfulMixin
  await dio.get(ApiRoutes.users.list); // "users"
  await dio.post(ApiRoutes.users.create); // "users"
  await dio.get(ApiRoutes.users.get(123)); // "users/123"

  // Nested routes
  await dio.get(ApiRoutes.users(123).posts.list); // "users/123/posts"
  await dio.get(ApiRoutes.users(123)
      .posts(5)
      .comments
      .featured); // "users/123/posts/5/comments/featured"

  // Using SimpleNestedRoute
  await dio.get(ApiRoutes.users(123).settings.path); // "users/123/settings"

  // With query parameters
  await dio.get(ApiRoutes.users.withQueryParams(
      {"role": "admin", "page": 1})); // "users?role=admin&page=1"
}
