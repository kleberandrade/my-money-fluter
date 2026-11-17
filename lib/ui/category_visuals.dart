import 'package:flutter/material.dart';
import '../domain/ledger.dart';

class CategoryAvatar extends StatelessWidget {
  final Category? category;
  const CategoryAvatar({super.key, this.category});
  @override
  Widget build(BuildContext context) {
    final color = Color(category?.color ?? 0xff38695e);
    return CircleAvatar(
      backgroundColor: color.withValues(alpha: .12),
      child: Icon(
        categoryIcon(category?.icon),
        color: Color.alphaBlend(color.withValues(alpha: .75), Colors.black),
      ),
    );
  }
}

// Constant icon registry supports release tree shaking; legacy raw values stay stored.
IconData categoryIcon(int? code) => switch (code) {
  0xe532 => Icons.restaurant_outlined,
  0xe318 => Icons.home_outlined,
  0xe8f9 => Icons.work_outline,
  0xe40f => Icons.local_cafe_outlined,
  0xe531 => Icons.directions_car_outlined,
  0xe8cc => Icons.shopping_bag_outlined,
  _ => Icons.category_outlined,
};
