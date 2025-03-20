import 'package:eazytalk/Screens/secondary_screens/words&sections/words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SectionDetailPage extends StatefulWidget {
  final String title;
  final String category;
  final Color categoryColor;
  
  const SectionDetailPage({
    Key? key, 
    required this.title, 
    required this.category,
    required this.categoryColor,
  }) : super(key: key);

  @override
  State<SectionDetailPage> createState() => _SectionDetailPageState();
}

class _SectionDetailPageState extends State<SectionDetailPage> {
  // Sample data for words in this section
  late List<Map<String, String>> words;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize words based on the category
    // This would typically come from a database or API
    if (widget.category == 'الأفعال') {
      words = [
        {'word': 'يأكل', 'description': 'التعبير عن الأكل بالإشارة', 'image': 'assets/images/signs/eat.png'},
        {'word': 'يشرب', 'description': 'الإشارة لشرب السوائل', 'image': 'assets/images/signs/drink.png'},
        {'word': 'ينام', 'description': 'التعبير عن النوم والراحة', 'image': 'assets/images/signs/sleep.png'},
        {'word': 'يقرأ', 'description': 'يشير إلى المطالعة ودراستها', 'image': 'assets/images/signs/read.png'},
        {'word': 'يكتب', 'description': 'يعبر عن الكتابة باستخدام القلم', 'image': 'assets/images/signs/write.png'},
        {'word': 'يسوق', 'description': 'قيادة السيارة أو الشاحنة', 'image': 'assets/images/signs/drive.png'},
        {'word': 'يمشي', 'description': 'التعبير عن المشي على الأقدام', 'image': 'assets/images/signs/walk.png'},
        {'word': 'يتحدث', 'description': 'الإشارة للتواصل والمحادثة', 'image': 'assets/images/signs/talk.png'},
        {'word': 'يدرس', 'description': 'التعلم والدراسة في المدرسة', 'image': 'assets/images/signs/study.png'},
      ];
    } else if (widget.category == 'العائلة') {
      words = [
        {'word': 'أب', 'description': 'الوالد ورب الأسرة', 'image': 'assets/images/signs/father.png'},
        {'word': 'أم', 'description': 'الوالدة وربة المنزل', 'image': 'assets/images/signs/mother.png'},
        {'word': 'أخ', 'description': 'الأخ الذكر في العائلة', 'image': 'assets/images/signs/brother.png'},
        {'word': 'أخت', 'description': 'الأخت الأنثى في العائلة', 'image': 'assets/images/signs/sister.png'},
        {'word': 'جد', 'description': 'والد الأب أو الأم', 'image': 'assets/images/signs/grandfather.png'},
        {'word': 'جدة', 'description': 'والدة الأب أو الأم', 'image': 'assets/images/signs/grandmother.png'},
        {'word': 'عم', 'description': 'أخو الأب', 'image': 'assets/images/signs/uncle.png'},
        {'word': 'خال', 'description': 'أخو الأم', 'image': 'assets/images/signs/maternal_uncle.png'},
      ];
    } else if (widget.category == 'الأسماء') {
      words = [
        {'word': 'منزل', 'description': 'المكان الذي نعيش فيه', 'image': 'assets/images/signs/house.png'},
        {'word': 'مدرسة', 'description': 'مكان التعليم والدراسة', 'image': 'assets/images/signs/school.png'},
        {'word': 'سيارة', 'description': 'وسيلة نقل بأربع عجلات', 'image': 'assets/images/signs/car.png'},
        {'word': 'كتاب', 'description': 'مجموعة من الأوراق المطبوعة', 'image': 'assets/images/signs/book.png'},
        {'word': 'هاتف', 'description': 'جهاز للاتصال والتواصل', 'image': 'assets/images/signs/phone.png'},
        {'word': 'حاسوب', 'description': 'جهاز إلكتروني للعمل والترفيه', 'image': 'assets/images/signs/computer.png'},
      ];
    } else if (widget.category == 'الأرقام') {
      words = [
        {'word': 'واحد', 'description': 'الرقم ١', 'image': 'assets/images/signs/one.png'},
        {'word': 'اثنان', 'description': 'الرقم ٢', 'image': 'assets/images/signs/two.png'},
        {'word': 'ثلاثة', 'description': 'الرقم ٣', 'image': 'assets/images/signs/three.png'},
        {'word': 'أربعة', 'description': 'الرقم ٤', 'image': 'assets/images/signs/four.png'},
        {'word': 'خمسة', 'description': 'الرقم ٥', 'image': 'assets/images/signs/five.png'},
        {'word': 'ستة', 'description': 'الرقم ٦', 'image': 'assets/images/signs/six.png'},
        {'word': 'سبعة', 'description': 'الرقم ٧', 'image': 'assets/images/signs/seven.png'},
        {'word': 'ثمانية', 'description': 'الرقم ٨', 'image': 'assets/images/signs/eight.png'},
        {'word': 'تسعة', 'description': 'الرقم ٩', 'image': 'assets/images/signs/nine.png'},
        {'word': 'عشرة', 'description': 'الرقم ١٠', 'image': 'assets/images/signs/ten.png'},
      ];
    } else {
      // Default list if category doesn't match
      words = [
        {'word': 'كلمة 1', 'description': 'وصف الكلمة الأولى', 'image': 'assets/images/signs/default.png'},
        {'word': 'كلمة 2', 'description': 'وصف الكلمة الثانية', 'image': 'assets/images/signs/default.png'},
        {'word': 'كلمة 3', 'description': 'وصف الكلمة الثالثة', 'image': 'assets/images/signs/default.png'},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Custom app bar to match your style
            Padding(
              padding: EdgeInsets.only(top: 27.h, left: 28.w, right: 28.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      'assets/icons/back-arrow.png',
                      width: 22.w,
                      height: 22.h,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.arrow_back_ios,
                        color: Colors.black,
                        size: 20.sp,
                      ),
                    ),
                  ),
                  Text(
                    'Words',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Show options menu
                      _showOptionsMenu();
                    },
                    child: Icon(
                      Icons.more_vert,
                      color: Colors.black,
                      size: 24.sp,
                    ),
                  ),
                ],
              ),
            ),
            
            // Expanded section with scroll view that includes the header
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 28.w),
                physics: BouncingScrollPhysics(),
                children: [
                  // Category title with colored word (now scrolls with the content)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 30.h),
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        children: [
                          TextSpan(text: 'Common '),
                          TextSpan(
                            text: widget.title,
                            style: TextStyle(
                              color: widget.categoryColor,
                            ),
                          ),
                          TextSpan(text: ' In Sign Language'),
                        ],
                      ),
                    ),
                  ),

                  // Words list
                  ...words.map((word) => _buildWordCard(word)).toList(),
                  
                  // Bottom spacing
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Word card widget
  Widget _buildWordCard(Map<String, String> word) {
    return GestureDetector(
      onTap: () {
        // Show word details
        _navigateToWordDetail(word);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              spreadRadius: 1,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Sign image with proper handling
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Image.asset(
                word['image'] ?? 'assets/images/signs/default.png',
                width: 60.w,
                height: 60.h,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60.w,
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.sign_language,
                      size: 30.sp,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 16.w),
            // Word and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word['word']!,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    word['description']!,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 12.sp,
                      color: Colors.black54,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Arrow icon
            Container(
              width: 36.w,
              height: 36.h,
              decoration: BoxDecoration(
                color: Color(0xFF00D0FF),
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF00D0FF).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 0,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Colors.white,
                size: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show options menu
  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 20.h),
            _buildOptionItem(
              icon: Icons.sort_by_alpha,
              title: 'Sort alphabetically',
              onTap: () {
                Navigator.pop(context);
                // Implement sorting
                setState(() {
                  words.sort((a, b) => a['word']!.compareTo(b['word']!));
                });
              },
            ),
            _buildOptionItem(
              icon: Icons.star_border,
              title: 'Show favorites only',
              onTap: () {
                Navigator.pop(context);
                // Implement showing favorites
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Showing favorites feature will be implemented soon')),
                );
              },
            ),
            _buildOptionItem(
              icon: Icons.search,
              title: 'Search',
              onTap: () {
                Navigator.pop(context);
                // Implement search
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Search feature will be implemented soon')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Option item widget
  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Color(0xFF00D0FF)),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 16.sp,
        ),
      ),
      onTap: onTap,
    );
  }

  // Navigate to word detail page
  void _navigateToWordDetail(Map<String, String> word) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => WordDetailPage(
        word: word['word']!,
        description: word['description']!,
        image: word['image'] ?? 'assets/images/signs/default.png',
        categoryColor: widget.categoryColor,
      ),
    ),
  );
}
}

