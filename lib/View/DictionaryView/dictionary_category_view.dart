import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lingola_travel/Core/Theme/my_colors.dart';
import '../VocabularyView/travel_vocabulary_view.dart';
import 'visual_dictionary_view.dart';
import '../ProfileView/profile_view.dart';

class DictionaryCategoryView extends StatefulWidget {
  final String categoryName;

  const DictionaryCategoryView({super.key, required this.categoryName});

  @override
  State<DictionaryCategoryView> createState() => _DictionaryCategoryViewState();
}

class _DictionaryCategoryViewState extends State<DictionaryCategoryView> {
  final TextEditingController _searchController = TextEditingController();
  Set<String> _bookmarkedItems = {};
  int _selectedNavIndex = 2; // Dictionary is index 2

  // Mock data for different categories
  final Map<String, List<Map<String, String>>> _categoryWords = {
    'Airport': [
      {'english': 'Passport', 'turkish': 'Pasaport'},
      {'english': 'Boarding Pass', 'turkish': 'Biniş Kartı'},
      {'english': 'Departure', 'turkish': 'Kalkış'},
      {'english': 'Arrival', 'turkish': 'Varış'},
      {'english': 'Gate', 'turkish': 'Kapı'},
      {'english': 'Baggage Claim', 'turkish': 'Bagaj Alanı'},
      {'english': 'Check-in', 'turkish': 'Bilet ve bagaj işlemi'},
      {'english': 'Flight', 'turkish': 'Uçuş'},
      {'english': 'Security', 'turkish': 'Güvenlik'},
      {'english': 'Customs', 'turkish': 'Gümrük'},
      {'english': 'Terminal', 'turkish': 'Terminal'},
      {'english': 'Runway', 'turkish': 'Pist'},
    ],
    'Accommodation': [
      {'english': 'Hotel', 'turkish': 'Otel'},
      {'english': 'Room', 'turkish': 'Oda'},
      {'english': 'Reception', 'turkish': 'Resepsiyon'},
      {'english': 'Reservation', 'turkish': 'Rezervasyon'},
      {'english': 'Check-in', 'turkish': 'Giriş'},
      {'english': 'Check-out', 'turkish': 'Çıkış'},
      {'english': 'Key Card', 'turkish': 'Anahtar Kart'},
      {'english': 'Breakfast', 'turkish': 'Kahvaltı'},
      {'english': 'Housekeeping', 'turkish': 'Oda Servisi'},
      {'english': 'Lobby', 'turkish': 'Lobi'},
    ],
    'Transportation': [
      {'english': 'Taxi', 'turkish': 'Taksi'},
      {'english': 'Bus', 'turkish': 'Otobüs'},
      {'english': 'Train', 'turkish': 'Tren'},
      {'english': 'Subway', 'turkish': 'Metro'},
      {'english': 'Ticket', 'turkish': 'Bilet'},
      {'english': 'Station', 'turkish': 'İstasyon'},
      {'english': 'Driver', 'turkish': 'Sürücü'},
      {'english': 'Fare', 'turkish': 'Ücret'},
      {'english': 'Stop', 'turkish': 'Durak'},
      {'english': 'Schedule', 'turkish': 'Tarife'},
    ],
    'Food & Drink': [
      {'english': 'Restaurant', 'turkish': 'Restoran'},
      {'english': 'Menu', 'turkish': 'Menü'},
      {'english': 'Waiter', 'turkish': 'Garson'},
      {'english': 'Bill', 'turkish': 'Hesap'},
      {'english': 'Breakfast', 'turkish': 'Kahvaltı'},
      {'english': 'Lunch', 'turkish': 'Öğle Yemeği'},
      {'english': 'Dinner', 'turkish': 'Akşam Yemeği'},
      {'english': 'Water', 'turkish': 'Su'},
      {'english': 'Coffee', 'turkish': 'Kahve'},
      {'english': 'Tea', 'turkish': 'Çay'},
      {'english': 'Dessert', 'turkish': 'Tatlı'},
      {'english': 'Tip', 'turkish': 'Bahşiş'},
    ],
    'Shopping': [
      {'english': 'Store', 'turkish': 'Mağaza'},
      {'english': 'Price', 'turkish': 'Fiyat'},
      {'english': 'Sale', 'turkish': 'İndirim'},
      {'english': 'Receipt', 'turkish': 'Fiş'},
      {'english': 'Cash', 'turkish': 'Nakit'},
      {'english': 'Credit Card', 'turkish': 'Kredi Kartı'},
      {'english': 'Size', 'turkish': 'Beden'},
      {'english': 'Color', 'turkish': 'Renk'},
      {'english': 'Discount', 'turkish': 'İndirim'},
      {'english': 'Refund', 'turkish': 'İade'},
      {'english': 'Shopping Bag', 'turkish': 'Alışveriş Çantası'},
      {'english': 'Fitting Room', 'turkish': 'Deneme Kabini'},
    ],
    'Culture': [
      {'english': 'Museum', 'turkish': 'Müze'},
      {'english': 'Gallery', 'turkish': 'Galeri'},
      {'english': 'Theater', 'turkish': 'Tiyatro'},
      {'english': 'Concert', 'turkish': 'Konser'},
      {'english': 'Exhibition', 'turkish': 'Sergi'},
      {'english': 'Ticket', 'turkish': 'Bilet'},
      {'english': 'Guide', 'turkish': 'Rehber'},
      {'english': 'Tour', 'turkish': 'Tur'},
      {'english': 'Monument', 'turkish': 'Anıt'},
      {'english': 'Historic Site', 'turkish': 'Tarihi Alan'},
    ],
    'Meeting': [
      {'english': 'Conference', 'turkish': 'Konferans'},
      {'english': 'Meeting Room', 'turkish': 'Toplantı Odası'},
      {'english': 'Presentation', 'turkish': 'Sunum'},
      {'english': 'Schedule', 'turkish': 'Program'},
      {'english': 'Appointment', 'turkish': 'Randevu'},
      {'english': 'Business Card', 'turkish': 'Kartvizit'},
      {'english': 'Colleague', 'turkish': 'Meslektaş'},
      {'english': 'Client', 'turkish': 'Müşteri'},
      {'english': 'Partner', 'turkish': 'Ortak'},
      {'english': 'Agreement', 'turkish': 'Anlaşma'},
    ],
    'Sport': [
      {'english': 'Gym', 'turkish': 'Spor Salonu'},
      {'english': 'Swimming Pool', 'turkish': 'Yüzme Havuzu'},
      {'english': 'Fitness', 'turkish': 'Fitness'},
      {'english': 'Trainer', 'turkish': 'Antrenör'},
      {'english': 'Equipment', 'turkish': 'Ekipman'},
      {'english': 'Membership', 'turkish': 'Üyelik'},
      {'english': 'Locker', 'turkish': 'Dolap'},
      {'english': 'Towel', 'turkish': 'Havlu'},
      {'english': 'Exercise', 'turkish': 'Egzersiz'},
      {'english': 'Yoga', 'turkish': 'Yoga'},
    ],
    'Health': [
      {'english': 'Hospital', 'turkish': 'Hastane'},
      {'english': 'Doctor', 'turkish': 'Doktor'},
      {'english': 'Pharmacy', 'turkish': 'Eczane'},
      {'english': 'Medicine', 'turkish': 'İlaç'},
      {'english': 'Prescription', 'turkish': 'Reçete'},
      {'english': 'Emergency', 'turkish': 'Acil'},
      {'english': 'Appointment', 'turkish': 'Randevu'},
      {'english': 'Symptoms', 'turkish': 'Belirtiler'},
      {'english': 'Pain', 'turkish': 'Ağrı'},
      {'english': 'Fever', 'turkish': 'Ateş'},
      {'english': 'Headache', 'turkish': 'Baş Ağrısı'},
      {'english': 'Insurance', 'turkish': 'Sigorta'},
    ],
    'Business': [
      {'english': 'Office', 'turkish': 'Ofis'},
      {'english': 'Manager', 'turkish': 'Müdür'},
      {'english': 'Employee', 'turkish': 'Çalışan'},
      {'english': 'Contract', 'turkish': 'Sözleşme'},
      {'english': 'Salary', 'turkish': 'Maaş'},
      {'english': 'Invoice', 'turkish': 'Fatura'},
      {'english': 'Report', 'turkish': 'Rapor'},
      {'english': 'Deadline', 'turkish': 'Son Tarih'},
      {'english': 'Project', 'turkish': 'Proje'},
      {'english': 'Budget', 'turkish': 'Bütçe'},
      {'english': 'Profit', 'turkish': 'Kâr'},
      {'english': 'Loss', 'turkish': 'Zarar'},
    ],
  };

