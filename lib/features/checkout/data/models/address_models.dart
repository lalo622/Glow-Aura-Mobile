class Province {
  final String code;
  final String name;

  const Province({required this.code, required this.name});

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      code: (json['code'] ?? json['provinceCode'] ?? '').toString(),
      name: (json['name'] ?? json['provinceName'] ?? '').toString(),
    );
  }
}

class Ward {
  final String code;
  final String name;

  const Ward({required this.code, required this.name});

  factory Ward.fromJson(Map<String, dynamic> json) {
    return Ward(
      code: (json['code'] ?? json['wardCode'] ?? '').toString(),
      name: (json['name'] ?? json['wardName'] ?? '').toString(),
    );
  }
}