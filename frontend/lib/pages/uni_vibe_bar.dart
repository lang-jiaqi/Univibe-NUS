import 'package:flutter/material.dart';

class UniVibeBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final int coins;
  final bool showDebug;
  final bool showBack; // add this to toggle return button

  const UniVibeBar({
    Key? key,
    required this.title,
    required this.coins,
    this.showDebug = false,
    this.showBack = false,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFD1FFC7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Row(
          children: [
            // Back/return button (if needed)
            if (showBack)
              IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Color(0xFF356AA8)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                fontFamily: 'PlayfairDisplay',
                color: Color(0xFF356AA8),
                letterSpacing: 1.0,
              ),
            ),
            Spacer(),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  colors: [Color(0xFFFFE082), Color(0xFFFFD54F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, color: Color(0xFFFBC02D), size: 22),
                  SizedBox(width: 5),
                  Text(
                    coins.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Color(0xFF705A00),
                    ),
                  ),
                ],
              ),
            ),
            if (showDebug) ...[
              SizedBox(width: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'DEBUG',
                  style: TextStyle(
                    color: Color(0xFF673AB7),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
