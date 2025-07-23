import 'package:flutter_recipe_app/data/repository/recipe_repository.dart';
import '../model/ingredient.dart';
import '../model/recipe.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  @override
  Future<List<Recipe>> getRecipes() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return [
      Recipe(
        id: '1',
        userId: 'user1',
        imageUrl:
            'https://images.unsplash.com/photo-1565299624946-b28f40a0ae38?q=80&w=1981&auto=format&fit=crop',
        recipeName: 'Spicy chicken burger with French fries',
        rating: 4.0,
        cookingTime: '20 min',
        ingredients: [
          Ingredient(
            name: 'Tomatos',
            amount: '500g',
            imageUrl: 'https://placehold.co/40x40/FF6347/FFFFFF?text=T',
          ),
          Ingredient(
            name: 'Cabbage',
            amount: '300g',
            imageUrl: 'https://placehold.co/40x40/90EE90/FFFFFF?text=C',
          ),
          Ingredient(
            name: 'Taco',
            amount: '300g',
            imageUrl: 'https://placehold.co/40x40/F4A460/FFFFFF?text=T',
          ),
          Ingredient(
            name: 'Slice Bread',
            amount: '300g',
            imageUrl: 'https://placehold.co/40x40/DEB887/FFFFFF?text=B',
          ),
        ],
        procedures: [
          'Lorem ipsum tempor incididunt ut labore et dolore,in voluptate velit esse cillum dolore eu fugiat nulla pariatur?',
          'Lorem ipsum tempor incididunt ut labore et dolore,in voluptate velit esse cillum dolore eu fugiat nulla pariatur?',
          'Lorem ipsum tempor incididunt ut labore et dolore,in voluptate velit esse cillum dolore eu fugiat nulla pariatur?',
        ],
      ),
      Recipe(
        id: '2',
        userId: 'user2',
        imageUrl:
            'https://images.unsplash.com/photo-1615937691194-97dbd3f3dc29?q=80&w=1964&auto=format&fit=crop',
        recipeName: 'Traditional spare ribs baked',
        rating: 4.5,
        cookingTime: '30 min',
        ingredients: List.generate(
          6,
          (i) => Ingredient(
            name: 'Chicken Part ${i + 1}',
            amount: '${(i + 1) * 100}g',
            imageUrl:
                'https://placehold.co/100x100/FFF/31343C?text=Chk${i + 1}',
          ),
        ),
        procedures: List.generate(
          5,
          (i) =>
              'Procedure step ${i + 1}: Detailed instructions for roasting the chicken perfectly.',
        ),
      ),
      Recipe(
        id: '5',
        userId: 'user2',
        imageUrl:
            'https://images.unsplash.com/photo-1529042410759-befb1204b468?q=80&w=1972&auto=format&fit=crop',
        recipeName: 'Classic Spaghetti Carbonara',
        rating: 4.9,
        cookingTime: '25 min',
        ingredients: List.generate(
          7,
          (i) => Ingredient(
            name: 'Pasta Ingredient ${i + 1}',
            amount: '${(i + 1) * 20}g',
            imageUrl:
                'https://placehold.co/100x100/FFF/31343C?text=Pst${i + 1}',
          ),
        ),
        procedures: List.generate(
          8,
          (i) =>
              'Carbonara Step ${i + 1}: The secret to authentic Italian carbonara.',
        ),
      ),
      Recipe(
        id: '6',
        userId: 'user3',
        imageUrl:
            'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?q=80&w=1980&auto=format&fit=crop',
        recipeName: 'Fluffy Pancakes',
        rating: 4.6,
        cookingTime: '20 min',
        ingredients: List.generate(
          9,
          (i) => Ingredient(
            name: 'Pancake Mix ${i + 1}',
            amount: '1/2 cup',
            imageUrl:
                'https://placehold.co/100x100/FFF/31343C?text=Pan${i + 1}',
          ),
        ),
        procedures: List.generate(
          6,
          (i) =>
              'Pancake Step ${i + 1}: Get the fluffiest pancakes every time with this tip.',
        ),
      ),
      Recipe(
        id: '7',
        userId: 'user1',
        imageUrl:
            'https://images.unsplash.com/photo-1473093295043-cdd812d0e601?q=80&w=2070&auto=format&fit=crop',
        recipeName: 'Tomato Basil Soup',
        rating: 4.3,
        cookingTime: '35 min',
        ingredients: List.generate(
          5,
          (i) => Ingredient(
            name: 'Soup Item ${i + 1}',
            amount: '1 can',
            imageUrl:
                'https://placehold.co/100x100/FFF/31343C?text=Sup${i + 1}',
          ),
        ),
        procedures: List.generate(
          9,
          (i) =>
              'Soup Step ${i + 1}: A guide to a creamy and delicious tomato soup.',
        ),
      ),
      Recipe(
        id: '8',
        userId: 'user2',
        imageUrl:
            'https://images.unsplash.com/photo-1588195538326-c5b1e9f80a1b?q=80&w=1950&auto=format&fit=crop',
        recipeName: 'Chocolate Lava Cake',
        rating: 4.9,
        cookingTime: '30 min',
        ingredients: List.generate(
          8,
          (i) => Ingredient(
            name: 'Cake Ingredient ${i + 1}',
            amount: '${(i + 1) * 10}g',
            imageUrl:
                'https://placehold.co/100x100/FFF/31343C?text=Cke${i + 1}',
          ),
        ),
        procedures: List.generate(
          10,
          (i) => 'Lava Cake Step ${i + 1}: Achieve the perfect molten center.',
        ),
      ),
      Recipe(
        id: '9',
        userId: 'user3',
        imageUrl:
            'https://images.unsplash.com/photo-1513104890138-7c749659a591?q=80&w=2070&auto=format&fit=crop',
        recipeName: 'Margherita Pizza',
        rating: 4.7,
        cookingTime: '20 min',
        ingredients: List.generate(
          6,
          (i) => Ingredient(
            name: 'Pizza Topping ${i + 1}',
            amount: 'some',
            imageUrl:
                'https://placehold.co/100x100/FFF/31343C?text=Pza${i + 1}',
          ),
        ),
        procedures: List.generate(
          7,
          (i) => 'Pizza Step ${i + 1}: From dough to oven, the complete guide.',
        ),
      ),
      Recipe(
        id: '10',
        userId: 'user1',
        imageUrl:
            'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?q=80&w=1974&auto=format&fit=crop',
        recipeName: 'Grilled Lemon Herb Chicken',
        rating: null,
        cookingTime: '40 min',
        ingredients: List.generate(
          12,
          (i) => Ingredient(
            name: 'Grill Item ${i + 1}',
            amount: '1 piece',
            imageUrl:
                'https://placehold.co/100x100/FFF/31343C?text=Grl${i + 1}',
          ),
        ),
        procedures: List.generate(
          8,
          (i) =>
              'Grilling Step ${i + 1}: Tips for a juicy and flavorful grilled chicken.',
        ),
      ),
      Recipe(
        id: '11',
        userId: 'user2',
        imageUrl:
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=2080&auto=format&fit=crop',
        recipeName: 'Healthy Quinoa Bowl',
        rating: 4.8,
        cookingTime: '25 min',
        ingredients: List.generate(
          15,
          (i) => Ingredient(
            name: 'Bowl Item ${i + 1}',
            amount: '1/2 cup',
            imageUrl:
                'https://placehold.co/100x100/FFF/31343C?text=Bwl${i + 1}',
          ),
        ),
        procedures: List.generate(
          5,
          (i) =>
              'Quinoa Bowl Step ${i + 1}: A guide to a healthy and tasty meal.',
        ),
      ),
      Recipe(
        id: '12',
        userId: 'user3',
        imageUrl:
            'https://images.unsplash.com/photo-1467003909585-2f8a72700288?q=80&w=1974&auto=format&fit=crop',
        recipeName: 'Pan-Seared Salmon',
        rating: 4.9,
        cookingTime: '15 min',
        ingredients: List.generate(
          7,
          (i) => Ingredient(
            name: 'Salmon Ingredient ${i + 1}',
            amount: '1 fillet',
            imageUrl:
                'https://placehold.co/100x100/FFF/31343C?text=Sal${i + 1}',
          ),
        ),
        procedures: List.generate(
          6,
          (i) => 'Salmon Step ${i + 1}: How to get that perfect crispy skin.',
        ),
      ),
      Recipe(
        id: '13',
        userId: 'user1',
        imageUrl:
            'https://images.unsplash.com/photo-1484723050470-6b1d3b2a3a2b?q=80&w=2070&auto=format&fit=crop',
        recipeName: 'Beef Tacos',
        rating: 4.5,
        cookingTime: '20 min',
        ingredients: List.generate(
          10,
          (i) => Ingredient(
            name: 'Taco Filling ${i + 1}',
            amount: 'some',
            imageUrl:
                'https://placehold.co/100x100/FFF/31343C?text=Tac${i + 1}',
          ),
        ),
        procedures: List.generate(
          8,
          (i) => 'Taco Step ${i + 1}: Building the ultimate beef taco.',
        ),
      ),
      Recipe(
        id: '14',
        userId: 'user2',
        imageUrl:
            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?q=80&w=2070&auto=format&fit=crop',
        recipeName: 'Vegetable Stir-fry',
        rating: 4.2,
        cookingTime: '15 min',
        ingredients: List.generate(
          18,
          (i) => Ingredient(
            name: 'Stir-fry Veggie ${i + 1}',
            amount: '1 cup',
            imageUrl:
                'https://placehold.co/100x100/FFF/31343C?text=Stir${i + 1}',
          ),
        ),
        procedures: List.generate(
          7,
          (i) => 'Stir-fry Step ${i + 1}: Quick and easy weeknight dinner.',
        ),
      ),
      Recipe(
        id: '15',
        userId: 'user3',
        imageUrl:
            'https://images.unsplash.com/photo-1476224203421-9ac39bcb3327?q=80&w=2070&auto=format&fit=crop',
        recipeName: 'Shrimp Scampi',
        rating: 4.7,
        cookingTime: '20 min',
        ingredients: List.generate(
          8,
          (i) => Ingredient(
            name: 'Scampi Item ${i + 1}',
            amount: 'some',
            imageUrl:
                'https://placehold.co/100x100/FFF/31343C?text=Sca${i + 1}',
          ),
        ),
        procedures: List.generate(
          6,
          (i) =>
              'Shrimp Scampi Step ${i + 1}: A classic Italian-American dish.',
        ),
      ),
      Recipe(
        id: '16',
        userId: 'user1',
        imageUrl:
            'https://images.unsplash.com/photo-1481931098730-318b6f776db0?q=80&w=1994&auto=format&fit=crop',
        recipeName: 'Blueberry Muffins',
        rating: 4.6,
        cookingTime: '30 min',
        ingredients: List.generate(
          9,
          (i) => Ingredient(
            name: 'Muffin Mix ${i + 1}',
            amount: '1/4 cup',
            imageUrl:
                'https://placehold.co/100x100/FFF/31343C?text=Muf${i + 1}',
          ),
        ),
        procedures: List.generate(
          7,
          (i) => 'Muffin Step ${i + 1}: Baking the perfect blueberry muffins.',
        ),
      ),
      Recipe(
        id: '17',
        userId: 'user2',
        imageUrl:
            'https://images.unsplash.com/photo-1506354666786-959d6d497f1a?q=80&w=2070&auto=format&fit=crop',
        recipeName: 'Homemade Pepperoni Pizza',
        rating: 4.8,
        cookingTime: '25 min',
        ingredients: List.generate(
          7,
          (i) => Ingredient(
            name: 'Pizza Item ${i + 1}',
            amount: 'some',
            imageUrl:
                'https://placehold.co/100x100/FFF/31343C?text=Piz${i + 1}',
          ),
        ),
        procedures: List.generate(
          8,
          (i) => 'Pizza Step ${i + 1}: Making delicious pizza from scratch.',
        ),
      ),
      Recipe(
        id: '18',
        userId: 'user3',
        imageUrl:
            'https://images.unsplash.com/photo-1432139555190-58524dae6a55?q=80&w=1972&auto=format&fit=crop',
        recipeName: 'BBQ Pulled Pork',
        rating: 4.9,
        cookingTime: '4 hours',
        ingredients: List.generate(
          10,
          (i) => Ingredient(
            name: 'Pork Ingredient ${i + 1}',
            amount: '1 cup',
            imageUrl:
                'https://placehold.co/100x100/FFF/31343C?text=Prk${i + 1}',
          ),
        ),
        procedures: List.generate(
          5,
          (i) => 'Pulled Pork Step ${i + 1}: Slow-cooked to perfection.',
        ),
      ),
      Recipe(
        id: '19',
        userId: 'user1',
        imageUrl:
            'https://images.unsplash.com/photo-1512152272829-e3139592d56f?q=80&w=2070&auto=format&fit=crop',
        recipeName: 'Cheeseburger',
        rating: 4.4,
        cookingTime: '15 min',
        ingredients: List.generate(
          8,
          (i) => Ingredient(
            name: 'Burger Item ${i + 1}',
            amount: '1',
            imageUrl:
                'https://placehold.co/100x100/FFF/31343C?text=Bur${i + 1}',
          ),
        ),
        procedures: List.generate(
          6,
          (i) =>
              'Cheeseburger Step ${i + 1}: Grilling the perfect cheeseburger.',
        ),
      ),
      Recipe(
        id: '20',
        userId: 'user2',
        imageUrl:
            'https://images.unsplash.com/photo-1598515214211-89d3c7373058?q=80&w=1974&auto=format&fit=crop',
        recipeName: 'Chicken Caesar Salad',
        rating: 4.3,
        cookingTime: '20 min',
        ingredients: List.generate(
          9,
          (i) => Ingredient(
            name: 'Salad Item ${i + 1}',
            amount: 'some',
            imageUrl:
                'https://placehold.co/100x100/FFF/31343C?text=Sld${i + 1}',
          ),
        ),
        procedures: List.generate(
          5,
          (i) => 'Caesar Salad Step ${i + 1}: Creating a classic Caesar salad.',
        ),
      ),
    ];
  }
}
