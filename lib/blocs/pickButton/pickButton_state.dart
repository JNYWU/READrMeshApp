part of 'pickButton_cubit.dart';

abstract class PickButtonState extends Equatable {
  const PickButtonState();

  @override
  List<Object> get props => [];
}

class PickButtonInitial extends PickButtonState {}

class PickButtonUpdating extends PickButtonState {
  final Comment? comment;
  const PickButtonUpdating({this.comment});
}

class PickButtonUpdateFailed extends PickButtonState {
  final bool originIsPicked;
  const PickButtonUpdateFailed(this.originIsPicked);
}

class PickButtonUpdateSuccess extends PickButtonState {
  final Comment? comment;
  const PickButtonUpdateSuccess({this.comment});
}

class RemovePickAndComment extends PickButtonState {
  final String commentId;
  const RemovePickAndComment(this.commentId);
}
