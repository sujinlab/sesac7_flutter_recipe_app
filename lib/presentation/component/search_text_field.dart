import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/presentation/screen/search/search_view_model.dart';

class SearchTextField extends StatefulWidget {
  final SearchViewModel viewModel;

  const SearchTextField({super.key, required this.viewModel});

  @override
  _SearchTextFieldState createState() => _SearchTextFieldState();
}

class _SearchTextFieldState extends State<SearchTextField> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _textController.text = widget.viewModel.state.keyword;
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        key: const ValueKey('search_text_field'),
        controller: _textController,
        focusNode: _focusNode,
        onChanged: (text) {
          widget.viewModel.onKeywordChanged(text);
        },
        decoration: const InputDecoration(
          hintText: '레시피 검색...',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
