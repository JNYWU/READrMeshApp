import 'package:get/get.dart';
import 'package:readr/controller/community/communityPageController.dart';
import 'package:readr/controller/community/recommendMemberBlockController.dart';
import 'package:readr/controller/latest/latestPageController.dart';
import 'package:readr/controller/latest/recommendPublisherBlockController.dart';
import 'package:readr/controller/mainAppBarController.dart';
import 'package:readr/controller/notify/notifyPageController.dart';
import 'package:readr/controller/rootPageController.dart';
import 'package:readr/controller/wallet/walletPageController.dart';
import 'package:readr/services/community_service.dart';
import 'package:readr/services/invitationCodeService.dart';
import 'package:readr/services/latestService.dart';
import 'package:readr/services/notifyService.dart';

import 'proxyServerApiHelper.dart';

class InitControllerBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(RootPageController(), permanent: true);
    Get.put(RecommendMemberBlockController(), permanent: true);
    Get.put(CommunityPageController(CommunityService()), permanent: true);
    Get.put(RecommendPublisherBlockController(LatestService()),
        permanent: true);
    Get.put(LatestPageController(LatestService()), permanent: true);
    Get.put(MainAppBarController(InvitationCodeService()), permanent: true);
    Get.put(NotifyPageController(NotifyService()), permanent: true);
    Get.put(WalletPageController(), permanent: true);
    Get.put(ProxyServerApiHelper.instance);
  }
}
