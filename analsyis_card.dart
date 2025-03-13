import 'package:flutter/material.dart';
import 'dbhandle.dart'; // Import your DBHelper class

class AnalysisCard extends StatefulWidget {
  const AnalysisCard({super.key});

  @override
  _AnalysisCardState createState() => _AnalysisCardState();
}

class _AnalysisCardState extends State<AnalysisCard> {
  final List<String> availableTags = [
    "Foods & Drinks",
    "Shopping",
    "Groceries",
    "Online Purchases",
    "Travel",
    "Medical",
    "Personal",
    "Bills",
    "Subscriptions",
    "In App Purchases",
    "Untagged",
  ];

  Map<String, num> tagSums = {};

  @override
  void initState() {
    super.initState();
    _fetchTransactionCounts();
  }

  Future<void> _fetchTransactionCounts() async {
    final dbHelper = DatabaseHelper(); // Initialize your DBHelper
    final transactions = await dbHelper.getOutgoingTransactions();

    // Initialize tag counts
    tagSums = {for (var tag in availableTags) tag: 0};

    // Count occurrences of each tag
    for (var transaction in transactions) {
      String? tag = transaction['tags']; // Assuming 'tags' is the key in your transaction map
      if (tag != null && tagSums.containsKey(tag)) {
        tagSums[tag] = (tagSums[tag] ?? 0) + transaction['debit_amt']; // Safely increment the count
      } else {
        tagSums["Untagged"] = (tagSums["Untagged"] ?? 0) + transaction['debit_amt']; // Safely increment the count for untagged
      }
    }

    // Update the state to reflect the new counts
    setState(() {});
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
            Text(
              'Analysis',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SizedBox(height: 16),
            ...availableTags.map((tag) {
              num count = tagSums[tag] ?? 0;
              if (count > 0) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(tag, style: TextStyle(fontSize: 16)),
                      Text(count.toStringAsFixed(2), style: TextStyle(fontSize: 16)),
                    ],
                  ),
                );
              } else {
                return SizedBox.shrink(); // Don't show anything if count is 0
              }
            }).toList(),
          ],
        ),
      ),
    );
  }
}