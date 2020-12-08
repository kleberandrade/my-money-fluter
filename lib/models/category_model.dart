import 'package:flutter/material.dart';

class CategoryModel {
  String name;
  IconData icon;
  Color color;

  CategoryModel({
    this.name,
    this.icon,
    this.color,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'icon': icon?.codePoint,
      'color': color?.value,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return CategoryModel(
      name: map['name'],
      icon: IconData(map['icon'], fontFamily: 'MaterialIcons'),
      color: Color(map['color']),
    );
  }
}
