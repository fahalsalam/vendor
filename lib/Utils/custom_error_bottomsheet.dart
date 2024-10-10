import 'package:flutter/material.dart';

void showCustomErrorBottomSheet({
  required BuildContext context,
  required String title,
  required List<InlineSpan> messageSpans,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
    ),
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            double iconSize = constraints.maxWidth * 0.1;
            double titleFontSize = constraints.maxWidth * 0.05;
            double messageFontSize = constraints.maxWidth * 0.04;
            double buttonFontSize = constraints.maxWidth * 0.045;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                SizedBox(height: 16),
                Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: iconSize < 40 ? iconSize : 40,
                ),
                SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleFontSize < 24 ? titleFontSize : 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: messageSpans,
                    style: TextStyle(
                      fontSize: messageFontSize < 16 ? messageFontSize : 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, // Full width button
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: buttonFontSize < 18 ? buttonFontSize : 18,
                        color: Colors.white, // White text color
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(
                        vertical: 12,
                      ), 
                    ),
                  ),
                ),
                SizedBox(height: 16),
              ],
            );
          },
        ),
      );
    },
  );
}