import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'transactions.db');

    // Check if the database already exists
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      // If not, copy it from assets
      final ByteData data = await rootBundle.load('assets/transactions.db');
      final List<int> bytes = data.buffer.asUint8List();
      await File(path).writeAsBytes(bytes);
    }

    return await openDatabase(path);
  }

// Method to update the tag for a given transaction ID
  Future<void> updateTag(String refId, String newTag) async {
    final db = await database;

    // Update the tags column for the given transaction ID
    await db.update(
      'transactions',
      {'tags': newTag},
      where: 'reference_no=?',
      whereArgs: [refId],
    );
  }
  Future<Map<String, dynamic>> getByRef(String refId) async {
    final db = await database;

    // Update the tags column for the given transaction ID
    List<Map<String,dynamic>> trans= await db.query(
      'transactions',
      where: 'reference_no = ?',
      whereArgs: [refId],
    );
    return trans.last;
  }


  Future<List<Map<String, dynamic>>> getDateWiseTransactions(
      int date, int month, int year) async {
    final db = await database;
    String curDate =
        '$year-${month.toString().padLeft(2, '0')}-${date.toString().padLeft(2, '0')}';
    String nextDate =
        '$year-${month.toString().padLeft(2, '0')}-${(date + 1).toString().padLeft(2, '0')}';
    final List<Map<String, dynamic>> transactions = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [curDate, nextDate],
    );
    return transactions;
  }

  Future<List<Map<String, dynamic>>> getMonthlyTransactions(
      int year, int month) async {
    final db = await database;
    String startDate =
        '$year-${month.toString().padLeft(2, '0')}-01'; // First day of the month
    String endDate =
        '$year-${month.toString().padLeft(2, '0')}-31'; // Last day of the month

    return await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
    );
  }

  Future<List<Map<String, dynamic>>> getYearlyTransactions(int year) async {
    final db = await database;
    final String startDate = '$year-01-01';
    final String endDate = '$year-12-31';

    return await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
    );
  }

  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;
    return await db.query('transactions');
  }

  Future<Map<String, dynamic>> getLastTransaction() async {
    final db = await database;

    // Step 1: Get the most recent date
    final List<Map<String, dynamic>> recentDateResult =
        await db.rawQuery('SELECT MAX(date) as recent_date FROM transactions');

    String recentDate = recentDateResult.first['recent_date'];

    // Step 2: Fetch all transactions for that date
    final List<Map<String, dynamic>> transactions = await db.query(
      'transactions',
      where: 'date = ?',
      whereArgs: [recentDate],
    );

    return transactions
        .last; // Return all transactions for the most recent date
  }

  Future<Map<String, dynamic>> getFirstTransaction() async {
    final db = await database;

    // Step 1: Get the earliest date
    final List<Map<String, dynamic>> earliestDateResult = await db
        .rawQuery('SELECT MIN(date) as earliest_date FROM transactions');
    String earliestDate = earliestDateResult.first['earliest_date'];

    // Step 2: Fetch all transactions for that date
    final List<Map<String, dynamic>> transactions = await db.query(
      'transactions',
      where: 'date = ?',
      whereArgs: [earliestDate],
    );
    return transactions.first; // Return all transactions for the earliest date
  }

  Future<List<Map<String, dynamic>>> getDayWiseData(
      DateTime startDate, DateTime endDate) async {
    final db = await database;
    List<Map<String, dynamic>> dayWiseData = [];

    // Prepare the SQL query to get inflow, outflow, and last transaction for each day
    String sql = '''
    SELECT 
        date,
        SUM(credit_amt) AS inflow,
        SUM(debit_amt) AS outflow,
        (SELECT balance_amt 
         FROM transactions 
         WHERE date = t.date 
         ORDER BY rowid DESC 
         LIMIT 1) AS last_balance
      FROM 
        transactions t
      WHERE 
        date BETWEEN ? AND ?
      GROUP BY 
        date
      ORDER BY 
        date
    ''';

    // Execute the query with the start and end dates
    final List<Map<String, dynamic>> results = await db.rawQuery(sql, [
      startDate.toIso8601String().split('T')[0],
      endDate.toIso8601String().split('T')[0],
    ]);

    // Process the results
    for (var row in results) {
      dayWiseData.add({
        'date': row['date'],
        'inflow': row['inflow'] ?? 0.0,
        'outflow': row['outflow'] ?? 0.0,
        'last_balance': row['last_balance'] ?? 0.0,
      });
    }

    return dayWiseData;
  }

  Future<List<Map<String, dynamic>>> searchData(String query) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'transactions',
      where: 'transaction_details LIKE ?', // Use LIKE for partial matching
      whereArgs: ['%$query%'], // Add wildcards for partial matching
    );
    return result;
  }
  Future<List<Map<String, dynamic>>> getOutgoingTransactions() async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'transactions',
      where: 'debit_amt > 0', // Check if debit_amt exists and matches the query
    );
    return result;
  }
}
