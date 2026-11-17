import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'ledger_repository.dart';

Future<LedgerRepository> openRepository() async {
  final directory = await getApplicationDocumentsDirectory();
  return LedgerRepository(
    await openLedger(databaseFactoryIo, p.join(directory.path, 'my_money.db')),
  );
}
