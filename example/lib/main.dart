import 'package:flutter/material.dart';
import 'package:flutter_simple_access_engine/flutter_simple_access_engine.dart';

void main() {
  runApp(const DemoApp());
}

class DemoApp extends StatefulWidget {
  const DemoApp({super.key});

  @override
  State<DemoApp> createState() => _DemoAppState();
}

class _DemoAppState extends State<DemoApp> {
  Map<String, List<String>>? permissions = {
    'billing': ['view'],
    'admin': ['*'],
  };

  void _setLoading() {
    setState(() {
      permissions = null;
    });
  }

  void _setViewer() {
    setState(() {
      permissions = {
        'billing': ['view'],
        'workspace': ['view'],
      };
    });
  }

  void _setBillingEditor() {
    setState(() {
      permissions = {
        'billing': ['view', 'pay', 'export'],
        'workspace': ['create', 'view'],
      };
    });
  }

  void _setAdmin() {
    setState(() {
      permissions = {
        '*': ['*'],
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return AbacProvider(
      permissions: permissions,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: const Color(0xFF0F766E),
        ),
        home: DashboardScreen(
          permissions: permissions,
          onLoading: _setLoading,
          onViewer: _setViewer,
          onBilling: _setBillingEditor,
          onAdmin: _setAdmin,
        ),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.permissions,
    required this.onLoading,
    required this.onViewer,
    required this.onBilling,
    required this.onAdmin,
  });

  final Map<String, List<String>>? permissions;
  final VoidCallback onLoading;
  final VoidCallback onViewer;
  final VoidCallback onBilling;
  final VoidCallback onAdmin;

  @override
  Widget build(BuildContext context) {
    final abac = Abac.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ABAC Demo Dashboard'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Permissions state: ${abac.isReady ? 'ready' : 'loading'}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton(onPressed: onLoading, child: const Text('Loading')),
              FilledButton(onPressed: onViewer, child: const Text('Viewer')),
              FilledButton(onPressed: onBilling, child: const Text('Billing')),
              FilledButton(onPressed: onAdmin, child: const Text('Admin')),
            ],
          ),
          const SizedBox(height: 24),
          const Text('Billing widget'),
          const SizedBox(height: 8),
          AbacVisibility(
            feature: 'billing',
            action: 'view',
            loading: const _StateCard(label: 'Billing loading', color: Colors.amber),
            fallback: const _StateCard(label: 'Billing denied', color: Colors.red),
            child: const _StateCard(label: 'Billing granted', color: Colors.green),
          ),
          const SizedBox(height: 16),
          AbacVisibility(
            feature: 'billing',
            action: 'pay',
            loading: const _StateCard(label: 'Pay loading', color: Colors.amber),
            fallback: const _StateCard(label: 'Pay denied', color: Colors.red),
            child: FilledButton(
              onPressed: () {},
              child: const Text('Pay invoice'),
            ),
          ),
          const SizedBox(height: 24),
          const Text('Admin page'),
          const SizedBox(height: 8),
          SizedBox(
            height: 220,
            child: AbacPage(
              feature: 'admin',
              action: 'view',
              loading: const Center(child: CircularProgressIndicator()),
              fallback: const Center(
                child: Text('Custom admin fallback'),
              ),
              child: const _AdminPanel(),
            ),
          ),
          const SizedBox(height: 24),
          _PermissionsPanel(permissions: permissions),
        ],
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(label),
    );
  }
}

class _AdminPanel extends StatelessWidget {
  const _AdminPanel();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Admin area'),
            SizedBox(height: 8),
            Text('This screen is visible when admin access is granted.'),
          ],
        ),
      ),
    );
  }
}

class _PermissionsPanel extends StatelessWidget {
  const _PermissionsPanel({required this.permissions});

  final Map<String, List<String>>? permissions;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Current permissions'),
            const SizedBox(height: 8),
            Text(
              permissions == null
                  ? 'null'
                  : permissions!.entries
                      .map((entry) => '${entry.key}: ${entry.value.join(', ')}')
                      .join('\n'),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use the buttons above to switch between loading, viewer, billing, and admin states.',
            ),
          ],
        ),
      ),
    );
  }
}
