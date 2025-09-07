import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  // A list of student data to display. This can be passed from the previous screen.
  final List<Map<String, dynamic>> studentResults;

  // For now, we'll use a hard-coded list of data since it's not being passed from the
  // previous screen. This should be replaced with real data later.
  static const List<Map<String, dynamic>> _hardcodedResults = [

    {
      'name': 'Gautam Kumar',
      'id': '67890',
      'optionalDetail': 'Science Quiz',
      'score': 88,
      'total': 100,
    },
    {
      'name': 'Jane Doe',
      'id': '11223',
      'optionalDetail': 'History Exam',
      'score': 76,
      'total': 100,
    },
    {
      'name': 'John Smith',
      'id': '44556',
      'optionalDetail': 'English Essay',
      'score': 92,
      'total': 100,
    },
  ];

  const ResultScreen({
    super.key,
    this.studentResults = _hardcodedResults,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4F8), // A light, clean background color
      appBar: AppBar(
        title: const Text(
          "Evaluation Results",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E88E5), // A vibrant blue
        elevation: 0,
        leading: const BackButton(
          color: Colors.white,
        ),
      ),
      // The body now uses a ListView.builder to create a list of cards dynamically.
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: ListView.builder(
          itemCount: studentResults.length,
          itemBuilder: (context, index) {
            // Get the data for the current student
            final student = studentResults[index];
            final name = student['name'] ?? 'Unknown Student';
            final id = student['id'] ?? 'N/A';
            final optionalDetail = student['optionalDetail'] ?? 'No extra info';
            final score = student['score'] ?? 0;
            final total = student['total'] ?? 100;

            // Determine the color of the score based on the result
            Color scoreColor;
            if (score / total >= 0.9) {
              scoreColor = Colors.green.shade600;
            } else if (score / total >= 0.7) {
              scoreColor = Colors.orange.shade600;
            } else {
              scoreColor = Colors.red.shade600;
            }

            // Wrap the card in an InkWell to make it clickable
            return InkWell(
              // Placeholder for the tap logic.
              onTap: () {
                // You can add your navigation logic here.
                // For example, navigate to a detailed view of this student's results.
                print("Tapped on student: $name");
              },
              borderRadius: BorderRadius.circular(20),
              child: Card(
                elevation: 10, // Increased elevation for a floating effect
                margin: const EdgeInsets.symmetric(vertical: 10.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFE3F2FD), // Light Blue
                        Color(0xFFBBDEFB), // Lighter Blue
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // A modern-looking circular avatar with a subtle shadow
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 40,
                            color: Color(0xFF1565C0), // Deeper Blue
                          ),
                        ),
                        const SizedBox(width: 24),
                        // Student name and other details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0D47A1), // Darkest Blue
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.school_outlined, size: 16, color: Colors.blueGrey),
                                  const SizedBox(width: 4),
                                  Text(
                                    optionalDetail,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blueGrey[700],
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.badge, size: 16, color: Colors.blueGrey),
                                  const SizedBox(width: 4),
                                  Text(
                                    'ID: $id',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blueGrey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Display score in a prominent badge-like container
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: scoreColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: scoreColor.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '$score',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
