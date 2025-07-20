import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/data/data_source/recipe_data_source_impl.dart';
import 'package:flutter_recipe_app/data/repository/recipe_repository_impl.dart';
import 'package:flutter_recipe_app/presentation/component/card/recipe_card.dart';
import 'package:flutter_recipe_app/presentation/component/search_text_field.dart';
import 'package:flutter_recipe_app/presentation/screen/search/search_view_model.dart';

void main() {
  final searchViewModel = SearchViewModel(
    recipeRepository: RecipeRepositoryImpl(
      RecipeDataSourceImpl(
        baseUrl:
            'https://raw.githubusercontent.com/junsuk5/mock_json/refs/heads/main',
      ),
    ),
  );
  // 초기 데이터 로드를 위해 빈 문자열로 검색 실행
  searchViewModel.fetchSearchResult('');

  runApp(
    MaterialApp(
      home: ListenableBuilder(
        listenable: searchViewModel,
        builder: (context, child) {
          // ViewModel을 화면에 주입
          return SearchViewScreen(
            viewModel: searchViewModel,
          );
        },
      ),
    ),
  );
}

// StatelessWidget으로 변경
class SearchViewScreen extends StatelessWidget {
  final SearchViewModel viewModel;

  const SearchViewScreen({
    super.key,
    required this.viewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            SizedBox(
              width: 30,
              height: 30,
              child: Icon(Icons.arrow_back),
            ),
            Expanded(
              child: Text(
                'Search recipes',
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(
              width: 30,
              height: 30,
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final state = viewModel.state;

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (state.errorMessage.isNotEmpty) {
      return Column(
        children: [
          SearchTextField(viewModel: viewModel),
          Center(
            child: Text(state.errorMessage),
          ),
        ],
      );
    }

    return Column(
      children: [
        SearchTextField(viewModel: viewModel),

        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 두 열로 설정
              crossAxisSpacing: 8.0, // 열 간 간격
              mainAxisSpacing: 8.0, // 행 간 간격
              childAspectRatio: 0.75, // 카드의 가로세로 비율 조정
            ),
            itemCount: state.recipes.length,
            itemBuilder: (context, index) {
              final recipe = state.recipes[index];
              return RecipeCard(recipe: recipe);
            },
          ),
        ),
      ],
    );
  }
}
