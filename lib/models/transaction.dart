import 'package:drift/drift.dart';
//import 'package:flutter/material.dart';

class Transactions extends Table{
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(max: 128)();
  IntColumn get category_id => integer()();
  DateTimeColumn get transcation_date => dateTime()();
  IntColumn get amount => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}