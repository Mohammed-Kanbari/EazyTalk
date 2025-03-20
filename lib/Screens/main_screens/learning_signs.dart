import 'package:eazytalk/Screens/secondary_screens/words&sections/section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LearnSignsPage extends StatefulWidget {
  const LearnSignsPage({super.key});

  @override
  State<LearnSignsPage> createState() => _LearnSignsPageState();
}

class _LearnSignsPageState extends State<LearnSignsPage> {
  // List of most used words
  final List<Map<String, String>> mostUsedWords = [
    {'arabic': 'السلام عليكم', 'translation': 'Peace be upon you'},
    {'arabic': 'وعليكم السلام', 'translation': 'And peace be upon you too'},
    {'arabic': 'شكراً', 'translation': 'Thank you'},
    {'arabic': 'مرحباً', 'translation': 'Hello'},
  ];

  // List of sign language sections
  final List<Map<String, dynamic>> sections = [
    {
      'title': 'الأفعال',
      'subtitle': 'كلمات تعبر عن الأفعال',
      'color': Color(0xFFE6DAFF),
      'icon': 'assets/icons/action.png',
      'route': '/actions',
    },
    {
      'title': 'العائلة',
      'subtitle': 'إشارات تعبر العائلة في لغة الإشارة',
      'color': Color(0xFFFFEADA),
      'icon': 'assets/icons/family.png',
      'route': '/family',
    },
    {
      'title': 'الأسماء',
      'subtitle': 'الصفات والأشياء',
      'color': Color(0xFFD6F5FF),
      'icon': 'assets/icons/things.png',
      'route': '/nouns',
    },
    {
      'title': 'الأرقام',
      'subtitle': 'تعلم الأرقام في لغة الإشارة',
      'color': Color(0xFFFFDAF0),
      'icon': 'assets/icons/numbers.png',
      'route': '/numbers',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: EdgeInsets.only(top: 27.0.h, right: 28.w, left: 28.w),
              child: Text(
                'Learn Sign Language',
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: 30.h),

            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Introduction text
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 16.sp,
                            color: const Color.fromARGB(255, 0, 0, 0),
                          ),
                          children: [
                            const TextSpan(text: 'Master '),
                            TextSpan(
                              text: 'essential signs',
                              style: TextStyle(
                                color: const Color(0xFF00D0FF),
                              ),
                            ),
                            const TextSpan(text: ' for everyday communication.'),
                          ],
                        ),
                      ),
                      SizedBox(height: 30.h),

                      // Most Used Words section
                      Text(
                        'Most Used Words :',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Most Used Words horizontal list
                      SizedBox(
                        height: 80.h,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: mostUsedWords.length,
                          separatorBuilder: (context, index) => SizedBox(width: 12.w),
                          itemBuilder: (context, index) {
                            return _buildWordCard(mostUsedWords[index]);
                          },
                        ),
                      ),
                      SizedBox(height: 60.h),

                      // Sections title
                      Text(
                        'Sections :',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 20.h),

                      // Sections grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 15.w,
                          mainAxisSpacing: 15.h,
                          childAspectRatio: 1.2,
                        ),
                        itemCount: sections.length,
                        itemBuilder: (context, index) {
                          return _buildSectionCard(sections[index]);
                        },
                      ),
                      
                      SizedBox(height: 20.h), // Bottom spacing
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for most used word card
  Widget _buildWordCard(Map<String, String> word) {
    return GestureDetector(
      onTap: () {
        // Show details or play animation/video for this word
        _showWordDetails(word);
      },
      child: Container(
        width: 160.w,
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Color(0xFFB1EEFF),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              spreadRadius: 1,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            word['arabic']!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  // Widget for section card
  Widget _buildSectionCard(Map<String, dynamic> section) {
    return GestureDetector(
      onTap: () {
        // Navigate to the section details page
        _navigateToSection(section);
      },
      child: Container(
        decoration: BoxDecoration(
          color: section['color'],
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              spreadRadius: 1,
              offset: Offset(0, 3),
            ),
          ],
        ),
        padding: EdgeInsets.all(15.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(6.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 14.sp,
                    color: Colors.black54,
                  ),
                ),
                // Image placeholder - replace with actual icon asset
                Image.asset(
                  section['icon'],
                  width: 32.w,
                  height: 32.h,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.category,
                    size: 32.sp,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            Spacer(),
            Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section['title'],
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    section['subtitle'],
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 10.sp,
                      color: Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show word details modal
  void _showWordDetails(Map<String, String> word) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            SizedBox(height: 20.h),
            // Word in Arabic
            Text(
              word['arabic']!,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 10.h),
            // Translation
            Text(
              word['translation']!,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16.sp,
                color: Colors.black54,
              ),
            ),
            SizedBox(height: 20.h),
            // Placeholder for sign language image/animation
            Container(
              width: double.infinity,
              height: 180.h,
              decoration: BoxDecoration(
                color: Color(0xFFF1F3F5),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Center(
                child: Icon(
                  Icons.sign_language,
                  size: 60.sp,
                  color: Color(0xFF00D0FF),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            // Practice button
            SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton(
                onPressed: () {
                  // Practice functionality
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00D0FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Practice this sign',
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToSection(Map<String, dynamic> section) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SectionDetailPage(
          title: section['title'],
          category: section['title'],
          categoryColor: section['color'],
        ),
      ),
    );
  }
}