import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class WordDetailPage extends StatefulWidget {
  final String word;
  final String description;
  final String image;
  final Color categoryColor;
  final String? videoPath; // Add videoPath parameter

  const WordDetailPage({
    Key? key,
    required this.word,
    required this.description,
    required this.image,
    required this.categoryColor,
    this.videoPath, // Optional video path
  }) : super(key: key);

  @override
  State<WordDetailPage> createState() => _WordDetailPageState();
}

class _WordDetailPageState extends State<WordDetailPage> {
  bool isFavorite = false;
  int _selectedTabIndex = 0;
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  final List<String> _tabTitles = ['وصف', 'تعليمات', 'نصائح للإتقان'];

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    if (widget.videoPath != null && widget.videoPath!.isNotEmpty) {
      _videoController = VideoPlayerController.asset(widget.videoPath!)
        ..initialize().then((_) {
          setState(() {
            _isVideoInitialized = true;
          });
        }).catchError((error) {
          print("Error initializing video: $error");
        });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  // Get dynamic instructions based on the word
  List<String> _getInstructions() {
    // Default instructions if no specific ones are found
    List<String> defaultInstructions = [
      'ابدأ برفع يدك اليمنى مفتوحة بجانب الوجه',
      'حرك يدك في حركة دائرية خفيفة',
      'ثم اجعل يدك تنزل للأمام مع إشارة الإحترام',
      'حافظ على الابتسامة أثناء الإشارة',
    ];
    
    // Word-specific instructions
    switch (widget.word) {
      case 'يأكل':
        return [
          'ضع أطراف أصابعك معاً',
          'حرك يدك نحو فمك',
          'افتح يدك قليلاً ثم أغلقها كأنك تأكل',
          'كرر هذه الحركة مرتين'
        ];
      case 'يشرب':
        return [
          'شكل يدك كأنك تمسك كوباً',
          'حرك يدك نحو فمك',
          'اعمل حركة الشرب',
          'يمكن إمالة رأسك للخلف قليلاً'
        ];
      case 'ينام':
        return [
          'ضع كفك مفتوحاً بجانب خدك',
          'أغلق عينيك ببطء',
          'أمل رأسك قليلاً للجانب',
          'حافظ على الإشارة لثانية أو اثنتين'
        ];
      case 'يقرأ':
        return [
          'افتح كفيك كأنك تمسك كتاباً',
          'حرك عينيك من اليمين إلى اليسار',
          'اجعل تعبير وجهك يعكس التركيز',
          'حافظ على ثبات اليدين أثناء الإشارة'
        ];
      case 'يكتب':
        return [
          'اجعل يدك اليسرى مفتوحة كأنها ورقة',
          'استخدم اليد اليمنى كأنك تمسك قلماً',
          'حرك يدك اليمنى على اليسرى بحركة الكتابة',
          'حافظ على تركيز النظر على حركة اليد'
        ];
      case 'السلام عليكم':
      case 'مرحباً':
        return [
          'ارفع يدك اليمنى بجانب وجهك',
          'حرك يدك للأمام بانحناء خفيف',
          'ابتسم أثناء تقديم الإشارة',
          'يمكن تكرار الحركة مرتين للتأكيد'
        ];
      case 'شكراً':
        return [
          'ضع أصابعك على شفتيك',
          'حرك يدك للأمام وللأسفل',
          'انهِ الحركة بفتح الكف',
          'ابتسم أثناء تقديم الإشارة'
        ];
      case 'أب':
        return [
          'ضع إبهامك على جبينك',
          'افرد أصابعك الأخرى للأعلى',
          'حرك يدك للأمام قليلاً',
          'احتفظ بتعبير وجه يدل على الاحترام'
        ];
      case 'أم':
        return [
          'ضع إبهامك على ذقنك',
          'افرد أصابعك الأخرى',
          'حرك يدك للأمام قليلاً',
          'اعرض ابتسامة دافئة أثناء الإشارة'
        ];
      case 'واحد':
        return [
          'ارفع سبابتك للأعلى',
          'اجعل باقي أصابعك مطوية',
          'حافظ على ثبات اليد لحظة',
          'يمكن تحريك اليد قليلاً للتأكيد'
        ];
      case 'اثنان':
        return [
          'ارفع السبابة والوسطى للأعلى',
          'اجعل باقي أصابعك مطوية',
          'باعد قليلاً بين الإصبعين',
          'حافظ على وضوح الإشارة'
        ];
      default:
        return defaultInstructions;
    }
  }

  // Get dynamic tips based on the word
  List<String> _getTips() {
    // Default tips if no specific ones are found
    List<String> defaultTips = [
      'حافظ على اتصال العين أثناء تقديم الإشارة',
      'يمكن استخدام تعبيرات الوجه المناسبة مع الإشارة لتأكيد المعنى',
      'التدرب على الإشارة أمام المرآة يساعد على إتقانها',
      'تدرب بسرعات مختلفة',
    ];
    
    // Word-specific tips
    switch (widget.word) {
      case 'يأكل':
      case 'يشرب':
        return [
          'تعتبر إشارات الطعام والشراب من الإشارات الأساسية للمبتدئين',
          'حاول أن تجعل حركتك طبيعية كأنك تقوم بالفعل حقيقةً',
          'استخدم تعابير الوجه المناسبة مثل الرضا أو التلذذ',
          'يمكن تغيير سرعة الحركة للتعبير عن شدة الجوع أو العطش'
        ];
      case 'يقرأ':
      case 'يكتب':
        return [
          'اجعل حركاتك واضحة ومحددة',
          'يمكن تغيير وضعية الإشارة حسب نوعية الكتابة أو القراءة',
          'تعبيرات الوجه مهمة للتعبير عن مدى الاهتمام بالقراءة',
          'تُستخدم هذه الإشارة كثيراً في سياق التعليم'
        ];
      case 'السلام عليكم':
      case 'مرحباً':
        return [
          'ابدأ كل محادثة بهذه الإشارة كتقليد مهم',
          'الابتسامة جزء لا يتجزأ من هذه الإشارة',
          'انتبه إلى مستوى اليد، يجب أن تكون بمستوى الصدر أو أعلى قليلاً',
          'هذه من أكثر الإشارات استخداماً في التواصل اليومي'
        ];
      case 'شكراً':
        return [
          'اجعل الإشارة تنبع من القلب لتعطي دفئاً أكثر',
          'تأكد من وضوح حركة الشكر بفتح الكف في نهاية الحركة',
          'يمكن تكرار الإشارة للتعبير عن الامتنان الشديد',
          'تعتبر هذه الإشارة من أكثر الإشارات تقديراً في مجتمع الصم'
        ];
      default:
        return defaultTips;
    }
  }

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
                              // Show video player if initialized, otherwise show image
                              _isVideoInitialized && _videoController != null
                                  ? AspectRatio(
                                      aspectRatio: _videoController!.value.aspectRatio,
                                      child: VideoPlayer(_videoController!),
                                    )
                                  : Image.asset(
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
                              // Play button overlay
                              Center(
                                child: GestureDetector(
                                  onTap: () {
                                    if (_videoController != null && _isVideoInitialized) {
                                      setState(() {
                                        _videoController!.value.isPlaying
                                            ? _videoController!.pause()
                                            : _videoController!.play();
                                      });
                                    }
                                  },
                                  child: Container(
                                    width: 60.h,
                                    height: 60.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.8),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _videoController != null && _isVideoInitialized && _videoController!.value.isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Color(0xFF00D0FF),
                                      size: 40.sp,
                                    ),
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
                                fontSize: 28.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 20.h),

                            // Tags row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _buildTag('مبتدئ', Color(0xFFFCE8DD)),
                                SizedBox(width: 16.w),
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
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
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

  // Instructions tab content with dynamic instructions
  Widget _buildInstructionsTab() {
    List<String> instructions = _getInstructions();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        instructions.length,
        (index) => _buildInstructionStep(
          number: '${index + 1}',
          description: instructions[index],
        ),
      ),
    );
  }

  // Tips tab content with dynamic tips
  Widget _buildTipsTab() {
    List<String> tips = _getTips();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tips.map((tip) => _buildTipItem(tip)).toList(),
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