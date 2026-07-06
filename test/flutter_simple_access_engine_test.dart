import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_simple_access_engine/flutter_simple_access_engine.dart';

void main() {
  group('normalizePermissions', () {
    test('lowercases and trims valid entries', () {
      final result = normalizePermissions({
        '  Billing  ': [' View ', 'PAY', 'view'],
        'Workspace': [' Create ', 'VIEW'],
      });

      expect(result, {
        'billing': ['view', 'pay'],
        'workspace': ['create', 'view'],
      });
    });

    test('ignores invalid values safely', () {
      final result = normalizePermissions({
        null: ['view'],
        'billing': ['view', '', '  ', 123, null],
        'workspace': 'view',
        '  ': ['create'],
      });

      expect(result, {
        'billing': ['view'],
      });
    });

    test('preserves wildcard permissions', () {
      final result = normalizePermissions({
        'billing': ['*'],
        '*': ['*'],
      });

      expect(result, {
        'billing': ['*'],
        '*': ['*'],
      });
    });
  });

  group('hasAccess', () {
    test('matches exact permission', () {
      expect(
        hasAccess({
          'billing': ['view'],
        }, 'billing', 'view'),
        isTrue,
      );
    });

    test('is case insensitive', () {
      expect(
        hasAccess({
          'billing': ['view'],
        }, 'Billing', 'VIEW'),
        isTrue,
      );
    });

    test('supports feature wildcard', () {
      expect(
        hasAccess({
          'billing': ['*'],
        }, 'billing', 'export'),
        isTrue,
      );
    });

    test('supports global wildcard', () {
      expect(
        hasAccess({
          '*': ['*'],
        }, 'any-feature', 'any-action'),
        isTrue,
      );
    });

    test('returns false when permission is missing', () {
      expect(
        hasAccess({
          'billing': ['view'],
        }, 'billing', 'export'),
        isFalse,
      );
    });
  });

  group('widget integration', () {
    testWidgets('provider exposes readiness and context.can', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AbacProvider(
            permissions: {
              'billing': ['view'],
            },
            child: Builder(
              builder: (context) {
                final abac = Abac.of(context);
                return Column(
                  textDirection: TextDirection.ltr,
                  children: [
                    Text('ready:${abac.isReady}', textDirection: TextDirection.ltr),
                    Text('can:${context.can('billing', 'view')}', textDirection: TextDirection.ltr),
                  ],
                );
              },
            ),
          ),
        ),
      );

      expect(find.text('ready:true'), findsOneWidget);
      expect(find.text('can:true'), findsOneWidget);
    });

    testWidgets('provider reports not ready when permissions are null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AbacProvider(
            permissions: null,
            child: Builder(
              builder: (context) {
                final abac = Abac.of(context);
                return Text('ready:${abac.isReady}', textDirection: TextDirection.ltr);
              },
            ),
          ),
        ),
      );

      expect(find.text('ready:false'), findsOneWidget);
    });

    testWidgets('AbacVisibility renders child, fallback, and loading states', (tester) async {
      final permissions = ValueNotifier<Map<String, List<String>>?>(null);

      await tester.pumpWidget(
        MaterialApp(
          home: ValueListenableBuilder<Map<String, List<String>>?>(
            valueListenable: permissions,
            builder: (context, value, _) {
              return AbacProvider(
                permissions: value,
                child: Column(
                  textDirection: TextDirection.ltr,
                  children: const [
                    AbacVisibility(
                      feature: 'billing',
                      action: 'view',
                      loading: Text('loading', textDirection: TextDirection.ltr),
                      fallback: Text('fallback', textDirection: TextDirection.ltr),
                      child: Text('visible', textDirection: TextDirection.ltr),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('loading'), findsOneWidget);

      permissions.value = {
        'billing': ['view'],
      };
      await tester.pump();

      expect(find.text('visible'), findsOneWidget);

      permissions.value = {
        'billing': ['export'],
      };
      await tester.pump();

      expect(find.text('fallback'), findsOneWidget);
    });

    testWidgets('AbacPage renders loading, child, and forbidden states', (tester) async {
      final permissions = ValueNotifier<Map<String, List<String>>?>(null);

      await tester.pumpWidget(
        MaterialApp(
          home: ValueListenableBuilder<Map<String, List<String>>?>(
            valueListenable: permissions,
            builder: (context, value, _) {
              return AbacProvider(
                permissions: value,
                child: AbacPage(
                  feature: 'billing',
                  action: 'view',
                  loading: const Text('loading', textDirection: TextDirection.ltr),
                  fallback: const Text('custom-fallback', textDirection: TextDirection.ltr),
                  child: const Text('screen', textDirection: TextDirection.ltr),
                ),
              );
            },
          ),
        ),
      );

      expect(find.text('loading'), findsOneWidget);

      permissions.value = {
        'billing': ['view'],
      };
      await tester.pump();

      expect(find.text('screen'), findsOneWidget);

      permissions.value = {
        'billing': ['export'],
      };
      await tester.pump();

      expect(find.text('custom-fallback'), findsOneWidget);
    });

    testWidgets('AbacPage shows default forbidden widget when denied', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AbacProvider(
            permissions: {
              'billing': ['view'],
            },
            child: AbacPage(
              feature: 'billing',
              action: 'pay',
              child: Text('screen', textDirection: TextDirection.ltr),
            ),
          ),
        ),
      );

      expect(find.text('403 Forbidden'), findsOneWidget);
    });
  });
}
