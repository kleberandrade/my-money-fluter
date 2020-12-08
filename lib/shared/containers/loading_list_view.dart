import 'package:flutter/material.dart';

import 'package:my_money/shared/containers/centered_message.dart';
import 'package:my_money/shared/containers/centered_progress.dart';

class LoadingListView extends StatelessWidget {
  final bool loading;
  final int itemCount;
  final EdgeInsets padding;
  final String emptyText;
  final IconData emptyIcon;
  final Function(BuildContext, int) itemBuilder;

  const LoadingListView({
    Key key,
    this.itemCount,
    this.itemBuilder,
    this.loading = false,
    this.padding = const EdgeInsets.all(20.0),
    this.emptyText = 'Vazio',
    this.emptyIcon = Icons.warning,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (loading) {
      print('Loading');
      return Expanded(child: CenteredProgress());
    }

    print('Length $itemCount');
    if (itemCount == 0) {
      return Expanded(
        child: CenteredMessage(
          message: emptyText,
          icon: emptyIcon,
        ),
      );
    }

    print('Exibe lista');
    return ListView.builder(
      shrinkWrap: true,
      padding: padding,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
