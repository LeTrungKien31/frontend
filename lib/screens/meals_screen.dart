import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../provider.dart';

class MealModel {
  final int id;
  final String name;
  final String imageUrl;
  final double kcal;
  final double carbs;
  final double protein;
  final double fat;
  final bool isFavorite;

  const MealModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.kcal,
    required this.carbs,
    required this.protein,
    required this.fat,
    this.isFavorite = false,
  });
}

final sampleMeals = [
  MealModel(id: 1, name: 'Hamburger thịt bò', imageUrl: 'hamburger', 
      kcal: 250, carbs: 30, protein: 13, fat: 9, isFavorite: true),
  MealModel(id: 2, name: 'Canh hải sản', imageUrl: 'seafood_soup',
      kcal: 920, carbs: 109, protein: 55, fat: 32, isFavorite: true),
  MealModel(id: 3, name: 'Canh cá nấu chua ngọt', imageUrl: 'fish_soup',
      kcal: 280, carbs: 18, protein: 20, fat: 12, isFavorite: true),
  MealModel(id: 4, name: 'Spaghetti sốt cà chua thịt bò', imageUrl: 'spaghetti',
      kcal: 450, carbs: 55, protein: 22, fat: 15, isFavorite: true),
  MealModel(id: 5, name: 'Cơm gà xối mỡ', imageUrl: 'chicken_rice',
      kcal: 650, carbs: 70, protein: 35, fat: 25),
  MealModel(id: 6, name: 'Phở bò', imageUrl: 'pho',
      kcal: 380, carbs: 45, protein: 25, fat: 12),
];

class MealsScreen extends ConsumerStatefulWidget {
  const MealsScreen({super.key});
  @override
  ConsumerState<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends ConsumerState<MealsScreen> {
  final _searchController = TextEditingController();
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _addMealToLog(MealModel meal) async {
    await ref.read(mealServiceProvider).add(foodId: meal.id, servings: 1);
    ref.invalidate(todayMealKcalProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã thêm ${meal.name}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final favorites = sampleMeals.where((m) => m.isFavorite).toList();
    final others = sampleMeals.where((m) => !m.isFavorite).toList();
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('MÓN ĂN'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm món ăn...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            if (favorites.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('Yêu thích',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              ),
              const SizedBox(height: 12),
              _buildMealsGrid(favorites),
            ],
            if (others.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                child: Text('Tất cả',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600])),
              ),
              _buildMealsGrid(others),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMealsGrid(List<MealModel> meals) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: meals.length,
      itemBuilder: (ctx, i) => _buildMealCard(meals[i]),
    );
  }

  Widget _buildMealCard(MealModel meal) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, '/meal/detail', arguments: meal),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: Container(
                    height: 100,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: Center(
                      child: _buildMealImage(meal),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () {},
                    child: Icon(
                      meal.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: meal.isFavorite ? Colors.red : Colors.grey,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meal.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildNutrientChip('${meal.kcal.toInt()}', 'KCal'),
                      _buildNutrientChip('${meal.carbs.toInt()}', 'Carbs'),
                      _buildNutrientChip('${meal.protein.toInt()}', 'Protein'),
                      _buildNutrientChip('${meal.fat.toInt()}', 'Fat'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientChip(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          Text(label,
              style: TextStyle(fontSize: 9, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildMealImage(MealModel meal) {
    final emojis = {
      'hamburger': '🍔',
      'seafood_soup': '🍲',
      'fish_soup': '🐟',
      'spaghetti': '🍝',
      'chicken_rice': '🍗',
      'pho': '🍜',
    };
    return Text(emojis[meal.imageUrl] ?? '🍽️', style: const TextStyle(fontSize: 48));
  }
}