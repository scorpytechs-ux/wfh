import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../core/constants/app_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, AppConstants.appName, AppConstants.dbName);

    // Ensure the directory exists
    final dbDir = Directory(dirname(path));
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }

    return await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 4, // Incremented version for forms evaluation columns
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTables(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS documents');
      await db.execute('DROP TABLE IF EXISTS customers');
      await _createTables(db);
    }
    if (oldVersion < 3) {
      final tableInfo = await db.rawQuery("PRAGMA table_info(users)");
      final columns = tableInfo.map((info) => info['name']).toList();

      if (!columns.contains('role')) {
        await db.execute("ALTER TABLE users ADD COLUMN role TEXT DEFAULT 'candidate'");
      }
      if (!columns.contains('isBlocked')) {
        await db.execute("ALTER TABLE users ADD COLUMN isBlocked INTEGER DEFAULT 0");
      }
      if (!columns.contains('earnings')) {
        await db.execute("ALTER TABLE users ADD COLUMN earnings REAL DEFAULT 0.0");
      }
    }
    if (oldVersion < 4) {
      final formsTableInfo = await db.rawQuery("PRAGMA table_info(forms)");
      final formsColumns = formsTableInfo.map((info) => info['name']).toList();
      
      if (!formsColumns.contains('score')) {
        await db.execute("ALTER TABLE forms ADD COLUMN score REAL DEFAULT 0.0");
      }
      if (!formsColumns.contains('mistakes')) {
        await db.execute("ALTER TABLE forms ADD COLUMN mistakes TEXT DEFAULT '[]'");
      }
      if (!formsColumns.contains('status')) {
        await db.execute("ALTER TABLE forms ADD COLUMN status TEXT DEFAULT 'pending'");
      }
    }
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        role TEXT DEFAULT 'candidate',
        isBlocked INTEGER DEFAULT 0,
        earnings REAL DEFAULT 0.0
      )
    ''');

    await db.execute('''
      CREATE TABLE forms (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        serialNo TEXT,
        title TEXT,
        firstName TEXT,
        lastName TEXT,
        initial TEXT,
        email TEXT,
        fatherName TEXT,
        dob TEXT,
        gender TEXT,
        profession TEXT,
        mailingStreet TEXT,
        mailingCity TEXT,
        mailingPostal TEXT,
        mailingCountry TEXT,
        serviceProvider TEXT,
        fileNo TEXT,
        referenceNo TEXT,
        simNo TEXT,
        imsi1 TEXT,
        imsi2 TEXT,
        typeOfPlan TEXT,
        creditCardType TEXT,
        contractValue TEXT,
        dateOfIssue TEXT,
        dateOfRenewal TEXT,
        installment TEXT,
        amountInWords TEXT,
        remarks TEXT,
        score REAL DEFAULT 0.0,
        mistakes TEXT DEFAULT '[]',
        status TEXT DEFAULT 'pending',
        FOREIGN KEY (userId) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
    
    // Existing tables (customers, documents) just in case we still need them
    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        customerName TEXT NOT NULL,
        contractNumber TEXT NOT NULL,
        mobile TEXT NOT NULL,
        email TEXT,
        address TEXT,
        dob TEXT,
        contractValue REAL NOT NULL,
        contractMonths INTEGER NOT NULL,
        installmentAmount REAL NOT NULL,
        status TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE documents (
        id TEXT PRIMARY KEY,
        customerId TEXT NOT NULL,
        fileName TEXT NOT NULL,
        filePath TEXT NOT NULL,
        uploadedAt TEXT NOT NULL,
        FOREIGN KEY (customerId) REFERENCES customers (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> getScoredForms(String userId) async {
    final db = await database;
    return await db.query(
      'forms',
      where: 'userId = ? AND status = ?',
      whereArgs: [userId, 'sent'],
    );
  }
}
