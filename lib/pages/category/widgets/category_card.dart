import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:my_money/models/category_model.dart';

class CategoryCard extends StatelessWidget {
  final CategoryModel category;
  final Function(CategoryModel) onSelect;
  final Function(CategoryModel) onUpdate;
  final Function(CategoryModel) onDelete;

  const CategoryCard({
    Key key,
    this.category,
    this.onSelect,
    this.onUpdate,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: _buildCard(),
      actions: _buildActions(),
      secondaryActions: _buildActions(),
    );
  }

  _buildActions() {
    return [
      IconSlideAction(
        caption: 'Editar',
        color: Colors.blue,
        icon: Icons.edit,
        onTap: () => onUpdate(category),
      ),
      IconSlideAction(
        caption: 'Excluir',
        color: Colors.red,
        icon: Icons.delete,
        onTap: () => onDelete(category),
      ),
    ];
  }

  _buildCard() {
    return Card(
      child: ListTile(
        onTap: () => onSelect(category),
        title: Text(category.name),
        leading: Icon(
          category.icon,
          color: category.color,
        ),
      ),
    );
  }
}
