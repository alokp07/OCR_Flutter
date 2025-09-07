import 'package:flutter/material.dart';
import 'ocr_page.dart';

class ScoreEvaluationPage extends StatelessWidget {
  const ScoreEvaluationPage({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Colors.black;
    const Color titleColor = Color(0xFF333333); // A softer black
    const Color subtitleColor = Color(0xFF888888);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE8F1F2), // A very light, calm blue-grey
              Color(0xFFFFFFFF), // White
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Choose an evaluation method',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Select how you would like to evaluate your scores.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 60),

                  // OCR Button
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const OCRPage()));
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      backgroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(100),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFDDDDDD), width: 1.5),
                      ),
                      elevation: 4, // Subtle shadow for a card-like effect
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.camera_alt_outlined, size: 36),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'OCR',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Text(
                                'Use your camera to scan printed scores and text.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: subtitleColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // OMR Button
                  OutlinedButton(
                    onPressed: () {
                      // TODO: Navigate to the OMR page
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      backgroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(100),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: const BorderSide(color: Color(0xFFDDDDDD), width: 1.5),
                      ),
                      elevation: 4, // Subtle shadow for a card-like effect
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.quiz_outlined, size: 36),
                        const SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'OMR',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: titleColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              child: Text(
                                'Scan answer sheets with multiple choice questions.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: subtitleColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
