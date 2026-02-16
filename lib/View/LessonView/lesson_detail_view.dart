import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'package:lingola_travel/Services/speech_recognition_service.dart';
import 'package:lingola_travel/Services/tts_service.dart';
import 'package:lingola_travel/Repositories/lesson_repository.dart';
import 'package:lingola_travel/Models/course_model.dart';

class LessonDetailView extends StatefulWidget {
  final String lessonId;
  final bool isPremium;

  const LessonDetailView({
    super.key,
    required this.lessonId,
    this.isPremium = false,
  });

  @override
  State<LessonDetailView> createState() => _LessonDetailViewState();
}

class _LessonDetailViewState extends State<LessonDetailView>
    with TickerProviderStateMixin {
  final SpeechRecognitionService _speechService = SpeechRecognitionService();
  final TtsService _ttsService = TtsService();
  final LessonRepository _lessonRepository = LessonRepository();

  late AnimationController _listenButtonController;
  late Animation<double> _listenButtonAnimation;

  // Lesson data from backend
  LessonModel? _lesson;
  bool _isLoading = true;
  String? _errorMessage;

  int currentStep = 3;
  int totalSteps = 10;
  bool isBookmarked = false; // Bookmark state
  bool isRecording = false; // Recording state
  bool isPlaying = false; // Audio playing state
  String recordedText = ''; // Recorded text from speech recognition
  bool showResult = false; // Show result screen
  double similarityScore = 0.0; // Similarity score from speech comparison
  final GlobalKey _bookmarkButtonKey = GlobalKey(); // Key for bookmark button

  // Recording timer
  Timer? _recordingTimer;
  int _recordingSeconds = 0;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for listen button border
    _listenButtonController = AnimationController(
      duration: Duration(milliseconds: 3000), // 3 seconds for sentence
      vsync: this,
    );

    _listenButtonAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _listenButtonController, curve: Curves.linear),
    );

    _initializeServices();
    _loadLessonData();
  }

  /// Load lesson data from backend
  Future<void> _loadLessonData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _lessonRepository.getLessonById(widget.lessonId);

      if (response.success && response.data != null) {
        setState(() {
          _lesson = response.data;
          totalSteps = response.data!.totalSteps;
          _isLoading = false;
        });
        print('✅ Lesson loaded: ${_lesson?.title}');
        print('📝 Example sentence: ${_lesson?.exampleSentence}');
        print('🔑 Key vocabulary: ${_lesson?.keyVocabularyTerm}');
        print('📚 Vocabulary count: ${_lesson?.vocabulary?.length ?? 0}');
      } else {
        setState(() {
          _errorMessage = (response.error ?? 'Ders yüklenemedi').toString();
          _isLoading = false;
        });
        print('❌ Lesson load failed: ${response.error}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Bir hata oluştu: $e';
        _isLoading = false;
      });
      print('❌ Error loading lesson: $e');
    }
  }

  /// Initialize TTS and Speech Recognition services
  Future<void> _initializeServices() async {
    try {
      await _ttsService.init();
      await _speechService.initialize();
      print('✅ TTS and Speech Recognition initialized');
    } catch (e) {
      print('❌ Error initializing services: $e');
    }
  }

  @override
  void dispose() {
    _listenButtonController.dispose();
    _recordingTimer?.cancel();
    _ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator
    if (_isLoading) {
      return Scaffold(
        backgroundColor: MyColors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF4ECDC4)),
        ),
      );
    }

    // Show error message
    if (_errorMessage != null || _lesson == null) {
      return Scaffold(
        backgroundColor: MyColors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48.sp, color: MyColors.grey400),
              SizedBox(height: 16.h),
              Text(
                _errorMessage ?? 'Ders bulunamadı',
                style: TextStyle(fontSize: 16.sp, color: MyColors.grey600),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Geri Dön'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: MyColors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Main scrollable content with bottom buttons
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar with progress
                  _buildTopBar(),

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

                  SizedBox(height: 24.h),

                  // Bottom navigation buttons (inside scroll)
                  _buildBottomButtons(),

                  SizedBox(height: 32.h), // Extra bottom padding
                ],
              ),
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
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
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
      _lesson?.title.toUpperCase() ?? 'LOADING...',
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
    final sentence = _lesson?.exampleSentence ?? '';
    final keyTerm = _lesson?.keyVocabularyTerm ?? '';

    if (sentence.isEmpty) {
      return Center(
        child: Text(
          'Cümle yükleniyor...',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            fontFamily: 'Montserrat',
            color: MyColors.textSecondary,
          ),
        ),
      );
    }

    // Find the key vocabulary term in the sentence (case insensitive)
    final lowerSentence = sentence.toLowerCase();
    final lowerKeyTerm = keyTerm.toLowerCase();
    final startIndex = lowerSentence.indexOf(lowerKeyTerm);

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
          children: startIndex >= 0 && keyTerm.isNotEmpty
              ? [
                  // Text before the key term
                  if (startIndex > 0)
                    TextSpan(text: '"${sentence.substring(0, startIndex)}'),
                  // Highlighted key term
                  TextSpan(
                    text: sentence.substring(
                      startIndex,
                      startIndex + keyTerm.length,
                    ),
                    style: TextStyle(
                      color: Color(0xFF4ECDC4),
                      fontWeight: FontWeight.w700,
                      decoration: TextDecoration.underline,
                      decorationColor: Color(0xFF4ECDC4),
                      decorationThickness: 2,
                    ),
                  ),
                  // Text after the key term
                  TextSpan(
                    text: '${sentence.substring(startIndex + keyTerm.length)}"',
                  ),
                ]
              : [
                  // No highlighting if key term not found
                  TextSpan(text: '"$sentence"'),
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
        // Speaker button with progress animation
        AnimatedBuilder(
          animation: _listenButtonAnimation,
          builder: (context, child) {
            return _buildAudioButton(
              iconPath: 'assets/icons/volume.svg',
              size: 56.w,
              iconSize: 22.sp,
              color: MyColors.grey200,
              iconColor: MyColors.textSecondary,
              borderProgress: isPlaying ? _listenButtonAnimation.value : 0.0,
              onTap: () async {
                if (isPlaying) {
                  // Stop TTS
                  await _ttsService.stop();
                  _listenButtonController.stop();
                  _listenButtonController.reset();
                  setState(() {
                    isPlaying = false;
                  });
                } else {
                  final sentence = _lesson?.exampleSentence ?? '';
                  if (sentence.isEmpty) {
                    print('❌ No sentence to speak');
                    return;
                  }

                  // Start TTS and animation
                  setState(() {
                    isPlaying = true;
                  });

                  // Start border animation
                  _listenButtonController.reset();
                  _listenButtonController.forward();

                  try {
                    await _ttsService.speak(sentence);
                    // Wait a bit to ensure completion
                    await Future.delayed(Duration(milliseconds: 500));
                  } catch (e) {
                    print('❌ TTS error: $e');
                  } finally {
                    if (mounted) {
                      _listenButtonController.stop();
                      _listenButtonController.reset();
                      setState(() {
                        isPlaying = false;
                      });
                    }
                  }
                }
              },
            );
          },
        ),

        SizedBox(width: 24.w),

        // Microphone button (main)
        _buildAudioButton(
          iconPath: 'assets/icons/microphone.svg',
          size: 72.w,
          iconSize: 30.sp,
          color: Color(0xFF4ECDC4),
          iconColor: MyColors.white,
          onTap: () {
            if (isRecording) {
              // Stop recording and check
              _stopRecordingAndCheck();
            } else {
              // Start recording
              _startRecording();
            }
          },
        ),

        SizedBox(width: 24.w),

        // Bookmark button
        Container(
          key: _bookmarkButtonKey,
          child: _buildAudioButton(
            iconPath: 'assets/icons/save.svg',
            size: 56.w,
            iconSize: 22.sp,
            color: isBookmarked ? Color(0xFF4ECDC4) : MyColors.grey200,
            iconColor: isBookmarked ? MyColors.white : MyColors.textSecondary,
            onTap: () {
              _showSaveDialog();
            },
          ),
        ),
      ],
    );
  }

  /// Single audio button
  Widget _buildAudioButton({
    required String iconPath,
    required double size,
    required double iconSize,
    required Color color,
    required Color iconColor,
    required VoidCallback onTap,
    double borderProgress = 0.0,
  }) {
    final bool isMicButton = size == 72.w;
    final bool showPulse = isMicButton && isRecording;
    final bool showBorderProgress = borderProgress > 0.0;

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

          // Progress arc for speaker button (green border fill)
          if (showBorderProgress)
            CustomPaint(
              size: Size(size + 12.w, size + 12.w),
              painter: CircularProgressPainter(
                progress: borderProgress,
                color: Color(0xFF4ECDC4),
                strokeWidth: 4,
              ),
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
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                width: iconSize,
                height: iconSize,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Vocabulary section
  Widget _buildVocabularySection() {
    final vocabulary = _lesson?.vocabulary ?? [];

    if (vocabulary.isEmpty) {
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
          Center(
            child: Text(
              'Kelime bulunamadı',
              style: TextStyle(fontSize: 14.sp, color: MyColors.textSecondary),
            ),
          ),
        ],
      );
    }

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

        ...vocabulary.map((vocab) => _buildVocabularyCard(vocab)).toList(),
      ],
    );
  }

  /// Single vocabulary card
  Widget _buildVocabularyCard(LessonVocabularyModel vocab) {
    // Parse icon color from string (e.g., "#4ECDC4")
    Color iconColor = Color(0xFF4ECDC4);
    if (vocab.iconColor != null && vocab.iconColor!.startsWith('#')) {
      try {
        iconColor = Color(
          int.parse(vocab.iconColor!.substring(1), radix: 16) + 0xFF000000,
        );
      } catch (e) {
        // Use default color if parsing fails
      }
    }

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
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Center(
              child: _buildVocabularyIcon(vocab.iconPath, iconColor),
            ),
          ),

          SizedBox(width: 12.w),

          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vocab.term,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                    color: MyColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  vocab.definition,
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

  /// Build vocabulary icon with error handling
  Widget _buildVocabularyIcon(String? iconPath, Color iconColor) {
    // If no icon path, show default icon
    if (iconPath == null || iconPath.isEmpty) {
      return Icon(Icons.translate, size: 20.sp, color: iconColor);
    }

    // Return icon builder that handles errors gracefully
    return Builder(
      builder: (context) {
        try {
          // Check if asset exists before loading
          return SvgPicture.asset(
            iconPath,
            width: 20.w,
            height: 20.w,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            fit: BoxFit.contain,
            placeholderBuilder: (context) =>
                Icon(Icons.translate, size: 20.sp, color: iconColor),
          );
        } catch (e) {
          print('⚠️ SVG error for $iconPath: $e');
          // Return safe fallback icon
          return Icon(Icons.translate, size: 20.sp, color: iconColor);
        }
      },
    );
  }

  /// Bottom navigation buttons
  Widget _buildBottomButtons() {
    return Row(
      children: [
        // Previous button (shorter)
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: () {
              // Navigate back to previous screen (course detail)
              Navigator.pop(context);
            },
            child: Container(
              height: 48.h, // 56.h'den 48.h'ye küçültüldü
              decoration: BoxDecoration(
                color: MyColors.grey200,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Arrow with glassmorphism on the far left
                  Positioned(
                    left: 8.w,
                    child: ClipRRect(
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
                            size: 16.sp, // 18.sp'den 16.sp'ye küçültüldü
                            color: MyColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Text(
                    'Previous',
                    style: TextStyle(
                      fontSize: 14.sp, // 15.sp'den 14.sp'ye küçültüldü
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
              // Check if lesson is completed successfully
              if (currentStep < totalSteps) {
                // Move to next step within lesson
                setState(() {
                  currentStep++;
                });
                print('✅ Moved to step $currentStep/$totalSteps');
              } else {
                // Lesson completed, go back to course detail
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🎉 Lesson completed!'),
                    duration: Duration(seconds: 2),
                    backgroundColor: Color(0xFF4ECDC4),
                  ),
                );
                Future.delayed(Duration(seconds: 2), () {
                  Navigator.pop(context);
                });
              }
            },
            child: Container(
              height: 48.h, // 56.h'den 48.h'ye küçültüldü
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
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 15.sp, // 16.sp'den 15.sp'ye küçültüldü
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Montserrat',
                      color: MyColors.white,
                    ),
                  ),
                  // Arrow with glassmorphism on the far right
                  Positioned(
                    right: 8.w,
                    child: ClipRRect(
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
                            size: 16.sp, // 18.sp'den 16.sp'ye küçültüldü
                            color: MyColors.white,
                          ),
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
    );
  }

  /// Recording indicator with waveform
  Widget _buildRecordingIndicator() {
    // Format seconds as MM:SS
    final minutes = _recordingSeconds ~/ 60;
    final seconds = _recordingSeconds % 60;
    final timeString = '$minutes:${seconds.toString().padLeft(2, '0')}';

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
            timeString,
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
              _stopRecordingAndCheck();
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

  /// Show save dropdown menu to choose Word or Phrase
  void _showSaveDialog() async {
    // Get the render box for positioning
    final RenderBox? button =
        _bookmarkButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (button == null) return;

    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    final Offset buttonPosition = button.localToGlobal(
      Offset.zero,
      ancestor: overlay,
    );

    // Position it slightly shifted to the right of the button's edge
    final RelativeRect position = RelativeRect.fromLTRB(
      buttonPosition.dx + button.size.width - 100.w, // Shift left edge right
      buttonPosition.dy + button.size.height + 8.h,
      MediaQuery.of(context).size.width -
          (buttonPosition.dx +
              button.size.width +
              20.w), // Shift right edge past button
      0,
    );

    final result = await showMenu<String>(
      context: context,
      position: position,
      color: Colors.white,
      useRootNavigator: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.08),
      constraints: BoxConstraints(minWidth: 120.w, maxWidth: 120.w),
      surfaceTintColor: Colors.white,
      items: [
        PopupMenuItem<String>(
          value: 'word',
          height: 40.h,
          child: Center(
            child: Text(
              'Word',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
                color: Color(0xFF8B9AAF),
              ),
            ),
          ),
        ),
        PopupMenuDivider(height: 1.h),
        PopupMenuItem<String>(
          value: 'phrase',
          height: 40.h,
          child: Center(
            child: Text(
              'Phrases',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                fontFamily: 'Montserrat',
                color: Color(0xFF8B9AAF),
              ),
            ),
          ),
        ),
      ],
    );

    if (result != null) {
      _saveItem(result);
    }
  }

  /// Save item to library
  void _saveItem(String type) {
    setState(() {
      isBookmarked = true;
    });

    // SnackBar feedback removed as requested by user
    // Button color change in build method provides the visual feedback
    print('Saved as $type');
  }

  /// Start speech recognition
  void _startRecording() async {
    setState(() {
      isRecording = true;
      recordedText = '';
      similarityScore = 0.0;
      _recordingSeconds = 0;
    });

    // Start recording timer
    _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted && isRecording) {
        setState(() {
          _recordingSeconds++;
        });
      }
    });

    // Get language code from lesson
    final languageCode = _lesson?.targetLanguage ?? 'en';

    try {
      await _speechService.startListening(
        languageCode: languageCode,
        onResult: (recognizedText) {
          // Final result
          print('🎤 Recognized: $recognizedText');
          setState(() {
            recordedText = recognizedText;
          });
          _stopRecordingAndCheck();
        },
        onPartialResult: (partialText) {
          // Partial recognition (optional)
          print('🎤 Partial: $partialText');
        },
      );
    } catch (e) {
      print('❌ Speech recognition error: $e');
      _recordingTimer?.cancel();
      setState(() {
        isRecording = false;
        _recordingSeconds = 0;
      });
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mikrofon hatası. Lütfen tekrar deneyin.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  /// Stop recording and check text match
  void _stopRecordingAndCheck() async {
    _recordingTimer?.cancel();

    setState(() {
      isRecording = false;
    });

    await _speechService.stopListening();

    // Check if we have recorded text
    if (recordedText.isEmpty) {
      print('⚠️ No text was recognized');
      setState(() {
        _recordingSeconds = 0;
      });
      return;
    }

    // Get target sentence from lesson
    final targetSentence = _lesson?.exampleSentence ?? '';
    if (targetSentence.isEmpty) {
      print('⚠️ No target sentence available');
      return;
    }

    // Calculate similarity score
    similarityScore = _speechService.compareTexts(recordedText, targetSentence);
    print('📊 Similarity score: $similarityScore');
    print('🎯 Target: $targetSentence');
    print('🗣️ Spoken: $recordedText');

    // Show result
    setState(() {
      showResult = true;
    });

    // Auto-hide result after 2.5 seconds
    Future.delayed(Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          showResult = false;
          recordedText = '';
          _recordingSeconds = 0;
        });
      }
    });
  }

  /// Check if speech is successful (similarity >= 0.8)
  bool _isSuccessful() {
    return similarityScore >= 0.8;
  }

  /// Build result overlay with blur effect
  Widget _buildResultOverlay() {
    final isSuccess = _isSuccessful();

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
              SizedBox(height: 8.h),
              Text(
                'Score: ${(similarityScore * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Montserrat',
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for circular progress indicator around listen button
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.color,
    this.strokeWidth = 4,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw arc starting from top (-pi/2) and going clockwise based on progress
    // progress = 0.0 means no arc, progress = 1.0 means full circle
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // Start at top (-pi/2)
      6.2832 * progress, // Sweep angle based on progress (2*pi * progress)
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
