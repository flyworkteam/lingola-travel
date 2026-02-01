import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'lesson_result_view.dart';

class LessonDetailView extends StatefulWidget {
  final Map<String, dynamic> lessonData;

  const LessonDetailView({super.key, required this.lessonData});

  @override
  State<LessonDetailView> createState() => _LessonDetailViewState();
}

class _LessonDetailViewState extends State<LessonDetailView> {
  int currentStep = 3;
  int totalSteps = 10;
  bool isBookmarked = false; // Bookmark state
  bool isRecording = false; // Recording state
  bool isPlaying = false; // Audio playing state
  String recordedText = ''; // Recorded text from speech recognition
  bool showResult = false; // Show result screen

  // The correct sentence to match
  final String targetSentence =
      'I would like to check in for my flight to London';

  // Mock vocabulary data
  final List<Map<String, dynamic>> _vocabulary = [
    {
      'icon': Icons.location_on,
      'iconColor': Color(0xFF4ECDC4),
      'term': 'Check-in',
      'definition':
          'The process of reporting your arrival at an airport or hotel.',
    },
    {
      'icon': Icons.confirmation_number,
      'iconColor': Color(0xFF4ECDC4),
      'term': 'Boarding Pass',
      'definition':
          'A document provided by an airline during check-in, giving a passenger permission to board.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
                // Top bar with progress
                _buildTopBar(),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20.h),

                        // Unit title
                        _buildUnitTitle(),

                        SizedBox(height: 20.h),

                        // Lesson image
                        _buildLessonImage(),

                        SizedBox(height: 20.h),

                        // Listen & Repeat badge
                        _buildListenRepeatBadge(),

                        SizedBox(height: 16.h),

                        // Sentence with highlighted word
                        _buildSentence(),

                        SizedBox(height: 32.h),

                        // Audio controls
                        _buildAudioControls(),

                        // Recording indicator (shown when recording)
                        if (isRecording) ...[
                          SizedBox(height: 16.h),
                          _buildRecordingIndicator(),
                        ],

                        SizedBox(height: 40.h),

                        // Key Vocabulary section
                        _buildVocabularySection(),

                        SizedBox(height: 100.h), // Space for bottom buttons
                      ],
                    ),
                  ),
                ),

                // Bottom navigation buttons
                _buildBottomButtons(),
              ],
            ),

            // Result overlay with blur effect
            if (showResult) _buildResultOverlay(),
          ],
        ),
      ),
    );
  }

  /// Top bar with close button and progress
  Widget _buildTopBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Row(
        children: [
          // Close button
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: MyColors.grey200,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.close,
                size: 24.sp,
                color: MyColors.textPrimary,
              ),
            ),
          ),

          SizedBox(width: 16.w),

          // Progress bar
          Expanded(
            child: Column(
              children: [
                // Progress indicator
                Stack(
                  children: [
                    // Background
                    Container(
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: MyColors.grey200,
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),
                    // Progress
                    FractionallySizedBox(
                      widthFactor: currentStep / totalSteps,
                      child: Container(
                        height: 6.h,
                        decoration: BoxDecoration(
                          color: Color(0xFF4ECDC4),
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 16.w),

          // Progress text
          Text(
            '$currentStep/$totalSteps',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
              color: Color(0xFF4ECDC4),
            ),
          ),
        ],
      ),
    );
  }

  /// Unit title
  Widget _buildUnitTitle() {
    return Text(
      'UNIT 1: At the Airport',
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        fontFamily: 'Montserrat',
        color: Color(0xFF4ECDC4),
        letterSpacing: 0.5,
      ),
    );
  }

  /// Lesson image
  Widget _buildLessonImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: Image.asset(
        'assets/images/courseairport.png',
        width: double.infinity,
        height: 200.h,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 200.h,
            color: MyColors.grey200,
            child: Center(
              child: Icon(
                Icons.image_not_supported,
                size: 48.sp,
                color: MyColors.grey400,
              ),
            ),
          );
        },
      ),
    );
  }

  /// Listen & Repeat badge
  Widget _buildListenRepeatBadge() {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: MyColors.grey200,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          'LISTEN & REPEAT',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
            color: MyColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  /// Sentence with highlighted word
  Widget _buildSentence() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
            color: MyColors.textPrimary,
            height: 1.4,
          ),
          children: [
            TextSpan(text: '"I would like to '),
            TextSpan(
              text: 'check in',
              style: TextStyle(
                color: Color(0xFF4ECDC4),
                fontWeight: FontWeight.w700,
                decoration: TextDecoration.underline,
                decorationColor: Color(0xFF4ECDC4),
                decorationThickness: 2,
              ),
            ),
            TextSpan(text: ' for my flight to London."'),
          ],
        ),
      ),
    );
  }

  /// Audio controls
  Widget _buildAudioControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Speaker button
        _buildAudioButton(
          icon: Icons.volume_up,
          size: 56.w,
          iconSize: 28.sp,
          color: MyColors.grey200,
          iconColor: MyColors.textSecondary,
          onTap: () {
            setState(() {
              isPlaying = !isPlaying;
            });
            // TODO: Play audio
          },
        ),

        SizedBox(width: 24.w),

        // Microphone button (main)
        _buildAudioButton(
          icon: isRecording ? Icons.mic : Icons.mic_none,
          size: 72.w,
          iconSize: 36.sp,
          color: Color(0xFF4ECDC4),
          iconColor: MyColors.white,
          onTap: () {
            if (isRecording) {
              // Stop recording and simulate speech recognition
              _stopRecordingAndCheck();
            } else {
              // Start recording
              setState(() {
                isRecording = true;
                recordedText = '';
              });
            }
          },
        ),

        SizedBox(width: 24.w),

        // Bookmark button
        _buildAudioButton(
          icon: isBookmarked ? Icons.bookmark : Icons.bookmark_border,
          size: 56.w,
          iconSize: 28.sp,
          color: isBookmarked ? Color(0xFF4ECDC4) : MyColors.grey200,
          iconColor: isBookmarked ? MyColors.white : MyColors.textSecondary,
          onTap: () {
            setState(() {
              isBookmarked = !isBookmarked;
            });
          },
        ),
      ],
    );
  }

  /// Single audio button
  Widget _buildAudioButton({
    required IconData icon,
    required double size,
    required double iconSize,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final bool isMicButton = size == 72.w;
    final bool showPulse = isMicButton && isRecording;
    final bool isSpeakerButton = icon == Icons.volume_up;
    final bool showProgress = isSpeakerButton && isPlaying;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulsing outer ring when recording
          if (showPulse)
            Container(
              width: size + 16.w,
              height: size + 16.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color(0xFF4ECDC4).withOpacity(0.3),
                  width: 3,
                ),
              ),
            ),

          // Progress arc for speaker button
          if (showProgress)
            CustomPaint(
              size: Size(size + 10.w, size + 10.w),
              painter: AudioProgressPainter(),
            ),

          // Main button
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: color == Color(0xFF4ECDC4)
                  ? [
                      BoxShadow(
                        color: Color(0xFF4ECDC4).withOpacity(0.3),
                        blurRadius: showPulse ? 20 : 12,
                        offset: Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, size: iconSize, color: iconColor),
          ),
        ],
      ),
    );
  }

  /// Vocabulary section
  Widget _buildVocabularySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Vocabulary',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
            color: MyColors.textPrimary,
          ),
        ),

        SizedBox(height: 16.h),

        ..._vocabulary.map((vocab) => _buildVocabularyCard(vocab)).toList(),
      ],
    );
  }

  /// Single vocabulary card
  Widget _buildVocabularyCard(Map<String, dynamic> vocab) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: MyColors.grey100,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: vocab['iconColor'].withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(vocab['icon'], size: 24.sp, color: vocab['iconColor']),
          ),

          SizedBox(width: 12.w),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vocab['term'],
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                    color: MyColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  vocab['definition'],
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Montserrat',
                    color: MyColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom navigation buttons
  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: MyColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous button (shorter)
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () {
                print('Previous lesson');
                // TODO: Navigate to previous
              },
              child: Container(
                height: 56.h,
                decoration: BoxDecoration(
                  color: MyColors.grey200,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Arrow with glassmorphism
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            size: 18.sp,
                            color: MyColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Previous',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                        color: MyColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SizedBox(width: 12.w),

          // Continue button (longer)
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () {
                print('Next lesson');
                // TODO: Navigate to next
              },
              child: Container(
                height: 56.h,
                decoration: BoxDecoration(
                  color: Color(0xFF4ECDC4),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF4ECDC4).withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Montserrat',
                        color: MyColors.white,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    // Arrow with glassmorphism
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(
                            Icons.arrow_forward,
                            size: 18.sp,
                            color: MyColors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Recording indicator with waveform
  Widget _buildRecordingIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: MyColors.grey100,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          // Timer
          Text(
            '0:02',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              fontFamily: 'Montserrat',
              color: MyColors.textPrimary,
            ),
          ),

          SizedBox(width: 16.w),

          // Waveform animation
          Expanded(child: _buildWaveform()),

          SizedBox(width: 16.w),

          // Stop button
          GestureDetector(
            onTap: () {
              setState(() {
                isRecording = false;
              });
            },
            child: Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: Color(0xFF4ECDC4),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(Icons.stop, color: MyColors.white, size: 24.sp),
            ),
          ),
        ],
      ),
    );
  }

  /// Waveform visualization
  Widget _buildWaveform() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: List.generate(30, (index) {
        // Create varying heights for waveform effect
        final heights = [4, 8, 12, 16, 20, 16, 12, 8, 4];
        final height = heights[index % heights.length].toDouble();

        return Container(
          width: 2.w,
          height: height.h,
          margin: EdgeInsets.symmetric(horizontal: 1.w),
          decoration: BoxDecoration(
            color: index % 3 == 0
                ? MyColors.textPrimary
                : MyColors.textSecondary,
            borderRadius: BorderRadius.circular(1.r),
          ),
        );
      }),
    );
  }

  /// Stop recording and check text match
  void _stopRecordingAndCheck() {
    setState(() {
      isRecording = false;
    });

    // Simulate speech recognition with delay
    Future.delayed(Duration(milliseconds: 500), () {
      // TODO: Replace with actual speech recognition
      // For now, simulate random success/failure
      final random = DateTime.now().millisecond % 2 == 0;

      setState(() {
        // Simulate recognized text
        recordedText = random
            ? 'I would like to check in for my flight to London'
            : 'I would like to checking for my flight to London';
        showResult = true;
      });

      // Auto-hide result after 2 seconds
      final isSuccess = _checkTextMatch(
        random
            ? 'I would like to check in for my flight to London'
            : 'I would like to checking for my flight to London',
        targetSentence,
      );

      Future.delayed(Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            showResult = false;
            recordedText = '';
          });
        }
      });
    });
  }

  /// Check if recorded text matches target sentence
  bool _checkTextMatch(String recorded, String target) {
    // Normalize both texts: lowercase, remove punctuation
    String normalize(String text) {
      return text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();
    }

    final normalizedRecorded = normalize(recorded);
    final normalizedTarget = normalize(target);

    return normalizedRecorded == normalizedTarget;
  }

  /// Build result overlay with blur effect
  Widget _buildResultOverlay() {
    final isSuccess = _checkTextMatch(recordedText, targetSentence);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: Container(
        color: Colors.black.withOpacity(0.3),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                isSuccess
                    ? 'assets/images/success.png'
                    : 'assets/images/tryagain.png',
                fit: BoxFit.contain,
              ),
              SizedBox(height: 16.h),
              Text(
                isSuccess ? 'Successful!' : 'Try Again!',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Montserrat',
                  color: isSuccess ? Color(0xFF2EC4B6) : Color(0xFFF44336),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AudioProgressPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF4ECDC4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - 3) / 2;

    // Draw arc starting from top (-pi/2) and going clockwise
    // Drawing about 240 degrees (4*pi/3) to simulate progress
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.57, // Start at top (-pi/2)
      4.18, // Sweep angle (approx 240 degrees)
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
