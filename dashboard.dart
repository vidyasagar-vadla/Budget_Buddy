import 'package:budget_buddy/analsyis_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'fetch_model.dart';
import 'balance_card.dart';
import 'cash_flow_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FetcherModel()
        ..calculateFinancialMetrics(year: 2025, month: 1)
        ..fetchDayWiseData(year: 2025, yearPart: 1)
        ..initializeTransactionDates(),
      child: DashboardScreenContent(),
    );
  }
}

class DashboardScreenContent extends StatelessWidget {
  const DashboardScreenContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Budget Buddy...',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          Icon(Icons.notifications, color: Colors.black),
          SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BalanceCard(), // Use the BalanceCard widget
              SizedBox(height: 20),
              CashFlowCard(), // Use the CashFlowCard widget
              AnalysisCard()
            ],
          ),
        ),
      ),
    );
  }
}