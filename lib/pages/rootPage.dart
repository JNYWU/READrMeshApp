import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:readr/blocs/config/bloc.dart';
import 'package:readr/blocs/config/events.dart';
import 'package:readr/blocs/config/states.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/helpers/updateMessages.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/pages/readr/readrSkeletonScreen.dart';
import 'package:upgrader/upgrader.dart';

class RootPage extends StatefulWidget {
  @override
  _RootPageState createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {
  @override
  void initState() {
    _loadingConfig();
    super.initState();
  }

  _loadingConfig() async {
    context.read<ConfigBloc>().add(LoadingConfig(context));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConfigBloc, ConfigState>(
        builder: (BuildContext context, ConfigState state) {
      if (state is ConfigError) {
        final error = state.error;
        print('ConfigError: ${error.message}');
        return ErrorPage(error: error, onPressed: () => _loadingConfig());
      }
      if (state is ConfigLoaded) {
        return UpgradeAlert(
          minAppVersion: state.minAppVersion,
          messages: UpdateMessages(),
          dialogStyle: Platform.isAndroid
              ? UpgradeDialogStyle.material
              : UpgradeDialogStyle.cupertino,
          child: AutoTabsScaffold(
            routes: const [ReadrRouter(), MemberCenterRouter()],
            bottomNavigationBuilder: (_, tabsRouter) {
              return BottomNavigationBar(
                elevation: 10,
                backgroundColor: Colors.white,
                currentIndex: tabsRouter.activeIndex,
                onTap: tabsRouter.setActiveIndex,
                selectedItemColor: bottomNavigationBarSelectedColor,
                unselectedItemColor: bottomNavigationBarUnselectedColor,
                items: [
                  BottomNavigationBarItem(
                    icon: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: SvgPicture.asset(
                        logoSimplifySvg,
                        width: 18,
                        height: 18,
                        color: tabsRouter.activeIndex == 0
                            ? bottomNavigationBarSelectedColor
                            : bottomNavigationBarUnselectedColor,
                      ),
                    ),
                    label: 'READr',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(
                      Icons.person_outline_outlined,
                      size: 21,
                    ),
                    label: '會員中心',
                  ),
                ],
              );
            },
          ),
        );
      }

      // state is Init, loading, or other
      return ReadrSkeletonScreen();
    });
  }
}