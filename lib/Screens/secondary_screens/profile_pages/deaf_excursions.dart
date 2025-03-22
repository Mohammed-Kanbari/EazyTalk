import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/models/excursion_model.dart';
import 'package:eazytalk/services/url/url_launcher_service.dart';
import 'package:eazytalk/widgets/common/modal_header.dart';
import 'package:eazytalk/widgets/excursions/destination_card.dart';

class DeafFriendlyExcursions extends StatefulWidget {
  const DeafFriendlyExcursions({super.key});

  @override
  State<DeafFriendlyExcursions> createState() => _DeafFriendlyExcursionsState();
}

class _DeafFriendlyExcursionsState extends State<DeafFriendlyExcursions> {
  // List of excursion destinations
  final List<ExcursionModel> _destinations = [
    ExcursionModel(
      title: 'Half-day City Tour of Dubai',
      description: 'You\'ll see some of Dubai\'s most famous landmarks, take beautiful pictures and experience the great beauty of the city.',
      image: 'assets/images/dubai-4k-most-downloaded-wallpaper-preview.jpg',
      url: 'https://www.youtube.com/watch?v=s4eUxCTqNm8',
    ),
    
    ExcursionModel(
      title: 'Tanoura Show',
      description: 'Live up the classic Arabian dream on the desert safari with a delectable barbeque dinner, cultural performances to keep you entertained and a number of desert adventure to participate.',
      image: 'assets/images/03.jpg',
      url: 'https://www.youtube.com/watch?v=pXMvv9WyL88',
    ),
    
    ExcursionModel(
      title: 'Ferrari World',
      description: 'Ferrari World Abu Dhabi - home to the world\'s fastest rollercoaster, the highest loop ride, the tallest space-frame structure ever built on the planet and over 40 record-breaking attractions. This is the ultimate destination for non-stop, hyper-adrenaline, heart-racing fun!.',
      image: 'assets/images/Image-4-Ferrari-World-Abu-Dhabi.jpg',
      url: 'https://www.youtube.com/watch?v=VJsHnvgQ4dI',
    ),
  ];

  // Handle opening YouTube URL
  void _handleExplorePressed(String url) {
    UrlLauncherService.launchUrlWithErrorHandling(
      context, 
      url,
      errorMessage: 'Could not launch the video'
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
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: ModalHeader(
                title: 'Deaf-friendly\nExcursions',
                onClose: () => Navigator.pop(context),
              ),
            ),

            // Content - Destinations list with subtitle
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 28.w),
                itemCount: _destinations.length + 1, // Add 1 for the subtitle
                itemBuilder: (context, index) {
                  if (index == 0) {
                    // First item is the subtitle
                    return _buildSubtitle();
                  }
                  
                  // Adjust index for destinations after the subtitle
                  final destination = _destinations[index - 1];
                  return DestinationCard(
                    destination: destination,
                    onExplorePressed: () => _handleExplorePressed(destination.url),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build subtitle widget
  Widget _buildSubtitle() {
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
                color: AppColors.primary,
              ),
            ),
            const TextSpan(
                text: ' hideaways where fun knows no boundaries.'),
          ],
        ),
      ),
    );
  }
}