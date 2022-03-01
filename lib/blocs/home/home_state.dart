part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeReloading extends HomeState {}

class HomeRefreshing extends HomeState {}

class HomeRefresh extends HomeState {}

class UpdatingFollowing extends HomeState {}

class UpdateRecommendedMembers extends HomeState {
  final List<MemberFollowableItem> recommendedMembers;
  const UpdateRecommendedMembers(this.recommendedMembers);
}

class UpdateRecommendedPublishers extends HomeState {
  final List<PublisherFollowableItem> recommendedPublishers;
  const UpdateRecommendedPublishers(this.recommendedPublishers);
}

class HomeLoaded extends HomeState {
  final List<NewsListItem> allLatestNews;
  final List<NewsListItem> followingStories;
  final List<NewsListItem> latestComments;
  final List<MemberFollowableItem> recommendedMembers;
  final List<PublisherFollowableItem> recommendedPublishers;
  final bool showPaywall;
  final bool showFullScreenAd;
  const HomeLoaded({
    required this.allLatestNews,
    required this.followingStories,
    required this.latestComments,
    required this.recommendedMembers,
    required this.showFullScreenAd,
    required this.showPaywall,
    required this.recommendedPublishers,
  });
}

class HomeError extends HomeState {
  final dynamic error;
  const HomeError(this.error);
}

class HomeReloadFailed extends HomeState {
  final dynamic error;
  const HomeReloadFailed(this.error);
}

class UpdateFollowingFailed extends HomeState {
  final dynamic error;
  const UpdateFollowingFailed(this.error);
}

class LoadingMoreFollowingPicked extends HomeState {}

class LoadMoreFollowingPickedSuccess extends HomeState {
  final List<NewsListItem> newFollowingStories;
  const LoadMoreFollowingPickedSuccess(this.newFollowingStories);
}

class LoadMoreFollowingPickedFailed extends HomeState {
  final dynamic error;
  const LoadMoreFollowingPickedFailed(this.error);
}

class LoadingMoreNews extends HomeState {}

class LoadMoreNewsSuccess extends HomeState {
  final List<NewsListItem> newLatestNews;
  const LoadMoreNewsSuccess(this.newLatestNews);
}

class LoadMoreNewsFailed extends HomeState {
  final dynamic error;
  const LoadMoreNewsFailed(this.error);
}
