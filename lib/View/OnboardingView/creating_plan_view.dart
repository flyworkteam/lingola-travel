import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Core/Theme/my_colors.dart';
import '../../Core/Routes/app_routes.dart';

/// Creating Personalized Plan View - Loading Screen
/// Shows animated progress while creating user's personalized plan
class CreatingPlanView extends StatefulWidget {
  const CreatingPlanView({super.key});

  @override
  State<CreatingPlanView> createState() => _CreatingPlanViewState();
}

class _CreatingPlanViewState extends State<CreatingPlanView>
    with TickerProviderStateMixin {
  late AnimationController _rotationController1;
  late AnimationController _rotationController2;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  int _currentProgress = 0;
  String _currentStatus = 'Analyzing your professional background...';

  final List<String> _statusMessages = [
    'Analyzing your professional background...',
    'Customizing vocabulary sets...',
    'Preparing your learning path...',
    'Optimizing for your goals...',
    'Finalizing your personalized plan...',
  ];

  @override
  void initState() {
    super.initState();

    // First rotation animation (clockwise)
    _rotationController1 = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    // Second rotation animation (counter-clockwise, faster)
    _rotationController2 = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    // Progress animation
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 4500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0, end: 100).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeInOut,
      ),
    )..addListener(() {
        setState(() {
          _currentProgress = _progressAnimation.value.toInt();
          
          // Update status message based on progress
          if (_currentProgress < 20) {
            _currentStatus = _statusMessages[0];
          } else if (_currentProgress < 40) {
            _currentStatus = _statusMessages[1];
          } else if (_currentProgress < 60) {
            _currentStatus = _statusMessages[2];
          } else if (_currentProgress < 80) {
            _currentStatus = _statusMessages[3];
          } else {
            _currentStatus = _statusMessages[4];
          }
        });
      });

    // Start progress after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _progressController.forward();
    });
  }

  @override
  void dispose() {
    _rotationController1.dispose();
    _rotationController2.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _onGetStarted() {
    if (_currentProgress >= 100) {
      // TODO: Navigate to home screen
      // Navigator.pushReplacementNamed(context, AppRoutes.home);
      print('Navigating to home...');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            children: [
              SizedBox(height: 60.h),

              // Title
              Text(
                'Creating Your\nPersonalized Plan',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                  color: MyColors.black,
                  height: 1.2,
                ),
              ),

              SizedBox(height: 16.h),

              // Subtitle
              Text(
                'Our AI is tailoring your language\ntravel experience based on your\nunique goals.',
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  color: MyColors.grey600,
                  height: 1.4,
                ),
              ),

              SizedBox(height: 60.h),

              // Animated Progress Circle with Globe
              SizedBox(
                width: 240.w,
                height: 240.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer ring - rotating clockwise
                    AnimatedBuilder(
                      animation: _rotationController1,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationController1.value * 2 * 3.14159,
                          child: CustomPaint(
                            size: Size(240.w, 240.w),
                            painter: CircularProgressPainter(
                              progress: 0.65, // Fixed 65% arc
                              color: MyColors.lingolaPrimaryColor,
                              strokeWidth: 3.w,
                            ),
                          ),
                        );
                      },
                    ),

                    // Middle ring - rotating counter-clockwise
                    AnimatedBuilder(
                      animation: _rotationController2,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: -_rotationController2.value * 2 * 3.14159,
                          child: CustomPaint(
                            size: Size(200.w, 200.w),
                            painter: CircularProgressPainter(
                              progress: 0.5, // Fixed 50% arc
                              color: MyColors.lingolaPrimaryColor.withOpacity(0.4),
                              strokeWidth: 3.w,
                            ),
                          ),
                        );
                      },
                    ),

                    // Inner circle background
                    Container(
                      width: 160.w,
                      height: 160.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: MyColors.lingolaPrimaryColor.withOpacity(0.1),
                      ),
                    ),

                    // Globe icon
                    Image.asset(
                      'assets/images/dunya.png',
                      width: 80.w,
                      height: 80.w,
                      fit: BoxFit.contain,
                      color: MyColors.lingolaPrimaryColor,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 60.h),

              // Status message
              Text(
                _currentStatus,
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: MyColors.black,
                ),
              ),

              SizedBox(height: 24.h),

              // Progress bar with percentage
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Optimization',
                        style: GoogleFonts.montserrat(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: MyColors.black,
                        ),
                      ),
                      Text(
                        '$_currentProgress%',
                        style: GoogleFonts.montserrat(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: MyColors.lingolaPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: LinearProgressIndicator(
                      value: _currentProgress / 100,
                      minHeight: 8.h,
                      backgroundColor: MyColors.grey200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        MyColors.lingolaPrimaryColor,
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              // Get Started Button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: _currentProgress >= 100 ? _onGetStarted : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.lingolaPrimaryColor,
                    disabledBackgroundColor: MyColors.grey300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Get Started',
                    style: GoogleFonts.montserrat(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: MyColors.white,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom painter for circular progress indicator
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Draw arc (progress)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start from top
      2 * 3.14159 * progress, // Progress angle
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
