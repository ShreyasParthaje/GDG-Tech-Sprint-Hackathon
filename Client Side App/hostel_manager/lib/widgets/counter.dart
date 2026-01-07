import 'package:flutter/material.dart';

class Counter extends StatelessWidget {
  final int value;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const Counter({
    super.key,
    required this.value,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.remove, size: 18),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              value.toString(),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          GestureDetector(
            onTap: onAdd,
            child: const Icon(Icons.add, size: 18),
          ),
        ],
      ),
    );
  }
}
