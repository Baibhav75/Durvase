class BannerModel {
  final bool status;
  final String message;
  final List<BannerItem> data;

  BannerModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      status: json["Status"],
      message: json["Message"],
      data: (json["Data"] as List)
          .map((e) => BannerItem.fromJson(e))
          .toList(),
    );
  }
}

class BannerItem {
  final int bannerId;
  final String imagePath;

  BannerItem({
    required this.bannerId,
    required this.imagePath,
  });

  factory BannerItem.fromJson(Map<String, dynamic> json) {
    return BannerItem(
      bannerId: json["BannerId"],
      imagePath: json["ImagePath"],
    );
  }

  String get imageUrl =>
      "https://durvasaayurved.online$imagePath";
}