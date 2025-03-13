import 'package:flutter/material.dart';

class HighValuedTransactions extends StatelessWidget {
  final List<Map<String, dynamic>> filteredTransactions;

  const HighValuedTransactions({Key? key, required this.filteredTransactions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return filteredTransactions.isEmpty
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Here the Transactions which are',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            'above 10,000 are shown',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text('No transactions found.', style: TextStyle(fontSize: 16)),
          SizedBox(height: 10),
          Text('😞', style: TextStyle(fontSize: 80)),
          SizedBox(height: 30),
        ],
      ),
    )
        : ListView.builder(
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        final transaction = filteredTransactions[index];
        return Card(
          margin: EdgeInsets.all(10),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transaction Alert',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                SizedBox(height: 10),
                Text(
                  '${transaction['description']}',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo),
                ),
                SizedBox(height: 5),
                Text(
                  'Count: ${transaction['count']} times this year',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 5),
                Text(
                  'Warning: This transaction has occurred more than mentioned count this year and exceeds 10,000.',
                  style: TextStyle(fontSize: 14, color: Colors.redAccent),
                ),
                SizedBox(height: 5),
                Text(
                  'Please consider reducing such transactions.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}