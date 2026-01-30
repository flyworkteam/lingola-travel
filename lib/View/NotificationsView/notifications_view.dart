import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  // Sample notifications data
  List<NotificationItem> notifications = [
    NotificationItem(
      id: '1',
      icon: '✋',
      title: 'Premium avantajlarını kaçırma!',
      message: 'Premium aboneliği olarak fırsatları yakala',
      time: '17:58',
      isPremium: true,
    ),
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

  void _deleteNotification(String id) {
    setState(() {
      notifications.removeWhere((notification) => notification.id == id);
    });
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Container(
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Trash icon
                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFEBEE), // Light red
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Color(0xFFE53935), // Red
                    size: 40.sp,
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                // Title
                Text(
                  'Delete All\nNotifications?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                    color: MyColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                
                SizedBox(height: 12.h),
                
                // Description
                Text(
                  'Are you sure you want to delete all\nyour notifications? This action\ncannot be undone',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Montserrat',
                    color: MyColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                
                SizedBox(height: 32.h),
                
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
                          height: 56.h,
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
                          setState(() {
                            notifications.clear();
                          });
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 56.h,
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
                    Icon(
                      Icons.delete_outline,
                      color: Color(0xFFE53935),
                      size: 20.sp,
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Delete All',
                      style: TextStyle(
                        fontSize: 14.sp,
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
      body: notifications.isEmpty
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
              padding: EdgeInsets.all(16.w),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Dismissible(
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
                    margin: EdgeInsets.only(bottom: 12.h),
                    decoration: BoxDecoration(
                      color: Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 28.sp,
                    ),
                  ),
                  child: _buildNotificationCard(notification),
                );
              },
            ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: notification.isPremium
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4ECDC4), // Turquoise
                  Color(0xFF44B3AC),
                ],
              )
            : null,
        color: notification.isPremium ? null : Colors.white,
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
          Text(
            notification.icon,
            style: TextStyle(fontSize: 24.sp),
          ),
          
          SizedBox(width: 12.w),
          
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                    color: notification.isPremium ? Colors.white : MyColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Montserrat',
                    color: notification.isPremium
                        ? Colors.white.withOpacity(0.9)
                        : MyColors.textSecondary,
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
              color: notification.isPremium
                  ? Colors.white.withOpacity(0.8)
                  : MyColors.textSecondary,
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
