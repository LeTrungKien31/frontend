import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';

class IngredientModel {
  final int id;
  final String name;
  final String imageUrl;
  final double kcalPer100g;

  const IngredientModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.kcalPer100g,
  });
}

// Sample data matching the images
final sampleIngredients = [
  IngredientModel(id: 1, name: 'Cà rốt', imageUrl: 'carrot', kcalPer100g: 41.0),
  IngredientModel(id: 2, name: 'Khoai tây', imageUrl: 'potato', kcalPer100g: 77.0),
  IngredientModel(id: 3, name: 'Cá nâu', imageUrl: 'fish', kcalPer100g: 96.0),
  IngredientModel(id: 4, name: 'Thịt heo', imageUrl: 'pork', kcalPer100g: 500.0),
  IngredientModel(id: 5, name: 'Gà', imageUrl: 'chicken', kcalPer100g: 239.0),
  IngredientModel(id: 6, name: 'Tôm', imageUrl: 'shrimp', kcalPer100g: 85.0),
];

class IngredientsScreen extends ConsumerStatefulWidget {
  const IngredientsScreen({super.key});
  @override
  ConsumerState<IngredientsScreen> createState() => _IngredientsScreenState();
}

class _IngredientsScreenState extends ConsumerState<IngredientsScreen> {
  final _searchController = TextEditingController();
  List<IngredientModel> _filteredIngredients = sampleIngredients;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredIngredients = sampleIngredients;
      } else {
        _filteredIngredients = sampleIngredients
            .where((i) => i.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('NGUYÊN LIỆU'),
        actions: [
          IconButton(icon: const Icon(Icons.bar_chart), onPressed: () {}),
          IconButton(icon: const Icon(Icons.note_add), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm nguyên liệu...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filteredIngredients.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (ctx, index) {
                return _buildIngredientItem(_filteredIngredients[index]);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new ingredient
        },
        backgroundColor: AppColors.error,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildIngredientItem(IngredientModel ingredient) {
    return InkWell(
      onTap: () {
        // Navigate to ingredient detail or add to meal
        _showAddIngredientDialog(ingredient);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: _buildIngredientImage(ingredient),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                ingredient.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${ingredient.kcalPer100g} Kcal',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '100.0g',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientImage(IngredientModel ingredient) {
    // Map ingredient names to emojis for demo
    final emojis = {
      'carrot': '🥕',
      'potato': '🥔',
      'fish': '🐟',
      'pork': '🥓',
      'chicken': '🍗',
      'shrimp': '🦐',
    };
    
    return Center(
      child: Text(
        emojis[ingredient.imageUrl] ?? '🍽️',
        style: const TextStyle(fontSize: 36),
      ),
    );
  }

  Future<void> _showAddIngredientDialog(IngredientModel ingredient) async {
    final amountController = TextEditingController(text: '100');
    
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Thêm ${ingredient.name}'),
        content: TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Số lượng (gram)',
            suffixText: 'g',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Thêm'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      final amount = double.tryParse(amountController.text) ?? 100;
      final kcal = (ingredient.kcalPer100g * amount / 100).round();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã thêm ${ingredient.name}: $kcal Kcal')),
      );
    }
  }
}