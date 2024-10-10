import 'package:flutter/material.dart';

class TransactionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isRedemption;

  const TransactionIcon({
    required this.icon,
    required this.color,
    required this.isRedemption,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      color: color,
      size: 24,
    );
  }
}
