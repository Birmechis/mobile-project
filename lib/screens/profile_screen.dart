import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final StorageService storage = StorageService();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  String userName = '';
  String userEmail = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadUserProfile();
  }

  void loadUserProfile() async {
    setState(() => isLoading = true);
    try {
      final name = await storage.getUserName();
      final email = await storage.getUserEmail();
      setState(() {
        userName = name ?? 'Guest User';
        userEmail = email ?? 'guest@example.com';
        nameController.text = userName;
        emailController.text = userEmail;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading profile')),
      );
    }
  }

  void saveProfile() async {
    if (nameController.text.isEmpty || emailController.text.isEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Validation Error'),
          content: Text('Please fill in all fields'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      await storage.saveUserName(nameController.text);
      await storage.saveUserEmail(emailController.text);

      setState(() {
        userName = nameController.text;
        userEmail = emailController.text;
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile saved successfully')),
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header with Stack layout
                  SizedBox(
                    height: 150,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.blue, Colors.lightBlue],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        Positioned(
                          top: 50,
                          left: 20,
                          child: CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 60,
                          left: 130,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                userEmail,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 30),

                  // Form Section
                  Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),

                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                  SizedBox(height: 16),

                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: saveProfile,
                          child: Text('Save Profile'),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Back'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
