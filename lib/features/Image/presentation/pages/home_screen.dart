import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:piecyfer_test/features/Image/presentation/pages/image_detail.dart';

import '../../../../core/common/widgets/image_cache.dart';
import '../../domain/entities/image.dart';
import '../bloc/image_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final PagingController<int, ImageEntity> _pagingController = PagingController(firstPageKey: 1);
  Timer? _debounce; // Timer for debouncing

  @override
  void initState() {
    super.initState();

    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
  }

  Future<void> _fetchPage(int pageKey) async {
    context.read<ImageBloc>().add(LoadMoreImages( limit: 20, page: pageKey));
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _searchController.dispose();
    _debounce?.cancel(); // Cancel debounce timer when disposing
    super.dispose();
  }

  void _onSearchChanged(String query) {
    context.read<ImageBloc>().add(DebouncedSearch(query: query));
    if (_debounce?.isActive ?? false) _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<ImageBloc>().add(FetchImages(query: query, limit: 20, page: 1));
      _pagingController.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Image Gallery',
          style: TextStyle(fontSize: 20.sp),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h), // Reduced vertical padding
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              onChanged: (query) {
                _onSearchChanged(query); // Call the debounce search function
              },
              decoration: InputDecoration(
                hintText: 'Search for images...',
                hintStyle: TextStyle(fontSize: 16.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                prefixIcon: Icon(Icons.search, size: 24.sp),
              ),
            ),
            SizedBox(height: 12.h), // Reduced space below search bar

            // Display images with PagedGridView
            Expanded(
              child: BlocListener<ImageBloc, ImageState>(
                listener: (context, state) {
                  if (state is ImageLoaded) {
                    final isLastPage = state.hasReachedMax;
                    if (isLastPage) {
                      _pagingController.appendLastPage(state.images);
                    } else {
                      final nextPageKey = _pagingController.nextPageKey! + 1;
                      _pagingController.appendPage(state.images, nextPageKey);
                    }
                  } else if (state is ImageError) {
                    _pagingController.error = state.message;

                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        backgroundColor: Colors.red,
                        content: Text(state.message)));

                  }
                },
                child: PagedGridView<int, ImageEntity>(
                  pagingController: _pagingController,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _calculateItemsPerRow(context),
                    crossAxisSpacing: 8.w, // Reduced horizontal spacing
                    mainAxisSpacing: 8.h,  // Reduced vertical spacing
                    childAspectRatio: _calculateAspectRatio(context), // Dynamic aspect ratio
                  ),
                  builderDelegate: PagedChildBuilderDelegate<ImageEntity>(
                    itemBuilder: (context, image, index) {
                      final double itemWidth = (MediaQuery.of(context).size.width / _calculateItemsPerRow(context)) - 8.w;
                      final double itemHeight = itemWidth * 0.75;

                      return GestureDetector(
                        onTap: () => _openFullScreenImage(context, image.largeImageURL ?? ''),
                        child: SizedBox(
                          width: itemWidth,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CachedImageWidget(
                                imageUrl: image.previewURL ?? '',
                                width: itemWidth,
                                height: itemHeight,
                              ),
                              SizedBox(height: 6.h), // Reduced vertical spacing
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Views
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.visibility,
                                          size: 14.sp.clamp(14, 20),  // Ensures icon size doesn't go below 14 and doesn't exceed 20
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          '${image.views}',
                                          style: TextStyle(
                                            fontSize: 12.sp.clamp(12, 16),  // Sets a default minimum size of 12 and max of 16
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Likes
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.favorite,
                                          size: 14.sp.clamp(14, 20),  // Sets a default size range for the icon
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          '${image.likes}',
                                          style: TextStyle(
                                            fontSize: 12.sp.clamp(12, 16),  // Ensures the text is at least 12sp and max 16sp
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    firstPageProgressIndicatorBuilder: (context) => const Center(child: CircularProgressIndicator()),
                    newPageProgressIndicatorBuilder: (context) => const Center(child: CircularProgressIndicator()),
                    noItemsFoundIndicatorBuilder: (context) => Center(
                      child: Text(
                        'No images found!',
                        style: TextStyle(fontSize: 14.sp),
                      ),
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
  // Open the full-screen image with an animation
  void _openFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: FullScreenImagePage(imageUrl: imageUrl),
          );
        },
      ),
    );
  }


  // Dynamically calculate the number of items per row based on screen width
  int _calculateItemsPerRow(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1200) {
      return 5; // Large screen (web or desktop)
    } else if (screenWidth >= 800) {
      return 3; // Medium screen (tablet or smaller desktop)
    } else {
      return 2; // Small screen (mobile)
    }
  }

  // Dynamically calculate the child aspect ratio based on the screen width
  double _calculateAspectRatio(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth >= 1200) {
      return 1.1; // Wider aspect ratio for larger screens (e.g., web)
    } else if (screenWidth >= 800) {
      return 1.1; // Moderate aspect ratio for tablets or smaller desktops
    } else {
      return 1.1; // Standard aspect ratio for mobile
    }
  }
}
