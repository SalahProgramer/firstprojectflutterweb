import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../../utilities/print_looger.dart';
import '../models_DB/address_item_model.dart';


class CartDatabaseHelper {
  static final CartDatabaseHelper _instance = CartDatabaseHelper._internal();
  static final int dbVersion = 14;

  factory CartDatabaseHelper() => _instance;

  CartDatabaseHelper._internal();

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;

    _database = await _initDatabase();
    return _database;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'fawri.db');

    return await openDatabase(
      path,
      version: dbVersion,
      onUpgrade: _onUpgrade,
      onCreate: (db, version) async {
        await _createDb(db);
      },
    );
  }

  Future<void> _createDb(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS addresses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        area_id TEXT NOT NULL,
        area_name TEXT NOT NULL,
        city_id TEXT NOT NULL,
        city_name TEXT NOT NULL,
        user_id INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    printLog("was updated address items");

    await db.execute('DROP TABLE IF EXISTS addresses');
    await _createDb(db);
  }

  Future<void> clearUserAddress() async {
    final db = await database;
    await db!.delete('addresses');
  }

  Future<int> insertAddressItem(AddressItem item) async {
    final db = await database;
    return await db!.insert('addresses', item.toJson());
  }

  Future<List<AddressItem>> getAddresses() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db!.query('addresses');
    return List.generate(
      maps.length,
      (i) => AddressItem.fromJson(maps[i]),
    );
  }

  Future<List<AddressItem>> getUserAddresses() async {
    final Database? db = await database;
    final List<Map<String, dynamic>> maps = await db!.query('addresses');

    return List.generate(maps.length, (i) {
      return AddressItem(
        id: maps[i]['id'],
        userId: maps[i]['user_id'],
        areaId: maps[i]['area_id'],
        cityId: maps[i]['city_id'],
        areaName: maps[i]['area_name'],
        name: maps[i]['name'],
        cityName: maps[i]['city_name'],
      );
    });
  }

  Future<void> deleteAddressItem(int id) async {
    final db = await database;
    printLog(id);
    await db!.delete('addresses', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateAddressItem(AddressItem item) async {
    final db = await database;
    await db!.update(
      'addresses',
      item.toJson(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }
}
