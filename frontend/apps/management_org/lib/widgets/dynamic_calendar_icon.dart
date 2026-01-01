import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DynamicCalendarIcon extends StatelessWidget {
  final double size;
  const DynamicCalendarIcon({super.key, this.size = 44.0});

  @override
  Widget build(BuildContext context) {
    // Scaling factor relative to default 44
    final scale = size / 44.0;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8 * scale),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4 * scale,
            offset: Offset(0, 2 * scale),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 14 * scale,
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(8 * scale)),
            ),
            alignment: Alignment.center,
            child: Text(
              DateFormat('MMM').format(DateTime.now()).toUpperCase(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 8 * scale,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                '${DateTime.now().day}',
                style: TextStyle(
                  color: const Color(0xFF333333),
                  fontSize: 20 * scale,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
