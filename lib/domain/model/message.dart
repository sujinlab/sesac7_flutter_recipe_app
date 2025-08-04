import 'package:freezed_annotation/freezed_annotation.dart';

part 'message.freezed.dart';

@freezed
sealed class MessageStatus with _$MessageStatus {
  const factory MessageStatus.sending() = Sending;
  const factory MessageStatus.sent() = Sent;
  const factory MessageStatus.failed() = Failed;
  const factory MessageStatus.incoming() = Incoming;
}

@freezed
abstract class Message with _$Message {
  const factory Message({
    required String id,
    required String content,
    required String senderId,
    required int timestamp,
    required MessageStatus status,
  }) = _Message;
}
