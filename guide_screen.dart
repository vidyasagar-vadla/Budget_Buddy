import 'package:flutter/material.dart';

class GuideScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Budget Buddy Guide'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildSection(
              title: 'Dashboard',
              description: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: "1. Current Balance: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "Displays the user's current account balance prominently at the top of the screen. Updated in real-time to reflect the latest transactions.\n\n"),
                    TextSpan(text: "2. Balance Overview Across Time: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "Provides graphical representations of balance trends over various time frames: Monthly balance changes, Yearly balance summaries, Overall historical balance data for comprehensive insights.\n\n"),
                    TextSpan(text: "3. Cash Flow Analysis: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "Visualizes cash flow across different periods, showcasing: Incoming funds (e.g., deposits, income), Outgoing expenses (e.g., bills, purchases), Remaining savings, allowing users to track their financial health effectively. Users can filter cash flow data by month, year, or custom date ranges.\n\n"),
                    TextSpan(text: "4. Tagged Transactions Analysis: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "Offers detailed analysis of transactions that users have tagged for better organization. Each tagged category is represented graphically, allowing users to see spending patterns and trends. Users can easily identify areas for potential savings or adjustments in spending habits."),
                  ],
                ),
                style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
              ),
            ),
            SizedBox(height: 16.0), // Add some space between sections
            _buildSection(
              title: 'Transactions',
              description: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: "1. Transaction List: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "A detailed list of all transactions, showing incoming and outgoing funds. Each transaction includes the date, amount, description, and associated tags for easy categorization.\n\n"),
                    TextSpan(text: "2. Filter Options: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "Users can filter transactions to view only incoming or outgoing transactions, making it easier to track specific types of financial activity.\n\n"),
                    TextSpan(text: "3. Search Bar: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "A search feature allows users to quickly find specific transactions by entering keywords related to the transaction description, amount, or tags.\n\n"),
                    TextSpan(text: "4. User -Friendly Interface: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "The layout is clean and organized, ensuring easy navigation through transactions.\n\n"),
                    TextSpan(text: "5. Responsive Design: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "The screen adapts to different device sizes for a seamless user experience."),
                  ],
                ),
                style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
              ),
            ),
            SizedBox(height: 16.0),
            _buildSection(
              title: 'Insights',
              description: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: "1. High-Valued Transactions: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "Easily identify your highest-value transactions over a specified period, helping you understand significant expenditures.\n\n"),
                    TextSpan(text: "2. Expenditure Analysis by Tags: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "View detailed insights into your spending for specific tags across different years. This feature allows you to track how much you spend on categorized items, helping you make informed financial decisions.\n\n"),
                    TextSpan(text: "3. Trends Over Time: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "Analyze spending trends over months or years, allowing you to see how your financial habits change over time.\n\n"),
                    TextSpan(text: "4. Visual Representations: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "Graphical representations of your spending data make it easier to digest and understand your financial behavior."),
                  ],
                ),
                style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
              ),
            ),
            SizedBox(height: 16.0),
            _buildSection(
              title: 'Profile',
              description: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: "1. Personal Information: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "Users can view and edit their personal details, including name, mobile number, and email address. Keeping this information up-to-date ensures effective communication and account security.\n\n"),
                    TextSpan(text: "2. Profile Picture: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "Users have the option to upload or change their profile picture, adding a personal touch to their account.\n\n"),
                    TextSpan(text: "3. Account Settings: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "Manage various account settings, such as notification preferences, privacy settings, and security options (e.g., changing passwords or enabling two-factor authentication).\n\n"),
                    TextSpan(text: "4. Transaction History: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "Quick access to view past transactions directly from the profile screen, allowing users to monitor their financial activities without navigating away.\n\n"),
                    TextSpan(text: "5. Logout Option: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "Users can easily log out of their account when they are finished using the app, ensuring their account remains secure.\n\n"),
                    TextSpan(text: "6. User -Friendly Interface: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "The layout is designed for easy navigation, making it simple for users to find and update their information.\n\n"),
                    TextSpan(text: "7. Responsive Design: ", style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(text: "The Profile Screen is optimized for various devices, ensuring a seamless experience across smartphones and tablets."),
                  ],
                ),
                style: TextStyle(fontSize: 14.0, color: Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Text description}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.0),
        description,
      ],
    );
  }
}