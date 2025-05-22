import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';

import 'package:renal_care_app/core/theme/app_colors.dart';
import 'package:renal_care_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, this.title = 'RenalCare home page'});
  final String title;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _counter = 0;
  DateTime? _lastBackPress;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<void> _handleLogout() async {
    await ref.read(authViewModelProvider.notifier).signOut();
    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // always block automatic pops
      canPop: false,
      onPopInvokedWithResult: (_, __) async {
        final now = DateTime.now();
        if (_lastBackPress == null ||
            now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
          _lastBackPress = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Apasă din nou pentru a ieși din aplicație'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          // second back press → exit app
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          // transparenţă + gradient pe toată suprafaţa
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.gradient1,
                  AppColors.gradient2,
                  AppColors.gradient3,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Titlu şi iconiţe în alb
          title: Text(
            widget.title,
            style: const TextStyle(color: AppColors.whiteColor),
          ),
          iconTheme: const IconThemeData(color: AppColors.whiteColor),

          actions: [
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              tooltip: 'Chat',
              onPressed: () => context.go('/chat'),
            ),

            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _handleLogout,
            ),
          ],
        ),

        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('You have pushed the button this many times:'),
              Text(
                '$_counter',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),

        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.gradient2,
          onPressed: _incrementCounter,
          tooltip: 'Increment',
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
      ),
    );
  }
}
