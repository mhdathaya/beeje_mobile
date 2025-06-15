class Banner {
  final int id;
  final String name;
  final String bannerUrl;
  final String? description;

  Banner({
    required this.id,
    required this.name,
    required this.bannerUrl,
    this.description,
  });

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      id: json['id'],
      name: json['name'],
      bannerUrl: json['banner_url'],
      description: json['description'],
    );
  }
}

class BannerResponse {
  final bool success;
  final List<Banner> data;

  BannerResponse({
    required this.success,
    required this.data,
  });

  factory BannerResponse.fromJson(Map<String, dynamic> json) {
    var bannerList = (json['data'] as List)
        .map((bannerJson) => Banner.fromJson(bannerJson))
        .toList();

    return BannerResponse(
      success: json['success'],
      data: bannerList,
    );
  }
}