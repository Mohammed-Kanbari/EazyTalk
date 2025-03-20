import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WordDetailPage extends StatefulWidget {
  final String word;
  final String description;
  final String image;
  final Color categoryColor;

  const WordDetailPage({
    Key? key,
    required this.word,
    required this.description,
    required this.image,
    required this.categoryColor,
  }) : super(key: key);

  @override
  State<WordDetailPage> createState() => _WordDetailPageState();
}

class _WordDetailPageState extends State<WordDetailPage> {
  bool isFavorite = false;
  int _selectedTabIndex = 0;

  final List<String> _tabTitles = ['وصف', 'تعليمات', 'نصائح للإتقان'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom app bar
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
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isFavorite = !isFavorite;
                      });
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 1,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Colors.black,
                        size: 18.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Video card
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 28.w, vertical: 60.h),
                      child: Container(
                        width: double.infinity,
                        height: 200.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              spreadRadius: 0,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                widget.image,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.videocam,
                                        size: 50.sp,
                                        color: Colors.grey[400],
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        'Video demonstration',
                                        style: TextStyle(
                                          fontFamily: 'DM Sans',
                                          fontSize: 14.sp,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Center(
                                child: Container(
                                  width: 60.h,
                                  height: 60.h,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.8),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: Color(0xFF00D0FF),
                                    size: 40.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Word card with tags
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 28.w),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            vertical: 24.h, horizontal: 20.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          border: Border.all(
                            color: Color(0xFFE8E8E8),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 12,
                              spreadRadius: 2,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Arabic word title
                            Text(
                              widget.word,
                              style: TextStyle(
                                fontFamily: 'Sora',
                                fontSize: 28.sp, // Larger text size
                                fontWeight: FontWeight.w700, // Bolder text
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 20.h), // More spacing

                            // Tags row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildTag('مبتدئ', Color(0xFFFCE8DD)),
                                SizedBox(
                                    width: 16.w), // More spacing between tags
                                _buildTag('عبارة شائعة', Color(0xFFE6DAFF)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Tabs section
                    Padding(
                      padding: EdgeInsets.only(top: 16.h),
                      child: Column(
                        children: [
                          // Tab bar
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 28.w),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: List.generate(
                                _tabTitles.length,
                                (index) => _buildTabItem(index),
                              ),
                            ),
                          ),

                          // Tab content
                          Padding(
                            padding: EdgeInsets.all(28.r),
                            child: _buildTabContent(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build tag widget
  Widget _buildTag(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 6,
            spreadRadius: 0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'DM Sans',
          fontSize: 14.sp, // Slightly larger
          fontWeight: FontWeight.w600, // Bolder
          color: Colors.black87,
        ),
      ),
    );
  }

  // Build tab item widget
  Widget _buildTabItem(int index) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Color(0xFF00D0FF) : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            _tabTitles[index],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected ? Color(0xFF00D0FF) : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  // Build tab content based on selected tab
  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0: // Description
        return _buildDescriptionTab();
      case 1: // Instructions
        return _buildInstructionsTab();
      case 2: // Tips
        return _buildTipsTab();
      default:
        return _buildDescriptionTab();
    }
  }

  // Description tab content
  Widget _buildDescriptionTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.description,
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 16.sp,
            height: 1.5,
            color: Colors.black87,
          ),
          textDirection: TextDirection.rtl,
        ),
        SizedBox(height: 20.h),
        SizedBox(height: 8.h),
        Text(
          '',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 16.sp,
            height: 1.5,
            color: Colors.black87,
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }

  // Instructions tab content
  Widget _buildInstructionsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInstructionStep(
          number: '1',
          description: 'ابدأ برفع يدك اليمنى مفتوحة بجانب الوجه',
        ),
        _buildInstructionStep(
          number: '2',
          description: 'حرك يدك في حركة دائرية خفيفة',
        ),
        _buildInstructionStep(
          number: '3',
          description: 'ثم اجعل يدك تنزل للأمام مع إشارة الإحترام',
        ),
        _buildInstructionStep(
          number: '4',
          description: 'حافظ على الابتسامة أثناء الإشارة',
        ),
      ],
    );
  }

  // Tips tab content
  Widget _buildTipsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTipItem(
          'حافظ على اتصال العين أثناء تقديم الإشارة',
        ),
        _buildTipItem(
          'يمكن استخدام تعبيرات الوجه المناسبة مع الإشارة لتأكيد المعنى',
        ),
        _buildTipItem(
          'التدرب على الإشارة أمام المرآة يساعد على إتقانها',
        ),
        _buildTipItem(
          'هذه الإشارة من الإشارات الأساسية التي يجب إتقانها',
        ),
      ],
    );
  }

  // Build instruction step widget
  Widget _buildInstructionStep(
      {required String number, required String description}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30.w,
            height: 30.h,
            decoration: BoxDecoration(
              color: Color(0xFF00D0FF).withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00D0FF),
                ),
              ),
            ),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Text(
              description,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16.sp,
                height: 1.5,
                color: Colors.black87,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }

  // Build tip item widget
  Widget _buildTipItem(String text) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: Row(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: Color(0xFF00D0FF),
            size: 24.sp,
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 16.sp,
                height: 1.5,
                color: Colors.black87,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
        ],
      ),
    );
  }
}
