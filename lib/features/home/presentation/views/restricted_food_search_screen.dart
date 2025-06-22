import 'package:barcode_scan2/gen/protos/protos.pbenum.dart';
import 'package:barcode_scan2/platform_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

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

  Future<void> _onScanBarcode() async {
    // cerem permisiuni camerei
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
      if (!mounted) return;
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission denied')),
        );
        return;
      }
    }

    // dacă avem permisiune, scanăm codul de bare
    final result = await BarcodeScanner.scan();
    if (!mounted) return;

    // dacă a fost anulat sau nu s-a citit nimic, ieșim
    if (result.type != ResultType.Barcode || result.rawContent.isEmpty) return;

    // procesăm codul
    await ref
        .read(restrictedFoodViewModelProvider.notifier)
        .scanBarcodeAndCheck(result.rawContent);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(restrictedFoodViewModelProvider);
    final vm = ref.read(restrictedFoodViewModelProvider.notifier);

    //  Error handling + retry
    if (state.error != null) {
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
          leading: BackButton(color: Colors.white),
          title: const Text(
            'Search for food',
            style: TextStyle(color: Colors.white),
          ),
        ),

        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Eroare: ${state.error}',
                style: const TextStyle(color: Colors.red),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: vm.reload, // reapelăm încărcarea
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gradient3,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(200, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Search bar
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
                  vm.clear();
                }
              },
            ),
            const SizedBox(height: 12),

            if (!state.loading && state.filtered.isNotEmpty) ...[
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: state.filtered.length,
                itemBuilder:
                    (_, i) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        state.filtered[i].name,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
              ),
            ],

            // list‐view cu potențialele match-uri parțiale
            if (!state.loading && state.resultMessage != null) ...[
              const SizedBox(height: 8),
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

            // Textul explicativ
            Expanded(
              child: Center(
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
            const SizedBox(height: 24),

            // Butonul de scanare
            Center(
              child: SizedBox(
                width: 240,
                height: 80,
                child: ElevatedButton.icon(
                  onPressed: _onScanBarcode,
                  icon: const Icon(
                    Icons.qr_code_scanner,
                    size: 31,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Scan Barcode',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gradient3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 6,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
