import 'package:json_annotation/json_annotation.dart';

part 'message_dto.g.dart';

@JsonSerializable()
class MessageDto {
  final String id;
  final String content;
  final String senderId;
  final int timestamp;
  MessageDto({
    required this.id,
    required this.content,
    required this.senderId,
    required this.timestamp,
  });
  factory MessageDto.fromJson(Map<String, dynamic> json) =>
      _$MessageDtoFromJson(json);
  Map<String, dynamic> toJson() => _$MessageDtoToJson(this);
}
