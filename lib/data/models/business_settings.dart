class BusinessSettings {
  final String id;
  final String? businessName;
  final String? address;
  final double taxRate;
  final DateTime? updatedAt;

  BusinessSettings({
    required this.id,
    this.businessName,
    this.address,
    required this.taxRate,
    this.updatedAt,
  });

  factory BusinessSettings.fromJson(Map<String, dynamic> json) {
    return BusinessSettings(
      id: json['id'],
      businessName: json['businessName'],
      address: json['address'],
      taxRate: json['taxRate'] is int
          ? (json['taxRate'] as int).toDouble()
          : double.parse(json['taxRate'].toString()),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'businessName': businessName,
      'address': address,
      'taxRate': taxRate,
    };
  }
}
