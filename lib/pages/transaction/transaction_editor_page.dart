import 'package:flutter/material.dart';

import '../../controllers/transaction/transaction_editor_controller.dart';
import '../../errors/transaction_error.dart';
import '../../helpers/snackbar_helper.dart';
import '../../helpers/validator_helper.dart';
import '../../models/transaction_model.dart';
import '../../shared/buttons/primary_button.dart';
import '../../shared/buttons/transaction_type_button.dart';
import '../../shared/dialogs/loading_dialog.dart';
import '../../shared/inputs/date_input_field.dart';
import '../../shared/inputs/money_input_field.dart';
import '../../shared/inputs/select_input_field.dart';
import '../../shared/inputs/simple_input_field.dart';
import '../../shared/inputs/switch_input_field.dart';

class TransactionEditorPage extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionEditorPage({
    Key key,
    this.transaction,
  }) : super(key: key);

  @override
  _TransactionEditorPageState createState() => _TransactionEditorPageState();
}

class _TransactionEditorPageState extends State<TransactionEditorPage> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TransactionEditorController();

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _controller.setCategory(widget.transaction.category);
      _controller.setDate(widget.transaction.date);
      _controller.setDescription(widget.transaction.description);
      _controller.setIsPending(widget.transaction.isPending);
      _controller.setMoney(widget.transaction.value);
      _controller.setType(widget.transaction.type);
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
      title: Text('Transação'),
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
            TransactionTypeButton(
              initialValue: 0,
              onChanged: (value) {
                setState(() {
                  _controller.setType(value);
                });
              },
            ),
            SizedBox(height: 20.0),
            MoneyInputField(
              label: 'Valor',
              initialValue: _controller.money,
              onSaved: (money) {
                setState(() {
                  _controller.setMoney(money);
                });
              },
              validator: (value) {
                return value <= 0.0 ? 'Precisa ser maior que R\$ 0,00' : null;
              },
            ),
            SizedBox(height: 20.0),
            SimpleInputField(
              label: 'Descrição',
              initialValue: _controller.description,
              onSaved: (description) {
                setState(() {
                  _controller.setDescription(description);
                });
              },
              validator: (text) {
                return text.trim().isEmpty ? 'Precisa de uma descrição' : null;
              },
            ),
            SizedBox(height: 20.0),
            DateInputField(
              label: 'Data',
              initialValue: _controller.date,
              onSaved: (date) {
                setState(() {
                  _controller.setDate(date);
                });
              },
              validator: (data) {
                return data == null ? 'Campo obrigatório' : null;
              },
            ),
            SizedBox(height: 20.0),
            SelectInputField(
              label: 'Categoria',
              initialValue: _controller.category?.name ?? '',
              onTap: () async {
                final category =
                    await Navigator.pushNamed(context, '/category');
                if (category != null) {
                  setState(() {
                    _controller.setCategory(category);
                  });
                }
              },
              validator: ValidatorHelper.isValidText,
            ),
            SizedBox(height: 20.0),
            SwitchInputField(
              label: 'Esta pendente?',
              value: _controller.isPending,
              onChanged: (value) {
                setState(() => _controller.setIsPending(value));
              },
            ),
            SizedBox(height: 20.0),
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
      final result = await _controller.create();
      LoadingDialog.hide();
      result.fold(_onSaveError, _onSaveSuccess);
    }
  }

  _onSaveError(TransactionError error) {
    SnackbarHelper.showFailureMessage(
      context,
      message: error.message,
    );
  }

  _onSaveSuccess(TransactionModel category) {
    Navigator.pop(context, category);
  }
}
