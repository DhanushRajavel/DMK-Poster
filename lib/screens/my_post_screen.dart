import 'package:dmk/components/bottom_nav_bar.dart';
import 'package:dmk/constant.dart';
import 'package:dmk/screens/save_and_download.dart';
import 'package:dmk/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyPostScreen extends StatefulWidget {
  @override
  State<MyPostScreen> createState() => _MyPostScreenState();
}

class _MyPostScreenState extends State<MyPostScreen> {
  List<dynamic> posts = [];
  int currentPage = 1;
  bool isLoadingMore = false;
  bool hasMore = true;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _loadAccessTokenAndFetchPosts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadAccessTokenAndFetchPosts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accesstoken');
    if (accessToken != null) {
      _fetchPosts(accessToken);
    } else {
      print('No access token found');
    }
  }

  Future<void> _fetchPosts(String accessToken) async {
    if (isLoadingMore || !hasMore) return;

    setState(() => isLoadingMore = true);

    try {
      final response = await ApiService.commonPostDataMethod(
        accesstoken: accessToken,
        endPoint: 'p1-my-poster?page=$currentPage',
      );

      if (response['status'] == 1) {
        final responseData = response['response']['request_data']['data'];
        final totalPosts = response['response']['request_data']['total'];

        setState(() {
          posts.addAll(responseData ?? []); // Append new posts
          hasMore =
              posts.length < totalPosts; // Check if more data is available
          currentPage++; // Increment page count
        });
      } else {
        print('Error fetching data: ${response['error']}');
      }
    } catch (e) {
      print('Error during fetch: $e');
    } finally {
      setState(() => isLoadingMore = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        hasMore &&
        !isLoadingMore) {
      _loadAccessTokenAndFetchPosts(); // Load next page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          scrolledUnderElevation: 0.0,
          title: Text(
            'My Posts',
            style: kSubTitleStyle(),
          )),
      body: posts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : GridView.builder(
              controller: _scrollController,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              itemCount: posts.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == posts.length && hasMore) {
                  return const Center(child: CircularProgressIndicator());
                }

                final post = posts[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SaveAndDownload(
                                  imageUrl: post['photo'],
                                )));
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      post['photo'],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error),
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: const BottomNavBar(index: 1),
    );
  }
}
