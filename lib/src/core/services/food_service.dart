import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:smartnutri/src/features/search/domain/food_item.dart';

abstract class FoodCatalog {
  List<FoodItem> get foods;
  Future<List<FoodItem>> getAll();
}

class FoodService implements FoodCatalog {
  FoodService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;
  List<FoodItem>? _cached;
  bool _isLoading = false;

  /// Synchronous access to the loaded food list (returns seed data if not yet loaded).
  @override
  List<FoodItem> get foods => _cached ?? _seedFoods;

  // Kept as seed fallback — used only when Firestore is empty.
  static const List<FoodItem> _seedFoods = [
    // ── Món nước ───────────────────────────────────────────────────────────
    FoodItem(
      id: 'pho_bo',
      name: 'Phở bò',
      calorieKcal: 68,
      proteinG: 5.8,
      carbG: 9.2,
      fatG: 1.2,
      category: 'Món nước',
      defaultPortionG: 400,
    ),
    FoodItem(
      id: 'pho_ga',
      name: 'Phở gà',
      calorieKcal: 62,
      proteinG: 5.2,
      carbG: 8.8,
      fatG: 1.0,
      category: 'Món nước',
      defaultPortionG: 400,
    ),
    FoodItem(
      id: 'bun_bo_hue',
      name: 'Bún bò Huế',
      calorieKcal: 72,
      proteinG: 6.2,
      carbG: 9.8,
      fatG: 1.4,
      category: 'Món nước',
      defaultPortionG: 400,
    ),
    FoodItem(
      id: 'bun_rieu',
      name: 'Bún riêu cua',
      calorieKcal: 65,
      proteinG: 5.5,
      carbG: 8.5,
      fatG: 1.3,
      category: 'Món nước',
      defaultPortionG: 400,
    ),
    FoodItem(
      id: 'bun_mam',
      name: 'Bún mắm',
      calorieKcal: 78,
      proteinG: 6.5,
      carbG: 10.5,
      fatG: 1.5,
      category: 'Món nước',
      defaultPortionG: 400,
    ),
    FoodItem(
      id: 'hu_tieu',
      name: 'Hủ tiếu Nam Vang',
      calorieKcal: 75,
      proteinG: 5.5,
      carbG: 10.2,
      fatG: 1.5,
      category: 'Món nước',
      defaultPortionG: 400,
    ),
    FoodItem(
      id: 'mi_quang',
      name: 'Mì Quảng',
      calorieKcal: 80,
      proteinG: 6.0,
      carbG: 11.0,
      fatG: 1.8,
      category: 'Món nước',
      defaultPortionG: 400,
    ),
    FoodItem(
      id: 'banh_canh',
      name: 'Bánh canh ghẹ',
      calorieKcal: 70,
      proteinG: 5.8,
      carbG: 9.5,
      fatG: 1.2,
      category: 'Món nước',
      defaultPortionG: 400,
    ),
    FoodItem(
      id: 'sup_cua',
      name: 'Súp cua',
      calorieKcal: 55,
      proteinG: 4.5,
      carbG: 7.0,
      fatG: 0.8,
      category: 'Món nước',
      defaultPortionG: 300,
    ),
    FoodItem(
      id: 'lau_thai',
      name: 'Lẩu Thái',
      calorieKcal: 60,
      proteinG: 5.0,
      carbG: 7.5,
      fatG: 1.0,
      category: 'Món nước',
      defaultPortionG: 350,
    ),

    // ── Cơm ───────────────────────────────────────────────────────────────
    FoodItem(
      id: 'com_trang',
      name: 'Cơm trắng',
      calorieKcal: 130,
      proteinG: 2.7,
      carbG: 28.2,
      fatG: 0.3,
      category: 'Tinh bột',
      defaultPortionG: 200,
    ),
    FoodItem(
      id: 'com_ga',
      name: 'Cơm gà nướng',
      calorieKcal: 140,
      proteinG: 9.8,
      carbG: 18.5,
      fatG: 3.5,
      category: 'Cơm',
      defaultPortionG: 350,
    ),
    FoodItem(
      id: 'com_suon',
      name: 'Cơm sườn nướng',
      calorieKcal: 155,
      proteinG: 11.2,
      carbG: 19.8,
      fatG: 4.2,
      category: 'Cơm',
      defaultPortionG: 350,
    ),
    FoodItem(
      id: 'com_rang',
      name: 'Cơm rang trứng',
      calorieKcal: 165,
      proteinG: 4.5,
      carbG: 28.8,
      fatG: 3.8,
      category: 'Cơm',
      defaultPortionG: 300,
    ),
    FoodItem(
      id: 'com_tam',
      name: 'Cơm tấm sườn bì',
      calorieKcal: 160,
      proteinG: 10.5,
      carbG: 20.0,
      fatG: 4.5,
      category: 'Cơm',
      defaultPortionG: 380,
    ),
    FoodItem(
      id: 'com_chien_duong_chau',
      name: 'Cơm chiên Dương Châu',
      calorieKcal: 175,
      proteinG: 5.5,
      carbG: 30.0,
      fatG: 4.5,
      category: 'Cơm',
      defaultPortionG: 300,
    ),
    FoodItem(
      id: 'com_ca_kho',
      name: 'Cơm cá kho tộ',
      calorieKcal: 145,
      proteinG: 10.0,
      carbG: 19.5,
      fatG: 3.5,
      category: 'Cơm',
      defaultPortionG: 350,
    ),
    FoodItem(
      id: 'com_bo_luc_lac',
      name: 'Cơm bò lúc lắc',
      calorieKcal: 170,
      proteinG: 12.5,
      carbG: 19.0,
      fatG: 5.5,
      category: 'Cơm',
      defaultPortionG: 380,
    ),

    // ── Bánh mì / Bánh ────────────────────────────────────────────────────
    FoodItem(
      id: 'banh_mi_thit',
      name: 'Bánh mì thịt',
      calorieKcal: 245,
      proteinG: 10.8,
      carbG: 32.5,
      fatG: 9.5,
      category: 'Bánh mì',
      defaultPortionG: 200,
    ),
    FoodItem(
      id: 'banh_mi_trung',
      name: 'Bánh mì trứng',
      calorieKcal: 220,
      proteinG: 9.2,
      carbG: 30.8,
      fatG: 7.5,
      category: 'Bánh mì',
      defaultPortionG: 180,
    ),
    FoodItem(
      id: 'banh_mi_pate',
      name: 'Bánh mì patê',
      calorieKcal: 255,
      proteinG: 11.0,
      carbG: 31.0,
      fatG: 10.5,
      category: 'Bánh mì',
      defaultPortionG: 200,
    ),
    FoodItem(
      id: 'banh_mi_op_la',
      name: 'Bánh mì ốp lá',
      calorieKcal: 235,
      proteinG: 10.5,
      carbG: 29.0,
      fatG: 9.0,
      category: 'Bánh mì',
      defaultPortionG: 190,
    ),
    FoodItem(
      id: 'banh_cuon',
      name: 'Bánh cuốn nhân thịt',
      calorieKcal: 105,
      proteinG: 5.5,
      carbG: 15.5,
      fatG: 2.2,
      category: 'Bánh mì',
      defaultPortionG: 200,
    ),
    FoodItem(
      id: 'banh_xeo',
      name: 'Bánh xèo (1 cái)',
      calorieKcal: 165,
      proteinG: 7.5,
      carbG: 22.0,
      fatG: 6.5,
      category: 'Bánh mì',
      defaultPortionG: 200,
    ),
    FoodItem(
      id: 'banh_bao',
      name: 'Bánh bao nhân thịt',
      calorieKcal: 220,
      proteinG: 8.5,
      carbG: 35.0,
      fatG: 5.0,
      category: 'Bánh mì',
      defaultPortionG: 100,
    ),

    // ── Thịt ──────────────────────────────────────────────────────────────
    FoodItem(
      id: 'ga_luoc',
      name: 'Gà luộc',
      calorieKcal: 165,
      proteinG: 23.5,
      carbG: 0,
      fatG: 7.5,
      category: 'Thịt',
      defaultPortionG: 150,
    ),
    FoodItem(
      id: 'thit_heo_luoc',
      name: 'Thịt heo nạc luộc',
      calorieKcal: 185,
      proteinG: 22.8,
      carbG: 0,
      fatG: 10.5,
      category: 'Thịt',
      defaultPortionG: 100,
    ),
    FoodItem(
      id: 'thit_bo_xao',
      name: 'Thịt bò xào hành',
      calorieKcal: 198,
      proteinG: 21.5,
      carbG: 3.0,
      fatG: 11.0,
      category: 'Thịt',
      defaultPortionG: 150,
    ),
    FoodItem(
      id: 'suon_heo_nuong',
      name: 'Sườn heo nướng',
      calorieKcal: 242,
      proteinG: 20.0,
      carbG: 2.0,
      fatG: 17.0,
      category: 'Thịt',
      defaultPortionG: 150,
    ),
    FoodItem(
      id: 'ga_chien',
      name: 'Gà chiên giòn',
      calorieKcal: 250,
      proteinG: 22.0,
      carbG: 8.0,
      fatG: 15.5,
      category: 'Thịt',
      defaultPortionG: 150,
    ),
    FoodItem(
      id: 'thit_kho',
      name: 'Thịt heo kho tàu',
      calorieKcal: 210,
      proteinG: 20.0,
      carbG: 3.5,
      fatG: 13.0,
      category: 'Thịt',
      defaultPortionG: 120,
    ),
    FoodItem(
      id: 'vit_quay',
      name: 'Vịt quay (100g)',
      calorieKcal: 337,
      proteinG: 19.0,
      carbG: 0,
      fatG: 28.5,
      category: 'Thịt',
      defaultPortionG: 150,
    ),
    FoodItem(
      id: 'cha_gio',
      name: 'Chả giò (2 cái)',
      calorieKcal: 180,
      proteinG: 7.5,
      carbG: 20.0,
      fatG: 9.0,
      category: 'Thịt',
      defaultPortionG: 100,
    ),

    // ── Hải sản ───────────────────────────────────────────────────────────
    FoodItem(
      id: 'ca_hoi_nuong',
      name: 'Cá hồi nướng',
      calorieKcal: 208,
      proteinG: 22.1,
      carbG: 0,
      fatG: 13.5,
      category: 'Hải sản',
      defaultPortionG: 150,
    ),
    FoodItem(
      id: 'ca_thu_kho',
      name: 'Cá thu kho',
      calorieKcal: 180,
      proteinG: 20.5,
      carbG: 2.5,
      fatG: 10.0,
      category: 'Hải sản',
      defaultPortionG: 100,
    ),
    FoodItem(
      id: 'tom_luoc',
      name: 'Tôm luộc',
      calorieKcal: 99,
      proteinG: 20.3,
      carbG: 0.9,
      fatG: 1.1,
      category: 'Hải sản',
      defaultPortionG: 150,
    ),
    FoodItem(
      id: 'tom_xao_ty',
      name: 'Tôm xào tỏi ớt',
      calorieKcal: 120,
      proteinG: 18.5,
      carbG: 3.5,
      fatG: 3.5,
      category: 'Hải sản',
      defaultPortionG: 150,
    ),
    FoodItem(
      id: 'muc_xao',
      name: 'Mực xào sả ớt',
      calorieKcal: 110,
      proteinG: 18.0,
      carbG: 3.0,
      fatG: 2.5,
      category: 'Hải sản',
      defaultPortionG: 150,
    ),
    FoodItem(
      id: 'oc_luoc',
      name: 'Ốc luộc',
      calorieKcal: 90,
      proteinG: 12.5,
      carbG: 4.2,
      fatG: 2.5,
      category: 'Hải sản',
      defaultPortionG: 150,
    ),
    FoodItem(
      id: 'cua_rang_muoi',
      name: 'Cua rang muối',
      calorieKcal: 115,
      proteinG: 17.0,
      carbG: 2.0,
      fatG: 4.5,
      category: 'Hải sản',
      defaultPortionG: 150,
    ),
    FoodItem(
      id: 'ca_chien',
      name: 'Cá chép chiên',
      calorieKcal: 195,
      proteinG: 18.5,
      carbG: 5.0,
      fatG: 11.0,
      category: 'Hải sản',
      defaultPortionG: 150,
    ),

    // ── Trứng ─────────────────────────────────────────────────────────────
    FoodItem(
      id: 'trung_luoc',
      name: 'Trứng gà luộc',
      calorieKcal: 155,
      proteinG: 12.6,
      carbG: 1.1,
      fatG: 10.6,
      category: 'Trứng',
      defaultPortionG: 60,
    ),
    FoodItem(
      id: 'trung_op_la',
      name: 'Trứng ốp lá',
      calorieKcal: 185,
      proteinG: 12.2,
      carbG: 0.5,
      fatG: 14.5,
      category: 'Trứng',
      defaultPortionG: 60,
    ),
    FoodItem(
      id: 'trung_chien',
      name: 'Trứng chiên hành',
      calorieKcal: 200,
      proteinG: 12.0,
      carbG: 1.5,
      fatG: 16.0,
      category: 'Trứng',
      defaultPortionG: 60,
    ),
    FoodItem(
      id: 'trung_vit_luoc',
      name: 'Trứng vịt luộc',
      calorieKcal: 185,
      proteinG: 13.0,
      carbG: 1.0,
      fatG: 14.0,
      category: 'Trứng',
      defaultPortionG: 70,
    ),
    FoodItem(
      id: 'trung_cut',
      name: 'Trứng cút luộc (5 quả)',
      calorieKcal: 178,
      proteinG: 13.0,
      carbG: 0.5,
      fatG: 13.5,
      category: 'Trứng',
      defaultPortionG: 50,
    ),

    // ── Rau củ ────────────────────────────────────────────────────────────
    FoodItem(
      id: 'rau_muong_xao',
      name: 'Rau muống xào tỏi',
      calorieKcal: 45,
      proteinG: 2.8,
      carbG: 5.2,
      fatG: 1.8,
      category: 'Rau củ',
      defaultPortionG: 150,
    ),
    FoodItem(
      id: 'bap_cai_luoc',
      name: 'Bắp cải luộc',
      calorieKcal: 25,
      proteinG: 1.3,
      carbG: 5.8,
      fatG: 0.1,
      category: 'Rau củ',
      defaultPortionG: 150,
    ),
    FoodItem(
      id: 'rau_cai_xao',
      name: 'Cải xanh xào tỏi',
      calorieKcal: 35,
      proteinG: 2.5,
      carbG: 4.5,
      fatG: 1.0,
      category: 'Rau củ',
      defaultPortionG: 150,
    ),
    FoodItem(
      id: 'gia_xao',
      name: 'Giá xào thịt',
      calorieKcal: 70,
      proteinG: 5.5,
      carbG: 5.0,
      fatG: 2.5,
      category: 'Rau củ',
      defaultPortionG: 150,
    ),
    FoodItem(
      id: 'khoai_lang_luoc',
      name: 'Khoai lang luộc',
      calorieKcal: 86,
      proteinG: 1.6,
      carbG: 20.1,
      fatG: 0.1,
      category: 'Tinh bột',
      defaultPortionG: 150,
    ),
    FoodItem(
      id: 'khoai_tay_luoc',
      name: 'Khoai tây luộc',
      calorieKcal: 77,
      proteinG: 2.0,
      carbG: 17.5,
      fatG: 0.1,
      category: 'Rau củ',
      defaultPortionG: 150,
    ),
    FoodItem(
      id: 'khoai_tay_chien',
      name: 'Khoai tây chiên',
      calorieKcal: 312,
      proteinG: 3.5,
      carbG: 41.5,
      fatG: 15.0,
      category: 'Rau củ',
      defaultPortionG: 100,
    ),
    FoodItem(
      id: 'dua_leo',
      name: 'Dưa leo tươi',
      calorieKcal: 16,
      proteinG: 0.7,
      carbG: 3.6,
      fatG: 0.1,
      category: 'Rau củ',
      defaultPortionG: 100,
    ),
    FoodItem(
      id: 'ca_rot_xao',
      name: 'Cà rốt xào trứng',
      calorieKcal: 60,
      proteinG: 3.5,
      carbG: 8.0,
      fatG: 2.0,
      category: 'Rau củ',
      defaultPortionG: 150,
    ),

    // ── Canh ──────────────────────────────────────────────────────────────
    FoodItem(
      id: 'canh_chua',
      name: 'Canh chua cá',
      calorieKcal: 42,
      proteinG: 3.8,
      carbG: 5.5,
      fatG: 0.8,
      category: 'Canh',
      defaultPortionG: 250,
    ),
    FoodItem(
      id: 'canh_bi_dao',
      name: 'Canh bí đao thịt',
      calorieKcal: 38,
      proteinG: 3.0,
      carbG: 5.0,
      fatG: 0.8,
      category: 'Canh',
      defaultPortionG: 250,
    ),
    FoodItem(
      id: 'canh_rau_ngot',
      name: 'Canh rau ngót thịt',
      calorieKcal: 45,
      proteinG: 4.0,
      carbG: 4.5,
      fatG: 1.0,
      category: 'Canh',
      defaultPortionG: 250,
    ),
    FoodItem(
      id: 'canh_kho_qua',
      name: 'Canh khổ qua nhồi thịt',
      calorieKcal: 50,
      proteinG: 4.5,
      carbG: 4.0,
      fatG: 1.5,
      category: 'Canh',
      defaultPortionG: 250,
    ),

    // ── Chay / Salad ──────────────────────────────────────────────────────
    FoodItem(
      id: 'dau_hu_xao',
      name: 'Đậu hủ xào sả ớt',
      calorieKcal: 95,
      proteinG: 8.5,
      carbG: 3.2,
      fatG: 5.5,
      category: 'Chay',
      defaultPortionG: 150,
    ),
    FoodItem(
      id: 'dau_hu_sot_ca',
      name: 'Đậu hủ sốt cà chua',
      calorieKcal: 85,
      proteinG: 7.5,
      carbG: 5.5,
      fatG: 3.5,
      category: 'Chay',
      defaultPortionG: 150,
    ),
    FoodItem(
      id: 'nam_xao_toi',
      name: 'Nấm xào tỏi',
      calorieKcal: 40,
      proteinG: 3.0,
      carbG: 5.5,
      fatG: 1.0,
      category: 'Chay',
      defaultPortionG: 150,
    ),
    FoodItem(
      id: 'salad_uc_ga',
      name: 'Salad ức gà',
      calorieKcal: 98,
      proteinG: 18.8,
      carbG: 2.5,
      fatG: 1.8,
      category: 'Salad',
      defaultPortionG: 200,
    ),
    FoodItem(
      id: 'salad_ca_ngu',
      name: 'Salad cá ngừ',
      calorieKcal: 110,
      proteinG: 17.5,
      carbG: 3.0,
      fatG: 3.5,
      category: 'Salad',
      defaultPortionG: 200,
    ),
    FoodItem(
      id: 'salad_trung',
      name: 'Salad trứng',
      calorieKcal: 120,
      proteinG: 8.5,
      carbG: 4.0,
      fatG: 8.0,
      category: 'Salad',
      defaultPortionG: 200,
    ),

    // ── Cháo ──────────────────────────────────────────────────────────────
    FoodItem(
      id: 'chao_ga',
      name: 'Cháo gà',
      calorieKcal: 55,
      proteinG: 4.2,
      carbG: 7.8,
      fatG: 0.8,
      category: 'Cháo',
      defaultPortionG: 350,
    ),
    FoodItem(
      id: 'chao_lon',
      name: 'Cháo lòng heo',
      calorieKcal: 65,
      proteinG: 5.5,
      carbG: 8.5,
      fatG: 1.2,
      category: 'Cháo',
      defaultPortionG: 350,
    ),
    FoodItem(
      id: 'chao_tom',
      name: 'Cháo tôm',
      calorieKcal: 58,
      proteinG: 5.0,
      carbG: 8.0,
      fatG: 0.8,
      category: 'Cháo',
      defaultPortionG: 350,
    ),
    FoodItem(
      id: 'chao_ca',
      name: 'Cháo cá',
      calorieKcal: 52,
      proteinG: 4.5,
      carbG: 7.5,
      fatG: 0.7,
      category: 'Cháo',
      defaultPortionG: 350,
    ),

    // ── Tinh bột / Bún / Mì ───────────────────────────────────────────────
    FoodItem(
      id: 'mi_goi',
      name: 'Mì gói nấu (1 gói)',
      calorieKcal: 130,
      proteinG: 3.8,
      carbG: 24.5,
      fatG: 2.5,
      category: 'Tinh bột',
      defaultPortionG: 350,
    ),
    FoodItem(
      id: 'bun_tuoi',
      name: 'Bún tươi',
      calorieKcal: 110,
      proteinG: 2.5,
      carbG: 25.0,
      fatG: 0.2,
      category: 'Tinh bột',
      defaultPortionG: 200,
    ),
    FoodItem(
      id: 'mi_trung',
      name: 'Mì trứng',
      calorieKcal: 140,
      proteinG: 5.0,
      carbG: 28.0,
      fatG: 1.5,
      category: 'Tinh bột',
      defaultPortionG: 200,
    ),
    FoodItem(
      id: 'banh_pho',
      name: 'Bánh phở (sống)',
      calorieKcal: 105,
      proteinG: 2.2,
      carbG: 23.5,
      fatG: 0.2,
      category: 'Tinh bột',
      defaultPortionG: 200,
    ),

    // ── Trái cây ──────────────────────────────────────────────────────────
    FoodItem(
      id: 'chuoi',
      name: 'Chuối',
      calorieKcal: 89,
      proteinG: 1.1,
      carbG: 22.8,
      fatG: 0.3,
      category: 'Trái cây',
      defaultPortionG: 120,
    ),
    FoodItem(
      id: 'tao',
      name: 'Táo',
      calorieKcal: 52,
      proteinG: 0.3,
      carbG: 13.8,
      fatG: 0.2,
      category: 'Trái cây',
      defaultPortionG: 180,
    ),
    FoodItem(
      id: 'xoai',
      name: 'Xoài',
      calorieKcal: 60,
      proteinG: 0.8,
      carbG: 15.0,
      fatG: 0.4,
      category: 'Trái cây',
      defaultPortionG: 150,
    ),
    FoodItem(
      id: 'dua_hau',
      name: 'Dưa hấu',
      calorieKcal: 30,
      proteinG: 0.6,
      carbG: 7.6,
      fatG: 0.2,
      category: 'Trái cây',
      defaultPortionG: 200,
    ),
    FoodItem(
      id: 'cam',
      name: 'Cam',
      calorieKcal: 47,
      proteinG: 0.9,
      carbG: 11.8,
      fatG: 0.1,
      category: 'Trái cây',
      defaultPortionG: 130,
    ),
    FoodItem(
      id: 'nho',
      name: 'Nho',
      calorieKcal: 69,
      proteinG: 0.7,
      carbG: 18.1,
      fatG: 0.2,
      category: 'Trái cây',
      defaultPortionG: 100,
    ),
    FoodItem(
      id: 'buoi',
      name: 'Bưởi',
      calorieKcal: 32,
      proteinG: 0.6,
      carbG: 8.1,
      fatG: 0.1,
      category: 'Trái cây',
      defaultPortionG: 150,
    ),
    FoodItem(
      id: 'thanh_long',
      name: 'Thanh long',
      calorieKcal: 50,
      proteinG: 1.1,
      carbG: 11.0,
      fatG: 0.4,
      category: 'Trái cây',
      defaultPortionG: 150,
    ),

    // ── Sữa / Dairy ───────────────────────────────────────────────────────
    FoodItem(
      id: 'yogurt',
      name: 'Yogurt không đường',
      calorieKcal: 59,
      proteinG: 3.5,
      carbG: 7.8,
      fatG: 0.8,
      category: 'Sữa',
      defaultPortionG: 150,
    ),
    FoodItem(
      id: 'sua_tuoi',
      name: 'Sữa tươi không đường',
      calorieKcal: 61,
      proteinG: 3.2,
      carbG: 4.8,
      fatG: 3.3,
      category: 'Sữa',
      defaultPortionG: 200,
    ),
    FoodItem(
      id: 'sua_chua_co_duong',
      name: 'Sữa chua có đường',
      calorieKcal: 95,
      proteinG: 3.0,
      carbG: 17.0,
      fatG: 1.5,
      category: 'Sữa',
      defaultPortionG: 150,
    ),
    FoodItem(
      id: 'pho_mai',
      name: 'Phô mai tươi',
      calorieKcal: 98,
      proteinG: 6.5,
      carbG: 3.5,
      fatG: 7.0,
      category: 'Sữa',
      defaultPortionG: 50,
    ),

    // ── Tráng miệng / Đồ uống ─────────────────────────────────────────────
    FoodItem(
      id: 'banh_chuoi',
      name: 'Bánh chuối hấp',
      calorieKcal: 135,
      proteinG: 2.2,
      carbG: 27.5,
      fatG: 2.5,
      category: 'Tráng miệng',
      defaultPortionG: 100,
    ),
    FoodItem(
      id: 'che_dau_xanh',
      name: 'Chè đậu xanh',
      calorieKcal: 110,
      proteinG: 4.5,
      carbG: 22.0,
      fatG: 0.5,
      category: 'Tráng miệng',
      defaultPortionG: 200,
    ),
    FoodItem(
      id: 'che_ba_mau',
      name: 'Chè ba màu',
      calorieKcal: 130,
      proteinG: 3.0,
      carbG: 27.0,
      fatG: 1.5,
      category: 'Tráng miệng',
      defaultPortionG: 200,
    ),
    FoodItem(
      id: 'kem_tuoi',
      name: 'Kem tươi (1 cây)',
      calorieKcal: 145,
      proteinG: 2.5,
      carbG: 22.0,
      fatG: 5.5,
      category: 'Tráng miệng',
      defaultPortionG: 80,
    ),
    FoodItem(
      id: 'nuoc_cam_tuoi',
      name: 'Nước cam tươi',
      calorieKcal: 45,
      proteinG: 0.7,
      carbG: 10.4,
      fatG: 0.2,
      category: 'Tráng miệng',
      defaultPortionG: 250,
    ),
    FoodItem(
      id: 'tra_sua',
      name: 'Trà sữa trân châu',
      calorieKcal: 168,
      proteinG: 2.0,
      carbG: 36.5,
      fatG: 2.5,
      category: 'Tráng miệng',
      defaultPortionG: 500,
    ),
    FoodItem(
      id: 'sinh_to_chuoi',
      name: 'Sinh tố chuối',
      calorieKcal: 120,
      proteinG: 2.5,
      carbG: 25.0,
      fatG: 1.5,
      category: 'Tráng miệng',
      defaultPortionG: 300,
    ),
  ];

