import 'package:flutter/material.dart';
import '../state/meal_booking_state.dart';
import '../widgets/meal_card.dart';
import '../widgets/segmented_tab.dart';
import 'booking_page.dart';
import 'qr_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool showAvailable = true;
  final meals = ['Breakfast', 'Lunch', 'Snacks'];

  @override
  Widget build(BuildContext context) {
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
                child: ValueListenableBuilder<Set<String>>(
                  valueListenable: MealBookingState.bookedMeals,
                  builder: (_, booked, __) {
                    final visibleMeals = showAvailable
                        ? meals.where((m) => !booked.contains(m))
                        : meals.where((m) => booked.contains(m));

                    return ListView(
                      children: visibleMeals.map((meal) {
                        return MealCard(
                          meal: meal,
                          buttonText: showAvailable
                              ? 'Book meal'
                              : 'View QR Code',
                          onPressed: () async {
                            if (showAvailable) {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      BookingPage(meal: meal),
                                ),
                              );
                              setState(() {});
                            } else {
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
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
