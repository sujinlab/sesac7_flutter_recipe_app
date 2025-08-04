import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_recipe_app/domain/model/message.dart';

part 'chat_state.freezed.dart';

@freezed
abstract class ChatState with _$ChatState {
  const factory ChatState({
    @Default([]) List<Message> messages,
    @Default(false) bool isLoading,
    @Default('') String currentUserId,
    String? errorMessage,
  }) = _ChatState;
}
