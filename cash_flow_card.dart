import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'fetch_model.dart'; // Make sure to import your FetcherModel

class CashFlowCard extends StatefulWidget {
  const CashFlowCard({super.key});

  @override
  _CashFlowCardState createState() => _CashFlowCardState();
}

class _CashFlowCardState extends State<CashFlowCard> {
  String _selectedPeriod = 'Monthly'; // Default selection
  int _currentMonth = 1;
  int _currentYear = 2025;

  void _updateCashFlowData() {
    final fetcherModel = Provider.of<FetcherModel>(context, listen: false);
    if (_selectedPeriod == 'Monthly') {
      fetcherModel.calculateFinancialMetrics(year: _currentYear, month: _currentMonth);
    } else if (_selectedPeriod == "Yearly") {
      fetcherModel.calculateFinancialMetrics(year: _currentYear);
    } else {
      fetcherModel.calculateFinancialMetrics();
    }
  }

  void _showOutOfRangeSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('No Data Available for this period'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _previous() {
    final fetcherModel = Provider.of<FetcherModel>(context, listen: false);

    // Store previous values
    int previousMonth = _currentMonth;
    int previousYear = _currentYear;

    if (_selectedPeriod == 'Monthly') {
      if (_currentMonth == 1) {
        if (_currentYear > fetcherModel.firstTransactionDate!.year) {
          _currentMonth = 12;
          _currentYear--;
        } else {
          _showOutOfRangeSnackbar();
          return;
        }
      } else {
        _currentMonth--;
      }

      // Check if the new month and year are valid
      if (_currentYear == fetcherModel.firstTransactionDate!.year &&
          _currentMonth < fetcherModel.firstTransactionDate!.month) {
        _showOutOfRangeSnackbar();
        // Revert to previous values
        _currentMonth = previousMonth;
        _currentYear = previousYear;
        return;
      }
    } else if (_selectedPeriod == 'Yearly') {
      if (_currentYear > fetcherModel.firstTransactionDate!.year) {
        _currentYear--;
      } else {
        _showOutOfRangeSnackbar();
        return;
      }
    }
    setState(() {
      _updateCashFlowData();
    });
  }

  void _next() {
    final fetcherModel = Provider.of<FetcherModel>(context, listen: false);

    // Store previous values
    int previousMonth = _currentMonth;
    int previousYear = _currentYear;

    if (_selectedPeriod == 'Monthly') {
      if (_currentMonth == 12) {
        if (_currentYear < fetcherModel.lastTransactionDate!.year) {
          _currentMonth = 1;
          _currentYear++;
        } else {
          _showOutOfRangeSnackbar();
          return;
        }
      } else {
        _currentMonth++;
      }

      // Check if the new month and year are valid
      if (_currentYear == fetcherModel.lastTransactionDate!.year &&
          _currentMonth > fetcherModel.lastTransactionDate!.month) {
        _showOutOfRangeSnackbar();
        // Revert to previous values
        _currentMonth = previousMonth;
        _currentYear = previousYear;
        return;
      }
    } else if (_selectedPeriod == 'Yearly') {
      if (_currentYear < fetcherModel.lastTransactionDate!.year) {
        _currentYear++;
      } else {
        _showOutOfRangeSnackbar();
        return;
      }
    }
    setState(() {
      _updateCashFlowData();
    });
  }

  String _getPeriodLabel() {
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];

    if (_selectedPeriod == 'Monthly') {
      return '${monthNames[_currentMonth - 1]} $_currentYear'; // Month is 1-indexed
    } else if (_selectedPeriod == 'Yearly') {
      return '$_currentYear';
    } else {
      final fetcherModel = Provider.of<FetcherModel>(context, listen: false);
      String startMonth = monthNames[fetcherModel.firstTransactionDate!.month - 1];
      String endMonth = monthNames[fetcherModel.lastTransactionDate!.month - 1];
      return 'From: $startMonth ${fetcherModel.firstTransactionDate!.year} To: $endMonth ${fetcherModel.lastTransactionDate!.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('Cash Flow', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    SizedBox(width: 8), // Add some space between the title and buttons
                    IconButton(
                      icon: Icon(Icons.arrow_left, size: 30,color: Colors.brown,),
                      onPressed: _previous,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                    IconButton(
                      icon: Icon(Icons.arrow_right, size: 30,color: Colors.brown,),
                      onPressed: _next,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
                DropdownButton<String>(
                  value: _selectedPeriod,
                  icon: Icon(Icons.arrow_drop_down, color: Colors.black),
                  dropdownColor: Colors .white,
                  underline: SizedBox(),
                  items: <String>['Monthly', 'Yearly', 'All']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: TextStyle(color: Colors.black)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedPeriod = newValue!;
                      _updateCashFlowData();
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 8), // Space between title and label
            Text(
              _getPeriodLabel(),
              style: TextStyle(fontSize: 14, color: Colors.indigo),
            ),
            SizedBox(height: 20),
            // Incoming
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Incoming', style: TextStyle(color: Colors.green, fontSize: 16)),
                SizedBox(height: 4),
                Consumer<FetcherModel>(
                  builder: (context, dataModel, child) {
                    return Text('+₹${dataModel.inflow.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.green, fontSize: 24, fontWeight: FontWeight.bold));
                  },
                ),
              ],
            ),
            Divider(),
            // Outgoing
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Outgoing', style: TextStyle(color: Colors.red, fontSize: 16)),
                SizedBox(height: 4),
                Consumer<FetcherModel>(
                  builder: (context, dataModel, child) {
                    return Text('-₹${dataModel.outflow.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold));
                  },
                ),
              ],
            ),
            Divider(),
            // Left
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Left', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(height: 4),
                Consumer<FetcherModel>(
                  builder: (context, dataModel, child) {
                    return Text('₹${dataModel.leftBalance.toStringAsFixed(2)}',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}