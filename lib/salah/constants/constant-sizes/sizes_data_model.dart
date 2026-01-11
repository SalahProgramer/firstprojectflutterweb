class AppSizesData {
  final SizeCategory men;
  final SizeCategory women;
  final SizeCategory womenPlus;
  final SizeCategory kidsBoys;
  final SizeCategory kidsGirls;
  final SizeCategory womenShoes;
  final SizeCategory menShoes;
  final SizeCategory kidsShoes;
  final SizeCategory underwear;
  final SizeCategory weddingAndEvents;
  final SizeCategory womenAndBaby;

  AppSizesData({
    required this.men,
    required this.women,
    required this.womenPlus,
    required this.kidsBoys,
    required this.kidsGirls,
    required this.womenShoes,
    required this.menShoes,
    required this.kidsShoes,
    required this.underwear,
    required this.weddingAndEvents,
    required this.womenAndBaby,
  });

  factory AppSizesData.fromJson(Map<String, dynamic> json) {
    return AppSizesData(
      men: SizeCategory.fromJson(json['men'] as Map<String, dynamic>? ?? {}),
      women: SizeCategory.fromJson(
        json['women'] as Map<String, dynamic>? ?? {},
      ),
      womenPlus: SizeCategory.fromJson(
        json['womenPlus'] as Map<String, dynamic>? ?? {},
      ),
      kidsBoys: SizeCategory.fromJson(
        json['kidsBoys'] as Map<String, dynamic>? ?? {},
      ),
      kidsGirls: SizeCategory.fromJson(
        json['kidsGirls'] as Map<String, dynamic>? ?? {},
      ),
      womenShoes: SizeCategory.fromJson(
        json['womenShoes'] as Map<String, dynamic>? ?? {},
      ),
      menShoes: SizeCategory.fromJson(
        json['menShoes'] as Map<String, dynamic>? ?? {},
      ),
      kidsShoes: SizeCategory.fromJson(
        json['kidsShoes'] as Map<String, dynamic>? ?? {},
      ),
      underwear: SizeCategory.fromJson(
        json['underwear'] as Map<String, dynamic>? ?? {},
      ),
      weddingAndEvents: SizeCategory.fromJson(
        json['weddingAndEvents'] as Map<String, dynamic>? ?? {},
      ),
      womenAndBaby: SizeCategory.fromJson(
        json['womenAndBaby'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'men': men.toJson(),
      'women': women.toJson(),
      'womenPlus': womenPlus.toJson(),
      'kidsBoys': kidsBoys.toJson(),
      'kidsGirls': kidsGirls.toJson(),
      'womenShoes': womenShoes.toJson(),
      'menShoes': menShoes.toJson(),
      'kidsShoes': kidsShoes.toJson(),
      'underwear': underwear.toJson(),
      'weddingAndEvents': weddingAndEvents.toJson(),
      'womenAndBaby': womenAndBaby.toJson(),
    };
  }
}

class SizeCategory {
  final Map<String, String>? sizesList;
  final List<String>? sizesListSimple;
  final Map<String, bool>? sizesMap;

  SizeCategory({this.sizesList, this.sizesListSimple, this.sizesMap});

  factory SizeCategory.fromJson(Map<String, dynamic> json) {
    return SizeCategory(
      sizesList: json['sizesList'] != null
          ? Map<String, String>.from(json['sizesList'] as Map)
          : null,
      sizesListSimple: json['sizesListSimple'] != null
          ? List<String>.from(json['sizesListSimple'] as List)
          : null,
      sizesMap: json['sizesMap'] != null
          ? Map<String, bool>.from(json['sizesMap'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (sizesList != null) {
      data['sizesList'] = sizesList;
    }
    if (sizesListSimple != null) {
      data['sizesListSimple'] = sizesListSimple;
    }
    if (sizesMap != null) {
      data['sizesMap'] = sizesMap;
    }
    return data;
  }
}
