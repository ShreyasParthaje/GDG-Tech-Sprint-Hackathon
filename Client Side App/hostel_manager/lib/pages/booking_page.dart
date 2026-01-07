import 'package:flutter/material.dart';
import '../models/meal_item.dart';
import '../state/meal_booking_state.dart';
import '../widgets/counter.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingPage extends StatefulWidget {
  final String meal;

  const BookingPage({super.key, required this.meal});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<MealItem> items = [];
  late DocumentReference mealDoc;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _ensureAnonymousLogin();
  }

  /// Ensure user is logged in anonymously
  Future<void> _ensureAnonymousLogin() async {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
    await _fetchMealItems();
  }

  /// Fetch meal items from Firestore
  Future<void> _fetchMealItems() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('meals')
        .where('mealName', isEqualTo: widget.meal)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      setState(() {
        items = [];
        loading = false;
      });
      return;
    }

    final doc = snapshot.docs.first;
    mealDoc = doc.reference;

    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    final List<MealItem> fetchedItems = [];

    data.forEach((key, value) {
      if (key == 'mealName' || key == 'date' || key == 'type' || key == 'createdAt' || key == 'votedUserIds') {
        return; // skip metadata
      }
      final bool isCountable = (value[0] as bool);
      fetchedItems.add(MealItem(name: key, isDiscrete: isCountable));
    });

    setState(() {
      items = fetchedItems;
      loading = false;
    });
  }

  void increase(MealItem item) => setState(() => item.quantity++);
  void decrease(MealItem item) {
    if (item.quantity > 1) setState(() => item.quantity--);
  }

  /// Book meal and increment demand for selected items
  Future<void> _bookMeal() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final docSnapshot = await mealDoc.get();
    final votedUsers = List<String>.from(docSnapshot.get('votedUserIds') ?? []);

    if (votedUsers.contains(uid)) {
      // User already booked this meal
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already booked this meal!')),
      );
      return;
    }

    final Map<String, dynamic> updates = {};

    for (final item in items) {
      if (!item.selected) continue;

      final current = List<dynamic>.from(docSnapshot.get(item.name));
      final bool isCountable = current[0] as bool;
      final int currentDemand = current[1] as int;

      updates[item.name] = [isCountable, currentDemand + (isCountable ? item.quantity : 1)];
    }

    // Add current user to votedUserIds at meal level
    updates['votedUserIds'] = [...votedUsers, uid];

    if (updates.isNotEmpty) {
      await mealDoc.update(updates);
    }

    // Mark meal as booked locally
    MealBookingState.bookedMeals.value = {
      ...MealBookingState.bookedMeals.value,
      widget.meal,
    };

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              widget.meal,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                children: items.map((item) {
                  return Row(
                    children: [
                      Checkbox(
                        value: item.selected,
                        onChanged: (v) => setState(() => item.selected = v!),
                      ),
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 18,
                          decoration: item.selected ? null : TextDecoration.lineThrough,
                        ),
                      ),
                      const Spacer(),
                      if (item.isDiscrete)
                        Counter(
                          value: item.quantity,
                          onAdd: () => increase(item),
                          onRemove: () => decrease(item),
                        ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: _bookMeal,
                child: const Text(
                  'Book meal',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
