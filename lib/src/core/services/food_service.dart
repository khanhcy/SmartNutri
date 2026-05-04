import 'package:smartnutri/src/features/search/domain/food_item.dart';

class FoodService {
  static const List<FoodItem> _foods = [
    FoodItem(id: 'pho_bo', name: 'Phở bò', calorieKcal: 68, proteinG: 5.8, carbG: 9.2, fatG: 1.2, category: 'Món nước', defaultPortionG: 400),
    FoodItem(id: 'bun_bo_hue', name: 'Bún bò Huế', calorieKcal: 72, proteinG: 6.2, carbG: 9.8, fatG: 1.4, category: 'Món nước', defaultPortionG: 400),
    FoodItem(id: 'com_trang', name: 'Cơm trắng', calorieKcal: 130, proteinG: 2.7, carbG: 28.2, fatG: 0.3, category: 'Tinh bột', defaultPortionG: 200),
    FoodItem(id: 'com_ga', name: 'Cơm gà nướng', calorieKcal: 140, proteinG: 9.8, carbG: 18.5, fatG: 3.5, category: 'Cơm', defaultPortionG: 350),
    FoodItem(id: 'com_suon', name: 'Cơm sườn nướng', calorieKcal: 155, proteinG: 11.2, carbG: 19.8, fatG: 4.2, category: 'Cơm', defaultPortionG: 350),
    FoodItem(id: 'com_rang', name: 'Cơm rang trứng', calorieKcal: 165, proteinG: 4.5, carbG: 28.8, fatG: 3.8, category: 'Cơm', defaultPortionG: 300),
    FoodItem(id: 'banh_mi_thit', name: 'Bánh mì thịt', calorieKcal: 245, proteinG: 10.8, carbG: 32.5, fatG: 9.5, category: 'Bánh mì', defaultPortionG: 200),
    FoodItem(id: 'banh_mi_trung', name: 'Bánh mì trứng', calorieKcal: 220, proteinG: 9.2, carbG: 30.8, fatG: 7.5, category: 'Bánh mì', defaultPortionG: 180),
    FoodItem(id: 'ga_luoc', name: 'Gà luộc', calorieKcal: 165, proteinG: 23.5, carbG: 0, fatG: 7.5, category: 'Thịt', defaultPortionG: 150),
    FoodItem(id: 'thit_heo_luoc', name: 'Thịt heo nạc luộc', calorieKcal: 185, proteinG: 22.8, carbG: 0, fatG: 10.5, category: 'Thịt', defaultPortionG: 100),
    FoodItem(id: 'ca_hoi_nuong', name: 'Cá hồi nướng', calorieKcal: 208, proteinG: 22.1, carbG: 0, fatG: 13.5, category: 'Hải sản', defaultPortionG: 150),
    FoodItem(id: 'ca_thu_kho', name: 'Cá thu kho', calorieKcal: 180, proteinG: 20.5, carbG: 2.5, fatG: 10.0, category: 'Hải sản', defaultPortionG: 100),
    FoodItem(id: 'trung_luoc', name: 'Trứng gà luộc', calorieKcal: 155, proteinG: 12.6, carbG: 1.1, fatG: 10.6, category: 'Trứng', defaultPortionG: 60),
    FoodItem(id: 'trung_op_la', name: 'Trứng ốp lá', calorieKcal: 185, proteinG: 12.2, carbG: 0.5, fatG: 14.5, category: 'Trứng', defaultPortionG: 60),
    FoodItem(id: 'rau_muong_xao', name: 'Rau muống xào tỏi', calorieKcal: 45, proteinG: 2.8, carbG: 5.2, fatG: 1.8, category: 'Rau củ', defaultPortionG: 150),
    FoodItem(id: 'canh_chua', name: 'Canh chua cá', calorieKcal: 42, proteinG: 3.8, carbG: 5.5, fatG: 0.8, category: 'Canh', defaultPortionG: 250),
    FoodItem(id: 'dau_hu_xao', name: 'Đậu hủ xào sả ớt', calorieKcal: 95, proteinG: 8.5, carbG: 3.2, fatG: 5.5, category: 'Chay', defaultPortionG: 150),
    FoodItem(id: 'salad_uc_ga', name: 'Salad ức gà', calorieKcal: 98, proteinG: 18.8, carbG: 2.5, fatG: 1.8, category: 'Salad', defaultPortionG: 200),
    FoodItem(id: 'hu_tieu', name: 'Hủ tiếu Nam Vang', calorieKcal: 75, proteinG: 5.5, carbG: 10.2, fatG: 1.5, category: 'Món nước', defaultPortionG: 400),
    FoodItem(id: 'mi_goi', name: 'Mì gói nấu (1 gói)', calorieKcal: 130, proteinG: 3.8, carbG: 24.5, fatG: 2.5, category: 'Tinh bột', defaultPortionG: 350),
    FoodItem(id: 'khoai_lang_luoc', name: 'Khoai lang luộc', calorieKcal: 86, proteinG: 1.6, carbG: 20.1, fatG: 0.1, category: 'Tinh bột', defaultPortionG: 150),
    FoodItem(id: 'bap_cai_luoc', name: 'Bắp cải luộc', calorieKcal: 25, proteinG: 1.3, carbG: 5.8, fatG: 0.1, category: 'Rau củ', defaultPortionG: 150),
    FoodItem(id: 'chuoi', name: 'Chuối', calorieKcal: 89, proteinG: 1.1, carbG: 22.8, fatG: 0.3, category: 'Trái cây', defaultPortionG: 120),
    FoodItem(id: 'tao', name: 'Táo', calorieKcal: 52, proteinG: 0.3, carbG: 13.8, fatG: 0.2, category: 'Trái cây', defaultPortionG: 180),
    FoodItem(id: 'yogurt', name: 'Yogurt không đường', calorieKcal: 59, proteinG: 3.5, carbG: 7.8, fatG: 0.8, category: 'Sữa', defaultPortionG: 150),
    FoodItem(id: 'sua_tuoi', name: 'Sữa tươi không đường', calorieKcal: 61, proteinG: 3.2, carbG: 4.8, fatG: 3.3, category: 'Sữa', defaultPortionG: 200),
    FoodItem(id: 'oc_luoc', name: 'Ốc luộc', calorieKcal: 90, proteinG: 12.5, carbG: 4.2, fatG: 2.5, category: 'Hải sản', defaultPortionG: 150),
    FoodItem(id: 'chao_ga', name: 'Cháo gà', calorieKcal: 55, proteinG: 4.2, carbG: 7.8, fatG: 0.8, category: 'Cháo', defaultPortionG: 350),
    FoodItem(id: 'banh_chuoi', name: 'Bánh chuối hấp', calorieKcal: 135, proteinG: 2.2, carbG: 27.5, fatG: 2.5, category: 'Tráng miệng', defaultPortionG: 100),
    FoodItem(id: 'che_dau_xanh', name: 'Chè đậu xanh', calorieKcal: 110, proteinG: 4.5, carbG: 22.0, fatG: 0.5, category: 'Tráng miệng', defaultPortionG: 200),
  ];

  List<FoodItem> search(String query) {
    if (query.trim().isEmpty) return [];
    final q = _removeDiacritics(query.toLowerCase().trim());
    return _foods.where((f) {
      final name = _removeDiacritics(f.name.toLowerCase());
      return name.contains(q);
    }).take(20).toList();
  }

  List<FoodItem> getAll() => List.unmodifiable(_foods);

  List<FoodItem> getByCategory(String category) =>
      _foods.where((f) => f.category == category).toList();

  FoodItem? getById(String id) {
    try {
      return _foods.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  static String _removeDiacritics(String s) {
    const withDiacritics =
        'àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþÿăắặẳẵằâấậẩẫàáảãạêếệểễèéẻẽẹôốộổỗòóỏõọơớợởỡờúùủũụưứựửữừíìỉĩịđ';
    const withoutDiacritics =
        'aaaaaaaceeeeiiiionoooooouuuuytya aaaaaaaaaaaaaeeeeeeeeeoooooooooooooouuuuuuuuuuuiiiiid';
    var result = s;
    for (var i = 0; i < withDiacritics.length; i++) {
      result = result.replaceAll(withDiacritics[i], withoutDiacritics[i]);
    }
    return result;
  }
}
