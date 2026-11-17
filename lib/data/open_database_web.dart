import 'package:sembast_web/sembast_web.dart';
import 'ledger_repository.dart';

Future<LedgerRepository> openRepository() async =>
    LedgerRepository(await openLedger(databaseFactoryWeb, 'my_money.db'));
