import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TaskTagSelector extends StatelessWidget {
  final String selectedTag;
  final Function(String) onTagSelected;

  static const List<Map<String, dynamic>> tags = [
    {'label': 'Work',     'icon': Icons.work_outline_rounded,  'color': Color(0xFF5C6BC0)},
    {'label': 'Study',    'icon': Icons.menu_book_rounded,     'color': Color(0xFF26A69A)},
    {'label': 'Creative', 'icon': Icons.brush_outlined,        'color': Color(0xFFEC407A)},
  ];

  const TaskTagSelector({
    super.key,
    required this.selectedTag,
    required this.onTagSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: tags.map((tag) {
        final isSelected = tag['label'] == selectedTag;
        final color = tag['color'] as Color;

        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact(); // satisfying tap feedback
            onTagSelected(tag['label'] as String);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut, // springy feel
            margin: const EdgeInsets.symmetric(horizontal: 6),
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 20 : 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withOpacity(0.15)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected ? color : Colors.white12,
                width: isSelected ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 12,
                        spreadRadius: 0,
                      )
                    ]
                  : [
                      const BoxShadow(
                        color: Colors.transparent,
                        blurRadius: 0,
                        spreadRadius: 0,
                      )
                  ],
            ),
            child: Row(
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  child: Icon(
                    tag['icon'] as IconData,
                    size: 15,
                    color: isSelected ? color : Colors.white24,
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  child: SizedBox(width: isSelected ? 6 : 4),
                ),
                Text(
                  tag['label'] as String,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white38,
                    fontSize: 13,
                    fontWeight: isSelected
                        ? FontWeight.w500
                        : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}