import 'package:go_router/go_router.dart';
import 'package:flutter_recipe_app/presentation/screen/chat/chat_screen_root.dart';

final router = GoRouter(
  initialLocation: '/chat/1',
  routes: [
    GoRoute(
      path: '/chat/:roomId',
      builder: (context, state) =>
          ChatScreenRoot(roomId: state.pathParameters['roomId']!),
    ),
  ],
);
