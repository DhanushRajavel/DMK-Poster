import 'package:dmk/components/bottom_nav_bar.dart';
import 'package:dmk/components/reusable_button.dart';
import 'package:dmk/constant.dart';
import 'package:dmk/screens/save_and_download.dart';
import 'package:dmk/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  Map<String, dynamic>? feedsData;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accesstoken = prefs.getString('accesstoken');
    if (accesstoken != null) {
      return _fetchFeedsData(accesstoken);
    }
  }

  Future<void> _fetchFeedsData(String accesstoken) async {
    try {
      final response = await ApiService.commonPostDataMethod(
          accesstoken: accesstoken, endPoint: "p1-get-feed");
      if (response.containsKey('error')) {
        debugPrint('Error fetching video data: ${response['error']}');
      } else {
        setState(() {
          feedsData = response['response'];
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("error while fetching data $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        scrolledUnderElevation: 0.0,
        elevation: 0,
        title: Text(
          'Explore',
          style: kSubTitleStyle(),
        ),
      ),
      body: isLoading
          ? _buildLoading()
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: ListView.builder(
                itemCount:
                    feedsData != null ? feedsData!['feed_poster'].length : 0,
                itemBuilder: (context, index) {
                  final poster = feedsData!['feed_poster'][index];
                  return Column(
                    children: [
                      _buildFeedsCard(poster),
                      const SizedBox(
                        height: 10,
                      )
                    ],
                  );
                },
              ),
            ),
      bottomNavigationBar: const BottomNavBar(index: 3),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildFeedsCard(final poster) {
    return Card(
      color: const Color(0xFFFFECEC),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(10),
            ),
            child: poster != null
                ? GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  SaveAndDownload(imageUrl: poster['photo'])));
                    },
                    child: Image.network(
                      poster['photo'],
                      width: 372,
                      height: 372,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.broken_image,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
                  )
                : Text(
                    'No Poster',
                    style: kSubTitleStyle(),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: ReusableButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              SaveAndDownload(imageUrl: poster['photo'])));
                },
                title: 'Next',
                    color: const Color(0xFFFF0000)),
          ),
        ],
      ),
    );
  }
}
