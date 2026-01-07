import 'package:flutter/material.dart';
import '../widgets/meal_card.dart';
import '../widgets/segmented_tab.dart';
import 'booking_page.dart';
import 'qr_page.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showAvailable = true;
  bool loading = true;
  List<String> availableMeals = [];
  List<String> bookedMeals = [];
  String? uid;

  @override
  void initState() {
    super.initState();
    _initUserAndMeals();
  }

  Future<void> _initUserAndMeals() async {
  // Ensure anonymous login
  User? user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    final userCredential = await FirebaseAuth.instance.signInAnonymously();
    user = userCredential.user;
  }

  if (user == null) {
    // Should never happen, but just in case
    debugPrint('Anonymous login failed');
    return;
  }

  uid = user.uid;

  await _fetchMeals();
  setState(() {
    loading = false;
  });
}


  Future<void> _fetchMeals() async {
    final snapshot = await FirebaseFirestore.instance.collection('meals').get();
    final List<String> available = [];
    final List<String> booked = [];

    for (final doc in snapshot.docs) {
      final data = doc.data();
      final votedUsers = List<String>.from(data['votedUserIds'] ?? []);
      final mealName = data['mealName'] as String;

      if (votedUsers.contains(uid)) {
        booked.add(mealName);
      } else {
        available.add(mealName);
      }
    }

    setState(() {
      availableMeals = available;
      bookedMeals = booked;
    });
  }

  void _refreshMeals() async {
    setState(() => loading = true);
    await _fetchMeals();
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final visibleMeals = showAvailable ? availableMeals : bookedMeals;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SegmentedTab(
                isLeftSelected: showAvailable,
                onChanged: (v) => setState(() => showAvailable = v),
              ),
              const SizedBox(height: 30),
              Text(
                showAvailable ? 'Available meals' : 'Booked meals',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: visibleMeals.isEmpty
                    ? Center(
                        child: Text(
                          showAvailable
                              ? 'No available meals'
                              : 'No booked meals',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView(
                        children: visibleMeals.map((meal) {
                          return MealCard(
                            meal: meal,
                            buttonText: showAvailable ? 'Book meal' : 'View QR Code',
                            onPressed: () async {
                              if (showAvailable) {
                                // Open BookingPage
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BookingPage(meal: meal),
                                  ),
                                );
                                // Refresh after booking
                                _refreshMeals();
                              } else {
                                // Open QR code page
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => QrPage(meal: meal),
                                  ),
                                );
                              }
                            },
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
