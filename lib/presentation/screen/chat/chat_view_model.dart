import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/data/data_source/local/connectivity_service.dart';
import 'package:flutter_recipe_app/data/data_source/local/local_cache.dart';
import 'package:flutter_recipe_app/domain/model/message.dart';
import 'package:flutter_recipe_app/domain/use_case/get_chat_messages_use_case.dart';
import 'package:flutter_recipe_app/domain/use_case/send_message_use_case.dart';
import 'package:flutter_recipe_app/presentation/screen/chat/chat_action.dart';
import 'package:flutter_recipe_app/presentation/screen/chat/chat_event.dart';
import 'package:flutter_recipe_app/presentation/screen/chat/chat_state.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

const bool isMockMode = true;

class ChatViewModel with ChangeNotifier {
  final GetChatMessagesUseCase _getMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final ConnectivityService _connectivityService;
  final LocalCache _localCache;
  final _eventController = StreamController<ChatEvent>.broadcast();
  Stream<ChatEvent> get eventStream => _eventController.stream;
  StreamSubscription? _messageSubscription;
  String _currentRoomId = '';
  ChatViewModel(
    this._getMessagesUseCase,
    this._sendMessageUseCase,
    this._connectivityService,
    this._localCache,
  );
  ChatState _state = const ChatState(currentUserId: 'user123');
  ChatState get state => _state;
  void openChatRoom(String roomId) {
    if (_messageSubscription != null) return;
    _currentRoomId = roomId;
    final cachedMessages = _localCache.getAllMessages();
    _state = state.copyWith(isLoading: true, messages: cachedMessages);
    notifyListeners();

    _messageSubscription = _getMessagesUseCase
        .execute(roomId)
        .listen(
          (newMessages) {
            final List<Message> updatedMessages = List.from(state.messages);
            for (final newMessage in newMessages) {
              final existingIndex = updatedMessages.indexWhere(
                (m) => m.id == newMessage.id,
              );
              if (existingIndex != -1) {
                if (updatedMessages[existingIndex].status is Sending) {
                  updatedMessages[existingIndex] = newMessage.copyWith(
                    status: const MessageStatus.sent(),
                  );
                  _localCache.updateMessageStatus(
                    newMessage.id,
                    const MessageStatus.sent(),
                  );
                }
              } else {
                updatedMessages.add(newMessage);
                _localCache.saveMessage(newMessage);
              }
            }
            updatedMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
            _state = state.copyWith(
              messages: updatedMessages,
              isLoading: false,
            );
            notifyListeners();
          },
          onError: (e) {
            _eventController.add(ChatEvent.showSnackbar('메시지 로드 오류: $e'));
            _state = state.copyWith(isLoading: false);
            notifyListeners();
          },
        );

    if (isMockMode) {
      Future.delayed(Duration(milliseconds: 500), () {
        if (_messageSubscription != null) {
          _state = state.copyWith(isLoading: false);
          notifyListeners();
        }
      });
    }
  }

  void closeChatRoom() {
    _messageSubscription?.cancel();
    _messageSubscription = null;
    _currentRoomId = '';
    _state = const ChatState(currentUserId: 'user123');
    _localCache.clearCache();
    notifyListeners();
  }

  Future<void> onAction(ChatAction action) async {
    switch (action) {
      case SendMessage(:final content):
        final hasConnection = await _connectivityService.hasConnection();
        if (!hasConnection) {
          _eventController.add(const ChatEvent.showSnackbar('오프라인 상태입니다.'));
          return;
        }
        final newMessage = Message(
          id: uuid.v4(),
          content: content,
          senderId: state.currentUserId,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          status: const MessageStatus.sending(),
        );
        final updatedMessages = [...state.messages, newMessage];
        _state = state.copyWith(messages: updatedMessages);
        _localCache.saveMessage(newMessage);
        notifyListeners();
        try {
          await _sendMessageUseCase.execute(_currentRoomId, newMessage);
          final successMessages = state.messages
              .map(
                (m) => m.id == newMessage.id
                    ? m.copyWith(status: const MessageStatus.sent())
                    : m,
              )
              .toList();
          _state = state.copyWith(messages: successMessages);
          _localCache.updateMessageStatus(
            newMessage.id,
            const MessageStatus.sent(),
          );
          notifyListeners();
        } catch (e) {
          _eventController.add(const ChatEvent.showSnackbar('메시지 전송 실패'));
          final errorMessages = state.messages
              .map(
                (m) => m.id == newMessage.id
                    ? m.copyWith(status: const MessageStatus.failed())
                    : m,
              )
              .toList();
          _state = state.copyWith(messages: errorMessages);
          _localCache.updateMessageStatus(
            newMessage.id,
            const MessageStatus.failed(),
          );
          notifyListeners();
        }
    }
  }

  @override
  void dispose() {
    closeChatRoom();
    _eventController.close();
    super.dispose();
  }
}
