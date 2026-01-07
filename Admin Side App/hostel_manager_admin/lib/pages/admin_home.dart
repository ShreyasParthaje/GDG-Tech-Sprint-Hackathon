import 'package:flutter/material.dart';
import '../state/admin_state.dart';
import '../models/meal.dart';
import '../models/food_item.dart';
import '../widgets/toggle.dart';
import '../widgets/item_row.dart';
import '../widgets/edit_popup.dart';
import '../widgets/styles.dart';
import 'meal_detail_page.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  final AdminState state = AdminState();
  Future<void> _uploadMealToFirestore() async {
    final Map<String, dynamic> mealData = {};

    // Convert food items to Firestore fields
    for (final item in state.tempItems) {
      final bool isCountable = item.type == 'Countable';
      mealData[item.name] = [isCountable, 0]; // [isCountable, demand]
    }

    // Add metadata fields
    mealData['mealName'] = state.mealNameController.text;
    mealData['date'] = '09/01/2026'; // hardcoded for now
    mealData['type'] = 'Lunch'; // can be dynamic later
    mealData['createdAt'] = FieldValue.serverTimestamp();

    // NEW: initialize votedUserIds array for this meal
    mealData['votedUserIds'] = <String>[];

    await FirebaseFirestore.instance.collection('meals').add(mealData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Toggle(
                  showCreate: state.showCreate,
                  onCreate: () => setState(() => state.showCreate = true),
                  onView: () => setState(() => state.showCreate = false),
                ),
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    state.showCreate ? 'Create Meal' : 'View Meals',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: state.showCreate ? _createMeal() : _viewMeals(context),
                ),
              ],
            ),
          ),
          if (state.editingItem != null)
            EditPopup(
              state: state,
              onSave: () {
                setState(() {
                  state.editingItem!.name = state.editController.text;
                  state.editingItem!.type = state.editType;
                  state.editingItem = null;
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _createMeal() {
    return ListView(
      children: [
        const Text('Meal Name', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        TextField(
          controller: state.mealNameController,
          decoration: inputStyle(),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: cardStyle(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Name of food item',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: state.nameController,
                decoration: inputStyle(),
              ),
              const SizedBox(height: 14),
              const Text('Type', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: pillStyle(),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: state.selectedType,
                          items: const [
                            DropdownMenuItem(
                              value: 'Countable',
                              child: Text('Countable'),
                            ),
                            DropdownMenuItem(
                              value: 'Non countable',
                              child: Text('Non countable'),
                            ),
                          ],
                          onChanged: (v) =>
                              setState(() => state.selectedType = v!),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    style: blackButton(),
                    onPressed: () {
                      if (state.nameController.text.isEmpty) return;
                      setState(() {
                        state.tempItems.add(
                          FoodItem(
                            state.nameController.text,
                            state.selectedType,
                          ),
                        );
                        state.nameController.clear();
                      });
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: cardStyle(),
          child: Column(
            children: state.tempItems.map((item) {
              return ItemRow(
                item: item,
                onEdit: () {
                  state.editController.text = item.name;
                  state.editType = item.type;
                  setState(() => state.editingItem = item);
                },
                onDelete: () {
                  setState(() => state.tempItems.remove(item));
                },
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 30),

        SizedBox(
          height: 50,
          child: ElevatedButton(
            style: blackButton(radius: 30),
            onPressed: () async {
              if (state.tempItems.isEmpty ||
                  state.mealNameController.text.isEmpty) {
                return;
              }

              try {
                await _uploadMealToFirestore();

                setState(() {
                  state.tempItems.clear();
                  state.mealNameController.clear();
                  state.showCreate = false;
                });
              } catch (e) {
                debugPrint('Error creating meal: $e');
              }
            },
            child: const Text(
              'Create Meal',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _viewMeals(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('meals')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No meals available', style: TextStyle(fontSize: 18)),
          );
        }

        final mealsDocs = snapshot.data!.docs;

        return ListView(
          children: mealsDocs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final mealName = data['mealName'] ?? 'Unnamed Meal';
            final date = data['date'] ?? '';

            return Container(
              margin: const EdgeInsets.only(bottom: 20),
              padding: const EdgeInsets.all(16),
              decoration: cardStyle(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        mealName,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: pillStyle(),
                        child: Text(date),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 44,
                    child: ElevatedButton(
                      style: blackButton(),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MealDetailPage(
                              meal: Meal(
                                mealName,
                                date,
                                [], // temp empty items; real items come from Firestore inside MealDetailPage
                              ),
                              mealDocId:
                                  doc.id, // pass the Firestore document ID
                            ),
                          ),
                        );
                      },
                      child: const Text('View meal'),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
