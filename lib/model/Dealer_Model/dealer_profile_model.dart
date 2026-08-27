class DealerProfileModel {
  final int? id;
  final String? dealerId;
  final String? name;
  final String? email;
  final String? phone;
  final String? gstNumber;
  final String? businessAddress;
  final String? profile;
  final bool isActive;
  final String? createdAt;

  DealerProfileModel({
    this.id,
    this.dealerId,
    this.name,
    this.email,
    this.phone,
    this.gstNumber,
    this.businessAddress,
    this.profile,
    this.isActive = false,
    this.createdAt,
  });

  factory DealerProfileModel.fromJson(Map<String, dynamic> json) {
    return DealerProfileModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      dealerId: json['dealerID']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      gstNumber: json['gstNumber']?.toString(),
      businessAddress: json['businessAddress']?.toString(),
      profile: json['profile']?.toString(),
      isActive: (json['isActive']?.toString().toLowerCase() == 'true'),
      createdAt: json['createdAt']?.toString(),
    );
  }

  static const String _baseImageUrl = 'https://durvasaayurved.online';

  String get resolvedImageUrl {
    if (profile == null || profile!.trim().isEmpty) return '';
    if (profile!.startsWith('http')) return profile!;
    return '$_baseImageUrl$profile';
  }

  String get formattedCreatedAt {
    if (createdAt == null || createdAt!.trim().isEmpty) return 'Not available';
    try {
      final date = DateTime.parse(createdAt!);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return createdAt!;
    }
  }
}