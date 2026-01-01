class MealItem {
  final String name;
  final bool isDiscrete;
  int quantity;
  bool selected;

  MealItem({
    required this.name,
    required this.isDiscrete,
    this.quantity = 1,
    this.selected = false,
  });
}
