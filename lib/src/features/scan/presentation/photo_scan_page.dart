import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:smartnutri/src/core/services/ai_food_service.dart';
import 'package:smartnutri/src/core/services/connectivity_service.dart';
import 'package:smartnutri/src/core/ui/theme/app_spacing.dart';
import 'package:smartnutri/src/features/meal_log/presentation/add_meal_bottom_sheet.dart';
import 'package:smartnutri/src/features/home/presentation/widgets/ai_suggestions_card.dart';
import 'package:smartnutri/src/features/scan/domain/scan_result.dart';

class PhotoScanPage extends StatefulWidget {
  const PhotoScanPage({super.key});

  @override
  State<PhotoScanPage> createState() => _PhotoScanPageState();
}

class _PhotoScanPageState extends State<PhotoScanPage> {
  final _picker = ImagePicker();
  Uint8List? _previewBytes;
  bool _analyzing = false;
  ScanResult? _scanResult;
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
      _scanResult = null;
    });

    final connectivity = context.read<ConnectivityService>();
    final ai = context.read<AiFoodService>();
    final online = await connectivity.isOnline;
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
    try {
      final result = await ai.identifyFood(base64);
      if (mounted) {
        setState(() {
          _analyzing = false;
          _scanResult = result;
          if (result.items.isEmpty) {
            _error =
                'AI không nhận diện được món ăn trong ảnh. '
                'Thử lại với ảnh khác hoặc tìm thủ công.';
          }
        });
      }
    } on AiFoodServiceException catch (e) {
      if (mounted) {
        setState(() {
          _analyzing = false;
          _scanResult = null;
          _error = e.userMessage;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _analyzing = false;
          _scanResult = null;
          _error = 'Không thể phân tích ảnh lúc này. Vui lòng thử lại.';
        });
      }
    }
  }

  void _selectCandidate(ScannedFoodItem item) {
    showAddMealSheet(
      context,
      preselectedFood: item.foodItem,
      initialMealType: mealTypeForNow(),
    );
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
                    onTap: _analyzing
                        ? null
                        : () => _pickAndAnalyze(ImageSource.camera),
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

            // Preview
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

            // Loading
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

            // Error
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

            // Results
            if (_scanResult != null && _scanResult!.items.isNotEmpty) ...[
              Text(
                'Kết quả nhận diện',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: AppSpacing.sm),
              ..._scanResult!.items.map(
                (item) => Card(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _selectCandidate(item),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: colorScheme.primaryContainer,
                            child: Icon(
                              Icons.restaurant,
                              color: colorScheme.primary,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        item.foodItem.name,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleSmall,
                                      ),
                                    ),
                                    if (item.isAiEstimated) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.amber.withValues(
                                            alpha: 0.2,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        child: const Text(
                                          '⚡ Ước tính AI',
                                          style: TextStyle(fontSize: 10),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.foodItem.calorieKcal.round()} kcal/100g'
                                  '  •  P:${item.foodItem.proteinG.round()}g'
                                  '  C:${item.foodItem.carbG.round()}g'
                                  '  F:${item.foodItem.fatG.round()}g',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Chip(
                            label: Text(
                              '${(item.confidence * 100).round()}%',
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
