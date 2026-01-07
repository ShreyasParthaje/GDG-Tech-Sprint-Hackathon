import 'package:flutter/material.dart';

class MealBookingState {
  static final ValueNotifier<Set<String>> bookedMeals =
      ValueNotifier(<String>{});
}
