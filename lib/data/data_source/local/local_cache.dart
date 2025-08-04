import 'package:flutter_recipe_app/domain/model/message.dart';

class LocalCache {
  final Map<String, Message> _messages = {};
  List<Message> getAllMessages() {
    return _messages.values.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  void saveMessage(Message message) {
    _messages[message.id] = message;
  }

  void updateMessageStatus(String messageId, MessageStatus status) {
    final message = _messages[messageId];
    if (message != null) {
      _messages[messageId] = message.copyWith(status: status);
    }
  }

  void clearCache() {
    _messages.clear();
  }
}
