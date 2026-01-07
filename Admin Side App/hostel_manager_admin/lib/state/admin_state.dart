import 'package:flutter/material.dart';
import '../models/meal.dart';
import '../models/food_item.dart';

class AdminState {
  bool showCreate = true;

  final List<Meal> meals = [];
  final List<FoodItem> tempItems = [];

  final mealNameController = TextEditingController();
  final nameController = TextEditingController();
  final editController = TextEditingController();

  String selectedType = 'Countable';
  String editType = 'Countable';

  FoodItem? editingItem;
}
