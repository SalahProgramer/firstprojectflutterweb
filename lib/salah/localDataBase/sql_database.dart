import 'package:fawri_app_refactor/server/functions/functions.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class SqlDb {
  static Database? _database;

  Future<Database?> get database async {
    if (_database == null) {
      _database = await initialDb();
      return _database;
    } else {
      return _database;
    }
  }

  Future<Database> initialDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, "fawriv4.7.db");
    Database fawriDb = await openDatabase(
      path,
      onCreate: onCreate,
      onUpgrade: (db, oldVersion, newVersion) {},
      onConfigure: (db) async {
        // Enable WAL mode to reduce I/O and improve performance
        // This works for both new and existing databases
        // onConfigure is called before onCreate/onUpgrade, ensuring WAL is set early
        try {
          // Set WAL mode - this must be done before any other operations
          await db.execute('PRAGMA journal_mode=WAL;');
          
          // Verify WAL mode was set correctly
          final verifyResult = await db.rawQuery('PRAGMA journal_mode;');
          final actualMode = verifyResult.isNotEmpty && verifyResult.first.isNotEmpty
              ? verifyResult.first.values.first.toString().toUpperCase()
              : 'unknown';
          
          if (actualMode != 'WAL') {
            printLog('Warning: Database journal_mode is $actualMode, expected WAL');
          } else {
            printLog('Database journal_mode successfully set to WAL');
          }
          
          // Also set additional pragmas for better performance
          await db.execute('PRAGMA synchronous=NORMAL;');
          await db.execute('PRAGMA temp_store=MEMORY;');
        } catch (e) {
          // If WAL mode fails, log the error
          printLog('Failed to enable WAL mode: $e');
        }
      },
      version:
          1, //the version we do change to any update in do update in create database
      singleInstance: true, // Ensure single database instance
    );
    return fawriDb;
  }

  //----------------------------------------------------------------------------------
  // Create_database
  Future<void> onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE "cart" (
      "id" TEXT NOT NULL PRIMARY KEY,
      "image" TEXT NOT NULL,
      "title" TEXT NOT NULL,
      "new_price" TEXT NOT NULL,
      "old_price" TEXT NOT NULL,
      "product_id" INTEGER NOT NULL,
      "favourite" TEXT NOT NULL,
      "shopId" TEXT NOT NULL,
      "size" TEXT NOT NULL,
      "basic_quantity" INTEGER NOT NULL,
      "quantity" INTEGER NOT NULL,
      "employee" TEXT NOT NULL,
      "sku" TEXT NOT NULL,
      "vendor_sku" TEXT NOT NULL,
      "place_in_warehouse" TEXT NOT NULL,
      "nickname" TEXT NOT NULL,
      "indexVariants" INTEGER NOT NULL,
      "variantId" INTEGER NOT NULL,
      "total_price" TEXT NOT NULL,
      "has_offer" TEXT NOT NULL,
      "tags" TEXT NOT NULL DEFAULT '[]'
    )
  ''');

    await db.execute('''
    CREATE TABLE "favourite" (
      "id" TEXT NOT NULL,
      "image" TEXT NOT NULL,
      "title" TEXT NOT NULL,
      "new_price" TEXT NOT NULL,
      "old_price" TEXT NOT NULL,
      "tags" TEXT NOT NULL DEFAULT '[]',
      "variantId" INTEGER NOT NULL,
      "product_id" INTEGER NOT NULL PRIMARY KEY)
  ''');

    await db.execute('''
      CREATE TABLE "itemViewed" (
        "id" INTEGER PRIMARY KEY AUTOINCREMENT,
        "created_at" TEXT NOT NULL DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE "bigCategoriesImages" (
"main_category" TEXT NOT NULL,
"image" TEXT NOT NULL
        
      )
    ''');

    printLog("create database and table================================");
  }

  //----------------------------------------------------------------------------------
  // Update_database
  Future<void> onUpdate(Database db, int oldVersion, int newVersion) async {
    printLog("onUpdate================================");
  }

  //----------------------------------------------------------------------------------
  //read_data
  Future<List<Map>> readData({required String sql}) async {
    Database? fawriDb = await database;
    List<Map> response = await fawriDb!.rawQuery(sql);
    return response;
  }

  //----------------------------------------------------------------------------------
  //insert_data
  Future<int> insertData({required String sql}) async {
    Database? fawriDb = await database;
    int response = await fawriDb!.rawInsert(
      sql,
    ); //return the integer the raw (if 0 mean failed the mission  else 1 is success)
    return response;
  }

  //----------------------------------------------------------------------------------
  //delete_data
  Future<int> deleteData({required String sql}) async {
    Database? fawriDb = await database;
    int response = await fawriDb!.rawDelete(
      sql,
    ); //return the integer the raw (if 0 mean failed the mission  else 1 is success)
    return response;
  }

  //----------------------------------------------------------------------------------
  //update_data
  Future<int> updateData({required String sql}) async {
    Database? fawriDb = await database;
    int response = await fawriDb!.rawUpdate(
      sql,
    ); //return the integer the raw   (if 0 mean failed the mission  else 1 is success)
    return response;
  }
}
