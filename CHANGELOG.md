## 0.0.4

Refactor Route System for Clarity & Type-Safety

-   Converted RestRoute and NestedRoute to abstract classes
-   These base classes can no longer be instantiated directly.
-   Provides a clearer contract for subclasses.
-   Introduced an abstract copyWith() method
-   Subclasses must now implement copyWith() to create new instances.
-   Eliminates the need for \_copyWith() and copyWithImpl().
-   Updated internal methods to use copyWith()
-   Ensures consistent instance creation and avoids type casting issues.
-   Breaking Changes
-   Subclasses like SimpleRoute and SimpleNestedRoute must now implement copyWith().
-   Any direct instantiation of RestRoute or NestedRoute will no longer be possible.

## 0.0.5

-   Update example
