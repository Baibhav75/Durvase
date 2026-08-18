import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../constants/app_colors.dart';
import '../../model/banner_model.dart';

class BannerSection extends StatefulWidget {
  final Future<List<BannerItem>>? bannerFuture;
  final VoidCallback? onBannerTap;

  const BannerSection({
    super.key,
    required this.bannerFuture,
    this.onBannerTap,
  });

  @override
  State<BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends State<BannerSection>
    with SingleTickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _animController;

  // Staggered Animation Tweens
  late final Animation<double> _containerScale;
  late final Animation<double> _imageFade;
  late final Animation<Offset> _imageSlide;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _badgeScale;

  int _currentIndex = 0;
  Timer? _autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.94);

    // Setup 6-stage Staggered Entrance Animation (Total 900ms)
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _containerScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
      ),
    );

    _imageFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeIn),
      ),
    );

    _imageSlide = Tween<Offset>(
      begin: const Offset(0.08, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
      ),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0.0, 0.4),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.4, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _badgeScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: const Interval(0.6, 1.0, curve: Curves.elasticOut),
      ),
    );

    _animController.forward();
  }

  void _startAutoSlide(int bannerCount) {
    _autoSlideTimer?.cancel();
    if (bannerCount <= 1) return;

    _autoSlideTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      if (_pageController.hasClients) {
        final nextPage = (_currentIndex + 1) % bannerCount;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<BannerItem>>(
      future: widget.bannerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerLoading();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox.shrink();
        }

        final banners = snapshot.data!;
        _startAutoSlide(banners.length);

        return AnimatedBuilder(
          animation: _animController,
          builder: (context, child) {
            return ScaleTransition(
              scale: _containerScale,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Hero Banner Carousel
                  SizedBox(
                    height: 175,
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: banners.length,
                      onPageChanged: (index) {
                        setState(() => _currentIndex = index);
                      },
                      itemBuilder: (context, index) {
                        final banner = banners[index];
                        return _buildHeroBannerCard(banner);
                      },
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Responsive Page Indicator Pills
                  if (banners.length > 1)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(banners.length, (index) {
                        final isActive = _currentIndex == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 280),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: isActive ? 22 : 6,
                          height: 5.5,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primaryGreen
                                : AppColors.primaryGold.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      }),
                    ),
                  const SizedBox(height: 6),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeroBannerCard(BannerItem banner) {
    return GestureDetector(
      onTap: widget.onBannerTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryGold.withOpacity(0.3),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(19),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Layered Background Banner Image
              FadeTransition(
                opacity: _imageFade,
                child: SlideTransition(
                  position: _imageSlide,
                  child: CachedNetworkImage(
                    imageUrl: banner.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Shimmer.fromColors(
                      baseColor: Colors.grey[200]!,
                      highlightColor: Colors.grey[50]!,
                      child: Container(color: AppColors.white),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: AppColors.primaryGreen.withOpacity(0.08),
                      child: const Icon(
                        Icons.local_florist_rounded,
                        color: AppColors.primaryGreen,
                        size: 40,
                      ),
                    ),
                  ),
                ),
              ),

              // 2. Soft Gradient Vignette for clear visual hierarchy
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.35),
                      Colors.transparent,
                      Colors.black.withOpacity(0.15),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),

              // 3. Subtle Floating Glassmorphic Pill Tag
              Positioned(
                top: 12,
                left: 12,
                child: SlideTransition(
                  position: _textSlide,
                  child: ScaleTransition(
                    scale: _badgeScale,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.88),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryGold.withOpacity(0.5),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            color: AppColors.primaryGreen,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '100% Herbal & Authentic',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[200]!,
        highlightColor: Colors.grey[50]!,
        child: Container(
          height: 165,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

