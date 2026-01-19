import 'package:flutter/material.dart';
import 'models.dart';
import 'question_text.dart';
import 'progress.dart';


class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestion = 0;
  int score = 0;
  String? selectedDropdownAnswer;
  int? selectedAnswerIndex; // Pour stocker l'index de la réponse sélectionnée

  final List<Question> questions = [
    Question(
      question: 'Qui est le plus coffee addict ?',
      answers: [
        Answer(text: 'Brad', isCorrect: false),
        Answer(text: 'Engue', isCorrect: true),
        Answer(text: 'Bastien', isCorrect: false),
      ],
    ),
    Question(
      question: 'Combien de fois Armand bois de l\'alcool par semaine ?',
      answers: [
        Answer(text: '5', isCorrect: false),
        Answer(text: '12', isCorrect: true),
        Answer(text: '2', isCorrect: false),
      ],
    ),
    Question(
      question: 'Qui à une chaine youtube pour enfant',
      answers: [
        Answer(text: 'Louis', isCorrect: false),
        Answer(text: 'Ethan', isCorrect: false),
        Answer(text: 'Enguerran', isCorrect: true),
      ],
    ),
    Question(
      question: 'Quel langage est utilisé avec Flutter ?',
      answers: [
        Answer(text: 'Kotlin', isCorrect: false),
        Answer(text: 'Dart', isCorrect: true),
        Answer(text: 'Swift', isCorrect: false),
      ],
    ),
  ];

  void answerQuestion(bool isCorrect) {
    // Afficher le feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? 'Bonne réponse ! ✓' : 'Mauvaise réponse... ✗'),
        backgroundColor: isCorrect ? const Color.fromARGB(255, 14, 73, 16) : Color(0xFF800020),
        duration: const Duration(seconds: 2),

        behavior: SnackBarBehavior.floating,
  
      ),
    );

    // Attendre un peu avant de passer à la question suivante
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        if (isCorrect) score++;
        currentQuestion++;
        selectedDropdownAnswer = null;
        selectedAnswerIndex = null; // Réinitialiser la sélection
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    const burgundyColor = Color(0xFF800020); // Rouge bordeaux

    if (currentQuestion >= questions.length) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Résultat', style: TextStyle(color: Colors.white)),
          flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF800020), Color.fromARGB(255, 201, 144, 158)],
            ),
          ),
        ),
          elevation: 4,
        ),
        body: Container(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Score final : $score / ${questions.length}',
                    style: const TextStyle(fontSize: 24, color: Colors.white)),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: burgundyColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    elevation: 5,
                  ),
                  onPressed: () {
                    setState(() {
                      currentQuestion = 0;
                      score = 0;
                      selectedDropdownAnswer = null;
                      selectedAnswerIndex = null;
                    });
                  },
                  child: const Text('Rejouer', style: TextStyle(fontSize: 18)),
                )
              ],
            ),
          ),
        ),
      );
    }

    final question = questions[currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Flutter', style: TextStyle(color: Colors.white)),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF800020), Color.fromARGB(255, 186, 111, 130)],
            ),
          ),
        ),
        elevation: 4,
      ),
      body: Container(

        child: Column(
          children: [
            // Compteur de progression
            Progress(
              currentQuestion: currentQuestion,
              totalQuestions: questions.length,
            ),
            // Contenu de la question
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    QuestionText(questionText: question.question),
                    Timer(const Duration(seconds: 5), );
                    const SizedBox(height: 20),
                    // Question 3 (index 2) utilise un DropdownMenu
                    if (currentQuestion == 2) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: burgundyColor, width: 2),
                        ),
                        child: DropdownButton<String>(
                          value: selectedDropdownAnswer,
                          hint: const Text('Sélectionnez une réponse'),
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: question.answers.map((answer) {
                            return DropdownMenuItem<String>(
                              value: answer.text,
                              child: Text(answer.text),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            setState(() {
                              selectedDropdownAnswer = value;
                            });
                          },
                        ),
                      ),
                    ] else ...[
                      // Pour les autres questions, on utilise les boutons sélectionnables
                      ...List.generate(question.answers.length, (index) {
                        final answer = question.answers[index];
                        final isSelected = selectedAnswerIndex == index;
                        
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSelected 
                                  ? const Color(0xFFA00030) // Plus clair si sélectionné
                                  : burgundyColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: isSelected ? 8 : 5,
                              side: isSelected 
                                  ? const BorderSide(color: Colors.white, width: 3)
                                  : null,
                            ),
                            onPressed: () {
                              setState(() {
                                selectedAnswerIndex = index;
                              });
                            },
                            child: Text(
                              answer.text, 
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
            // Bouton "Suivant" en bas
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: burgundyColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    elevation: 5,
                    disabledBackgroundColor: Colors.grey,
                    disabledForegroundColor: Colors.white70,
                  ),
                  onPressed: (currentQuestion == 2 
                      ? selectedDropdownAnswer == null 
                      : selectedAnswerIndex == null)
                      ? null
                      : () {
                          bool isCorrect;
                          if (currentQuestion == 2) {
                            // Pour le dropdown
                            final selectedAnswer = question.answers.firstWhere(
                              (answer) => answer.text == selectedDropdownAnswer,
                            );
                            isCorrect = selectedAnswer.isCorrect;
                          } else {
                            // Pour les boutons
                            isCorrect = question.answers[selectedAnswerIndex!].isCorrect;
                          }
                          answerQuestion(isCorrect);
                        },
                  child: const Text(
                    'Suivant',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}