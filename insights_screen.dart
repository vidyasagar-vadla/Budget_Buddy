import 'package:flutter/material.dart';
import 'package:budget_buddy/dbhandle.dart';
import 'high_valued_transactions.dart'; // Import the new file

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  _InsightsScreenState createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;
  int currentYear = DateTime.now().year;
  DateTime? firstTransactionDate;
  DateTime? lastTransactionDate;

  DatabaseHelper db = DatabaseHelper();
  int selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      transactions = await db.getAllTransactions();
      transactions = transactions.reversed.toList();

      if (transactions.isNotEmpty) {
        firstTransactionDate = DateTime.parse(transactions.last['date']);
        lastTransactionDate = DateTime.parse(transactions.first['date']);
      }

      setState(() {});
    } catch (e) {
      print('Error fetching transactions: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> filterHighValuedTransactions() {
    final Map<String, int> transactionCounts = {};

    for (var transaction in transactions) {
      if (transaction['debit_amt'] != null && transaction['debit_amt'] >= 10000) {
        final transactionDate = DateTime.parse(transaction['date']);
        if (transactionDate.year == currentYear) {
          final description = transaction['transaction_details'].split('/').length > 1
              ? transaction['transaction_details'].split('/')[1]
              : transaction['transaction_details'];

          transactionCounts[description] = (transactionCounts[description] ?? 0) + 1;
        }
      }
    }

    return transactionCounts.entries
        .where((entry) => entry.value > 1)
        .map((entry) => {
      'description': entry.key,
      'count': entry.value,
    })
        .toList();
  }

  List<Map<String, dynamic>> getAllTaggedTransactions() {
    return transactions.where((transaction) {
      final transactionDate = DateTime.parse(transaction['date']);
      return transaction['tags'] != null && transactionDate.year == currentYear;
    }).toList();
  }

  void changeYear(int delta) {
    final newYear = currentYear + delta;

    if (firstTransactionDate != null && lastTransactionDate != null) {
      if (newYear < firstTransactionDate!.year || newYear > lastTransactionDate!.year) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Year $newYear is out of range.'),
            duration: Duration(milliseconds: 2000),
          ),
        );
        return;
      }
    }

    setState(() {
      currentYear = newYear;
      isLoading = true;
    });
    fetchTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final filteredHighValuedTransactions = filterHighValuedTransactions();
    final allTaggedTransactions = getAllTaggedTransactions();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Insights',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTabIndex = 0; // High Valued
                  });
                },
                child: Column(
                  children: [
                    Text(
                      'High Valued',
                      style: TextStyle(
                        fontWeight: selectedTabIndex == 0 ? FontWeight.bold : FontWeight.normal,
                        color: selectedTabIndex == 0 ? Colors.blue : Colors.black,
                      ),
                    ),
                    if (selectedTabIndex == 0) Container(height: 2, width: 80, color: Colors.blue),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedTabIndex = 1; // Tagged
                  });
                },
                child: Column(
                  children: [
                    Text(
                      'Tagged',
                      style: TextStyle(
                        fontWeight: selectedTabIndex == 1 ? FontWeight.bold : FontWeight.normal,
                        color: selectedTabIndex == 1 ? Colors.blue : Colors.black,
                      ),
                    ),
                    if (selectedTabIndex == 1) Container(height: 2, width: 80, color: Colors.blue),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => changeYear(-1),
                  color: Colors.black,
                ),
                SizedBox(width: 20),
                Text(
                  '$currentYear',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                SizedBox(width: 20),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () => changeYear(1),
                  color: Colors.black,
                ),
              ],
            ),
          ),
          Expanded(
            child: selectedTabIndex == 0
                ? HighValuedTransactions(filteredTransactions: filteredHighValuedTransactions)
                : allTaggedTransactions.isEmpty
                ? Center(child: Text('No transactions found for any tags.'))
                : ListView.builder(
              itemCount: allTaggedTransactions.length,
              itemBuilder: (context, index) {
                final transaction = allTaggedTransactions[index];
                return Card(
                  margin: EdgeInsets.all(10),
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction['transaction_details'],
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 5),
                        Text('Amount: ${transaction['debit_amt'] ?? transaction['credit_amt']}'),
                        SizedBox(height: 5),
                        Text('Date: ${transaction['date']}'),
                        SizedBox(height: 5),
                        // Check if tags is a List or a String
                        Text('Tags: ${transaction['tags'] is List ? (transaction['tags'] as List).join(', ') : transaction['tags'] ?? 'No tags'}'),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}