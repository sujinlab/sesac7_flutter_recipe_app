import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/di/di_setup.dart';
import 'package:flutter_recipe_app/domain/model/message.dart';
import 'package:flutter_recipe_app/presentation/screen/chat/chat_event.dart';
import 'package:flutter_recipe_app/presentation/screen/chat/chat_screen.dart';
import 'package:flutter_recipe_app/presentation/screen/chat/chat_view_model.dart';

class ChatScreenRoot extends StatefulWidget {
  final String roomId;
  const ChatScreenRoot({super.key, required this.roomId});
  @override
  State<ChatScreenRoot> createState() => _ChatScreenRootState();
}

class _ChatScreenRootState extends State<ChatScreenRoot> {
  late final ChatViewModel viewModel;
  StreamSubscription<ChatEvent>? _eventSubscription;
  final _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    viewModel = getIt<ChatViewModel>();
    viewModel.openChatRoom(widget.roomId);
    _eventSubscription = viewModel.eventStream.listen((event) {
      if (mounted) {
        switch (event) {
          case ShowSnackbar(:final message):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
        }
      }
    });
    viewModel.addListener(_scrollToBottom);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    viewModel.removeListener(_scrollToBottom);
    viewModel.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, child) {
        return ChatScreen(
          state: viewModel.state,
          onAction: viewModel.onAction,
          scrollController: _scrollController,
        );
      },
    );
  }
}
