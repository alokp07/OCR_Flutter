import 'package:eval/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:math';

const String baseUrl = 'https://8a45689cca96.ngrok-free.app';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OCR App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const OCRPage(),
    );
  }
}

// Convert OCRPage to a StatefulWidget to manage the state of uploaded files
class OCRPage extends StatefulWidget {
  const OCRPage({super.key});

  @override
  State<OCRPage> createState() => _OCRPageState();
}

class _OCRPageState extends State<OCRPage> {
  // State variables to hold the selected file names and upload status
  PlatformFile? _questionPaperFile;
  List<PlatformFile>? _selectedAnswerSheets;

  String? _questionPaperFileName;
  String? _answerSheetFileName;
  bool _questionPaperUploaded = false;
  bool _answerSheetUploaded = false;

  // Helper method to trim file names for display
  String _getDisplayFileName(String? fileName) {
    if (fileName == null) {
      return '';
    }
    const int maxLetters = 11;
    if (fileName.length > maxLetters) {
      return '${fileName.substring(0, maxLetters)}...';
    }
    return fileName;
  }

  // Method to handle file picking for the question paper and API call
  Future<void> _pickQuestionPaper() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        final platformFile = result.files.first;

        setState(() {
          _questionPaperFile = platformFile;
          _questionPaperFileName = platformFile.name;
          _questionPaperUploaded = false;
        });

        if (platformFile.path == null) {
          print('File path is null. Cannot upload.');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to get file path. Please try a different file.'),
              ),
            );
          }
          setState(() {
            _questionPaperFile = null;
            _questionPaperFileName = null;
          });
          return;
        }

        var request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/process_question_paper'),
        );

        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            platformFile.path!,
            filename: platformFile.name,
          ),
        );

        try {
          var response = await request.send();
          var responseBody = await http.Response.fromStream(response);

          if (response.statusCode == 200) {
            setState(() {
              print("question paper response");
              print(responseBody.body);
              _questionPaperUploaded = true;
            });
            print('Question paper uploaded successfully!');
          } else {
            print('Failed to upload question paper. Status code: ${response.statusCode}');
            setState(() {
              _questionPaperFile = null;
              _questionPaperFileName = null;
            });
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to upload file. Please try again.'),
                ),
              );
            }
          }
        } catch (e) {
          print('Error during file upload: $e');
          setState(() {
            _questionPaperFile = null;
            _questionPaperFileName = null;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Network error. Failed to connect to server.'),
              ),
            );
          }
        }
      } else {
        print('File picking canceled or no files selected.');
      }
    } catch (e) {
      print('Error picking file: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to open file picker. Please try again.'),
          ),
        );
      }
    }
  }

  // Method to handle file picking for answer sheets
  Future<void> _pickAnswerSheets() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'png'],
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedAnswerSheets = result.files;
          _answerSheetFileName = '${result.files.length} file(s) selected';
          _answerSheetUploaded = true;
        });
        print('Answer sheets selected successfully!');
      } else {
        setState(() {
          _selectedAnswerSheets = null;
          _answerSheetFileName = null;
          _answerSheetUploaded = false;
        });
        print('File picking canceled or no files selected.');
      }
    } catch (e) {
      print('Error picking files: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to open file picker. Please try again.'),
          ),
        );
      }
    }
  }

  // Updated method to handle file submission with a new, more dynamic animation
  Future<void> _submitFiles() async {
    // Check if both a question paper and answer sheets have been selected.
    if (_questionPaperFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a question paper first.')),
      );
      return;
    }
    if (_selectedAnswerSheets == null || _selectedAnswerSheets!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one answer sheet.')),
      );
      return;
    }

    // Show a loading indicator while the API call is in progress.
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      pageBuilder: (context, _, __) => const Center(
        child: CircularProgressIndicator(color: Colors.deepPurple),
      ),
    );

    try {
      // Create a multipart request to send only the student answers
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/evaluate_answers'),
      );

      // Add all selected answer sheet files with the new key name 'student_answers'
      for (var file in _selectedAnswerSheets!) {
        if (file.path != null) {
          request.files.add(
            await http.MultipartFile.fromPath(
              'student_answers',
              file.path!,
              filename: file.name,
            ),
          );
        }
      }

      // Send the request and wait for the response
      var response = await request.send();
      var responseBody = await http.Response.fromStream(response);

      // Close the loading dialog
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (response.statusCode == 200) {
        print(" response");
        print(responseBody.body);
        print('Files submitted successfully for evaluation!');

        // Show the new, smooth success animation dialog
        showGeneralDialog(
          context: context,
          barrierDismissible: false,
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, anim1, anim2) {
            return const SuccessAnimationDialog();
          },
        );

        // Wait for the animation to finish and then navigate
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) {
            Navigator.of(context).pop(); // Close the animation dialog
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomeScreen(), // Redirect to the HomeTab page
              ),
            );
          }
        });

      } else {
        // Handle non-200 status codes
        print('Failed to evaluate answers. Status code: ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to evaluate files. Please try again.'),
            ),
          );
        }
      }
    } catch (e) {
      // Handle network or other errors during the API call
      print('Error during file submission: $e');
      if (mounted) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Network error. Failed to connect to server.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Column(
                  children: [
                    Text(
                      'OCR Scanner',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Get started by uploading your documents to be evaluated.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 48),
                // ModernOcrSection for Question Paper with dynamic title and animated check
                ModernOcrSection(
                  title: _questionPaperFileName != null
                      ? _getDisplayFileName(_questionPaperFileName)
                      : 'Add Question Paper',
                  subtitle: _questionPaperFileName != null
                      ? 'File: ${_getDisplayFileName(_questionPaperFileName)}'
                      : 'Upload Question Paper',
                  description:
                  'Upload the question paper for the exam you want to evaluate.',
                  icon: Icons.assignment,
                  iconColor: Colors.deepPurple,
                  onTap: _pickQuestionPaper, // Call the new method
                  isUploaded: _questionPaperUploaded, // Pass the upload status
                ),
                const SizedBox(height: 24),
                // ModernOcrSection for Answer Sheets with dynamic title and animated check
                ModernOcrSection(
                  title: _answerSheetFileName ?? 'Add Answer Sheets',
                  subtitle: _answerSheetFileName != null
                      ? _answerSheetFileName!
                      : 'Upload Answer Sheets',
                  description:
                  'Upload the answer sheets for the exam you want to evaluate.',
                  icon: Icons.file_upload,
                  iconColor: Colors.deepPurple,
                  onTap: _pickAnswerSheets, // Call the new method
                  isUploaded: _answerSheetUploaded, // Pass the upload status
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: _submitFiles, // Call the new submission method
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ModernOcrSection is now a StatefulWidget to manage its own animation
class ModernOcrSection extends StatefulWidget {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final bool isUploaded; // New property to determine if the checkmark should show

  const ModernOcrSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.isUploaded = false,
  });

  @override
  State<ModernOcrSection> createState() => _ModernOcrSectionState();
}

class _ModernOcrSectionState extends State<ModernOcrSection> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller with a longer duration
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Increased duration for a more visible animation
    );

    // Define the scale animation for the checkmark
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );

    // If the widget is already in an uploaded state when built, start the animation
    if (widget.isUploaded) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant ModernOcrSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isUploaded && !oldWidget.isUploaded) {
      _controller.forward(); // Animate the checkmark in
    } else if (!widget.isUploaded && oldWidget.isUploaded) {
      _controller.reverse(); // Animate the checkmark out (optional)
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.grey[50],
          ),
          padding: const EdgeInsets.all(24.0),
          child: Stack( // Use a Stack to position the checkmark icon on top of the content
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: widget.iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      widget.icon,
                      size: 32,
                      color: widget.iconColor,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.description,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Animated checkmark icon positioned at the top-right
              Positioned(
                top: 0,
                right: 0,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// A new widget to handle the success animation
class SuccessAnimationDialog extends StatefulWidget {
  const SuccessAnimationDialog({super.key});

  @override
  State<SuccessAnimationDialog> createState() => _SuccessAnimationDialogState();
}

class _SuccessAnimationDialogState extends State<SuccessAnimationDialog> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Reduced duration for a faster animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward(); // Start the animation automatically
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          // Reduced the size of the CustomPaint canvas
          return CustomPaint(
            painter: _SuccessPainter(animationValue: _controller.value),
            size: const Size(80, 80),
          );
        },
      ),
    );
  }
}

