import 'package:flutter/material.dart';

class HealthQuestionnaire extends StatefulWidget {
  final Map<String, dynamic> topic;
  final Function(String, Map<String, dynamic>) onComplete;
  final VoidCallback onBack;

  const HealthQuestionnaire({
    super.key,
    required this.topic,
    required this.onComplete,
    required this.onBack,
  });

  @override
  State<HealthQuestionnaire> createState() => _HealthQuestionnaireState();
}

class _HealthQuestionnaireState extends State<HealthQuestionnaire> {
  int currentQuestion = 0;
  Map<String, dynamic> answers = {};
  bool isSubmitting = false;

  void handleAnswer(String questionId, dynamic answer) {
    setState(() {
      answers[questionId] = answer;
    });
  }

  bool canProceed() {
    final current = widget.topic['questions'][currentQuestion];
    return !(current['required'] ?? false) || answers.containsKey(current['id']);
  }

  Map<String, dynamic> calculateResults() {
    final totalQuestions = widget.topic['questions'].length;
    final answeredQuestions = answers.length;
    double score = (answeredQuestions / totalQuestions) * 100;

    String riskLevel = 'low';
    List<String> recommendations = [];

    switch (widget.topic['id']) {
      case 'diabetes':
        if ((answers['age'] ?? 0) > 45 ||
            answers['family_history'] == 'Yes' ||
            answers['weight_status'] == 'Obese') {
          riskLevel = 'moderate';
          recommendations = [
            "Consider regular blood sugar monitoring.",
            "Maintain a healthy diet with limited refined sugars.",
            "Engage in regular physical activity.",
            "Schedule regular check-ups with your healthcare provider.",
          ];
        } else {
          recommendations = [
            "Continue maintaining healthy lifestyle habits.",
            "Monitor your weight and diet.",
            "Stay physically active.",
          ];
        }
        break;

      case 'heart_health':
        if (answers['smoking'] == 'Current smoker' ||
            (answers['blood_pressure'] ?? '').contains('High')) {
          riskLevel = 'high';
          recommendations = [
            "Consult with a cardiologist immediately.",
            "Consider smoking cessation programs if applicable.",
            "Monitor blood pressure regularly.",
            "Adopt a heart-healthy diet.",
          ];
        } else {
          recommendations = [
            "Continue heart-healthy habits.",
            "Engage in regular cardiovascular exercise.",
            "Monitor cholesterol levels.",
          ];
        }
        break;

      case 'mental_health':
        if (answers['stress_level'] == 'Very high' ||
            answers['mood_changes'] == 'Very often') {
          riskLevel = 'moderate';
          recommendations = [
            "Consider speaking with a mental health professional.",
            "Practice stress-reduction techniques like mindfulness or meditation.",
            "Maintain a regular sleep schedule.",
            "Engage in enjoyable social activities.",
          ];
        } else {
          recommendations = [
            "Continue practicing self-care and stress management.",
            "Maintain a healthy work-life balance.",
            "Stay socially connected with friends and family.",
          ];
        }
        break;

      default:
        recommendations = [
          "Maintain healthy lifestyle habits.",
          "Schedule regular check-ups with your healthcare provider.",
          "Stay informed about your health.",
        ];
    }

    return {
      'score': score,
      'riskLevel': riskLevel,
      'recommendations': recommendations,
      'answers': answers,
    };
  }

  Future<void> handleSubmit() async {
    setState(() {
      isSubmitting = true;
    });

    final results = calculateResults();
    await widget.onComplete(widget.topic['id'], results);

    setState(() {
      isSubmitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final questions = widget.topic['questions'] as List;
    final currentQ = questions[currentQuestion];
    final progress = (currentQuestion + 1) / questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic['title']),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LinearProgressIndicator(value: progress),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentQ['question'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (currentQ['type'] == 'radio')
                        ...List<Widget>.from(
                          (currentQ['options'] as List).map(
                            (option) => RadioListTile(
                              title: Text(option),
                              value: option,
                              groupValue: answers[currentQ['id']],
                              onChanged: (value) =>
                                  handleAnswer(currentQ['id'], value),
                            ),
                          ),
                        ),
                      if (currentQ['type'] == 'number')
                        TextField(
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: "Enter your answer",
                          ),
                          onChanged: (value) => handleAnswer(
                              currentQ['id'], int.tryParse(value) ?? 0),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: currentQuestion > 0
                      ? () => setState(() => currentQuestion--)
                      : null,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                ),
                currentQuestion < questions.length - 1
                    ? ElevatedButton.icon(
                        onPressed: canProceed()
                            ? () => setState(() => currentQuestion++)
                            : null,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Next'),
                      )
                    : ElevatedButton.icon(
                        onPressed: canProceed() && !isSubmitting
                            ? handleSubmit
                            : null,
                        icon: isSubmitting
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check_circle),
                        label: Text(
                          isSubmitting ? 'Submitting...' : 'Complete Assessment',
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
