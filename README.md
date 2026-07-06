# flutter_simple_access_engine

`flutter_simple_access_engine` is a lightweight ABAC permission engine for Flutter.

## Installation

Add the package to your Flutter app:

```yaml
dependencies:
  flutter_simple_access_engine:
    path: ../flutter_simple_access_engine
```

Or use the published version from `pub.dev` once available.

## Permission Format

Permissions are stored as a map of features to actions:

```dart
final permissions = {
  'billing': ['view', 'pay', 'export'],
  'workspace': ['create', 'view'],
};
```

Rules are case-insensitive and trimmed before matching.

## Wildcards

Feature wildcard:

```dart
final permissions = {
  'billing': ['*'],
};
```

Global wildcard:

```dart
final permissions = {
  '*': ['*'],
};
```

Lookup order:

1. exact feature + exact action
2. feature + `*`
3. `*` + `*`

## Quick Start

Wrap your app with `AbacProvider`:

```dart
AbacProvider(
  permissions: permissions,
  child: const MyApp(),
);
```

Check access in code:

```dart
final abac = Abac.of(context);
if (abac.can('billing', 'view')) {
  // show billing UI
}
```

## Provider Example

```dart
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AbacProvider(
      permissions: const {
        'billing': ['view'],
      },
      child: MaterialApp(
        home: const HomePage(),
      ),
    );
  }
}
```

If `permissions` is `null`, the provider is not ready and permission checks return `false`.

## Context Extension Example

Use the context extension for concise checks:

```dart
if (context.can('billing', 'view')) {
  return const BillingButton();
}
```

## Visibility Example

```dart
AbacVisibility(
  feature: 'billing',
  action: 'view',
  loading: const CircularProgressIndicator(),
  fallback: const Text('Access denied'),
  child: const BillingWidget(),
)
```

## Page Example

```dart
AbacPage(
  feature: 'billing',
  action: 'view',
  loading: const Center(child: CircularProgressIndicator()),
  fallback: const Center(child: Text('Custom forbidden')),
  child: const BillingScreen(),
)
```

Without a custom fallback, `AbacPage` shows a small default `403 Forbidden` widget.

## API Reference

- `AbacProvider` stores permissions at the root of the widget tree.
- `Abac.of(context)` returns an object with `isReady` and `can(feature, action)`.
- `AbacScope` is the internal inherited widget used by the provider.
- `BuildContext.can()` performs a permission check from any widget subtree under `AbacProvider`.
- `AbacVisibility` conditionally shows a child, fallback, or loading widget.
- `AbacPage` conditionally shows a child or a forbidden state.
- `normalizePermissions()` lowercases, trims, and filters permissions safely.
- `hasAccess()` evaluates exact and wildcard permissions.

## Example App

Run the example app from the `example/` folder to explore:

- dashboard state
- billing button gating
- admin page gating
- loading, granted, and denied states
- runtime permission changes
