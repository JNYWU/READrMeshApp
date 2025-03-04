import 'dart:ui';

import 'package:get/get.dart';
import 'package:readr/models/baseModel.dart';

class Category {
  String id;
  String name;
  String slug;
  String? title;
  DateTime? latestPostTime;

  Category({
    required this.id,
    required this.name,
    required this.slug,
    this.title,
    this.latestPostTime,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    DateTime? latestPostTime;
    if (BaseModel.checkJsonKeys(json, ['relatedPost'])) {
      if(json['relatedPost'][0]['publishTime']!=null) {
        latestPostTime =
            DateTime.parse(json['relatedPost'][0]['publishTime']).toLocal();
      }
    }

    String name = json[BaseModel.slugKey];

    if (Get.locale != const Locale('zh', 'TW') ||
        Get.locale != const Locale('zh', 'HK')) {
      switch (json[BaseModel.slugKey]) {
        case 'international':
        case '國際':
          name = 'slugInternational'.tr;
          break;
        case 'culture':
          name = 'slugCulture'.tr;
          break;
        case 'note':
          name = 'slugNote'.tr;
          break;
        case 'data':
          name = 'slugData'.tr;
          break;
        case 'omt':
          name = 'slugOmt'.tr;
          break;
        case 'environment':
          name = 'slugEnvironment'.tr;
          break;
        case 'humanrights':
          name = 'slugHumanRights'.tr;
          break;
        case 'politics':
          name = 'slugPolitics'.tr;
          break;
        case 'education':
          name = 'slugEducation'.tr;
          break;
        case 'breakingnews':
          name = 'slugBreakingNews'.tr;
          break;
      }
    }

    return Category(
      id: json[BaseModel.idKey],
      name: name,
      title: json['title'],
      slug: json[BaseModel.slugKey],
      latestPostTime: latestPostTime,
    );
  }

  factory Category.fromNewProductJson(Map<String, dynamic> json) {
    return Category(
      id: json[BaseModel.idKey],
      name: json['title'],
      slug: json[BaseModel.slugKey],
    );
  }

  Map<String, dynamic> toJson() => {
        BaseModel.idKey: id,
        BaseModel.nameKey: name,
        BaseModel.slugKey: slug,
      };

  bool isLatestCategory() {
    return id == 'latest';
  }

  bool isFeaturedCategory() {
    return id == 'featured';
  }

  static bool checkIsLatestCategoryBySlug(String? slug) {
    return slug == 'latest';
  }

  @override
  int get hashCode => Category(
        id: id,
        name: name,
        slug: slug,
        latestPostTime: latestPostTime,
      ).hashCode;

  @override
  bool operator ==(covariant Category other) {
    // compare this to other
    return id == other.id;
  }
}
