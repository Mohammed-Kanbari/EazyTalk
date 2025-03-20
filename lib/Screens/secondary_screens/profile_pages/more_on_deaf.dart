import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class MoreOnDeaf extends StatefulWidget {
  const MoreOnDeaf({Key? key}) : super(key: key);

  @override
  State<MoreOnDeaf> createState() => _MoreOnDeafState();
}

class _MoreOnDeafState extends State<MoreOnDeaf> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            Padding(
              padding: EdgeInsets.only(top: 27.h, left: 28.w, right: 28.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(width: 28.w, height: 28.h), // Placeholder for alignment
                  Text(
                    'More On Deaf',
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
            SizedBox(height: 30.h),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 28.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main Title
                      Text(
                        'Deaf in United Arab Emirates',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 30.h),

                      // Stats Grid
                      Row(
                        children: [
                          // Population Stat
                          Expanded(
                            child: _buildStatCard(
                              iconData: Icons.people,
                              iconColor: const Color(0xFF4A86E8),
                              title: '19.4k',
                              subtitle: 'Population',
                              backgroundColor: const Color(0xFFF1F8FF),
                            ),
                          ),
                          SizedBox(width: 15.w),
                          // Fund Stat
                          Expanded(
                            child: _buildStatCard(
                              iconData: Icons.attach_money,
                              iconColor: Colors.white,
                              title: '\$8.5M',
                              subtitle: 'Annual Support',
                              backgroundColor: const Color(0xFF4A86E8),
                              titleColor: Colors.white,
                              subtitleColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 15.h),
                      Row(
                        children: [
                          // Empowerment Stat
                          Expanded(
                            child: _buildStatCard(
                              icon: _buildCircularProgress(0.89),
                              title: '89%',
                              subtitle: 'Deaf Empowerment',
                              backgroundColor: const Color(0xFFF1F8FF),
                            ),
                          ),
                          SizedBox(width: 15.w),
                          // Organizations Stat
                          Expanded(
                            child: _buildStatCard(
                              iconData: Icons.business,
                              iconColor: const Color(0xFF4A86E8),
                              title: '36',
                              subtitle: 'association for deaf people',
                              backgroundColor: const Color(0xFFF1F8FF),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 25.h),

                      // Information Cards
                      _buildInfoCard(
                        title: 'Emirati Sign Language (ESL)',
                        content:
                            'Emirati Sign Language (ESL) is the main communication method for the deaf community in the UAE, with unique signs and cultural significance. The UAE government promotes its use in education, public services, and workplaces to increase inclusivity and awareness.',
                        url: 'https://zho.gov.ae/en/Sign-Language-Dictionary/UAE-Sign-Language-Categories'
                      ),

                      _buildInfoCard(
                        title: 'What Are Their Needs?',
                        content:
                            'The deaf community faces challenges in employment, healthcare, and social inclusion, requiring specialized services, job opportunities, and accessible technologies. There is a need for more awareness programs, and assistive devices to support their integration into society.',
                      ),

                      _buildInfoCard(
                        title: 'UAE Government Support for the Deaf Community',
                        content:
                            'The UAE government offers a range of services to the deaf community, including legal protections, inclusive education, and vocational training. It provides specialized healthcare, assistive technologies, and social services to ensure accessibility and integration. Public awareness and advocacy work to promote equality and reduce stigma for the deaf.',
                        url: 'https://u.ae/en/information-and-services/social-affairs/people-of-determination/protection-support-and-assistance-of-people-of-determination'
                      ),

                      // Educational Resources Section
                      SizedBox(height: 15.h),
                      Text(
                        'Educational Resources',
                        style: TextStyle(
                          fontFamily: 'Sora',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 15.h),
                      _buildEducationalResourceCard(
                        institutionName: "Zayed Higher Organization for People of Determination",
                        type: "Specialized Education Center",
                        description: "Provides comprehensive educational programs tailored for deaf students with focus on bilingual education using Emirati Sign Language and Arabic.",
                        location: "Abu Dhabi",
                        url: "https://zho.gov.ae",
                      ),

                      _buildEducationalResourceCard(
                        institutionName: "Sharjah City for Humanitarian Services",
                        type: "Inclusive Education Provider",
                        description: "Offers specialized courses for deaf students of all ages, including vocational training and integration programs with sign language support.",
                        location: "Sharjah",
                        url: "https://www.schs.ae",
                      ),

                      _buildEducationalResourceCard(
                        institutionName: "Al Amal School for the Deaf",
                        type: "K-12 Education",
                        description: "One of the oldest specialized schools for deaf students in the UAE, offering academic curriculum delivered in sign language from kindergarten through high school.",
                        location: "Sharjah",
                        url: "https://www.schs.ae",
                      ),

                      _buildEducationalResourceCard(
                        institutionName: "Emirates Association of the Deaf",
                        type: "Training & Development",
                        description: "Provides sign language courses, interpreter training, and regular workshops to support education and employment for the deaf community.",
                        location: "Multiple branches across UAE",
                       
                      ),

                      SizedBox(height: 20.h),
                      
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

  // Widget to build stat cards (top section)
  Widget _buildStatCard({
    IconData? iconData,
    Widget? icon,
    Color iconColor = Colors.blue,
    required String title,
    required String subtitle,
    Color backgroundColor = Colors.white,
    Color titleColor = Colors.black,
    Color subtitleColor = Colors.black87,
    Widget? customFooter,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Padding(
          padding: EdgeInsets.all(15.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                icon
              else if (iconData != null)
                Icon(iconData, color: iconColor, size: 30.sp),
              SizedBox(height: 12.h),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Sora',
                  fontSize: 35.sp,
                  fontWeight: FontWeight.w600,
                  color: titleColor,
                ),
              ),
              SizedBox(height: 5.h),
              Flexible(
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12.sp,
                    color: subtitleColor,
                  ),
                ),
              ),
              if (customFooter != null) ...[
                SizedBox(height: 8.h),
                customFooter,
              ],
            ],
          ),
        ),
      ),
    );
  }

  // Widget to build circular progress indicator for the empowerment stat
  Widget _buildCircularProgress(double percentage) {
    return SizedBox(
      width: 30.w,
      height: 30.h,
      child: CircularProgressIndicator(
        value: percentage,
        strokeWidth: 6.w,
        backgroundColor: Colors.grey[300],
        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4A86E8)),
      ),
    );
  }

  // Widget to build information cards with navigation arrow
  Widget _buildInfoCard({
    required String title, 
    required String content,
    String? url, // Optional URL to navigate to
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(15.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              content,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14.sp,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            // Only show the arrow if URL is provided
            if (url != null && url.isNotEmpty) ...[
              SizedBox(height: 10.h),
              Align(
                alignment: Alignment.bottomRight,
                child: GestureDetector(
                  onTap: () {
                    _launchUrl(url);
                  },
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D0FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: const Color(0xFF00D0FF),
                      size: 16.sp,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Widget to build educational resource cards
  Widget _buildEducationalResourceCard({
    required String institutionName,
    required String type,
    required String description,
    required String location,
    String? url,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF00D0FF).withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(15.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Institution Circle with first letter
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00D0FF).withOpacity(0.1),
              ),
              child: Center(
                child: Text(
                  institutionName.substring(0, 1),
                  style: TextStyle(
                    fontFamily: 'Sora',
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF00D0FF),
                  ),
                ),
              ),
            ),
            SizedBox(width: 15.w),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Institution name
                  Text(
                    institutionName,
                    style: TextStyle(
                      fontFamily: 'Sora',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  // Type
                  Text(
                    type,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF00D0FF),
                    ),
                  ),
                  SizedBox(height: 5.h),
                  // Description
                  Text(
                    description,
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 14.sp,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 5.h),
                  // Location with icon
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16.sp,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 5.w),
                      Text(
                        location,
                        style: TextStyle(
                          fontFamily: 'DM Sans',
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  // Website link if provided
                  if (url != null && url.isNotEmpty) ...[
                    SizedBox(height: 10.h),
                    GestureDetector(
                      onTap: () => _launchUrl(url),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Visit Website",
                            style: TextStyle(
                              fontFamily: 'DM Sans',
                              fontSize: 12.sp,
                              color: const Color(0xFF00D0FF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 5.w),
                          Icon(
                            Icons.arrow_forward,
                            size: 12.sp,
                            color: const Color(0xFF00D0FF),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  // Helper method to launch URLs
  Future<void> _launchUrl(String urlString) async {
    final Uri uri = Uri.parse(urlString);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $uri');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open website: $e')),
        );
      }
    }
  }
}