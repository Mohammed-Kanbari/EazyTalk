import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class DeafFriendlyExcursions extends StatefulWidget {
  const DeafFriendlyExcursions({super.key});

  @override
  State<DeafFriendlyExcursions> createState() => _DeafFriendlyExcursionsState();
}

class _DeafFriendlyExcursionsState extends State<DeafFriendlyExcursions> {
  // List of excursion destinations with added YouTube URLs
  final List<Map<String, String>> _destinations = [
    {
      'title': 'Half-day City Tour of Dubai',
      'description':
          'You\'ll see some of Dubai\'s most famous landmarks, take beautiful pictures and experience the great beauty of the city.',
      'image': 'assets/images/dubai-4k-most-downloaded-wallpaper-preview.jpg',
      'url': 'https://www.youtube.com/watch?v=s4eUxCTqNm8',
    },
    
    {
      'title': 'Tanoura Show',
      'description':
          'Live up the classic Arabian dream on the desert safari with a delectable barbeque dinner, cultural performances to keep you entertained and a number of desert adventure to participate.',
      'image': 'assets/images/03.jpg',
      'url': 'https://www.youtube.com/watch?v=pXMvv9WyL88',
    },
    {
      'title': 'Ferrari World',
      'description':
          'Ferrari World Abu Dhabi - home to the world\'s fastest rollercoaster, the highest loop ride, the tallest space-frame structure ever built on the planet and over 40 record-breaking attractions. This is the ultimate destination for non-stop, hyper-adrenaline, heart-racing fun!.',
      'image': 'assets/images/Image-4-Ferrari-World-Abu-Dhabi.jpg',
      'url': 'https://www.youtube.com/watch?v=VJsHnvgQ4dI',
    },
    
  ];

  // Method to launch URL
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        // Show an error if URL couldn't be launched
        _showErrorSnackBar('Could not launch the video');
      }
    } catch (e) {
      _showErrorSnackBar('An error occurred');
    }
  }

  // Method to show error snackbar
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Bar
            Padding(
              padding: EdgeInsets.only(top: 27.h, left: 28.w, right: 28.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      width: 28.w, height: 28.h), // Placeholder for alignment
                  Text(
                    'Deaf-friendly\nExcursions',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 28.sp),
                  ),
                ],
              ),
            ),

            // Destinations List (now including the subtitle)
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 28.w),
                itemCount: _destinations.length + 1, // Add 1 for the subtitle
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // First item is the subtitle
                    return Padding(
                      padding: EdgeInsets.only(top: 30.h, bottom: 30.h),
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontFamily: 'DM Sans',
                            fontSize: 16.sp,
                            color: Colors.black,
                          ),
                          children: [
                            const TextSpan(text: 'Discover '),
                            TextSpan(
                              text: 'delightful',
                              style: TextStyle(
                                color: const Color(0xFF00D0FF),
                              ),
                            ),
                            const TextSpan(
                                text: ' hideaways where fun knows no boundaries.'),
                          ],
                        ),
                      ),
                    );
                  }
                  
                  // Adjust index for destinations after the subtitle
                  return _buildDestinationCard(_destinations[index - 1]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDestinationCard(Map<String, String> destination) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.2),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            child: Image.asset(
              destination['image']!,
              width: double.infinity,
              height: 200.h,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination['title']!,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  destination['description']!,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14.sp,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16.h),
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      // Launch the YouTube URL
                      _launchURL(destination['url']!);
                    },
                    child: Text(
                      'Explore more',
                      style: TextStyle(
                        fontFamily: 'Sora',
                        fontSize: 14.sp,
                        color: const Color(0xFF00D0FF),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}