  List<Map<String, String>> get _words {
    return _categoryWords[widget.categoryName] ?? [];
  }

  int get _itemCount {
    final counts = {
      'Airport': 1240,
      'Accommodation': 1000,
      'Transportation': 980,
      'Food & Drink': 1250,
      'Shopping': 1520,
      'Culture': 550,
      'Meeting': 1520,
      'Sport': 1550,
      'Health': 1520,
      'Business': 1550,
    };
    return counts[widget.categoryName] ?? 0;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleBookmark(String id) {
    setState(() {
      if (_bookmarkedItems.contains(id)) {
        _bookmarkedItems.remove(id);
      } else {
        _bookmarkedItems.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.background,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 16.h),

              // Search bar
              _buildSearchBar(),

              SizedBox(height: 16.h),

              // Item count
              _buildItemCount(),

              SizedBox(height: 16.h),

              // Word list
              Expanded(child: _buildWordList()),
            ],
          ),

          // Floating bottom navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 20.h,
            child: _buildBottomNavigationBar(),
          ),
        ],
      ),
    );
  }

  /// AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: MyColors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: MyColors.textPrimary, size: 24.sp),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.categoryName,
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
          fontFamily: 'Montserrat',
          color: MyColors.textPrimary,
        ),
      ),
      centerTitle: true,
    );
  }

  /// Search bar
  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        height: 48.h,
        decoration: BoxDecoration(
          color: MyColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: MyColors.border, width: 1),
        ),
        child: TextField(
          controller: _searchController,
          style: TextStyle(
            fontSize: 14.sp,
            fontFamily: 'Montserrat',
            color: MyColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'Search words or phrases...',
            hintStyle: TextStyle(
              fontSize: 14.sp,
              fontFamily: 'Montserrat',
              color: MyColors.textSecondary,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: MyColors.textSecondary,
              size: 20.sp,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12.h),
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
      ),
    );
  }

  /// Item count
  Widget _buildItemCount() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '$_itemCount items',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            fontFamily: 'Montserrat',
            color: MyColors.textSecondary,
          ),
        ),
      ),
    );
  }

  /// Word list
  Widget _buildWordList() {
    return ListView.builder(
      padding: EdgeInsets.only(left: 20.w, right: 20.w, bottom: 100.h),
      itemCount: _words.length,
      itemBuilder: (context, index) {
        final word = _words[index];
        final wordId = '${widget.categoryName}-$index';
        return _buildWordCard(word, wordId);
      },
    );
  }

  /// Word card
  Widget _buildWordCard(Map<String, String> word, String id) {
    final isBookmarked = _bookmarkedItems.contains(id);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: MyColors.white,
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
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word['english']!,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Montserrat',
                    color: MyColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  word['turkish']!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Montserrat',
                    color: MyColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          // Audio button
          GestureDetector(
            onTap: () {
              print('Play audio: ${word['english']}');
            },
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Color(0xFF4ECDC4).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.volume_up,
                color: Color(0xFF4ECDC4),
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          // Bookmark button
          GestureDetector(
            onTap: () => _toggleBookmark(id),
            child: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? Color(0xFF4ECDC4) : MyColors.textSecondary,
              size: 24.sp,
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom Navigation Bar
  Widget _buildBottomNavigationBar() {
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        height: 65.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35.r),
          child: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: Image.asset(
                  'assets/images/home/altmenuarkaplan.png',
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        color: MyColors.white,
                        borderRadius: BorderRadius.circular(35.r),
                      ),
                    );
                  },
                ),
              ),

              // Navigation items - centered
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildNavItem(icon: Icons.grid_view_rounded, index: 0),
                      _buildNavItem(
                        icon: Icons.flight_takeoff_rounded,
                        index: 1,
                      ),
                      _buildNavItem(
                        icon: Icons.account_balance_rounded,
                        index: 2,
                      ),
                      _buildNavItem(icon: Icons.person_rounded, index: 3),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int index}) {
    final bool isActive = _selectedNavIndex == index;

    return GestureDetector(
      onTap: () {
        if (index == 0) {
          // Navigate back to home
          Navigator.popUntil(context, (route) => route.isFirst);
        } else if (index == 1) {
          // Navigate to Travel Vocabulary
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const TravelVocabularyView(),
            ),
            (route) => route.isFirst,
          );
        } else if (index == 2) {
          // Go back to Dictionary main view
          Navigator.pop(context);
        } else if (index == 3) {
          // Navigate to Profile
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const ProfileView()),
            (route) => route.isFirst,
          );
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 50.w,
        height: 50.w,
        decoration: BoxDecoration(
          color: isActive ? MyColors.white : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 26.sp,
          color: isActive ? MyColors.lingolaPrimaryColor : MyColors.grey400,
        ),
      ),
    );
  }
}
