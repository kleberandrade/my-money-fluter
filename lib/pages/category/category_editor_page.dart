import 'package:flutter/material.dart';

import '../../controllers/category/category_editor_controller.dart';
import '../../errors/category_error.dart';
import '../../helpers/snackbar_helper.dart';
import '../../helpers/validator_helper.dart';
import '../../models/category_model.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/dialogs/loading_dialog.dart';
import '../../shared/inputs/color_input_field.dart';
import '../../shared/inputs/icon_input_field.dart';
import '../../shared/inputs/simple_input_field.dart';

class CategoryEditorPage extends StatefulWidget {
  final CategoryModel category;

  const CategoryEditorPage({
    Key key,
    this.category,
  }) : super(key: key);

  @override
  _CategoryEditorPageState createState() => _CategoryEditorPageState();
}

class _CategoryEditorPageState extends State<CategoryEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = CategoryEditorController();

  @override
  void initState() {
    super.initState();
    if (widget.category != null) {
      setState(() {
        _controller.setName(widget.category.name);
        _controller.setColor(widget.category.color);
        _controller.setIcon(widget.category.icon);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  _buildAppBar() {
    return AppBar(
      title: Text('Nova Categoria'),
      centerTitle: true,
    );
  }

  _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SimpleInputField(
              label: 'Descrição',
              initialValue: _controller.name,
              onSaved: _controller.setName,
              validator: ValidatorHelper.isValidText,
            ),
            SizedBox(height: 20.0),
            IconInputField(
              label: 'Ícone',
              initialValue: _controller.icon,
              onSaved: _controller.setIcon,
              validator: ValidatorHelper.isValidText,
            ),
            SizedBox(height: 20.0),
            ColorInputField(
              label: 'Cor',
              initialValue: _controller.color,
              onSaved: _controller.setColor,
              validator: ValidatorHelper.isValidText,
            ),
            PrimaryButton(
              label: 'Salvar',
              onPressed: _onSave,
            )
          ],
        ),
      ),
    );
  }

  _onSave() async {
    final state = _formKey.currentState;
    if (state.validate()) {
      state.save();
      LoadingDialog.show(context);
      var result;
      if (widget.category == null) {
        result = await _controller.create();
      } else {
        //result = await _controller.update();
      }
      LoadingDialog.hide();
      result.fold(_onSaveError, _onSaveSuccess);
    }
  }

  _onSaveError(CategoryError error) {
    SnackbarHelper.showFailureMessage(
      context,
      message: error.message,
    );
  }

  _onSaveSuccess(CategoryModel category) {
    Navigator.pop(context, category);
  }
}
