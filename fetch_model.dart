import 'package:flutter/material.dart';
import 'dbhandle.dart';

class FetcherModel with ChangeNotifier {
  final DatabaseHelper dbHelper = DatabaseHelper();

  // State for day-wise data (for the graph)
  List<Map<String, dynamic>> _dayWiseData = [];

  // State for cash flow metrics
  double _lastBalance = 0.0;
  double _inflow = 0.0;
  double _outflow = 0.0;
  double _leftBalance = 0.0;
  double _currentBalance = 0.0;
  // New properties to store first and last transaction dates
  DateTime? _firstTransactionDate;
  DateTime? _lastTransactionDate;


  // Getters for day-wise data and cash flow metrics
  List<Map<String, dynamic>> get dayWiseData => _dayWiseData;
  double get lastBalance => _lastBalance;
  double get inflow => _inflow;
  double get outflow => _outflow;
  double get leftBalance => _leftBalance;
  double get currentBalance => _currentBalance;
  // Getters for first and last transaction dates
  DateTime? get firstTransactionDate => _firstTransactionDate;
  DateTime? get lastTransactionDate => _lastTransactionDate;

  Future<void> initializeTransactionDates() async {
    var firstTransaction = await dbHelper.getFirstTransaction();
    var lastTransaction = await dbHelper.getLastTransaction();

    if (firstTransaction.isNotEmpty && lastTransaction.isNotEmpty) {
      _firstTransactionDate = DateTime.parse(firstTransaction['date']);
      _lastTransactionDate = DateTime.parse(lastTransaction['date']);
    } else {
      _firstTransactionDate = null;
      _lastTransactionDate = null; // No transactions found
    }
    notifyListeners(); // Notify listeners to update the UI
  }


  // Fetch day-wise data for the graph
  Future<void> fetchDayWiseData({
    int? year,
    int? month,
    int? yearPart, // 1 for first 6 months, 2 for second 6 months
  }) async {
    DateTime startDate;
    DateTime endDate;

    if (month != null && year != null) {
      startDate = DateTime(year, month, 1);
      endDate = DateTime(year, month + 1, 0);
    } else if (year != null) {
      if (yearPart == 1) {
        // First 6 months
        startDate = DateTime(year, 1, 1);
        endDate = DateTime(year, 6, 30);
      } else if (yearPart == 2) {
        // Second 6 months
        startDate = DateTime(year, 7, 1);
        endDate = DateTime(year, 12, 31);
      } else {
        // If yearPart is not 1 or 2, fetch the entire year
        startDate = DateTime(year, 1, 1);
        endDate = DateTime(year, 12, 31);
      }
    } else {
      var firstTransaction = await dbHelper.getFirstTransaction();
      var lastTransaction = await dbHelper.getLastTransaction();

      if (firstTransaction.isNotEmpty && lastTransaction.isNotEmpty) {
        startDate = DateTime.parse(firstTransaction['date']);
        endDate = DateTime.parse(lastTransaction['date']);
      } else {
        return; // No transactions found
      }
    }

    _dayWiseData = await dbHelper.getDayWiseData(startDate, endDate);
    notifyListeners(); // Notify listeners to update the UI
  }

  // Calculate financial metrics for the CashFlowCard
  Future<void> calculateFinancialMetrics({
    int? year,
    int? month,
  }) async {
    DateTime startDate;
    DateTime endDate;

    if (month != null && year != null) {
      startDate = DateTime(year, month, 1);
      endDate = DateTime(year, month + 1, 0); // Last day of the month
    } else if (year != null) {
      startDate = DateTime(year, 1, 1);
      endDate = DateTime(year, 12, 31); // Last day of the year
    } else {
      var firstTransaction = await dbHelper.getFirstTransaction();
      var lastTransaction = await dbHelper.getLastTransaction();

      if (firstTransaction.isNotEmpty && lastTransaction.isNotEmpty) {
        startDate = DateTime.parse(firstTransaction['date']);
        endDate = DateTime.parse(lastTransaction['date']);
      } else {
        return; // No transactions found
      }
    }

    // Fetch day-wise data for the determined date range
    List<Map<String, dynamic>> dayWiseDataForMetrics = await dbHelper.getDayWiseData(startDate, endDate);

    _inflow = dayWiseDataForMetrics.fold(0.0, (sum, row) => sum + (row['inflow'] ?? 0.0));
    _outflow = dayWiseDataForMetrics.fold(0.0, (sum, row) => sum + (row['outflow'] ?? 0.0));
    _lastBalance = dayWiseDataForMetrics.isNotEmpty ? dayWiseDataForMetrics.last['last_balance'] ?? 0.0 : 0.0;

    var lastTrans = await dbHelper.getLastTransaction();
    _currentBalance = lastTrans['balance_amt'];

    // Calculate left balance
    _leftBalance = _inflow - _outflow > 0 ? _inflow - _outflow : 0.00;

    notifyListeners(); // Notify listeners to update the UI
  }
}