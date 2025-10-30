import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'drug.dart';
import '../../services/product_service.dart';

/// ===== Mock data (demo) =====
final _mockDrugs = <Drug>[
  const Drug(
    id: 'd1',
    name: 'Paracetamol 500',
    uses: 'Giảm đau, hạ sốt nhẹ đến vừa',
    imageUrl: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=800',
    price: 15000,
    categories: ['Giảm đau', 'Không kê đơn'],
    activeIngredient: 'Paracetamol',
    manufacturer: 'ABC Pharma',
    ratingAvg: 4.5,
    ratingCount: 128,
    indications: 'Đau đầu, đau cơ, cảm cúm…',
    contraindications: 'Bệnh gan nặng, quá mẫn paracetamol',
    dosage: 'Người lớn 500–1000mg/4–6h, tối đa 3g/ngày (tự dùng)',
    sideEffects: 'Hiếm: nổi mẩn, buồn nôn; quá liều: độc gan',
    notes: 'Không dùng chung nhiều chế phẩm chứa paracetamol',
  ),
  const Drug(
    id: 'd2',
    name: 'Ibuprofen 200',
    uses: 'Giảm đau, kháng viêm, hạ sốt',
    imageUrl: 'https://images.unsplash.com/photo-1573883431205-98b5a41f7f2e?w=800',
    price: 28000,
    categories: ['Kháng viêm', 'Không kê đơn'],
    activeIngredient: 'Ibuprofen',
    manufacturer: 'XYZ Healthcare',
    ratingAvg: 4.1,
    ratingCount: 89,
    indications: 'Đau răng, đau cơ, viêm khớp nhẹ…',
    contraindications: 'Loét dạ dày-tá tràng tiến triển, dị ứng NSAID',
    dosage: 'Người lớn 200–400mg mỗi 6–8h, tối đa 1200mg/ngày (OTC)',
    sideEffects: 'Đau thượng vị, buồn nôn; nguy cơ xuất huyết tiêu hoá',
    notes: 'Uống sau ăn; tránh phối hợp nhiều NSAID',
  ),
  const Drug(
    id: 'd3',
    name: 'Vitamin C 500',
    uses: 'Bổ sung vitamin C, hỗ trợ đề kháng',
    imageUrl: 'https://images.unsplash.com/photo-1582719478250-30997a33bafb?w=800',
    price: 45000,
    categories: ['Vitamin'],
    activeIngredient: 'Ascorbic acid',
    manufacturer: 'NutriCo',
    ratingAvg: 4.7,
    ratingCount: 210,
    indications: 'Thiếu vitamin C, mệt mỏi, cảm cúm',
    contraindications: 'Sỏi thận oxalat (thận trọng liều cao)',
    dosage: '500–1000mg/ngày tuỳ nhu cầu',
    sideEffects: 'Rối loạn tiêu hoá nhẹ nếu liều cao',
    notes: 'Không lạm dụng kéo dài liều cao',
  ),
  const Drug(
    id: 'd4',
    name: 'Amlodipine 5mg',
    uses: 'Hạ huyết áp, điều trị đau thắt ngực',
    imageUrl: 'https://images.unsplash.com/photo-1595433707802-6b2626ef1c86?w=800',
    price: 98000,
    categories: ['Tim mạch', 'Kê đơn'],
    activeIngredient: 'Amlodipine besylate',
    manufacturer: 'CardioPharm',
    ratingAvg: 4.3,
    ratingCount: 64,
    indications: 'Tăng huyết áp, đau thắt ngực',
    contraindications: 'Hạ huyết áp nặng',
    dosage: '5–10mg/ngày theo chỉ định bác sĩ',
    sideEffects: 'Phù mắt cá, đỏ bừng, chóng mặt',
    notes: 'Theo dõi huyết áp định kỳ, dùng theo toa',
  ),
];

/// ===== Filters state =====

enum DrugSortBy { relevance, priceAsc, priceDesc, ratingDesc }

final drugSearchQueryProvider = StateProvider<String>((_) => '');

/// danh sách category người dùng chọn (VD: {'Vitamin', 'Tim mạch'})
final selectedCategoriesProvider = StateProvider<Set<String>>((_) => <String>{});

/// khoảng giá lọc: [min, max] (đơn vị VND). null = không giới hạn
final priceRangeProvider = StateProvider<({double? min, double? max})>((_) => (min: null, max: null));

/// lọc theo rating tối thiểu (0..5)
final minRatingProvider = StateProvider<double>((_) => 0);

