import 'package:flutter_recipe_app/data/dto/message_dto.dart';
import 'package:flutter_recipe_app/domain/model/message.dart';

class MessageMapper {
  static Message fromDto(MessageDto dto) => Message(
        id: dto.id,
        content: dto.content,
        senderId: dto.senderId,
        timestamp: dto.timestamp,
        status: const MessageStatus.incoming(),
      );
}
