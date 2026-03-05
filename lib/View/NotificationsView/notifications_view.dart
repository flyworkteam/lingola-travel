import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import 'package:lingola_travel/Models/notification_model.dart';
import 'package:lingola_travel/Repositories/notification_repository.dart';
import 'package:lingola_travel/generated/locale_keys.g.dart';

class NotificationsView extends StatefulWidget {
  final bool isPremiumUser;

  const NotificationsView({super.key, this.isPremiumUser = false});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  final NotificationRepository _notificationRepository =
      NotificationRepository();

  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _notificationRepository.getNotifications();

      if (response.success && response.data != null) {
        setState(() {
          _notifications = response.data!;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage =
              response.error?.toString() ??
              LocaleKeys.notifications_load_failed.tr();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '${LocaleKeys.error_occurred.tr()}: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteNotification(String id) async {
    try {
      final response = await _notificationRepository.deleteNotification(id);

      if (response.success) {
        setState(() {
          _notifications.removeWhere((notification) => notification.id == id);
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.error?.toString() ??
                    LocaleKeys.notifications_delete_failed.tr(),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${LocaleKeys.error_occurred.tr()}: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _deleteAllNotifications() async {
    try {
      final response = await _notificationRepository.deleteAllNotifications();

      if (response.success) {
        setState(() {
          _notifications.clear();
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response.error?.toString() ??
                    LocaleKeys.notifications_delete_failed.tr(),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${LocaleKeys.error_occurred.tr()}: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
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
                Container(
                  width: 64.w,
                  height: 64.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE53935).withOpacity(0.3),
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
                Text(
                  LocaleKeys.notifications_delete_all_confirm_title.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                    color: MyColors.textPrimary,
                    height: 1.2,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  LocaleKeys.notifications_delete_all_confirm_subtitle.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13.sp,
                    letterSpacing: -0.3,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'Montserrat',
                    color: MyColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E0E0),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Center(
                            child: Text(
                              LocaleKeys.notifications_cancel_btn.tr(),
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
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          _deleteAllNotifications();
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          height: 48.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Center(
                            child: Text(
                              LocaleKeys.notifications_delete_btn.tr(),
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
    final normalNotifications = _notifications
        .where((n) => !n.isPremiumPromo)
        .toList();

    final bool showPremiumPromo = !widget.isPremiumUser;

    return Scaffold(
      backgroundColor: MyColors.background,
      appBar: AppBar(
        backgroundColor: MyColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 48,
        leading: Padding(
          padding: const EdgeInsets.only(left: 24.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: SvgPicture.asset(
              width: 13,
              'assets/icons/gerigelmeiconu.svg',
              fit: BoxFit.contain,
            ),
          ),
        ),
        title: Text(
          LocaleKeys.notifications_title.tr(),
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat',
            color: MyColors.textPrimary,
          ),
        ),
        centerTitle: true,
        actions: [
          Theme(
            data: Theme.of(context).copyWith(
              // Sağ tık menüsünün Material 3 tasarımlarındaki renklenmesini engeller
              popupMenuTheme: PopupMenuThemeData(
                color: Colors.white,
                surfaceTintColor: Colors.white,
              ),
            ),
            child: PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: MyColors.textPrimary,
                size: 24.sp,
              ),
              color: Colors.white,
              surfaceTintColor: Colors.white, // Tam bembeyaz olması için kritik
              elevation: 6, // Tasarımdaki o hafif gölgeyi verir
              offset: const Offset(
                0,
                45,
              ), // Butonun tam altına hizalanmasını sağlar
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  16.r,
                ), // Tasarımdaki yumuşak köşeler
              ),
              onSelected: (value) {
                if (value == 'delete_all') {
                  _showDeleteAllDialog();
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'delete_all',
                  height: 40.h, // Daha sıkı bir yükseklik
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min, // Sadece gerektiği kadar yer kapla
                    children: [
                      SvgPicture.asset(
                        'assets/icons/cop.svg',
                        width: 20.w, // İkon boyutu
                        height: 20.w,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFFE53935),
                          BlendMode.srcIn,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        LocaleKeys.notifications_delete_all_btn.tr(),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight:
                              FontWeight.w600, // Tasarımdaki gibi biraz kalın
                          fontFamily: 'Montserrat',
                          color: const Color(0xFFE53935),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4ECDC4)),
            )
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.sp, color: Colors.red),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: _loadNotifications,
                    child: Text(LocaleKeys.notifications_retry_btn.tr()),
                  ),
                ],
              ),
            )
          : (!showPremiumPromo && normalNotifications.isEmpty)
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
                    LocaleKeys.notifications_no_notifications.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Montserrat',
                      color: MyColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadNotifications,
              color: const Color(0xFF4ECDC4),
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                children: [
                  if (showPremiumPromo)
                    Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _buildStaticPremiumPromoCard(),
                    ),
                  ...normalNotifications.map((notification) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Dismissible(
                        key: Key(notification.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          _deleteNotification(notification.id);
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20.w),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(22.r),
                          ),
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                            size: 28.sp,
                          ),
                        ),
                        child: _buildNotificationCard(notification),
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }

  Widget _buildStaticPremiumPromoCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: MyColors.lingolaPrimaryColor,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFDCE1EC),
            blurRadius: 4,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🥇', style: TextStyle(fontSize: 24.sp)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  LocaleKeys.notifications_premium_promo_title.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  LocaleKeys.notifications_premium_promo_subtitle.tr(),
                  style: TextStyle(
                    fontSize: 13.sp,
                    letterSpacing: -0.5,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Montserrat',
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: notification.isRead ? MyColors.grey100 : Colors.white,
        borderRadius: BorderRadius.circular(22.r),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFDCE1EC),
            blurRadius: 4,
            offset: Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(notification.icon, style: TextStyle(fontSize: 24.sp)),
          SizedBox(width: 12.w),
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
          Text(
            notification.getFormattedTime(),
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