// The CustomPainter class to draw the animated circle and checkmark
class _SuccessPainter extends CustomPainter {
  final double animationValue;

  _SuccessPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // Paint for the circle - now a more vibrant color with a thicker stroke
    final circlePaint = Paint()
      ..color = Colors.lightGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    // The circle animation runs from 0.0 to 0.7
    if (animationValue <= 0.7) {
      final circleSweepAngle = 2 * pi * (animationValue / 0.7);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        circleSweepAngle,
        false,
        circlePaint,
      );
    } else {
      // Draw the complete circle
      canvas.drawCircle(center, radius, circlePaint);
    }

    // Paint for the checkmark - now a white, thicker stroke for better contrast
    final checkPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    // The checkmark animation runs from 0.7 to 1.0
    if (animationValue >= 0.7) {
      final checkProgress = (animationValue - 0.7) / 0.3;
      final path = Path();
      // The path for the checkmark with adjusted coordinates for better visual appeal
      path.moveTo(center.dx - radius * 0.4, center.dy + radius * 0.1);
      path.lineTo(center.dx - radius * 0.1, center.dy + radius * 0.4);
      path.lineTo(center.dx + radius * 0.4, center.dy - radius * 0.3);

      final pathMetrics = path.computeMetrics();
      for (final metric in pathMetrics) {
        final extractPath = metric.extractPath(0, metric.length * checkProgress);
        canvas.drawPath(extractPath, checkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    final oldPainter = oldDelegate as _SuccessPainter;
    return oldPainter.animationValue != animationValue;
  }
}
