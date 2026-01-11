class AppConstantData {
  final Map<String, String> mainCategories;
  final Map<String, String> subCategories;
  final List<CategoryItem> basicCategories;
  final List<CategoryItem> secondaryCategories;
  final List<CategoryItem> kidsShoes;
  final List<CategoryItem> men;
  final List<CategoryItem> women;
  final List<CategoryItem> womenPlus;
  final List<CategoryItem> allkids;
  final List<CategoryItem> girls;
  final List<CategoryItem> boys;
  final List<CategoryItem> womenAndBaby;
  final List<CategoryItem> allShoes;
  final List<CategoryItem> menShoes;
  final List<CategoryItem> womenShoes;
  final List<CategoryItem> underWare;
  final List<CategoryItem> home;
  final List<CategoryItem> apparel;
  final List<CategoryItem> beauty;
  final List<CategoryItem> electronics;
  final List<CategoryItem> bags;
  final List<CategoryItem> sports;
  final List<CategoryItem> kids;
  final List<CategoryItem> perfume;
  final List<Tag> tags;
  final List<Tag> tagsMen;
  final List<Tag> womenTags;

  AppConstantData({
    required this.mainCategories,
    required this.subCategories,
    required this.basicCategories,
    required this.secondaryCategories,
    required this.kidsShoes,
    required this.men,
    required this.women,
    required this.womenPlus,
    required this.allkids,
    required this.girls,
    required this.boys,
    required this.womenAndBaby,
    required this.allShoes,
    required this.menShoes,
    required this.womenShoes,
    required this.underWare,
    required this.home,
    required this.apparel,
    required this.beauty,
    required this.electronics,
    required this.bags,
    required this.sports,
    required this.kids,
    required this.perfume,
    required this.tags,
    required this.tagsMen,
    required this.womenTags,
  });

  factory AppConstantData.fromJson(Map<String, dynamic> json) {
    return AppConstantData(
      mainCategories: Map<String, String>.from(json['mainCategories'] ?? {}),
      subCategories: Map<String, String>.from(json['subCategories'] ?? {}),
      basicCategories:
          (json['basicCategories'] as List<dynamic>?)
              ?.map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      secondaryCategories:
          (json['secondaryCategories'] as List<dynamic>?)
              ?.map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      kidsShoes:
          (json['kidsShoes'] as List<dynamic>?)
              ?.map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      men:
          (json['men'] as List<dynamic>?)
              ?.map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      women:
          (json['women'] as List<dynamic>?)
              ?.map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      womenPlus:
          (json['womenPlus'] as List<dynamic>?)
              ?.map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      allkids:
          (json['allkids'] as List<dynamic>?)
              ?.map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      girls:
          (json['girls'] as List<dynamic>?)
              ?.map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      boys:
          (json['boys'] as List<dynamic>?)
              ?.map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      womenAndBaby:
          (json['womenAndBaby'] as List<dynamic>?)
              ?.map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      allShoes:
          (json['allShoes'] as List<dynamic>?)
              ?.map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      menShoes:
          (json['menShoes'] as List<dynamic>?)
              ?.map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      womenShoes:
          (json['womenShoes'] as List<dynamic>?)
              ?.map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      underWare:
          (json['underWare'] as List<dynamic>?)
              ?.map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      home:
          (json['home'] as List<dynamic>?)
              ?.map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      apparel:
          (json['apparel'] as List<dynamic>?)
              ?.map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      beauty:
          (json['beauty'] as List<dynamic>?)
              ?.map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      electronics:
          (json['electronics'] as List<dynamic>?)
              ?.map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      bags:
          (json['bags'] as List<dynamic>?)
              ?.map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      sports:
          (json['sports'] as List<dynamic>?)
              ?.map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      kids:
          (json['kids'] as List<dynamic>?)
              ?.map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      perfume:
          (json['perfume'] as List<dynamic>?)
              ?.map((e) => CategoryItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tags:
          (json['tags'] as List<dynamic>?)
              ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      tagsMen:
          (json['tagsMen'] as List<dynamic>?)
              ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      womenTags:
          (json['womenTags'] as List<dynamic>?)
              ?.map((e) => Tag.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mainCategories': mainCategories,
      'subCategories': subCategories,
      'basicCategories': basicCategories.map((e) => e.toJson()).toList(),
      'secondaryCategories': secondaryCategories
          .map((e) => e.toJson())
          .toList(),
      'kidsShoes': kidsShoes.map((e) => e.toJson()).toList(),
      'men': men.map((e) => e.toJson()).toList(),
      'women': women.map((e) => e.toJson()).toList(),
      'womenPlus': womenPlus.map((e) => e.toJson()).toList(),
      'allkids': allkids.map((e) => e.toJson()).toList(),
      'girls': girls.map((e) => e.toJson()).toList(),
      'boys': boys.map((e) => e.toJson()).toList(),
      'womenAndBaby': womenAndBaby.map((e) => e.toJson()).toList(),
      'allShoes': allShoes.map((e) => e.toJson()).toList(),
      'menShoes': menShoes.map((e) => e.toJson()).toList(),
      'womenShoes': womenShoes.map((e) => e.toJson()).toList(),
      'underWare': underWare.map((e) => e.toJson()).toList(),
      'home': home.map((e) => e.toJson()).toList(),
      'apparel': apparel.map((e) => e.toJson()).toList(),
      'beauty': beauty.map((e) => e.toJson()).toList(),
      'electronics': electronics.map((e) => e.toJson()).toList(),
      'bags': bags.map((e) => e.toJson()).toList(),
      'sports': sports.map((e) => e.toJson()).toList(),
      'kids': kids.map((e) => e.toJson()).toList(),
      'perfume': perfume.map((e) => e.toJson()).toList(),
      'tags': tags.map((e) => e.toJson()).toList(),
      'tagsMen': tagsMen.map((e) => e.toJson()).toList(),
      'womenTags': womenTags.map((e) => e.toJson()).toList(),
    };
  }
}

class CategoryItem {
  final String? id;
  final String name;
  final String image;
  final String mainCategory;
  final String? subCategory;

  CategoryItem({
    this.id,
    required this.name,
    required this.image,
    required this.mainCategory,
    this.subCategory,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id'] as String?,
      name: json['name'] as String? ?? '',
      image: json['image'] as String? ?? '',
      mainCategory: json['main_category'] as String? ?? '',
      subCategory: json['sub_category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'image': image,
      'main_category': mainCategory,
    };
    if (id != null) {
      data['id'] = id;
    }
    if (subCategory != null) {
      data['sub_category'] = subCategory;
    }
    return data;
  }
}

class Tag {
  final String tag;

  Tag({required this.tag});

  factory Tag.fromJson(Map<String, dynamic> json) {
    return Tag(tag: json['tag'] as String? ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'tag': tag};
  }
}
