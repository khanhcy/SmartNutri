import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/ai_food_service.dart';
import 'package:smartnutri/src/core/services/connectivity_service.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/features/meal_log/presentation/add_meal_bottom_sheet.dart';
import 'package:smartnutri/src/features/meal_log/domain/meal_entry.dart';
import 'package:smartnutri/src/features/search/domain/food_item.dart';

class PhotoScanPage extends StatefulWidget {
  const PhotoScanPage({super.key});

  @override
  State<PhotoScanPage> createState() => _PhotoScanPageState();
}

class _PhotoScanPageState extends State<PhotoScanPage> {
  final _picker = ImagePicker();
  Uint8List? _previewBytes;
  bool _analyzing = false;
  List<AiFoodCandidate> _candidates = [];
  String? _error;

  Future<void> _pickAndAnalyze(ImageSource source) async {
    final xfile = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (xfile == null) return;

    final bytes = await xfile.readAsBytes();
    if (!mounted) return;
    setState(() {
      _previewBytes = bytes;
      _analyzing = true;
      _error = null;
      _candidates = [];
    });

    // Check connectivity
    final online = context.read<ConnectivityService>().isOnline;
    if (!online) {
      if (mounted) {
        setState(() {
          _analyzing = false;
          _error = 'Cần kết nối mạng để dùng AI phân tích ảnh.';
        });
      }
      return;
    }

    final base64 = base64Encode(bytes);
    final ai = context.read<AiFoodService>();
    final results = await ai.identifyFood(base64);

    if (mounted) {
      setState(() {
        _analyzing = false;
        _candidates = results;
        if (results.isEmpty) {
          _error = 'AI không nhận diện được món ăn trong ảnh. '
              'Thử lại với ảnh khác hoặc tìm thủ công.';
        }
      });
    }
  }

  void _selectCandidate(FoodItem food) {
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Chụp ảnh món ăn')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Dùng AI để nhận diện món ăn từ ảnh',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.camera_alt,
                    label: 'Chụp ảnh',
                    color: colorScheme.primary,
                    onTap:
                        _analyzing ? null : () => _pickAndAnalyze(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.photo_library,
                    label: 'Thư viện',
                    color: colorScheme.secondary,
                    onTap: _analyzing
                        ? null
                        : () => _pickAndAnalyze(ImageSource.gallery),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // Preview / loading / results
            if (_previewBytes != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  _previewBytes!,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            if (_analyzing) ...[
              const SizedBox(height: AppSpacing.xl),
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: AppSpacing.md),
                  Text('AI đang phân tích...'),
                ],
              ),
            ],

            if (_error != null && !_analyzing) ...[
              const SizedBox(height: AppSpacing.md),
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
            ],

            if (_candidates.isNotEmpty) ...[
              Text(
                'Kết quả nhận diện',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              ..._candidates.map(
                (c) => Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _selectCandidate(c.foodItem),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: colorScheme.primaryContainer,
                            child: Icon(Icons.restaurant,
                                color: colorScheme.primary, size: 20),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.foodItem.name,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${c.foodItem.calorieKcal.round()} kcal/100g'
                                  '  •  P:${c.foodItem.proteinG.round()}g'
                                  '  C:${c.foodItem.carbG.round()}g'
                                  '  F:${c.foodItem.fatG.round()}g',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Chip(
                            label: Text(
                              '${(c.confidence * 100).round()}%',
                              style: const TextStyle(fontSize: 11),
                            ),
                            backgroundColor: colorScheme.primaryContainer,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: Column(
            children: [
              Icon(icon, size: 36, color: onTap == null ? Colors.grey : color),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: TextStyle(
                  color: onTap == null ? Colors.grey : null,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
