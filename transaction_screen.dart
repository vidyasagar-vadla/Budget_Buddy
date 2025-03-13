import 'package:budget_buddy/dbhandle.dart';
import 'package:flutter/material.dart';

class TransactionsScreen extends StatefulWidget {
  @override
  _TransactionsScreenState createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;
  String selectedFilter = 'all'; // State variable for selected filter

  DatabaseHelper db = DatabaseHelper(); // To track loading state

  @override
  void initState() {
    super.initState();
    initData(); // Fetch data when the widget is initialized
  }

  Future<void> initData() async {
    try {
      transactions = await db.getAllTransactions();
      transactions = transactions.reversed.toList();
      filterTransactions(); // Filter transactions based on the selected filter
    } catch (e) {
      print('Error fetching transactions: $e');
    } finally {
      setState(() {
        isLoading = false; // Update loading state
      });
    }
  }

  void filterTransactions() {
    if (selectedFilter == 'incoming') {
      transactions = transactions.where((transaction) => transaction['credit_amt'] != null).toList();
    } else if (selectedFilter == 'outgoing') {
      transactions = transactions.where((transaction) => transaction['debit_amt'] != null).toList();
    } else {
      // 'all' - do nothing, keep all transactions
    }
  }

  Future<void> onTagPressed(String refId, String currentTag) async {
    // Get the title of the transaction to search for
    var transaction = await db.getByRef(refId);
    String detailsToSearch = transaction['transaction_details'].split('/')[1];

    // Open the bottom sheet to select a new tag
    String? newTag = await showTagSelectionBottomSheet();

    if (newTag != null) {
      for (var transaction in transactions) {
        var temp = transaction['transaction_details'].split('/').length > 1
            ? transaction['transaction_details'].split('/')[1]
            : transaction['transaction_details'];
        if (temp == detailsToSearch) {
          // Update the tag in the database
          await db.updateTag(transaction['reference_no'], newTag);
        }
      }
      // Refresh the UI
      setState(() {
        initData(); // Refresh the transactions list
      });
    }
  }

  Future<String?> showTagSelectionBottomSheet() {
    String selectedTag = ""; // Default selected tag
    List<String> availableTags = [
      "Foods & Drinks",
      "Shopping",
      "Groceries",
      "Online Purchases",
      "Travel",
      "Medical",
      "Personal",
      "Bills",
      "Subscriptions",
      "In App Purchases"
    ];

    return showModalBottomSheet<String>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView( // Enable scrolling
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Select a Tag',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    ...availableTags.map((tag) {
                      return RadioListTile<String>(
                        title: Text(tag),
                        value: tag,
                        groupValue: selectedTag,
                        onChanged: (String? value) {
                          setState(() {
                            selectedTag = value!;
                          });
                        },
                      );
                    }).toList(),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, selectedTag); // Return the selected tag
                      },
                      child: Text('Confirm'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> search(String query) async {
    transactions = await db.searchData(query);
    transactions = transactions.reversed.toList();
    filterTransactions(); // Apply the current filter after searching
    setState(() {});
  }

  void updateFilter(String filter) {
    setState(() {
      selectedFilter = filter; // Update the selected filter
      initData(); // Re-fetch data to apply the filter
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Transactions', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          PopupMenuButton<String>(
            onSelected: updateFilter,
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'incoming',
                  child: Text('Incoming'),
                ),
                PopupMenuItem<String>(
                  value: 'outgoing',
                  child: Text('Outgoing'),
                ),
                PopupMenuItem<String>(
                  value: 'all',
                  child: Text('All'),
                ),
              ];
            },
            icon: Icon(Icons.filter_list),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              onChanged: search,
              decoration: InputDecoration(
                hintText: 'Search transactions',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator()) // Show loading indicator
                  : ListView.builder(
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.black54, width: 1.5),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    transaction['transaction_details'].split('/').length > 1
                                        ? transaction['transaction_details'].split('/')[1]
                                        : transaction['transaction_details'],
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text(
                                  DateTime.parse(transaction['date']).toString().split(' ')[0],
                                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                TextButton(
                                  onPressed: () => onTagPressed(transaction['reference_no'], transaction['tags'] ?? "Untagged"),
                                  style: TextButton.styleFrom(
                                    bac kgroundColor: Colors.indigo,
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    transaction['tags'] ?? "Untagged",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Text(
                                  transaction['credit_amt'] != null
                                      ? "+ ₹${transaction['credit_amt']}"
                                      : "- ₹${transaction['debit_amt']}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: transaction['credit_amt'] != null ? Colors.green : Colors.red,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}