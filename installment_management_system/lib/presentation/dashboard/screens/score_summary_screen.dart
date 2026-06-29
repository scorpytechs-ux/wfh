import 'package:flutter/material.dart';
import '../../files/state/form_data_model.dart';

class ScoreSummaryScreen extends StatelessWidget {
  final List<FormDataModel> forms;
  
  const ScoreSummaryScreen({super.key, required this.forms});

  @override
  Widget build(BuildContext context) {
    int totalForms = forms.length;
    double totalScore = 0;
    
    for (var form in forms) {
      totalScore += form.score ?? 0.0;
    }
    
    double averageScore = totalForms > 0 ? totalScore / totalForms : 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Project Score Summary"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.analytics, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              "Final Project Score",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              "${averageScore.toStringAsFixed(2)}%",
              style: TextStyle(
                fontSize: 64, 
                fontWeight: FontWeight.bold, 
                color: averageScore >= 90 ? Colors.green : (averageScore >= 70 ? Colors.orange : Colors.red)
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.builder(
                itemCount: forms.length,
                itemBuilder: (context, index) {
                  final form = forms[index];
                  final score = form.score ?? 0.0;
                  final mistakes = form.mistakes ?? [];
                  
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      title: Text("Serial No: ${form.serialNo}", style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: mistakes.isEmpty 
                        ? const Text("Perfect Form!", style: TextStyle(color: Colors.green)) 
                        : Text("Mistakes in: ${mistakes.join(', ')}", style: const TextStyle(color: Colors.red)),
                      trailing: Text(
                        "${score.toStringAsFixed(1)}%",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: score >= 90 ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
