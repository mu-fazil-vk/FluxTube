class AppInfoModel {
  AppInfoModel({
    required this.name,
    required this.url,
    required this.description,
    this.nickname,
    this.image,
  });

  final String name;
  final String? nickname;
  final String url;
  final String description;
  final String? image;
}
