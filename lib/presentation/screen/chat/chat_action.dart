import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_action.freezed.dart';

@freezed
sealed class ChatAction with _$ChatAction {
  const factory ChatAction.sendMessage(String content) = SendMessage;
}
