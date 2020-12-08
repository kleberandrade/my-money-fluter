import 'package:flutter/material.dart';
import 'package:my_money/controllers/category/category_controller.dart';
import 'package:my_money/models/category_model.dart';
import 'package:my_money/shared/containers/loading_list_view.dart';
import 'package:my_money/shared/inputs/search_input_field.dart';

import 'category_editor_page.dart';
import 'widgets/category_card.dart';

class CategoryPage extends StatefulWidget {
  @override
  _CategoryPageState createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final _controller = CategoryController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  _initialize() async {
    setState(() => _loading = true);
    await _controller.read();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  _buildFloatingActionButton() {
    return FloatingActionButton(child: Icon(Icons.add), onPressed: _onCreate);
  }

  _onCreate() async {
    final result = await Navigator.pushNamed(context, '/category/editor');
    if (result != null) {
      _initialize();
    }
  }

  _buildAppBar() {
    return AppBar(
      title: Text('Categorias'),
      centerTitle: true,
    );
  }

  _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SearchInputField(onChanged: _onSearch),
        LoadingListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          loading: _loading,
          itemCount: _controller.length,
          itemBuilder: _buildCategoryItem,
        ),
      ],
    );
  }

  _onSearch(String text) {
    setState(() => _controller.search(text));
  }

  Widget _buildCategoryItem(BuildContext context, int index) {
    final category = _controller.categoryFilteredList[index];
    return CategoryCard(
      category: category,
      onUpdate: _onUpdate,
      onDelete: _onDelete,
      onSelect: _onSelect,
    );
  }

  _onSelect(CategoryModel category) {
    Navigator.pop(context, category);
  }

  _onUpdate(CategoryModel category) {
    //Navigator.pushNamed(context, '/category/editor', arguments: category);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryEditorPage(category: category),
      ),
    );
  }

  _onDelete(CategoryModel category) {
    final index = _controller.categoryList.indexOf(category);
    _controller.delete(index);
    setState(() {});
  }
}
