import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:renal_care_app/core/di/restricted_food_providers.dart';
import 'package:renal_care_app/core/theme/app_colors.dart';

class RestrictedFoodSearchScreen extends ConsumerStatefulWidget {
  const RestrictedFoodSearchScreen({super.key});

  @override
  ConsumerState<RestrictedFoodSearchScreen> createState() =>
      _RestrictedFoodSearchScreenState();
}

class _RestrictedFoodSearchScreenState
    extends ConsumerState<RestrictedFoodSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(restrictedFoodViewModelProvider.notifier).clear();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSearch() {
    ref.read(restrictedFoodViewModelProvider.notifier).search(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(restrictedFoodViewModelProvider);

    return Scaffold(
      appBar: AppBar(
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go('/home');
          },
        ),
        title: const Text(
          'Search for food',
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter the name of the food',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _onSearch,
                ),
              ),
              onSubmitted: (_) => _onSearch(),
              onChanged: (_) {
                if (_controller.text.isEmpty) {
                  ref.read(restrictedFoodViewModelProvider.notifier).clear();
                }
              },
            ),
            const SizedBox(height: 8),

            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'This is a hygienic-dietary regimen, with normal protein, '
                    'low fat, low carbohydrate, and low sodium, avoiding spices '
                    'and alcoholic drinks. Foods should be prepared preferably '
                    'by boiling or grilling, favoring white meat (poultry, fish, '
                    'beef). Milk and dairy products are allowed; fruits are '
                    'permitted (avoid excessive consumption of high-sugar fruits '
                    'such as plums, grapes, and pears).',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (state.loading) const CircularProgressIndicator(),

            if (state.resultMessage != null && !state.loading) ...[
              Text(
                state.resultMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color:
                      state.resultMessage!.startsWith('❌')
                          ? Colors.red
                          : Colors.green,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],

            // list‐view cu potențialele match-uri parțiale:
            if (!state.loading && state.filtered.isNotEmpty) ...[
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children:
                      state.filtered.map((f) {
                        return ListTile(title: Text(f.name));
                      }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
