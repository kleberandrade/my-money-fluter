import 'package:flutter/material.dart';
import '../domain/ledger.dart';
import 'theme.dart';
import 'category_visuals.dart';

String? _validate<T>(String? text, T Function(String) parser) {
  try {
    parser(text ?? '');
    return null;
  } on FormatException catch (error) {
    return error.message;
  }
}

class EntryEditor extends StatefulWidget {
  final Entry? entry;
  final List<Category> categories;
  const EntryEditor({super.key, this.entry, required this.categories});
  @override
  State<EntryEditor> createState() => _EntryEditorState();
}

class _EntryEditorState extends State<EntryEditor> {
  final form = GlobalKey<FormState>();
  late final description = TextEditingController(
    text: widget.entry?.description,
  );
  late final amount = TextEditingController(
    text: widget.entry == null ? '' : Money.input(widget.entry!.cents),
  );
  late final date = TextEditingController(
    text: dateText(widget.entry?.date ?? DateTime.now()),
  );
  late EntryKind kind = widget.entry?.kind ?? EntryKind.expense;
  late bool pending = widget.entry?.pending ?? false;
  late Category? category = widget.entry?.category;
  late final List<Category> choices = [
    if (widget.entry?.category != null) widget.entry!.category!,
    ...widget.categories.where((c) => c.name != widget.entry?.category?.name),
  ];
  @override
  void dispose() {
    description.dispose();
    amount.dispose();
    date.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.entry == null ? 'Novo lançamento' : 'Editar lançamento'),
    content: SizedBox(
      width: 460,
      child: SingleChildScrollView(
        child: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Cada detalhe ajuda a entender seu dinheiro.',
                style: TextStyle(color: muted, fontSize: 13),
              ),
              const SizedBox(height: 24),
              SegmentedButton<EntryKind>(
                segments: const [
                  ButtonSegment(
                    value: EntryKind.expense,
                    label: Text('Despesa'),
                    icon: Icon(Icons.north_east),
                  ),
                  ButtonSegment(
                    value: EntryKind.income,
                    label: Text('Receita'),
                    icon: Icon(Icons.south_west),
                  ),
                ],
                selected: {kind},
                onSelectionChanged: (v) => setState(() => kind = v.single),
              ),
              const SizedBox(height: 24),
              TextFormField(
                key: const Key('description'),
                controller: description,
                autofocus: true,
                maxLength: 100,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Ex.: mercado da semana',
                ),
                validator: (v) => _validate(v, validName),
              ),
              const SizedBox(height: 16),
              TextFormField(
                key: const Key('amount'),
                controller: amount,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Valor (R\$)',
                  hintText: '0,00',
                  helperText: 'Use vírgula para centavos: 123,45',
                ),
                validator: (v) => _validate(v, Money.parse),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: date,
                keyboardType: TextInputType.datetime,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: 'Data',
                  helperText: 'dd/mm/aaaa',
                  suffixIcon: IconButton(
                    tooltip: 'Escolher data',
                    onPressed: () async {
                      DateTime initial;
                      try {
                        initial = parseDate(date.text);
                      } on FormatException {
                        initial = DateTime.now();
                      }
                      final selected = await showDatePicker(
                        context: context,
                        initialDate: initial,
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100, 12, 31),
                      );
                      if (selected != null) date.text = dateText(selected);
                    },
                    icon: const Icon(Icons.calendar_today_outlined),
                  ),
                ),
                validator: (v) => _validate(v, parseDate),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<Category?>(
                initialValue: category,
                isExpanded: true,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: [
                  const DropdownMenuItem<Category?>(
                    value: null,
                    child: Text('Sem categoria'),
                  ),
                  ...choices.map(
                    (c) => DropdownMenuItem<Category?>(
                      value: c,
                      child: Text(c.name, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                ],
                onChanged: (c) => category = c,
              ),
              if (choices.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Você pode criar categorias na aba Categorias.',
                    style: TextStyle(color: muted, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 16),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: const Text('Pendente'),
                subtitle: const Text('Ainda não foi pago ou recebido'),
                value: pending,
                onChanged: (v) => setState(() => pending = v),
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () {
          if (!form.currentState!.validate()) return;
          Navigator.pop(
            context,
            Entry(
              id: widget.entry?.id,
              description: description.text,
              cents: Money.parse(amount.text),
              date: parseDate(date.text),
              kind: kind,
              pending: pending,
              category: category,
            ),
          );
        },
        child: const Text('Salvar lançamento'),
      ),
    ],
  );
}

class CategoryEditor extends StatefulWidget {
  final Category? category;
  const CategoryEditor({super.key, this.category});
  @override
  State<CategoryEditor> createState() => _CategoryEditorState();
}

class _CategoryEditorState extends State<CategoryEditor> {
  final form = GlobalKey<FormState>();
  late final name = TextEditingController(text: widget.category?.name);
  late int icon = widget.category?.icon ?? 0xe318;
  late int color = widget.category?.color ?? 0xff38695e;
  @override
  void dispose() {
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.category == null ? 'Nova categoria' : 'Editar categoria',
    ),
    content: SizedBox(
      width: 400,
      child: SingleChildScrollView(
        child: Form(
          key: form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: name,
                autofocus: true,
                maxLength: 100,
                decoration: const InputDecoration(
                  labelText: 'Nome da categoria',
                ),
                validator: (v) => _validate(v, validName),
              ),
              const SizedBox(height: 20),
              const Text(
                'Ícone',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final choice in {
                    icon,
                    0xe318,
                    0xe532,
                    0xe8f9,
                    0xe40f,
                    0xe531,
                    0xe8cc,
                  })
                    IconButton.filledTonal(
                      isSelected: icon == choice,
                      tooltip: switch (choice) {
                        0xe318 => 'Casa',
                        0xe532 => 'Alimentação',
                        0xe8f9 => 'Trabalho',
                        0xe40f => 'Lazer',
                        0xe531 => 'Transporte',
                        0xe8cc => 'Compras',
                        _ => 'Ícone original',
                      },
                      onPressed: () => setState(() => icon = choice),
                      icon: Icon(categoryIcon(choice)),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              const Text('Cor', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final choice in {
                    color,
                    0xff38695e,
                    0xffb56b3f,
                    0xff5778a0,
                    0xff8c6bb1,
                  })
                    Semantics(
                      selected: choice == color,
                      child: IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: Color(choice),
                          foregroundColor:
                              ThemeData.estimateBrightnessForColor(
                                    Color(choice),
                                  ) ==
                                  Brightness.dark
                              ? Colors.white
                              : Colors.black,
                        ),
                        tooltip: switch (choice) {
                          0xff38695e => 'Verde floresta',
                          0xffb56b3f => 'Terracota',
                          0xff5778a0 => 'Azul',
                          0xff8c6bb1 => 'Violeta',
                          _ => 'Cor original',
                        },
                        onPressed: () => setState(() => color = choice),
                        icon: Icon(
                          choice == color ? Icons.check : Icons.circle_outlined,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: () {
          if (form.currentState!.validate()) {
            Navigator.pop(
              context,
              Category(
                id: widget.category?.id,
                name: name.text,
                icon: icon,
                color: color,
              ),
            );
          }
        },
        child: const Text('Salvar categoria'),
      ),
    ],
  );
}
