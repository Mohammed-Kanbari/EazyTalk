import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:eazytalk/core/theme/app_colors.dart';
import 'package:eazytalk/services/url/url_launcher_service.dart';
import 'package:eazytalk/widgets/common/modal_header.dart';
import 'package:eazytalk/widgets/stats/stat_card.dart';
import 'package:eazytalk/widgets/stats/circular_progress.dart';
import 'package:eazytalk/widgets/info/info_card.dart';
import 'package:eazytalk/widgets/education/educational_resource_card.dart';

class MoreOnDeaf extends StatefulWidget {
  const MoreOnDeaf({Key? key}) : super(key: key);

  @override
  State<MoreOnDeaf> createState() => _MoreOnDeafState();
}

class _MoreOnDeafState extends State<MoreOnDeaf> {
  // URL launcher service instance
  final UrlLauncherService _urlLauncherService = UrlLauncherService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 28.w),
              child: ModalHeader(
                title: 'More On Deaf',
                onClose: () => Navigator.pop(context),
              ),
            ),
            SizedBox(height: 30.h),

            // Main Content
            Expanded(
              child: _buildMainContent(),
            ),
          ],
        ),
      ),
    );
  }

  // Build the main scrollable content
  Widget _buildMainContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 28.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Title
            _buildMainTitle(),
            SizedBox(height: 30.h),

            // Stats Grid
            _buildStatsGrid(),
            SizedBox(height: 25.h),

            // Information Cards
            _buildInfoCards(),

            // Educational Resources Section
            _buildEducationalResourcesSection(),
            
            SizedBox(height: 20.h), // Bottom padding
          ],
        ),
      ),
    );
  }

  // Build the main title
  Widget _buildMainTitle() {
    return Text(
      'Deaf in United Arab Emirates',
      style: TextStyle(
        fontFamily: 'Sora',
        fontSize: 28.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black,
      ),
    );
  }

  // Build the stats grid
  Widget _buildStatsGrid() {
    return Column(
      children: [
        // First row of stats
        Row(
          children: [
            // Population Stat
            Expanded(
              child: StatCard(
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
              child: StatCard(
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
        // Second row of stats
        Row(
          children: [
            // Empowerment Stat
            Expanded(
              child: StatCard(
                icon: CircularProgressWidget(percentage: 0.89),
                title: '89%',
                subtitle: 'Deaf Empowerment',
                backgroundColor: const Color(0xFFF1F8FF),
              ),
            ),
            SizedBox(width: 15.w),
            // Organizations Stat
            Expanded(
              child: StatCard(
                iconData: Icons.business,
                iconColor: const Color(0xFF4A86E8),
                title: '36',
                subtitle: 'association for deaf people',
                backgroundColor: const Color(0xFFF1F8FF),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Build information cards
  Widget _buildInfoCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Emirati Sign Language (ESL)
        InfoCard(
          title: 'Emirati Sign Language (ESL)',
          content: 'Emirati Sign Language (ESL) is the main communication method for the deaf community in the UAE, with unique signs and cultural significance. The UAE government promotes its use in education, public services, and workplaces to increase inclusivity and awareness.',
          url: 'https://zho.gov.ae/en/Sign-Language-Dictionary/UAE-Sign-Language-Categories',
          onUrlTap: () => _launchUrl('https://zho.gov.ae/en/Sign-Language-Dictionary/UAE-Sign-Language-Categories'),
        ),

        // What Are Their Needs?
        InfoCard(
          title: 'What Are Their Needs?',
          content: 'The deaf community faces challenges in employment, healthcare, and social inclusion, requiring specialized services, job opportunities, and accessible technologies. There is a need for more awareness programs, and assistive devices to support their integration into society.',
        ),

        // UAE Government Support
        InfoCard(
          title: 'UAE Government Support for the Deaf Community',
          content: 'The UAE government offers a range of services to the deaf community, including legal protections, inclusive education, and vocational training. It provides specialized healthcare, assistive technologies, and social services to ensure accessibility and integration. Public awareness and advocacy work to promote equality and reduce stigma for the deaf.',
          url: 'https://u.ae/en/information-and-services/social-affairs/people-of-determination/protection-support-and-assistance-of-people-of-determination',
          onUrlTap: () => _launchUrl('https://u.ae/en/information-and-services/social-affairs/people-of-determination/protection-support-and-assistance-of-people-of-determination'),
        ),
      ],
    );
  }

  // Build educational resources section
  Widget _buildEducationalResourcesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section title
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
        
        // Educational resource cards
        EducationalResourceCard(
          institutionName: "Zayed Higher Organization for People of Determination",
          type: "Specialized Education Center",
          description: "Provides comprehensive educational programs tailored for deaf students with focus on bilingual education using Emirati Sign Language and Arabic.",
          location: "Abu Dhabi",
          url: "https://zho.gov.ae",
          onUrlTap: () => _launchUrl("https://zho.gov.ae"),
        ),

        EducationalResourceCard(
          institutionName: "Sharjah City for Humanitarian Services",
          type: "Inclusive Education Provider",
          description: "Offers specialized courses for deaf students of all ages, including vocational training and integration programs with sign language support.",
          location: "Sharjah",
          url: "https://www.schs.ae",
          onUrlTap: () => _launchUrl("https://www.schs.ae"),
        ),

        EducationalResourceCard(
          institutionName: "Al Amal School for the Deaf",
          type: "K-12 Education",
          description: "One of the oldest specialized schools for deaf students in the UAE, offering academic curriculum delivered in sign language from kindergarten through high school.",
          location: "Sharjah",
          url: "https://www.schs.ae",
          onUrlTap: () => _launchUrl("https://www.schs.ae"),
        ),

        EducationalResourceCard(
          institutionName: "Emirates Association of the Deaf",
          type: "Training & Development",
          description: "Provides sign language courses, interpreter training, and regular workshops to support education and employment for the deaf community.",
          location: "Multiple branches across UAE",
        ),
      ],
    );
  }

  // Helper method to launch URLs using the URL launcher service
  Future<void> _launchUrl(String url) async {
    await _urlLauncherService.launchUrlWithErrorHandling(
      context, 
      url,
      errorMessage: 'Could not open website'
    );
  }
}