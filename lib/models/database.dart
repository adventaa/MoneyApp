import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:koin/models/category.dart';
import 'package:koin/models/transaction.dart';
import 'package:koin/models/transaction_with_category.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
// import 'package:sqlite3/sqlite3.dart';
// import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

// ... the TodoItems table definition stays the same

part 'database.g.dart';

@DriftDatabase(
  tables: [Categories, Transactions])

class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // CRUD category

  Future<List<Category>> getAllCategoryRepo(int type) async{
    return await (select(categories)..where((tbl) => tbl.type.equals(type)))
      .get();
  }

  Future updateCategoryRepo (int id, String name) async{
    return (update(categories)..where((tbl) => tbl.id.equals(id)))
      .write(CategoriesCompanion(name : Value(name)));
  }

  Future deleteCategoryRepo (int id) async{
    return (delete(categories)..where((tbl) => tbl.id.equals(id)))
      .go();
  }

  // transaction

  Stream<List<TransactionWithCategory>>getTransactionByDateRepo(DateTime date){
    final query = (select(transactions).join([
      innerJoin(categories, categories.id.equalsExp(transactions.category_id))
    ])
      ..where(transactions.transcation_date.equals(date)));

    return query.watch().map((rows){
      return rows.map((row){
        return TransactionWithCategory(
          row.readTable(transactions), row.readTable(categories));
      }).toList();
    });
  }

  Future updateTransactionRepo (int id, int amount, int category_id, DateTime transactionDate, String nameDetail) async{
    return (update(transactions)..where((tbl) => tbl.id.equals(id)))
      .write(TransactionsCompanion(
        name: Value (nameDetail), 
        amount: Value (amount),
        category_id: Value(category_id),
        transcation_date: Value(transactionDate)));
  }

  Future deleteTransactionRepo(int id) async {
    return (delete(transactions)..where((tbl) => tbl.id.equals(id))).go();
  }
}

LazyDatabase _openConnection() {
  // the LazyDatabase util lets us find the right location for the file async.
  return LazyDatabase(() async {
    // put the database file, called db.sqlite here, into the documents folder
    // for your app.
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));

    // // Also work around limitations on old Android versions
    // if (Platform.isAndroid) {
    //   await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    // }

    // // Make sqlite3 pick a more suitable location for temporary files - the
    // // one from the system may be inaccessible due to sandboxing.
    // final cachebase = (await getTemporaryDirectory()).path;
    // // We can't access /tmp on Android, which sqlite3 would try by default.
    // // Explicitly tell it about the correct temporary directory.
    // sqlite3.tempDirectory = cachebase;

    return NativeDatabase(file);
  });
}