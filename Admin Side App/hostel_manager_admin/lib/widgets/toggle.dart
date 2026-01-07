import 'package:flutter/material.dart';

class Toggle extends StatelessWidget {
  final bool showCreate;
  final VoidCallback onCreate;
  final VoidCallback onView;

  const Toggle({
    super.key,
    required this.showCreate,
    required this.onCreate,
    required this.onView,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _button('Create', showCreate, onCreate),
          _button('View', !showCreate, onView),
        ],
      ),
    );
  }

  Widget _button(String text, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: active ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: active ? Colors.white : Colors.black54,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
