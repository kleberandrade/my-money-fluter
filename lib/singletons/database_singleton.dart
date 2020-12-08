import 'dart:async';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';

class DatabaseSingleton {
  static final DatabaseSingleton _singleton = DatabaseSingleton._();
  static DatabaseSingleton get instance => _singleton;

  Completer<Database> _openCompleter;

  DatabaseSingleton._();

  Future<Database> get database async {
    if (_openCompleter == null) {
      _openCompleter = Completer();
      _openDatabase();
    }

    return _openCompleter.future;
  }

  Future _openDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'my_money.db');
    final database = await databaseFactoryIo.openDatabase(path);
    _openCompleter.complete(database);
  }
}
