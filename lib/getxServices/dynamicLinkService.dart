import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:readr/getxServices/sharedPreferencesService.dart';
import 'package:readr/getxServices/userService.dart';
import 'package:readr/pages/loginMember/inputNamePage.dart';
import 'package:readr/pages/rootPage.dart';
import 'package:readr/pages/shared/follow/followingSyncToast.dart';
import 'package:readr/services/memberService.dart';
import 'package:readr/services/personalFileService.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DynamicLinkService extends GetxService {
  final _auth = FirebaseAuth.instance;
  Future<DynamicLinkService> initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink.listen((dynamicLink) async {
      final Uri deepLink = dynamicLink.link;

      if (_auth.isSignInWithEmailLink(deepLink.toString())) {
        _loginWithEmailLink(deepLink.toString());
      }
    }).onError((e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData? data =
        await FirebaseDynamicLinks.instance.getInitialLink();
    final Uri? deepLink = data?.link;

    if (deepLink != null) {
      if (_auth.isSignInWithEmailLink(deepLink.toString())) {
        _loginWithEmailLink(deepLink.toString());
      }
    }

    return this;
  }

  _loginWithEmailLink(String emailLink) async {
    SharedPreferences prefs = Get.find<SharedPreferencesService>().prefs;
    String email = prefs.getString('signInEmail') ?? "";

    // The client SDK will parse the code from the link for you.
    _auth
        .signInWithEmailLink(email: email, emailLink: emailLink)
        .then((value) async {
      // You can access the new user via value.user
      // Additional user info profile *not* available via:
      // value.additionalUserInfo.profile == null
      // You can check if the user is new or existing:
      // value.additionalUserInfo.isNewUser;

      print('Successfully signed in with email link!');
      await prefs.setString('loginType', 'email');
      if (value.additionalUserInfo!.isNewUser) {
        List<String> publisherTitleList = await _fetchPublisherTitles();
        Get.to(() => InputNamePage(publisherTitleList));
      } else {
        var result = await MemberService().fetchMemberData();
        if (result != null) {
          Fluttertoast.showToast(
            msg: "登入成功",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            fontSize: 16.0,
          );
          final List<String> followingPublisherIds =
              prefs.getStringList('followingPublisherIds') ?? [];
          if (followingPublisherIds.isNotEmpty) {
            Fluttertoast.showToast(
              msg: "同步追蹤清單中",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              fontSize: 16.0,
            );
            await Get.find<UserService>()
                .addVisitorFollowing(followingPublisherIds)
                .timeout(
              const Duration(minutes: 1),
              onTimeout: () {
                Get.find<UserService>().fetchUserData(member: result);
              },
            );
          } else {
            Get.find<UserService>().fetchUserData(member: result);
          }

          final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;
          if (isFirstTime) {
            Get.offAll(RootPage());
            await prefs.setBool('isFirstTime', false);
          } else {
            if (Get.currentRoute != '/') {
              Get.until((route) => Get.currentRoute != '/LoginPage');
            }

            if (followingPublisherIds.isNotEmpty) {
              showFollowingSyncToast();
            }
          }
        } else {
          List<String> publisherTitleList = await _fetchPublisherTitles();
          Get.to(() => InputNamePage(publisherTitleList));
        }
      }
    }).catchError((onError) async {
      print('Error signing in with email link $onError');
      Fluttertoast.showToast(
        msg: "登入失敗，請重新登入",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        fontSize: 16.0,
      );
      if (FirebaseAuth.instance.currentUser != null) {
        await FirebaseAuth.instance.signOut();
      }
    });
  }

  Future<List<String>> _fetchPublisherTitles() async {
    var publisherList = await PersonalFileService().fetchAllPublishers();
    List<String> publisherTitleList = [];
    for (var publisher in publisherList) {
      publisherTitleList.add(publisher.title);
    }
    return publisherTitleList;
  }
}
