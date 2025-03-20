import 'package:rest_route/rest_route.dart';
import 'package:test/test.dart';

// Define test routes based on the provided example
abstract class ApiRoutes {
  static final auth = AuthRoute();
  static final stories = StoryRoute();
  static const search = SimpleRoute('search');
}

class AuthRoute extends RestRoute<AuthRoute> {
  AuthRoute([String routePath = '']) : super('auth', routePath);

  String get login => join('login/token');

  @override
  AuthRoute copyWith(String newPath) => AuthRoute(newPath);
}

class StoryRoute extends RestRoute<StoryRoute> with RestfulMixin {
  StoryRoute([String routePath = '']) : super('stories', routePath);

  late final chapters = ChapterRoute(this);

  @override
  StoryRoute copyWith(String newPath) => StoryRoute(newPath);
}

class ChapterRoute extends NestedRoute<StoryRoute, ChapterRoute>
    with RestfulMixin {
  ChapterRoute(this.parent, [String routePath = ''])
      : super(parent, 'chapters', routePath);

  final StoryRoute parent;

  String get doSomething => join('doSomething');

  @override
  ChapterRoute copyWith(String newPath) => ChapterRoute(parent, newPath);
}

void main() {
  group('BaseRoute', () {
    test('createQueryString should format parameters correctly', () {
      final params = {'key1': 'value1', 'key2': 'value 2', 'key3': 123};
      final queryString = BaseRoute.createQueryString(params);
      expect(queryString, 'key1=value1&key2=value%202&key3=123');
    });

    test('joinPaths should handle path segments correctly', () {
      expect(BaseRoute.joinPaths('/', 'test'), '/test');
      expect(BaseRoute.joinPaths('/api', 'users'), '/api/users');
      expect(BaseRoute.joinPaths('api', 'users'), 'api/users');
    });
  });

  group('SimpleRoute', () {
    test('should create correct paths', () {
      final route = SimpleRoute('users');
      expect(route.path, 'users');
      expect(route.basePath, 'users');

      expect(route(123).path, 'users/123');
      expect(route(456).path, 'users/456');
    });

    test('should handle query parameters', () {
      final route = SimpleRoute('users');
      final path = route.withQueryParams({'page': 1, 'limit': 10});
      expect(path, 'users?page=1&limit=10');

      final idPath = route(123).withQueryParams({'active': true});
      expect(idPath, 'users/123?active=true');
    });
  });

  group('AuthRoute', () {
    test('should create correct paths', () {
      final auth = AuthRoute();
      expect(auth.path, 'auth');
      expect(auth.login, 'auth/login/token');
    });
  });

  group('RestfulMixin', () {
    test('should provide RESTful operations', () {
      final stories = StoryRoute();

      expect(stories.list, 'stories');
      expect(stories.create, 'stories');
      expect(stories.get(123), 'stories/123');
      expect(stories.update(456), 'stories/456');
      expect(stories.delete(789), 'stories/789');
    });
  });

  group('Nested Routes', () {
    test('should handle nested paths correctly', () {
      final stories = StoryRoute();

      expect(stories.chapters.path, 'stories/chapters');
      expect(stories(123).chapters.path, 'stories/123/chapters');
      expect(stories(123).chapters(456).path, 'stories/123/chapters/456');
      expect(
        stories(123).chapters(456).doSomething,
        'stories/123/chapters/456/doSomething',
      );
    });

    test('should work with RestfulNestedMixin', () {
      final stories = StoryRoute();
      final chapters = stories(10).chapters;

      expect(chapters.list, 'stories/10/chapters');
      expect(chapters.create, 'stories/10/chapters');
      expect(chapters.get(5), 'stories/10/chapters/5');
      expect(chapters.update(5), 'stories/10/chapters/5');
      expect(chapters.delete(5), 'stories/10/chapters/5');
    });
  });

  group('ApiRoutes usage', () {
    test('should match the example API calls', () {
      // Auth endpoints
      expect(ApiRoutes.auth.login, 'auth/login/token');

      // Story endpoints with RestfulMixin
      expect(ApiRoutes.stories.list, 'stories');
      expect(ApiRoutes.stories.create, 'stories');
      expect(ApiRoutes.stories.get(123), 'stories/123');
      expect(ApiRoutes.stories.update(123), 'stories/123');
      expect(ApiRoutes.stories.delete(123), 'stories/123');

      // Using simple route with query params
      final searchPath = ApiRoutes.search.withQueryParams({
        "q": "novel",
        "page": 1,
      });
      expect(searchPath, 'search?q=novel&page=1');

      // Nested route calls
      expect(ApiRoutes.stories(10).chapters(5).path, 'stories/10/chapters/5');
      expect(
        ApiRoutes.stories(10).chapters(122).doSomething,
        'stories/10/chapters/122/doSomething',
      );
    });
  });
}
