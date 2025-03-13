import 'package:flutter/material.dart';
import 'package:budget_buddy/dbhandle.dart';

class TaggedScreen extends StatefulWidget {
  const TaggedScreen({Key? key}) : super(key: key);

  @override
  _TaggedScreenState createState() => _TaggedScreenState();
}

class _TaggedScreenState extends State<TaggedScreen> {
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

  Map<String, double> getTaggedTransactions() {
    final Map<String, double> taggedSums = {};

    for (var transaction in transactions) {
      if (transaction['tags'] != null) {
        final tag = transaction['tags'];
        final amount = transaction['debit_amt'] ?? 0.0;

        taggedSums[tag] = (taggedSums[tag] ?? 0) + amount;
      }
    }

    return taggedSums;
  }

  @override
  Widget build(BuildContext context) {
    final taggedTransactions = getTaggedTransactions();

    return Scaffold(
      appBar: AppBar(
        title: Text('Tagged Transactions'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: taggedTransactions.length,
        itemBuilder: (context, index) {
          final tag = taggedTransactions.keys.elementAt(index);
          final sum = taggedTransactions[tag];
          return ListTile(
            title: Text(tag),
            subtitle: Text('Total Amount: $sum'),
          );
        },
      ),
    );
  }
}