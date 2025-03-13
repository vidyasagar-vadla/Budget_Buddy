import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'fetch_model.dart'; // Make sure to import your FetcherModel
import 'balance_chart.dart'; // Import your LineChartWidget

class BalanceCard extends StatefulWidget {
  const BalanceCard({super.key});

  @override
  _BalanceCardState createState() => _BalanceCardState();
}

class _BalanceCardState extends State<BalanceCard> {
  bool _isBalanceVisible = true; // State variable for balance visibility
  int _selectedPeriodIndex = 0; // Index for the selected period
  int _year = 2025; // Year field
  int _month = 1; // Month field

  void _toggleBalanceVisibility() {
    setState(() {
      _isBalanceVisible = !_isBalanceVisible; // Toggle visibility
    });
  }

  void _updateGraphPeriod(int index) {
    // Fetch data based on the selected graph period
    final fetcherModel = Provider.of<FetcherModel>(context, listen: false);
    if (_selectedPeriodIndex!=index){
      _year =2025;
      _month =1;
    }
    switch (index) {
      case 0: // Monthly
        fetcherModel.fetchDayWiseData(year: _year, month: _month); // Fetch monthly data
        break;
      case 1: // Yearly
        fetcherModel.fetchDayWiseData(year: _year); // Yearly data
        break;
      case 2: // All
        fetcherModel.fetchDayWiseData(); // All data
        break;
    }

    setState(() {

      _selectedPeriodIndex = index; // Update the selected index
    });
  }

  void _previous() {
    final fetcherModel = Provider.of<FetcherModel>(context, listen: false);
    int previousMonth = _month;
    int previousYear = _year;


    if (_selectedPeriodIndex == 0) { // Monthly
      if (_month > 1) {
        // Check if the current month and year are valid against firstTransactionDate
        if (_year >= fetcherModel.firstTransactionDate!.year && _month <= fetcherModel.firstTransactionDate!.month) {
          _showOutOfRangeSnackbar();
          _month = previousMonth;
          return;
        } else{
          _month--;
        }

      } else { // January
        if (_year > fetcherModel.firstTransactionDate!.year) {
          _month = 12;
          _year--;
        } else {
          _showOutOfRangeSnackbar();
          _month = previousMonth;
          _year = previousYear;
          return;
        }
      }
    } else if (_selectedPeriodIndex == 1) { // Yearly
      if (_year > fetcherModel.firstTransactionDate!.year) {
        _year--;
      } else {
        _showOutOfRangeSnackbar();
        _year = previousYear;
        return;
      }
    }
    _updateGraphPeriod(_selectedPeriodIndex);
  }

  void _next() {
    final fetcherModel = Provider.of<FetcherModel>(context, listen: false);
    int previousMonth = _month;
    int previousYear = _year;

    if (_selectedPeriodIndex == 0) { // Monthly
      if (_month < 12) {
        // Check if the current month and year are valid against firstTransactionDate
        if (_year <= fetcherModel.lastTransactionDate!.year && _month <= fetcherModel.lastTransactionDate!.month) {
          _showOutOfRangeSnackbar();
          _month = previousMonth;
          return;
        } else{
          _month++;
        }
      } else { // December
        if (_year < fetcherModel.lastTransactionDate!.year) {
          _month = 1;
          _year++;
        } else {
          _showOutOfRangeSnackbar();
          _month = previousMonth;
          _year = previousYear;
          return;
        }
      }
    } else if (_selectedPeriodIndex == 1) { // Yearly
      if (_year < fetcherModel.lastTransactionDate!.year) {
        _year++;
      } else {
        _showOutOfRangeSnackbar();
        _year = previousYear;
        return;
      }
    }
    _updateGraphPeriod(_selectedPeriodIndex);
  }
  var monthLabels = [ "January", "February", "March",
    "April", "May", "June",
    "July", "August", "September",
    "October", "November", "December"
  ];
  String _getMonthYearLabel() {
    final fetcherModel = Provider.of<FetcherModel>(context, listen: false);
    if (_selectedPeriodIndex == 0) {
      // Monthly
      return "${monthLabels[_month-1]} $_year";
    } else if (_selectedPeriodIndex == 1) {
      // Yearly
      return "$_year";
    } else {
      // All
      return "${monthLabels[fetcherModel.firstTransactionDate!.month-1]} ${fetcherModel.firstTransactionDate!.year} - ${monthLabels[fetcherModel.lastTransactionDate!.month-1]} ${fetcherModel.lastTransactionDate!.year}";
    }
  }



  void _showOutOfRangeSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Out of range'),
        duration: Duration(milliseconds: 15),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 16, 4, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current Balance
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Current Balance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _isBalanceVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.black54,
                        ),
                        onPressed: _toggleBalanceVisibility,
                      ),
                    ],
                  ),
                  Divider(thickness: 3, color: Colors.black54),
                  SizedBox(height: 8),
                  Consumer<FetcherModel>(
                    builder: (context, dataModel, child) {
                      return Text(
                        _isBalanceVisible ? '₹ ${dataModel.currentBalance}' : '****',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Consumer<FetcherModel>(
              builder: (context, dataModel, child) {
                if (dataModel.dayWiseData.isEmpty) {
                  return Center(child: Text('No data available'));
                }

                // Prepare data for the chart
                List<FlSpot> spots = dataModel.dayWiseData.map((data) {
                  DateTime date = DateTime.parse(data['date']);
                  double balance = data['last_balance'].toDouble();
                  return FlSpot(date.millisecondsSinceEpoch.toDouble(), balance);
                }).toList();

                // Calculate min and max values for Y-axis
                double minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
                double maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);
                return LineChartWidget(spots: spots, minY: minY, maxY: maxY, monthLabel: _getMonthYearLabel());
              },
            ),
            SizedBox(height: 16),
            // Graph Period Selection using ToggleButtons
            SizedBox(height: 16),
            // Previous and Next Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _previous,
                ),
                Center(
                  child: ToggleButtons(
                    isSelected: [0, 1, 2].map((index) => index == _selectedPeriodIndex).toList(),
                    onPressed: (int index) {
                      _updateGraphPeriod(index);
                    },
                    color: Colors.black54,
                    selectedColor: Colors.white,
                    fillColor: Colors.green,
                    borderColor: Colors.black54,
                    selectedBorderColor: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text('M', style: TextStyle(fontSize: 16)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text('Y', style: TextStyle(fontSize: 16)),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Text('All', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: _next,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}