  Future<List<String>> getCategories() async {
    await _ensureLoaded();
    final cats =
        (_cached?.map((f) => f.category).toSet().toList() ?? _seedCategories)
          ..sort();
    return cats;
  }

  static final List<String> _seedCategories = List.unmodifiable(
    _seedFoods.map((f) => f.category).toSet().toList()..sort(),
  );

  Future<List<FoodItem>> search(String query) async {
    await _ensureLoaded();
    if (query.trim().isEmpty) return [];
    final q = _removeDiacritics(query.toLowerCase().trim());
    final foods = _cached ?? _seedFoods;
    return foods
        .where((f) {
          final name = _removeDiacritics(f.name.toLowerCase());
          return name.contains(q);
        })
        .take(20)
        .toList();
  }

  @override
  Future<List<FoodItem>> getAll() async {
    await _ensureLoaded();
    return List.unmodifiable(_cached ?? _seedFoods);
  }

  Future<List<FoodItem>> getByCategory(String category) async {
    await _ensureLoaded();
    final foods = _cached ?? _seedFoods;
    return foods.where((f) => f.category == category).toList();
  }

  Future<FoodItem?> getById(String id) async {
    await _ensureLoaded();
    final foods = _cached ?? _seedFoods;
    try {
      return foods.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<FoodItem>> suggestedForCurrentMealtime() async {
    await _ensureLoaded();
    final hour = DateTime.now().hour;
    final ids = hour < 10
        ? <String>[
            'pho_bo',
            'banh_mi_thit',
            'chao_ga',
            'trung_op_la',
            'sua_tuoi',
          ]
        : hour < 14
        ? <String>['com_ga', 'com_tam', 'bun_bo_hue', 'rau_muong_xao', 'tao']
        : hour < 19
        ? <String>[
            'com_suon',
            'ca_hoi_nuong',
            'canh_chua',
            'com_trang',
            'chuoi',
          ]
        : <String>['chao_ga', 'mi_goi', 'salad_uc_ga', 'yogurt', 'tra_sua'];
    final results = <FoodItem>[];
    for (final id in ids) {
      final item = await getById(id);
      if (item != null) results.add(item);
    }
    return results;
  }

  Future<void> _ensureLoaded() async {
    if (_cached != null) return;
    if (_isLoading) {
      while (_isLoading) {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
      return;
    }
    _isLoading = true;
    try {
      final snapshot = await _firestore.collection('foods').get();
      if (snapshot.docs.isNotEmpty) {
        _cached = snapshot.docs.map((d) => FoodItem.fromMap(d.data())).toList();
      } else {
        _cached = List.unmodifiable(_seedFoods);
      }
    } catch (_) {
      _cached = List.unmodifiable(_seedFoods);
    } finally {
      _isLoading = false;
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
