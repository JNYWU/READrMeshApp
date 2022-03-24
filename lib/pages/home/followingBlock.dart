import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:readr/blocs/home/home_bloc.dart';
import 'package:readr/helpers/dataConstants.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/helpers/userHelper.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/followableItem.dart';
import 'package:readr/models/member.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/models/pickableItem.dart';
import 'package:readr/pages/home/comment/commentBottomSheet.dart';
import 'package:readr/pages/shared/newsInfo.dart';
import 'package:readr/pages/home/recommendFollow/recommendFollowItem.dart';
import 'package:readr/pages/shared/profilePhotoStack.dart';
import 'package:readr/pages/shared/profilePhotoWidget.dart';
import 'package:readr/pages/shared/timestamp.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FollowingBlock extends StatelessWidget {
  final List<NewsListItem> followingStories;
  final bool isLoadingMore;
  final bool loadingMoreFinish;
  final List<MemberFollowableItem> recommendedMembers;
  const FollowingBlock(
    this.followingStories,
    this.isLoadingMore,
    this.recommendedMembers,
    this.loadingMoreFinish,
  );

  @override
  Widget build(BuildContext context) {
    if (UserHelper.instance.currentUser.following.isEmpty) {
      return Container(
        color: Colors.white,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(87.5, 22, 87.5, 26),
              child: SvgPicture.asset(noFollowingSvg),
            ),
            const Text(
              '咦？這裡好像還缺點什麼...',
              style: TextStyle(
                color: readrBlack87,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            RichText(
              text: const TextSpan(
                  text: '追蹤您喜愛的人\n看看他們都精選了什麼新聞',
                  style: TextStyle(
                    color: readrBlack50,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    TextSpan(
                      text: ' 👀',
                      style: TextStyle(
                        fontSize: 16,
                        color: readrBlack,
                        fontWeight: FontWeight.w400,
                      ),
                    )
                  ]),
              textAlign: TextAlign.center,
            ),
            if (recommendedMembers.isNotEmpty) ...[
              const SizedBox(
                height: 32,
              ),
              SizedBox(
                height: 230,
                child: ListView.separated(
                  padding: const EdgeInsets.only(left: 20),
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (context, index) =>
                      RecommendFollowItem(recommendedMembers[index]),
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 12),
                  itemCount: recommendedMembers.length,
                ),
              ),
            ],
            const SizedBox(
              height: 16,
            ),
          ],
        ),
      );
    } else if (followingStories.isEmpty) {
      return Container();
    }
    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        color: homeScreenBackgroundColor,
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(0),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            if (index == 5 &&
                followingStories.length == 6 &&
                !loadingMoreFinish) {
              return _loadMoreWidget(context, followingStories[index]);
            }
            return _followingItem(context, followingStories[index]);
          },
          separatorBuilder: (context, index) => const SizedBox(height: 8.5),
          itemCount: followingStories.length,
        ),
      ),
    );
  }

  Widget _loadMoreWidget(BuildContext context, NewsListItem item) {
    List<String> alreadyFetchIds = [];
    for (var item in followingStories) {
      alreadyFetchIds.add(item.id);
    }
    return Stack(
      children: [
        Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _pickBar(context, item.followingPickMembers),
              if (item.heroImageUrl != null)
                CachedNetworkImage(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.width / 2,
                  imageUrl: item.heroImageUrl!,
                  placeholder: (context, url) => Container(
                    color: Colors.grey,
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey,
                    child: const Icon(Icons.error),
                  ),
                  fit: BoxFit.cover,
                ),
              Padding(
                padding: const EdgeInsets.only(top: 12, left: 20, right: 20),
                child: Text(
                  item.source.title,
                  style: const TextStyle(color: readrBlack50, fontSize: 14),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    top: 4, left: 20, right: 20, bottom: 8),
                child: Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: readrBlack87,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                child: NewsInfo(item),
              ),
            ],
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.white24,
                  Colors.white54,
                  Colors.white70,
                ],
                stops: [0.12, 0.12, 0.8, 0.9],
              ),
            ),
            alignment: Alignment.bottomCenter,
            padding: const EdgeInsets.only(bottom: 24),
            child: ElevatedButton(
              onPressed: () {
                context.read<HomeBloc>().add(LoadMoreFollowingPicked(
                      item.latestPickTime!,
                      alreadyFetchIds,
                    ));
              },
              style: ElevatedButton.styleFrom(
                primary: readrBlack,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
              ),
              child: isLoadingMore
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      '展開所有',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _followingItem(BuildContext context, NewsListItem item) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pickBar(context, item.followingPickMembers),
          InkWell(
            onTap: () {
              AutoRouter.of(context).push(NewsStoryRoute(
                news: item,
              ));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.heroImageUrl != null)
                  CachedNetworkImage(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width / 2,
                    imageUrl: item.heroImageUrl!,
                    placeholder: (context, url) => Container(
                      color: Colors.grey,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey,
                      child: const Icon(Icons.error),
                    ),
                    fit: BoxFit.cover,
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 12, left: 20, right: 20),
                  child: Text(
                    item.source.title,
                    style: const TextStyle(color: readrBlack50, fontSize: 14),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 4, left: 20, right: 20, bottom: 8),
                  child: Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: readrBlack87,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                  child: NewsInfo(item),
                ),
              ],
            ),
          ),
          if (item.showComment != null) ...[
            const Divider(
              indent: 20,
              endIndent: 20,
              color: readrBlack10,
              height: 1,
              thickness: 1,
            ),
            InkWell(
              onTap: () async {
                await CommentBottomSheet.showCommentBottomSheet(
                  context: context,
                  clickComment: item.showComment!,
                  item: NewsListItemPick(item),
                );
              },
              child: _commentsWidget(context, item.showComment!),
            ),
          ]
        ],
      ),
    );
  }

  Widget _pickBar(BuildContext context, List<Member> members) {
    if (members.isEmpty) {
      return Container();
    }
    List<Member> firstTwoMember = [];
    for (int i = 0; i < members.length && i < 2; i++) {
      firstTwoMember.add(members[i]);
    }

    List<Widget> children = [
      ProfilePhotoStack(firstTwoMember, 14),
      const SizedBox(width: 8),
    ];
    if (firstTwoMember.length == 1) {
      children.add(Flexible(
        child: GestureDetector(
          onTap: () {
            AutoRouter.of(context)
                .push(PersonalFileRoute(viewMember: firstTwoMember[0]));
          },
          child: ExtendedText(
            firstTwoMember[0].nickname,
            joinZeroWidthSpace: true,
            style: const TextStyle(fontSize: 14, color: readrBlack87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ));
      children.add(const Text(
        '精選了這篇',
        style: TextStyle(fontSize: 14, color: readrBlack50),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ));
    } else {
      children.add(Flexible(
        child: GestureDetector(
          onTap: () {
            AutoRouter.of(context)
                .push(PersonalFileRoute(viewMember: firstTwoMember[0]));
          },
          child: ExtendedText(
            firstTwoMember[0].nickname,
            joinZeroWidthSpace: true,
            style: const TextStyle(fontSize: 14, color: readrBlack87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ));
      children.add(const Text(
        '及',
        style: TextStyle(fontSize: 14, color: readrBlack50),
        maxLines: 1,
      ));
      children.add(Flexible(
        child: GestureDetector(
          onTap: () {
            AutoRouter.of(context)
                .push(PersonalFileRoute(viewMember: firstTwoMember[1]));
          },
          child: ExtendedText(
            firstTwoMember[1].nickname,
            joinZeroWidthSpace: true,
            style: const TextStyle(fontSize: 14, color: readrBlack87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ));
      children.add(const Text(
        '都精選了這篇',
        style: TextStyle(fontSize: 14, color: readrBlack50),
        maxLines: 1,
      ));
    }

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: children,
      ),
    );
  }

  Widget _commentsWidget(BuildContext context, Comment comment) {
    return Container(
      padding: const EdgeInsets.only(top: 16, right: 20, left: 20),
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              AutoRouter.of(context)
                  .push(PersonalFileRoute(viewMember: comment.member));
            },
            child: ProfilePhotoWidget(
              comment.member,
              22,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: GestureDetector(
                        onTap: () {
                          AutoRouter.of(context).push(PersonalFileRoute(
                            viewMember: comment.member,
                          ));
                        },
                        child: ExtendedText(
                          comment.member.nickname,
                          maxLines: 1,
                          joinZeroWidthSpace: true,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: readrBlack87,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 2,
                      margin: const EdgeInsets.fromLTRB(4.0, 1.0, 4.0, 0.0),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: readrBlack20,
                      ),
                    ),
                    Timestamp(comment.publishDate),
                  ],
                ),
                const SizedBox(height: 8.5),
                ExtendedText(
                  comment.content,
                  maxLines: 2,
                  style: const TextStyle(
                    color: Color.fromRGBO(0, 9, 40, 0.66),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  joinZeroWidthSpace: true,
                  overflowWidget: TextOverflowWidget(
                    position: TextOverflowPosition.end,
                    child: RichText(
                      text: const TextSpan(
                        text: '... ',
                        style: TextStyle(
                          color: Color.fromRGBO(0, 9, 40, 0.66),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        children: [
                          TextSpan(
                            text: '看完整留言',
                            style: TextStyle(
                              color: readrBlack50,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