/// sắp xếp
final sortByProvider = StateProvider<DrugSortBy>((_) => DrugSortBy.relevance);

/// danh sách tất cả category hiện có từ dữ liệu
final allCategoriesProvider = Provider<List<String>>((ref) {
  final asyncCategories = ref.watch(categoriesApiProvider);
  return asyncCategories.when(
    data: (categories) => categories,
    loading: () => _getMockCategories(),
    error: (_, __) => _getMockCategories(),
  );
});

/// min/max price từ dữ liệu (để UX slider biết biên)
final priceBoundaryProvider = Provider<({double min, double max})>((ref) {
  final drugs = ref.watch(drugsProvider);
  if (drugs.isEmpty) return (min: 0, max: 100000);
  final prices = drugs.map((e) => e.price).toList()..sort();
  return (min: prices.first, max: prices.last);
});

/// Provider để load dữ liệu từ API
final drugsApiProvider = FutureProvider<List<Drug>>((ref) async {
  try {
    final response = await ProductService.getProducts(limit: 100);
    if (response['success'] == true && response['data'] != null) {
      final products = response['data']['docs'] as List<dynamic>? ?? [];
      return products.map((product) => Drug.fromJson(product)).toList();
    }
    return _mockDrugs; // Fallback to mock data
  } catch (e) {
    return _mockDrugs; // Fallback to mock data
  }
});

/// Provider để load categories từ API
final categoriesApiProvider = FutureProvider<List<String>>((ref) async {
  try {
    final response = await ProductService.getCategories();
    if (response['success'] == true && response['data'] != null) {
      final categories = response['data']['docs'] as List<dynamic>? ?? [];
      return categories.map((cat) => cat['name'] as String).toList()..sort();
    }
    return _getMockCategories(); // Fallback to mock categories
  } catch (e) {
    return _getMockCategories(); // Fallback to mock categories
  }
});

/// Helper function để lấy categories từ mock data
List<String> _getMockCategories() {
  final set = <String>{};
  for (final d in _mockDrugs) {
    set.addAll(d.categories);
  }
  return set.toList()..sort();
}

/// Provider để quản lý danh sách các thuốc được chọn để tạo nhắc nhở
final selectedDrugsForReminderProvider = StateProvider<Set<Drug>>((_) => <Drug>{});

/// dữ liệu gốc (fallback)
final drugsProvider = Provider<List<Drug>>((ref) {
  final asyncDrugs = ref.watch(drugsApiProvider);
  return asyncDrugs.when(
    data: (drugs) => drugs,
    loading: () => _mockDrugs,
    error: (_, __) => _mockDrugs,
  );
});

/// áp dụng Search + Lọc + Sort
final filteredDrugsProvider = Provider<List<Drug>>((ref) {
  final q = ref.watch(drugSearchQueryProvider).trim().toLowerCase();
  final selectedCats = ref.watch(selectedCategoriesProvider);
  final priceR = ref.watch(priceRangeProvider);
  final minRating = ref.watch(minRatingProvider);
  final sortBy = ref.watch(sortByProvider);
  final list = ref.watch(drugsProvider);

  var result = list.where((d) {
    // search theo name/uses/activeIngredient
    final hit = q.isEmpty ||
        d.name.toLowerCase().contains(q) ||
        d.uses.toLowerCase().contains(q) ||
        (d.activeIngredient?.toLowerCase().contains(q) ?? false);

    // lọc category (chỉ khi có tick)
    final passCat = selectedCats.isEmpty || d.categories.any((c) => selectedCats.contains(c));

    // lọc giá
    final passPrice = (priceR.min == null || d.price >= priceR.min!) &&
                      (priceR.max == null || d.price <= priceR.max!);

    // lọc rating
    final passRating = d.ratingAvg >= minRating;

    return hit && passCat && passPrice && passRating;
  }).toList();

  // sắp xếp
  switch (sortBy) {
    case DrugSortBy.priceAsc:
      result.sort((a, b) => a.price.compareTo(b.price));
      break;
    case DrugSortBy.priceDesc:
      result.sort((a, b) => b.price.compareTo(a.price));
      break;
    case DrugSortBy.ratingDesc:
      result.sort((a, b) => b.ratingAvg.compareTo(a.ratingAvg));
      break;
    case DrugSortBy.relevance:
      // giữ nguyên thứ tự (mock), khi nối API có thể xếp theo điểm TF-IDF/Server
      break;
  }
  return result;
});
