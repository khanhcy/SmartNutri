import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/barcode_service.dart';
import 'package:smartnutri/src/core/services/connectivity_service.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/features/meal_log/presentation/add_meal_bottom_sheet.dart';
import 'package:smartnutri/src/features/meal_log/presentation/custom_meal_sheet.dart';
import 'package:smartnutri/src/features/meal_log/domain/meal_entry.dart';
import 'package:smartnutri/src/features/search/domain/food_item.dart';

class BarcodeScanPage extends StatefulWidget {
  const BarcodeScanPage({super.key});

  @override
  State<BarcodeScanPage> createState() => _BarcodeScanPageState();
}

class _BarcodeScanPageState extends State<BarcodeScanPage> {
  final _controller = MobileScannerController(
    formats: [BarcodeFormat.ean13, BarcodeFormat.ean8, BarcodeFormat.upcA],
  );
  FoodItem? _found;
  String? _error;
  bool _lookingUp = false;
  bool _paused = false;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_paused || _lookingUp) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final code = barcode.rawValue!;
    setState(() {
      _paused = true;
      _lookingUp = true;
      _error = null;
    });

    final online = context.read<ConnectivityService>().isOnline;
    if (!online) {
      if (mounted) {
        setState(() {
          _lookingUp = false;
          _error = 'Cần kết nối mạng để tra cứu mã vạch.';
        });
      }
      return;
    }

    final result = await context.read<BarcodeService>().lookupBarcode(code);
    if (mounted) {
      setState(() {
        _lookingUp = false;
        _found = result;
        if (result == null) {
          _error = 'Không tìm thấy sản phẩm với mã vạch này.';
        }
      });
    }
  }

  void _addFood(FoodItem food) {
    showAddMealSheet(
      context,
      preselectedFood: food,
      initialMealType: _mealTypeForNow(),
    );
  }

  MealType _mealTypeForNow() {
    final h = DateTime.now().hour;
    if (h < 10) return MealType.breakfast;
    if (h < 14) return MealType.lunch;
    if (h < 19) return MealType.dinner;
    return MealType.snack;
  }

  void _rescan() {
    setState(() {
      _paused = false;
      _found = null;
      _error = null;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Quét mã vạch')),
      body: Column(
        children: [
          // Scanner area
          Expanded(
            child: Stack(
              children: [
                if (!_paused)
                  MobileScanner(
                    controller: _controller,
                    onDetect: _onDetect,
                  ),
                if (_paused)
                  Container(color: Colors.black87),
                // Scan overlay border
                Center(
                  child: Container(
                    width: 280,
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _paused ? Colors.grey : colorScheme.primary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                // Torch toggle
                Positioned(
                  right: 16,
                  top: 16,
                  child: FloatingActionButton.small(
                    heroTag: 'torch',
                    onPressed: () => _controller.toggleTorch(),
                    child: Icon(
                      Icons.flash_on,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Result / loading area
          SizedBox(
            height: 200,
            child: _buildResultArea(colorScheme),
          ),
        ],
      ),
    );
  }

  Widget _buildResultArea(ColorScheme colorScheme) {
    if (_lookingUp) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: AppSpacing.sm),
            Text('Đang tra cứu...'),
          ],
        ),
      );
    }

    if (_found != null) {
      final food = _found!;
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    food.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (food.brand != null)
                  Chip(label: Text(food.brand!, style: const TextStyle(fontSize: 11))),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${food.calorieKcal.round()} kcal/100g  •  '
              'P:${food.proteinG.round()}g  C:${food.carbG.round()}g  '
              'F:${food.fatG.round()}g',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _rescan,
                    child: const Text('Quét lại'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(
                    onPressed: () => _addFood(food),
                    child: const Text('Thêm vào nhật ký'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: colorScheme.error),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Text(_error!)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _rescan,
                    child: const Text('Quét lại'),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => showCustomMealSheet(context),
                    child: const Text('Nhập thủ công'),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Center(
      child: Text(
        'Đưa mã vạch vào khung quét',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}
