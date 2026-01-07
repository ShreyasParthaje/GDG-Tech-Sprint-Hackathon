import 'food_item.dart';

class Meal {
  final String name;
  final String date;
  final List<FoodItem> items;

  Meal(this.name, this.date, this.items);
}
