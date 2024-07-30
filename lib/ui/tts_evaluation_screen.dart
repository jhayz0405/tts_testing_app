import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:leopard_flutter/leopard.dart';
import 'package:number_to_words/number_to_words.dart';
import '../service/elevenlabs_service.dart';
import '../service/leopard_service.dart';

class TTSEvaluationScreen extends StatefulWidget {
  @override
  _TTSEvaluationScreenState createState() => _TTSEvaluationScreenState();
}

class _TTSEvaluationScreenState extends State<TTSEvaluationScreen> {
  String inputText = "Hello world. This is a test sentence.";
  String transcribedText = "";
  double accuracy = 0.0;
  double precision = 0.0;
  double recall = 0.0;
  double f1Score = 0.0;
  double errorRate = 0.0;
  late LeopardService leopardService;

  @override
  void initState() {
    super.initState();
    initLeopard();
  }

  Future<void> initLeopard() async {
    leopardService = LeopardService();
    await leopardService.initLeopard();
  }

  Future<void> evaluateTTS() async {
    try {
      String audioFilePath = await ElevenLabsService().generateAudio(inputText);
      transcribedText = await leopardService.transcribeAudio(audioFilePath);
      String convertedText = convertNumbersToWords(inputText);
      calculateMetrics(convertedText, transcribedText);
    } catch (e) {
      print('Error during TTS evaluation: $e');
    }
  }

  String convertNumbersToWords(String text) {
    final numberRegExp = RegExp(r'\d+');
    return text.replaceAllMapped(numberRegExp, (match) {
      return NumberToWord().convert('en-in', int.parse(match.group(0)!));
    });
  }

  void calculateMetrics(String input, String transcribed) {
    int correctCharacters = 0;
    int totalInputCharacters = input.length;
    int totalTranscribedCharacters = transcribed.length;

    // True Positives (TP): Characters in the input text that are correctly transcribed.
    // False Positives (FP): Characters in the transcription that are not in the input text.
    // False Negatives (FN): Characters in the input text that are missing from the transcription.
    // True Negatives (TN): Not used here, as it does not apply to character-level evaluations.
    int falsePositives = 0;
    int falseNegatives = 0;
    int truePositives = 0;
    int trueNegatives = 0;

    for (int i = 0;
        i < totalInputCharacters && i < totalTranscribedCharacters;
        i++) {
      if (input[i] == transcribed[i]) {
        correctCharacters++;
      }
    }

    for (int i = 0; i < totalInputCharacters; i++) {
      if (i < totalTranscribedCharacters) {
        if (input[i] == transcribed[i]) {
          truePositives++;
        } else {
          falsePositives++;
        }
      } else {
        falseNegatives++;
      }
    }

    for (int i = totalInputCharacters; i < totalTranscribedCharacters; i++) {
      falsePositives++;
    }

    setState(() {
      accuracy = correctCharacters / totalInputCharacters;
      precision = correctCharacters / totalTranscribedCharacters;
      recall = correctCharacters / totalInputCharacters;
      f1Score = 2 * (precision * recall) / (precision + recall);

      double total = truePositives.toDouble() +
          falsePositives.toDouble() +
          falseNegatives.toDouble();
      errorRate = (falsePositives + falseNegatives) / total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("TTS Evaluation")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(labelText: "Input Text"),
              onChanged: (value) {
                inputText = value;
              },
            ),
            ElevatedButton(
              onPressed: evaluateTTS,
              child: Text("Evaluate TTS"),
            ),
            SizedBox(height: 35),
            Text("Transcribed Text: $transcribedText"),
            SizedBox(height: 30),
            Text("Accuracy: $accuracy"),
            Text("Precision: $precision"),
            Text("Recall: $recall"),
            Text("F1 Score: $f1Score"),
            Text("Error Rate: $errorRate"),
            SizedBox(height: 20),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 1,
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(toY: accuracy, color: Colors.blue)
                      ],
                      // showingTooltipIndicators: [0],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(toY: precision, color: Colors.green)
                      ],
                      // showingTooltipIndicators: [0],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(toY: recall, color: Colors.orange)
                      ],
                      // showingTooltipIndicators: [0],
                    ),
                    BarChartGroupData(
                      x: 3,
                      barRods: [
                        BarChartRodData(toY: f1Score, color: Colors.red)
                      ],
                      // showingTooltipIndicators: [0],
                    ),
                    BarChartGroupData(
                      x: 4,
                      barRods: [
                        BarChartRodData(toY: errorRate  , color: Colors.purple)
                      ],
                      // showingTooltipIndicators: [0],
                    ),
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return Text(
                                  'Accuracy\n${(accuracy * 100).toStringAsFixed(1)}%');
                            case 1:
                              return Text(
                                  'Precision\n${(precision * 100).toStringAsFixed(1)}%');
                            case 2:
                              return Text(
                                  'Recall\n${(recall * 100).toStringAsFixed(1)}%');
                            case 3:
                              return Text(
                                  'F1 Score\n${(f1Score * 100).toStringAsFixed(1)}%');
                            case 4:
                              return Text(
                                  'Error Rate\n${(errorRate * 100).toStringAsFixed(1)}%');
                            default:
                              return Text('');
                          }
                        },
                        reservedSize: 42,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
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
