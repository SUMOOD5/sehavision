class Medicine {
  final int id;
  final String name;
  final String? brand;
  final String? barcode;
  final String? dosage;
  final String? instructions;
  final String? warnings;
  final List<String>? interactions;
  final DateTime? expiryDate;
  final List<String>? imagePaths;
  final DateTime createdAt;
  final DateTime updatedAt;

  Medicine({
    required this.id,
    required this.name,
    this.brand,
    this.barcode,
    this.dosage,
    this.instructions,
    this.warnings,
    this.interactions,
    this.expiryDate,
    this.imagePaths,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      brand: json['brand'],
      barcode: json['barcode'],
      dosage: json['dosage'],
      instructions: json['instructions'],
      warnings: json['warnings'],
      interactions: json['interactions'] != null
          ? List<String>.from(json['interactions'])
          : null,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'])
          : null,
      imagePaths: json['image_paths'] != null
          ? List<String>.from(json['image_paths'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'barcode': barcode,
      'dosage': dosage,
      'instructions': instructions,
      'warnings': warnings,
      'interactions': interactions,
      'expiry_date': expiryDate?.toIso8601String(),
      'image_paths': imagePaths,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Medicine copyWith({
    int? id,
    String? name,
    String? brand,
    String? barcode,
    String? dosage,
    String? instructions,
    String? warnings,
    List<String>? interactions,
    DateTime? expiryDate,
    List<String>? imagePaths,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Medicine(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      barcode: barcode ?? this.barcode,
      dosage: dosage ?? this.dosage,
      instructions: instructions ?? this.instructions,
      warnings: warnings ?? this.warnings,
      interactions: interactions ?? this.interactions,
      expiryDate: expiryDate ?? this.expiryDate,
      imagePaths: imagePaths ?? this.imagePaths,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry >= 0;
  }

  String get displayName {
    if (brand != null && brand!.isNotEmpty) {
      return '$name ($brand)';
    }
    return name;
  }

  String get primaryImage {
    if (imagePaths != null && imagePaths!.isNotEmpty) {
      return imagePaths!.first;
    }
    return '';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Medicine &&
        other.id == id &&
        other.name == name &&
        other.brand == brand &&
        other.barcode == barcode;
  }

  @override
  int get hashCode {
    return id.hashCode ^ name.hashCode ^ brand.hashCode ^ barcode.hashCode;
  }

  @override
  String toString() {
    return 'Medicine(id: $id, name: $name, brand: $brand, barcode: $barcode)';
  }

  static Medicine empty() {
    return Medicine(
      id: 0,
      name: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
