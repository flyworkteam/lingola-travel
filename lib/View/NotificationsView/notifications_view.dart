import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';

class NotificationsView extends StatefulWidget {
  final bool isPremiumUser;

  const NotificationsView({
    super.key,
    this.isPremiumUser = false, // Default: free user
  });

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  // Sample notifications data (premium olmayan kullanıcılar için)
  List<NotificationItem> notifications = [
    NotificationItem(
      id: '2',
      icon: '☕',
      title: 'Kahven bitmeden biter!',
      message: 'Sadece 5 dakikalık bir pratik seni bekliyor.',
      time: '17:58',
      isPremium: false,
    ),
    NotificationItem(
      id: '3',
      icon: '😊',
      title: 'Sensiz bunlar çok sessiz...',
      message: '👋 Uzun zaman oldu! Plânlarımızdan hafızanı tazeliyelim mi?',
      time: '14:20',
      isPremium: false,
    ),
  ];

  // Premium notification (always at top for free users)
  final NotificationItem premiumNotification = NotificationItem(
    id: 'premium_sticky',
    icon: '✋',
    title: 'Premium avantajlarını kaçırma!',
    message: 'Premium aboneliği olarak fırsatları yakala',
    time: '17:58',
    isPremium: true,
  );

  void _deleteNotification(String id) {
    // Premium notification cannot be deleted by free users
    if (id == 'premium_sticky' && !widget.isPremiumUser) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Premium bildirimi silinemez'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      notifications.removeWhere((notification) => notification.id == id);
    });
  }

  void _deleteAllNotifications() {
    setState(() {
      notifications.clear();
    });
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          alignment: Alignment.bottomCenter,
          insetPadding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 8.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Trash icon with effect
                Container(
                  width: 64.w,
                  height: 64.h,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFEBEE), // Light red
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFE53935).withOpacity(0.3),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/deleteicon.png',
                    width: 32.w,
                    height: 32.h,
                  ),
                ),

                SizedBox(height: 20.h),

                // Title
                Text(
                  'Delete All Notifications?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                    color: MyColors.textPrimary,
                    height: 1.2,
                  ),
                ),

                SizedBox(height: 10.h),

                // Description
                Text(
                  'Are you sure you want to delete all\nyour notifications? This action\ncannot be undone',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Montserrat',
                    color: MyColors.textSecondary,
                    height: 1.4,
                  ),
                ),

                SizedBox(height: 24.h),

                // Buttons
                Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: Color(0xFFE0E0E0), // Light gray
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                                color: MyColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 16.w),

                    // Delete button
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _deleteAllNotifications();
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: Color(0xFFE53935), // Red
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Center(
                            child: Text(
                              'Delete',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Montserrat',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      appBar: AppBar(
        backgroundColor: MyColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: MyColors.textPrimary,
            size: 24.sp,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
            color: MyColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: MyColors.textPrimary,
              size: 24.sp,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            onSelected: (value) {
              if (value == 'delete_all') {
                _showDeleteAllDialog();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<String>(
                value: 'delete_all',
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/deleteicon.png',
                      width: 24.w,
                      height: 24.h,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Delete All',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Montserrat',
                        color: Color(0xFFE53935),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: (notifications.isEmpty && widget.isPremiumUser)
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64.sp,
                    color: MyColors.textSecondary,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No notifications',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                      color: MyColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              itemCount: widget.isPremiumUser
                  ? notifications.length
                  : notifications.length +
                        1, // +1 for sticky premium notification
              itemBuilder: (context, index) {
                // For free users, show premium notification first (sticky, non-dismissible)
                if (!widget.isPremiumUser && index == 0) {
                  return _buildPremiumNotificationCard(premiumNotification);
                }

                // Adjust index for regular notifications when premium card is shown
                final notificationIndex = widget.isPremiumUser
                    ? index
                    : index - 1;
                final notification = notifications[notificationIndex];

                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Dismissible(
                      key: Key(notification.id),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        _deleteNotification(notification.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Notification deleted'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: EdgeInsets.only(right: 20.w),
                        color: Color(0xFFE53935),
                        child: Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                          size: 28.sp,
                        ),
                      ),
                      child: _buildNotificationCard(notification),
                    ),
                  ),
                );
              },
            ),
    );
  }

  // Premium notification card (sticky, non-dismissible)
  Widget _buildPremiumNotificationCard(NotificationItem notification) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF4ECDC4), // Turquoise
            Color(0xFF44B3AC),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Text(notification.icon, style: TextStyle(fontSize: 24.sp)),

          SizedBox(width: 12.w),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Montserrat',
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 12.w),

          // Time
          Text(
            notification.time,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              fontFamily: 'Montserrat',
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Text(notification.icon, style: TextStyle(fontSize: 24.sp)),

          SizedBox(width: 12.w),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                    color: MyColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Montserrat',
                    color: MyColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 12.w),

          // Time
          Text(
            notification.time,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w400,
              fontFamily: 'Montserrat',
              color: MyColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// Notification model
class NotificationItem {
  final String id;
  final String icon;
  final String title;
  final String message;
  final String time;
  final bool isPremium;

  NotificationItem({
    required this.id,
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.isPremium,
  });
}
