import 'package:flutter/material.dart';
import 'package:budget_buddy/dbhandle.dart';

class MostRepeatedScreen extends StatefulWidget {
  const MostRepeatedScreen({Key? key}) : super(key: key);

  @override
  _MostRepeatedScreenState createState() => _MostRepeatedScreenState();
}

class _MostRepeatedScreenState extends State<MostRepeatedScreen> {
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

  DatabaseHelper db = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    fetchTransactions();
  }

  Future<void> fetchTransactions() async {
    try {
      transactions = await db.getAllTransactions();
      setState(() {});
    } catch (e) {
      print('Error fetching transactions: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> getMostRepeatedTransactions() {
    final Map<String, int> transactionCounts = {};

    for (var transaction in transactions) {
      final description = transaction['transaction_details'];
      transactionCounts[description] = (transactionCounts[description] ?? 0) + 1;
    }

    return transactionCounts.entries
        .where((entry) => entry.value > 1)
        .map((entry) => {
      'description': entry.key,
      'count': entry.value,
      'date': transactions.firstWhere((t) => t['transaction_details'] == entry.key)['date'],
    })
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final mostRepeatedTransactions = getMostRepeatedTransactions();

    return Scaffold(
      appBar: AppBar(
        title: Text('Most Repeated Transactions'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: mostRepeatedTransactions.length,
        itemBuilder: (context, index) {
          final transaction = mostRepeatedTransactions[index];
          return ListTile(
            title: Text(transaction['description']),
            subtitle: Text('Count: ${transaction['count']} - Date: ${transaction['date']}'),
          );
        },
      ),
    );
  }
}