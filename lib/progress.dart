import 'package:flutter/material.dart';

class Progress extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;

  const Progress({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            'Question ${currentQuestion + 1} sur $totalQuestions',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF800020),
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: (currentQuestion + 1) / totalQuestions,
            backgroundColor: const Color.fromARGB(255, 71, 71, 71).withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF800020)),
            minHeight: 8,
          ),
        ],
        
      ),
    );
  }
}


