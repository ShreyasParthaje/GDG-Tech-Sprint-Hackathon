import 'dart:ui';
import 'package:flutter/material.dart';
import '../state/admin_state.dart';
import 'styles.dart';

class EditPopup extends StatelessWidget {
  final AdminState state;
  final VoidCallback onSave;

  const EditPopup({
    super.key,
    required this.state,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          color: Colors.black.withOpacity(0.2),
          alignment: Alignment.center,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Name of food item',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: state.editController,
                  decoration: inputStyle(),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Type',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: pillStyle(),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: state.editType,
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
                      onChanged: (v) => state.editType = v!,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: blackButton(),
                    onPressed: onSave,
                    child: const Text(
                      'Edit',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
