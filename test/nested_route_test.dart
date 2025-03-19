import 'package:rest_route/rest_route.dart';
import 'package:test/test.dart';

abstract class ApiRoutes {
  static final user = UserRoute();
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

  late final comments = CommentsRoute(this);
  final UserRoute parent;

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

void main() {
  group('Multi-level Nested Routes', () {
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
      expect(
        users(1).posts(2).comments(3).report,
        'users/1/posts/2/comments/3/report',
      );
    });

    test('should work with SimpleNestedRoute', () {
      final users = UserRoute();

      expect(users(1).settings.path, 'users/1/settings');
      expect(users(1).settings('profile').path, 'users/1/settings/profile');

      final queryPath = users(1).settings.withQueryParams({'theme': 'dark'});
      expect(queryPath, 'users/1/settings?theme=dark');
    });

    test('should work with RESTful operations at each level', () {
      final users = UserRoute();

      // User level operations
      expect(users.list, 'users');
      expect(users.get(5), 'users/5');

      // Posts level operations
      expect(users(5).posts.list, 'users/5/posts');
      expect(users(5).posts.create, 'users/5/posts');
      expect(users(5).posts.get(10), 'users/5/posts/10');

      // Comments level operations
      expect(users(5).posts(10).comments.list, 'users/5/posts/10/comments');
      expect(users(5).posts(10).comments.create, 'users/5/posts/10/comments');
      expect(
        users(5).posts(10).comments.get(15),
        'users/5/posts/10/comments/15',
      );
      expect(
        users(5).posts(10).comments.update(15),
        'users/5/posts/10/comments/15',
      );
      expect(
        users(5).posts(10).comments.delete(15),
        'users/5/posts/10/comments/15',
      );
    });
  });
}
