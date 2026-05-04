import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartnutri/src/features/search/domain/food_item.dart';

/// Persists a short list of recently-used foods in SharedPreferences.
class RecentFoodsService extends ChangeNotifier {
  RecentFoodsService._({required List<FoodItem> initial}) : _recents = initial;

  static const _key = 'recent_foods';
  static const _maxItems = 10;

  final List<FoodItem> _recents;

  List<FoodItem> get recents => List.unmodifiable(_recents);

  static Future<RecentFoodsService> create() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    final items = raw
        .map((s) {
          try {
            return FoodItem.fromMap(jsonDecode(s) as Map<String, dynamic>);
          } catch (_) {
            return null;
          }
        })
        .whereType<FoodItem>()
        .toList();
    return RecentFoodsService._(initial: items);
  }

  /// Call after the user adds [food] to the log.
  Future<void> add(FoodItem food) async {
    _recents.removeWhere((f) => f.id == food.id);
    _recents.insert(0, food);
    if (_recents.length > _maxItems) _recents.removeLast();
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      _recents.map((f) => jsonEncode(f.toMap())).toList(),
    );
  }
}
