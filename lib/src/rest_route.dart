/// Base route utility class with common path handling functions
abstract class BaseRoute {
  const BaseRoute();

  /// Creates a query string from parameters
  static String createQueryString(Map<String, dynamic> params) {
    return params.entries
        .map(
          (e) =>
              '${Uri.encodeComponent(e.key)}='
              '${Uri.encodeComponent(e.value.toString())}',
        )
        .join('&');
  }

  /// Safely joins path segments
  static String joinPaths(String base, String additional) {
    if (base == '/') return '/$additional';
    return '$base/$additional';
  }

  /// Returns the base route name
  String get basePath;

  /// Returns the full path including route name and path
  String get path;

  /// Adds query parameters to the path
  String withQueryParams(Map<String, dynamic> params) {
    if (params.isEmpty) return path;
    final queryString = BaseRoute.createQueryString(params);
    return '$path?$queryString';
  }

  /// Joins the current path with a subpath
  String join(String routeName) {
    return BaseRoute.joinPaths(path, routeName);
  }
}

class RestRoute<T extends RestRoute<T>> extends BaseRoute {
  const RestRoute(this._routeName, [this._routePath = '']) : super();

  final String _routeName;
  final String _routePath;

  @override
  String get basePath => _routeName;

  @override
  String get path =>
      _routePath.isEmpty ? _routeName : '$_routeName/$_routePath';

  /// Creates a new instance with the given id
  T withId(dynamic id) {
    final newPath = id.toString();
    // This is where the type cast error happens
    // We can't cast RestRoute<T> to T directly because they're different types
    return copyWithImpl(newPath);
  }

  /// Minimal method for retrieving a specific resource by id
  String id(dynamic id) => _createPath(id.toString());

  /// Creates a new instance with the given path - base implementation
  RestRoute<T> _copyWith(String newPath) {
    return RestRoute<T>(_routeName, newPath);
  }

  /// Should be implemented by subclasses to return the proper concrete type
  T copyWithImpl(String newPath) {
    throw UnimplementedError('Subclasses must override _copyWithImpl');
  }

  /// Creates a path with the given segment
  String _createPath(String segment) {
    if (segment.isEmpty) return path;
    final newInstance = _copyWith(segment);
    return newInstance.path;
  }

  /// Convenient method for withId
  T call(dynamic id) {
    return withId(id);
  }
}

final class SimpleRoute extends RestRoute<SimpleRoute> {
  const SimpleRoute(super._routeName, [super._routePath]);

  @override
  SimpleRoute copyWithImpl(String newPath) {
    return SimpleRoute(_routeName, newPath);
  }
}

class NestedRoute<
  ParentT extends BaseRoute,
  SelfT extends NestedRoute<ParentT, SelfT>
>
    extends BaseRoute {
  const NestedRoute(this._parent, this._routeName, [this._routePath = ''])
    : super();

  final ParentT _parent;
  final String _routeName;
  final String _routePath;

  /// Creates a new instance with the given id
  SelfT withId(dynamic id) {
    final newPath = id.toString();
    return copyWithImpl(newPath);
  }

  /// Creates a new instance with the given path - base implementation
  NestedRoute<ParentT, SelfT> _copyWith(String newPath) {
    return NestedRoute<ParentT, SelfT>(_parent, _routeName, newPath);
  }

  /// Should be implemented by subclasses to return the proper concrete type
  SelfT copyWithImpl(String newPath) {
    throw UnimplementedError('Subclasses must override _copyWithImpl');
  }

  @override
  String get basePath => BaseRoute.joinPaths(_parent.path, _routeName);

  @override
  String get path =>
      _routePath.isEmpty ? basePath : BaseRoute.joinPaths(basePath, _routePath);

  /// Minimal method for retrieving a specific resource by id
  String id(dynamic id) => _createPath(id.toString());

  /// Creates a path with the given segment
  String _createPath(String segment) {
    if (segment.isEmpty) return path;
    final newInstance = _copyWith(segment);
    return newInstance.path;
  }

  /// Convenient method for withId
  SelfT call(dynamic id) {
    return withId(id);
  }
}

final class SimpleNestedRoute<ParentT extends BaseRoute>
    extends NestedRoute<ParentT, SimpleNestedRoute<ParentT>> {
  const SimpleNestedRoute(
    super._parent,
    super._routeName, [
    super._routePath = '',
  ]);

  @override
  SimpleNestedRoute<ParentT> copyWithImpl(String newPath) {
    return SimpleNestedRoute<ParentT>(_parent, _routeName, newPath);
  }
}

/// Mixin providing RESTful operations for any BaseRoute
mixin RestfulMixin on BaseRoute {
  //RESTful API methods
  /// Returns the path for retrieving a specific resource by id
  String get(dynamic id) => BaseRoute.joinPaths(path, id.toString());

  /// Returns the path for creating a new resource
  String get create => basePath;

  /// Returns the path for retrieving all resources
  String get list => basePath;

  /// Returns the path for updating a resource by id
  String update(dynamic id) => BaseRoute.joinPaths(path, id.toString());

  /// Returns the path for deleting a resource by id
  String delete(dynamic id) => BaseRoute.joinPaths(path, id.toString());
}
