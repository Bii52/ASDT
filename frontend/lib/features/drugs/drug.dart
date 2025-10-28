class Drug {
  final String id;

  // hiển thị cơ bản
  final String name;              // tên thương mại / brand
  final String uses;              // công dụng (mô tả ngắn)
  final String imageUrl;          // ảnh minh hoạ
  final double price;             // giá tham khảo (chỉ hiển thị, không bán)
  final String currency;          // đơn vị tiền tệ hiển thị (VD: VND)

  // phân loại/tra cứu
  final List<String> categories;  // VD: ["Vitamin"], ["Kháng sinh"], ["Tim mạch"]
  final String? activeIngredient; // tuỳ chọn: hoạt chất
  final String? manufacturer;     // tuỳ chọn: nhà sản xuất

  // đánh giá cộng đồng (tổng hợp)
  final double ratingAvg;         // trung bình 0..5
  final int ratingCount;

  // mở rộng về dược lý (tuỳ chọn, có thể để null/để dành API)
  final String? indications;      // chỉ định
  final String? contraindications;// chống chỉ định
  final String? dosage;           // liều dùng
  final String? sideEffects;      // tác dụng phụ
  final String? notes;            // lưu ý

  const Drug({
    required this.id,
    required this.name,
    required this.uses,
    required this.imageUrl,
    required this.price,
    this.currency = 'VND',
    required this.categories,
    this.activeIngredient,
    this.manufacturer,
    required this.ratingAvg,
    required this.ratingCount,
    this.indications,
    this.contraindications,
    this.dosage,
    this.sideEffects,
    this.notes,
  });

  factory Drug.fromJson(Map<String, dynamic> json) {
    return Drug(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      uses: json['uses'] ?? json['description'] ?? '',
      imageUrl: json['image'] ?? json['imageUrl'] ?? '',
      price: (json['referencePrice'] ?? json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'VND',
      categories: json['category'] != null 
          ? [json['category']['name'] ?? json['category'].toString()]
          : (json['categories'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      activeIngredient: json['activeIngredient'],
      manufacturer: json['manufacturer'],
      ratingAvg: (json['ratingAvg'] ?? 4.0).toDouble(),
      ratingCount: json['ratingCount'] ?? 0,
      indications: json['indications'],
      contraindications: json['contraindications'],
      dosage: json['dosage'],
      sideEffects: json['sideEffects'],
      notes: json['notes'],
    );
  }
}
