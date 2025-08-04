import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/domain/model/message.dart';
import 'package:flutter_recipe_app/presentation/screen/chat/chat_action.dart';
import 'package:flutter_recipe_app/presentation/screen/chat/chat_state.dart';

class ChatScreen extends StatelessWidget {
  final ChatState state;
  final void Function(ChatAction action) onAction;
  final ScrollController scrollController;
  const ChatScreen({
    super.key,
    required this.state,
    required this.onAction,
    required this.scrollController,
  });
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMyMessage = (message) => message.senderId == state.currentUserId;
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅방'),
        centerTitle: true,
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: scrollController,
                    itemCount: state.messages.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final message = state.messages[index];
                      final isMine = isMyMessage(message);
                      return Align(
                        alignment: isMine
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMine
                                ? theme.primaryColor.withOpacity(0.8)
                                : theme.colorScheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: isMine
                                  ? const Radius.circular(16)
                                  : const Radius.circular(4),
                              bottomRight: isMine
                                  ? const Radius.circular(4)
                                  : const Radius.circular(16),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Text(
                                  message.content,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: isMine ? Colors.white : Colors.black,
                                  ),
                                ),
                              ),
                              if (isMine) ...[
                                const SizedBox(width: 8),
                                if (message.status is Sending)
                                  const SizedBox(
                                    width: 12,
                                    height: 12,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                else if (message.status is Failed)
                                  const Icon(
                                    Icons.error_outline,
                                    size: 16,
                                    color: Colors.red,
                                  ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
          _MessageInput(
            onSendMessage: (content) {
              onAction(ChatAction.sendMessage(content));
            },
          ),
        ],
      ),
    );
  }
}

class _MessageInput extends StatefulWidget {
  final void Function(String content) onSendMessage;
  const _MessageInput({required this.onSendMessage});
  @override
  State<_MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<_MessageInput> {
  final TextEditingController _controller = TextEditingController();
  void _handleSendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onSendMessage(_controller.text.trim());
      _controller.clear();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: '메시지를 입력하세요...',
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _handleSendMessage(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _handleSendMessage,
            ),
          ],
        ),
      ),
    );
  }
}
