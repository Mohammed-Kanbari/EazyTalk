import 'package:eazytalk/Screens/secondary_screens/words&sections/section.dart';
import 'package:eazytalk/Screens/secondary_screens/words&sections/words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LearnSignsPage extends StatefulWidget {
  const LearnSignsPage({super.key});

  @override
  State<LearnSignsPage> createState() => _LearnSignsPageState();
}

class _LearnSignsPageState extends State<LearnSignsPage> {
  final _supabase = Supabase.instance.client;
  
  bool _isLoading = true;
  List<Map<String, dynamic>> mostUsedWords = [];
  List<Map<String, dynamic>> sections = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Load data from Supabase
  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      // Fetch sections
      final sectionsResponse = await _supabase
          .from('Sections')
          .select()
          .order('id');

      // Fetch most used words
      final wordsResponse = await _supabase
          .from('Words')
          .select()
          .eq('is_most_used', true)
          .order('id');

      // Process sections to convert color string to Color
      final processedSections = sectionsResponse.map<Map<String, dynamic>>((section) {
        return {
          'id': section['id'],
          'title': section['title'],
          'subtitle': section['subtitle'],
          'color': _hexToColor(section['color'] ?? '#E6DAFF'),
          'icon': section['icon_path'] ?? 'assets/icons/default.png',
        };
      }).toList();

      setState(() {
        sections = processedSections;
        mostUsedWords = wordsResponse;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _errorMessage = 'Failed to load data. Please check your connection.';
        _isLoading = false;
      });
    }
  }

  // Helper method to convert hex color string to Color
  Color _hexToColor(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF$hexColor';
    }
    return Color(int.parse(hexColor, radix: 16));
  }

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

            // Loading indicator or error message
            if (_isLoading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF00D0FF),
                  ),
                ),
              )
            else if (_errorMessage.isNotEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 60.sp,
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        _errorMessage,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 16.sp,
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 30.h),
                      ElevatedButton(
                        onPressed: _loadData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF00D0FF),
                          padding: EdgeInsets.symmetric(
                            horizontal: 20.w,
                            vertical: 10.h,
                          ),
                        ),
                        child: Text(
                          'Try Again',
                          style: TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 16.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  color: Color(0xFF00D0FF),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
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
                          mostUsedWords.isNotEmpty
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                    SizedBox(
                                      height: 80.h,
                                      child: ListView.separated(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: mostUsedWords.length,
                                        separatorBuilder: (context, index) =>
                                            SizedBox(width: 12.w),
                                        itemBuilder: (context, index) {
                                          return _buildWordCard(mostUsedWords[index]);
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox(),
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
                          sections.isNotEmpty
                              ? GridView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 15.w,
                                    mainAxisSpacing: 15.h,
                                    childAspectRatio: 1.2,
                                  ),
                                  itemCount: sections.length,
                                  itemBuilder: (context, index) {
                                    return _buildSectionCard(sections[index]);
                                  },
                                )
                              : Center(
                                  child: Text(
                                    'No sections available',
                                    style: TextStyle(
                                      fontFamily: 'DM Sans',
                                      fontSize: 16.sp,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),

                          SizedBox(height: 20.h), // Bottom spacing
                        ],
                      ),
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
  Widget _buildWordCard(Map<String, dynamic> word) {
    return GestureDetector(
      onTap: () {
        _navigateToWordDetail(word);
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
            word['word'] ?? 'Unknown',
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
        _navigateToSection(section);
      },
      child: Container(
        decoration: BoxDecoration(
          color: section['color'] ?? Color(0xFFE6DAFF),
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
                    section['title'] ?? 'Unknown Section',
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    section['subtitle'] ?? '',
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

  // Navigate to word detail page
  void _navigateToWordDetail(Map<String, dynamic> word) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WordDetailPage(
          wordId: word['id'],
          word: word['word'] ?? 'Unknown',
          description: word['description'] ?? '',
          image: word['image_path'] ?? 'assets/images/signs/default.png',
          categoryColor: Color(0xFFB1EEFF),
          videoPath: word['video_path'],
        ),
      ),
    );
  }

  // Navigate to section page
  void _navigateToSection(Map<String, dynamic> section) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SectionDetailPage(
          sectionId: section['id'],
          title: section['title'] ?? 'Unknown Section',
          category: section['title'] ?? 'Unknown Section',
          categoryColor: section['color'] ?? Color(0xFFE6DAFF),
        ),
      ),
    );
  }
}