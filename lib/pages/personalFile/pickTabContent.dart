import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:readr/blocs/personalFileTab/personalFileTab_bloc.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/member.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/models/pick.dart';
import 'package:readr/pages/errorPage.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/pages/personalFile/pickCommentItem.dart';
import 'package:readr/pages/shared/latestNewsItem.dart';
import 'package:visibility_detector/visibility_detector.dart';

class PickTabContent extends StatefulWidget {
  final Member viewMember;
  const PickTabContent({required this.viewMember});
  @override
  _PickTabContentState createState() => _PickTabContentState();
}

class _PickTabContentState extends State<PickTabContent> {
  List<Pick> _storyPickList = [];
  bool _isLoading = false;
  bool _isNoMore = false;
  @override
  void initState() {
    super.initState();
    _fetchPickData();
  }

  _fetchPickData() async {
    context.read<PersonalFileTabBloc>().add(FetchTabContent(
          viewMember: widget.viewMember,
          tabContentType: TabContentType.pick,
        ));
  }

  _loadMore() {
    _isLoading = true;
    context
        .read<PersonalFileTabBloc>()
        .add(LoadMore(lastPickTime: _storyPickList.last.pickedDate));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PersonalFileTabBloc, PersonalFileTabState>(
      listener: (context, state) {
        if (state is PersonalFileTabLoadMoreFailed ||
            state is PersonalFileTabReloadFailed) {
          _isLoading = false;
          Fluttertoast.showToast(
            msg: "載入失敗",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
            fontSize: 16.0,
          );
        }
      },
      builder: (context, state) {
        if (state is PersonalFileTabError) {
          final error = state.error;
          print('PickTabError: ${error.message}');

          return ErrorPage(
            error: error,
            onPressed: () => _fetchPickData(),
            hideAppbar: true,
          );
        }

        if (state is PersonalFileTabLoadingMore) {
          return _buildContent();
        }

        if (state is PersonalFileTabLoadMoreSuccess) {
          if (state.data != null && state.data!['storyPickList'].isNotEmpty) {
            _storyPickList.addAll(state.data!['storyPickList']);
            if (state.data!['storyPickList'].length < 10) {
              _isNoMore = true;
            }
          }
          _isLoading = false;
          return _buildContent();
        }

        if (state is PersonalFileTabLoaded) {
          if (state.data != null && state.data!['storyPickList'].isNotEmpty) {
            _storyPickList = state.data!['storyPickList'];
            if (_storyPickList.length < 10) {
              _isNoMore = true;
            }
            return _buildContent();
          } else {
            return _emptyWidget();
          }
        }

        return const Center(
          child: CircularProgressIndicator.adaptive(),
        );
      },
    );
  }

  Widget _emptyWidget() {
    bool isMine =
        UserHelper.instance.currentUser.memberId == widget.viewMember.memberId;
    return Container(
      color: homeScreenBackgroundColor,
      child: Center(
        child: Text(
          isMine ? '這裡還空空的\n趕緊將喜愛的新聞加入精選吧' : '這個人還沒有精選新聞',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black26,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(0),
      shrinkWrap: true,
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
          child: const Text(
            '精選文章',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        _buildPickStoryList(),
      ],
    );
  }

  Widget _buildPickStoryList() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemBuilder: (context, index) {
        if (index == _storyPickList.length) {
          if (_isNoMore) {
            return Container();
          }

          return VisibilityDetector(
            key: const Key('pickTab'),
            onVisibilityChanged: (visibilityInfo) {
              var visiblePercentage = visibilityInfo.visibleFraction * 100;
              if (visiblePercentage > 50 && !_isLoading) _loadMore();
            },
            child: const Center(
              child: CircularProgressIndicator.adaptive(),
            ),
          );
        }

        if (_storyPickList[index].pickComment != null) {
          return Column(
            children: [
              InkWell(
                onTap: () {
                  AutoRouter.of(context).push(NewsStoryRoute(
                    news: _storyPickList[index].story!,
                  ));
                },
                child: LatestNewsItem(
                  _storyPickList[index].story!,
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              PickCommentItem(
                comment: _storyPickList[index].pickComment!,
                isMyComment: UserHelper.instance.currentUser.memberId ==
                    widget.viewMember.memberId,
              ),
            ],
          );
        }
        return InkWell(
          onTap: () {
            AutoRouter.of(context).push(NewsStoryRoute(
              news: _storyPickList[index].story!,
            ));
          },
          child: LatestNewsItem(
            _storyPickList[index].story!,
          ),
        );
      },
      separatorBuilder: (context, index) {
        if (index == _storyPickList.length - 1) {
          return const SizedBox(
            height: 36,
          );
        }
        return const Padding(
          padding: EdgeInsets.only(top: 16, bottom: 20),
          child: Divider(
            color: Colors.black12,
            thickness: 1,
            height: 1,
          ),
        );
      },
      itemCount: _storyPickList.length + 1,
    );
  }
}
