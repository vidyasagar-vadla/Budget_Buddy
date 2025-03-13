import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'transaction_screen.dart';
import 'login_screen.dart';
import 'about_us_screen.dart';
import 'guide_screen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  double _rating = 0.0;
  String _submitMessage = '';

  // TextEditingControllers for user details
  final TextEditingController _nameController = TextEditingController(text: "Vidyasagar Vadla");
  final TextEditingController _mobileController = TextEditingController(text: "7382055697");
  final TextEditingController _emailController = TextEditingController(text: "vidya1sagar123@gmail.com");

  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _image = pickedFile;
        });
      }
    } catch (e) {
      print("Error picking image: $e");
    }
  }

  void _submitRating() {
    setState(() {
      _submitMessage = 'Rating Submitted: $_rating';
    });
  }

  void _editDetails() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Details", style: TextStyle(fontWeight: FontWeight.bold)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: "Name",
                    hintText: "Enter your name",
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _mobileController,
                  decoration: InputDecoration(
                    labelText: "Mobile No",
                    hintText: "Enter your mobile number",
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    hintText: "Enter your email",
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  // Update the profile details
                });
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        backgroundColor: Colors.purple,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 16),
            // Profile Section
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 35,
                      backgroundColor: Colors.pink,
                      backgroundImage: _image != null ? FileImage(File(_image!.path)) : null,
                      child: _image == null
                          ? Icon(Icons.camera_alt, color: Colors.white)
                          : null,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _nameController.text,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _mobileController.text,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          _emailController.text,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Payment Methods Section
            Card(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left side: Bank Account Icon and Name
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.grey[200],
                          child: Icon(Icons.account_balance_outlined, size: 30, color: Colors.blue),
                        ),
                        SizedBox(height: 8),
                        Text("Bank Account", style: TextStyle(fontWeight: FontWeight.bold)),
                        Text("KOTAK MAHINDRA", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                    SizedBox(width: 16),
                    // Right side: Account Holder Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Account Holder Name : \nVidyasagar Vadla", style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text("Account No: 1001119990012"),
                          SizedBox(height: 4),
                          Text("Mobile No: 7382055697"),
                          SizedBox(height: 4),
                          Text("IFSC Code: KOMC770012"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Credit/Debit Cards Section
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TransactionsScreen()),
                );
              },
              child: Card(
                margin: EdgeInsets.symmetric(horizontal: 16),
                child: ListTile(
                  leading: Icon(Icons.account_balance_wallet, color: Colors.blue),
                  title: Text("Transactions"),
                  trailing: Text("View", style: TextStyle(color: Colors.blue)),
                ),
              ),
            ),

            SizedBox(height: 16),

            // Grid of Cards
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.6,
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildGridCard(Icons.info, "About Us", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutUsScreen()),
                  );
                }),
                _buildGridCard(Icons.lightbulb, "Budget Buddy Guide", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GuideScreen()),
                  );
                }),
                _buildGridCard(Icons.edit, "Edit Details", _editDetails), // Updated to call _editDetails
                _buildGridCard(Icons.exit_to_app, "Logout", () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text("Logout"),
                      content: Text("Are you sure you want to logout?"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => LoginScreen()),
                                  (Route<dynamic> route) => false,
                            );
                          },
                          child: Text("Logout"),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),

            SizedBox(height: 16),

            // Rating Bar
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.blue,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            SizedBox(height: 20),
            // Submit Button
            OutlinedButton(
              onPressed: _submitRating,
              style: ElevatedButton.styleFrom(
                side: BorderSide(color: Colors.white12),
              ),
              child: Text(
                "Submit",
                style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
            SizedBox(height: 20),
            // Submit Message
            Text(
              _submitMessage,
              style: TextStyle(fontSize: 18, color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.blue),
            SizedBox(height: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}