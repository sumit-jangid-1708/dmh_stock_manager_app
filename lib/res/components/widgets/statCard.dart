import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  const StatCard({super.key, required this.title, required this.value, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(width: 2, color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),blurRadius: 8,
            offset: const Offset(0, 4)
          )
        ]
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w500,
              ),),
              Icon(icon, color: const Color(0xFF1A1A4F), size: 24,)
            ],
          ),
          const SizedBox(height: 10,),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
          const SizedBox( height: 4,),
          Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.shade600),)
        ],
      ),
    );
  }
}