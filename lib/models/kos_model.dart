class KosModel {
  final String id;
  final String ownerId;
  final String name;
  final String area;
  final String type; // 'Putra', 'Putri', 'Campur'
  final int pricePerMonth;
  final int availableRooms;
  final List<String> facilities;
  final String contactNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const KosModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.area,
    required this.type,
    required this.pricePerMonth,
    required this.availableRooms,
    required this.facilities,
    required this.contactNumber,
    this.createdAt,
    this.updatedAt,
  });

  bool get isAvailable => availableRooms > 0;

  factory KosModel.fromJson(Map<String, dynamic> json) {
    return KosModel(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      name: json['name'] as String,
      area: json['area'] as String,
      type: json['type'] as String,
      pricePerMonth: (json['price_per_month'] as num).toInt(),
      availableRooms: (json['available_rooms'] as num).toInt(),
      facilities: (json['facilities'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      contactNumber: json['contact_number'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson({bool includeId = true}) {
    final data = <String, dynamic>{
      'owner_id': ownerId,
      'name': name,
      'area': area,
      'type': type,
      'price_per_month': pricePerMonth,
      'available_rooms': availableRooms,
      'facilities': facilities,
      'contact_number': contactNumber,
    };
    if (includeId) {
      data['id'] = id;
    }
    return data;
  }

  KosModel copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? area,
    String? type,
    int? pricePerMonth,
    int? availableRooms,
    List<String>? facilities,
    String? contactNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KosModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      area: area ?? this.area,
      type: type ?? this.type,
      pricePerMonth: pricePerMonth ?? this.pricePerMonth,
      availableRooms: availableRooms ?? this.availableRooms,
      facilities: facilities ?? this.facilities,
      contactNumber: contactNumber ?? this.contactNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
