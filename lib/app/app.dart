import 'package:flutter/material.dart';

import '../bootstrap.dart';
import 'theme.dart';
import '../features/shell/presentation/main_shell.dart';

typedef AppBootstrapper = Future<AppDependencies> Function();

class EvApp extends StatefulWidget {
  const EvApp({super.key, this.dependencies, this.bootstrapper});

  final AppDependencies? dependencies;
  final AppBootstrapper? bootstrapper;

  @override
  State<EvApp> createState() => _EvAppState();
}

class _EvAppState extends State<EvApp> {
  late final Future<AppDependencies> _dependenciesFuture;

  @override
  void initState() {
    super.initState();

    final dependencies = widget.dependencies;
    _dependenciesFuture = dependencies != null
        ? Future.value(dependencies)
        : (widget.bootstrapper ?? bootstrapApp)();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EvApp',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: FutureBuilder<AppDependencies>(
        future: _dependenciesFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return MainShell(dependencies: snapshot.requireData);
          }

          if (snapshot.hasError) {
            return _BootstrapErrorView(error: snapshot.error);
          }

          return const _BootstrapLoadingView();
        },
      ),
    );
  }
}

class _BootstrapLoadingView extends StatelessWidget {
  const _BootstrapLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _BootstrapErrorView extends StatelessWidget {
  const _BootstrapErrorView({required this.error});

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Uygulama başlatılırken hata oluştu.\n$error',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
