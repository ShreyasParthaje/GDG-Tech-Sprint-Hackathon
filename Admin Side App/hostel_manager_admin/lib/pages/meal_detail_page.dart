import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../widgets/styles.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class MealDetailPage extends StatefulWidget {
  final Meal meal;
  final String mealDocId; // Firestore document ID

  const MealDetailPage({
    super.key,
    required this.meal,
    required this.mealDocId,
  });

  @override
  State<MealDetailPage> createState() => _MealDetailPageState();
}

class _MealDetailPageState extends State<MealDetailPage> {
  late final Stream<DocumentSnapshot> _mealStream;

  @override
  void initState() {
    super.initState();
    // Listen to the Firestore document for this meal
    _mealStream = FirebaseFirestore.instance
        .collection('meals')
        .doc(widget.mealDocId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
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
              widget.meal.name,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: _mealStream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Center(
                      child: Text(
                        'Meal data not found',
                        style: TextStyle(fontSize: 18),
                      ),
                    );
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;

                  // Filter out metadata fields
                  final foodEntries = data.entries.where(
                    (e) =>
                        e.key != 'mealName' &&
                        e.key != 'date' &&
                        e.key != 'type' &&
                        e.key != 'createdAt' &&
                        e.key != 'votedUserIds',
                  );

                  return ListView(
                    children: foodEntries.map((entry) {
                      final itemName = entry.key;
                      final value = entry.value as List<dynamic>;
                      final bool isCountable = value[0] as bool;
                      final int demand = value[1] as int;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: cardStyle(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              itemName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'DEMAND COUNT',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$demand', // live value from Firestore
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],
                        ),
                      );
                    }).toList(),
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
