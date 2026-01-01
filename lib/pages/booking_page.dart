import 'package:flutter/material.dart';
import '../models/meal_item.dart';
import '../state/meal_booking_state.dart';
import '../widgets/counter.dart';

class BookingPage extends StatefulWidget {
  final String meal;

  const BookingPage({super.key, required this.meal});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  late List<MealItem> items;

  @override
  void initState() {
    super.initState();
    items = [
      MealItem(name: 'Vada', isDiscrete: true),
      MealItem(name: 'Pav', isDiscrete: true, quantity: 3, selected: true),
      MealItem(name: 'Chutney', isDiscrete: false, selected: true),
      MealItem(name: 'Onion', isDiscrete: false),
    ];
  }

  void increase(MealItem item) => setState(() => item.quantity++);
  void decrease(MealItem item) {
    if (item.quantity > 1) {
      setState(() => item.quantity--);
    }
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
                        onChanged: (v) =>
                            setState(() => item.selected = v!),
                      ),
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 18,
                          decoration: item.selected
                              ? null
                              : TextDecoration.lineThrough,
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
                onPressed: () {
                  MealBookingState.bookedMeals.value = {
                    ...MealBookingState.bookedMeals.value,
                    widget.meal,
                  };
                  Navigator.pop(context);
                },
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
