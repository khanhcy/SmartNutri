import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:smartnutri/src/core/services/food_service.dart';
import 'package:smartnutri/src/features/search/domain/food_item.dart';

class FavoriteFoodsService extends ChangeNotifier {
  FavoriteFoodsService({
    FirebaseFirestore? firestore,
    required FoodCatalog foodCatalog,
  }) : _firestoreOverride = firestore,
       _foodCatalog = foodCatalog;

  final FirebaseFirestore? _firestoreOverride;
  final FoodCatalog _foodCatalog;
  final List<FoodItem> _favorites = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  List<FoodItem> get favorites => List.unmodifiable(_favorites);

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      _firestore.collection('users').doc(uid).collection('favorites');

  void init(String uid) {
    _sub?.cancel();
    _sub = _col(uid).snapshots().listen((snap) async {
      // Đảm bảo food catalog đã load trước khi resolve
      await _foodCatalog.getAll();

      final items = <FoodItem>[];
      for (final doc in snap.docs) {
        final foodId = doc.data()['foodId'] as String? ?? doc.id;
        FoodItem? food;
        try {
          food = _foodCatalog.foods.firstWhere((f) => f.id == foodId);
        } catch (_) {
          food = null;
        }
        if (food != null) items.add(food);
      }
      _favorites
        ..clear()
        ..addAll(items);
      notifyListeners();
    });
  }

  void disposeFor(String uid) {
    _sub?.cancel();
    _sub = null;
    _favorites.clear();
  }

  Future<bool> isFavorite(String uid, String foodId) async {
    final doc = await _col(uid).doc(foodId).get();
    return doc.exists;
  }

  Future<void> toggle(String uid, String foodId) async {
    final ref = _col(uid).doc(foodId);
    final doc = await ref.get();
    if (doc.exists) {
      await ref.delete();
    } else {
      await ref.set({
        'foodId': foodId,
        'addedAt': FieldValue.serverTimestamp(),
      });
    }
    notifyListeners();
  }
}
