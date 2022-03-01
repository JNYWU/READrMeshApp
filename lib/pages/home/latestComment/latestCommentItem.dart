import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_text/extended_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readr/blocs/home/home_bloc.dart';
import 'package:readr/helpers/router/router.dart';
import 'package:readr/models/comment.dart';
import 'package:readr/models/followableItem.dart';
import 'package:readr/models/newsListItem.dart';
import 'package:readr/pages/home/comment/commentBottomSheet.dart';
import 'package:readr/pages/home/newsInfo.dart';
import 'package:readr/pages/shared/followButton.dart';
import 'package:readr/pages/shared/profilePhotoWidget.dart';

class LatestCommentItem extends StatefulWidget {
  final NewsListItem news;
  const LatestCommentItem(this.news);

  @override
  _LatestCommentItemState createState() => _LatestCommentItemState();
}

class _LatestCommentItemState extends State<LatestCommentItem> {
  late MemberFollowableItem memberFollowableItem;

  @override
  void initState() {
    super.initState();
    memberFollowableItem = MemberFollowableItem(
      widget.news.showComment!.member,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Color.fromRGBO(0, 9, 40, 0.1), width: 1),
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              AutoRouter.of(context).push(NewsStoryRoute(
                news: widget.news,
              ));
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.news.heroImageUrl != null)
                  CachedNetworkImage(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width / 2,
                    imageUrl: widget.news.heroImageUrl!,
                    placeholder: (context, url) => Container(
                      color: Colors.grey,
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey,
                      child: const Icon(Icons.error),
                    ),
                    fit: BoxFit.cover,
                  ),
                if (widget.news.source != null)
                  Padding(
                    padding:
                        const EdgeInsets.only(top: 12, left: 12, right: 12),
                    child: Text(
                      widget.news.source!.title,
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 14),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 4, left: 12, right: 12, bottom: 8),
                  child: Text(
                    widget.news.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 12, right: 12, bottom: 16),
                  child: NewsInfo(widget.news),
                ),
              ],
            ),
          ),
          const Divider(
            indent: 12,
            endIndent: 12,
            color: Colors.black12,
            height: 1,
            thickness: 1,
          ),
          GestureDetector(
            onTap: () async {
              await CommentBottomSheet.showCommentBottomSheet(
                context: context,
                clickComment: widget.news.showComment!,
                storyId: widget.news.id,
              );
            },
            child: _commentsWidget(context, widget.news.showComment!),
          ),
        ],
      ),
    );
  }

  Widget _commentsWidget(BuildContext context, Comment comment) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(top: 16, right: 20, left: 20, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              AutoRouter.of(context)
                  .push(PersonalFileRoute(viewMember: comment.member));
            },
            child: Row(
              children: [
                ProfilePhotoWidget(
                  comment.member,
                  22,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comment.member.nickname,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '@${comment.member.customId}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                FollowButton(
                  memberFollowableItem,
                  onTap: (bool isFollowing) =>
                      context.read<HomeBloc>().add(RefreshHomeScreen()),
                  whenFailed: (bool isFollowing) =>
                      context.read<HomeBloc>().add(RefreshHomeScreen()),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 52, top: 8.5, bottom: 20),
            child: ExtendedText(
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
                          color: Colors.black54,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}