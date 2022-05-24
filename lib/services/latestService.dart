import 'dart:convert';

import 'package:get/get.dart';
import 'package:readr/getxServices/environmentService.dart';
import 'package:readr/getxServices/sharedPreferencesService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/helpers/apiBaseHelper.dart';
import 'package:readr/models/graphqlBody.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/publisher.dart';

abstract class LatestRepos {
  Future<List<NewsListItem>> fetchLatestNews({DateTime? lastNewsPublishTime});
  Future<List<NewsListItem>> fetchMoreLatestNews();
  Future<List<Publisher>> fetchRecommendPublishers();
}

class LatestService implements LatestRepos {
  final ApiBaseHelper _helper = ApiBaseHelper();
  final String _api = Get.find<EnvironmentService>().config.readrMeshApi;
  DateTime _earliestNewsPublishTime = DateTime.now();

  @override
  Future<List<NewsListItem>> fetchLatestNews(
      {DateTime? lastNewsPublishTime}) async {
    const String query = """
    query(
      \$followingPublisherIds: [ID!]
      \$timeFilter: DateTime
      \$followingMembers: [ID!]
      \$myId: ID
      \$lastNewsPublishTime: DateTime
    ){
      stories(
        take: 60
        orderBy:{
          published_date: desc
        }
        where:{
          is_active:{
            equals: true
          }
          source:{
            id:{
              in: \$followingPublisherIds
            }
          }
          published_date:{
            lt: \$lastNewsPublishTime
            gte: \$timeFilter
          }
        }
      ){
        id
        title
        url
        source{
          id
          title
        }
        full_content
        full_screen_ad
        paywall
        published_date
        og_image
        followingPicks: pick(
          where:{
            member:{
              id:{
                in: \$followingMembers
              }
            }
            state:{
              equals: "public"
            }
            kind:{
              equals: "read"
            }
            is_active:{
              equals: true
            }
          }
          orderBy:{
            picked_date: desc
          }
          take: 4
        ){
          member{
            id
            nickname
            avatar
            customId
          }
        }
        otherPicks:pick(
          where:{
            member:{
              id:{
                notIn: \$followingMembers
                not:{
                  equals: \$myId
                }
              }
            }
            state:{
              in: "public"
            }
            kind:{
              equals: "read"
            }
            is_active:{
              equals: true
            }
          }
          orderBy:{
            picked_date: desc
          }
          take: 4
        ){
          member{
            id
            nickname
            avatar
            customId
          }
        }
        pickCount(
          where:{
            state:{
              in: "public"
            }
            is_active:{
              equals: true
            }
          }
        )
        commentCount(
          where:{
            state:{
              in: "public"
            }
            is_active:{
              equals: true
            }
          }
        )
        myPickId: pick(
          where:{
            member:{
              id:{
                equals: \$myId
              }
            }
            state:{
              notIn: "private"
            }
            kind:{
              equals: "read"
            }
            is_active:{
              equals: true
            }
          }
        ){
          id
          pick_comment(
            where:{
              is_active:{
                equals: true
              }
            }
          ){
            id
          }
        }
      }
    }
    """;

    int duration =
        Get.find<SharedPreferencesService>().prefs.getInt('newsCoverage') ?? 24;
    //GQL DateTime must be Iso8601 format
    String timeFilter = DateTime.now()
        .subtract(Duration(hours: duration))
        .toUtc()
        .toIso8601String();

    List<String> followingMemberIds = [];
    List<String> followingPublisherIds = [];

    for (var memberId in Get.find<UserService>().currentUser.following) {
      followingMemberIds.add(memberId.memberId);
    }

    for (var publisher
        in Get.find<UserService>().currentUser.followingPublisher) {
      followingPublisherIds.add(publisher.id);
    }

    Map<String, dynamic> variables = {
      "followingMembers": followingMemberIds,
      "followingPublisherIds": followingPublisherIds,
      "myId": Get.find<UserService>().currentUser.memberId,
      "timeFilter": timeFilter,
      "lastNewsPublishTime": lastNewsPublishTime?.toUtc().toIso8601String() ??
          DateTime.now().toUtc().toIso8601String()
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    jsonResponse = await _helper.postByUrl(
      _api,
      jsonEncode(graphqlBody.toJson()),
      headers: {"Content-Type": "application/json"},
    );

    List<NewsListItem> allLatestNews = [];
    if (jsonResponse['data']['stories'].isNotEmpty) {
      for (var item in jsonResponse['data']['stories']) {
        allLatestNews.add(NewsListItem.fromJson(item));
      }
      _earliestNewsPublishTime = allLatestNews.last.publishedDate;
      // allLatestNews
      //     .sort((a, b) => b.publishedDate.hour.compareTo(a.publishedDate.hour));
    }

    return allLatestNews;
  }

  @override
  Future<List<NewsListItem>> fetchMoreLatestNews() async {
    return await fetchLatestNews(lastNewsPublishTime: _earliestNewsPublishTime);
  }

  @override
  Future<List<Publisher>> fetchRecommendPublishers() async {
    const String query = """
    query(
      \$followingPublisherIds: [ID!]
      \$readrId: ID
      \$followingMembers: [ID!]
    ){
      publishers(
        where:{
          id:{
            notIn: \$followingPublisherIds
            not:{
              equals: \$readrId
            }
          }
        }
        take: 20
      ){
        id
        title
        logo
        follower(
          where:{
            id:{
              in: \$followingMembers
            }
            is_active:{
              equals: true
            }
          }
          take: 1
        ){
          id
          nickname
          customId
        }
        followerCount(
          where:{
            is_active:{
              equals: true
            }
          }
        )
      }
    }
    """;

    List<String> followingMemberIds = [];
    List<String> followingPublisherIds = [];

    for (var memberId in Get.find<UserService>().currentUser.following) {
      followingMemberIds.add(memberId.memberId);
    }

    for (var publisher
        in Get.find<UserService>().currentUser.followingPublisher) {
      followingPublisherIds.add(publisher.id);
    }

    Map<String, dynamic> variables = {
      "followingMembers": followingMemberIds,
      "followingPublisherIds": followingPublisherIds,
      "readrId": Get.find<EnvironmentService>().config.readrPublisherId,
    };

    GraphqlBody graphqlBody = GraphqlBody(
      operationName: null,
      query: query,
      variables: variables,
    );

    late final dynamic jsonResponse;
    jsonResponse = await _helper.postByUrl(
      _api,
      jsonEncode(graphqlBody.toJson()),
      headers: {"Content-Type": "application/json"},
    );

    List<Publisher> recommendedPublishers = [];
    if (jsonResponse['data']['publishers'].isNotEmpty) {
      for (var publisher in jsonResponse['data']['publishers']) {
        recommendedPublishers.add(Publisher.fromJson(publisher));
      }
    }

    return recommendedPublishers;
  }
}