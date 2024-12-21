// ignore_for_file: prefer_const_constructors

import 'package:dmk/components/bottom_nav_bar.dart';
import 'package:dmk/screens/save_and_download.dart';
import 'package:dmk/screens/video_screen.dart';
import 'package:dmk/screens/view_all_category.dart';
import 'package:dmk/screens/view_all_tposter.dart';
import 'package:dmk/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:dmk/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String id = 'home_screen';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? homeData;
  bool isLoading = true;
  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final accesstoken = prefs.getString('accesstoken');
    if (accesstoken != null) {
      await _fetchHomeData(accesstoken);
    } else {
      print('No access token found');
    }
  }

  Future<void> _fetchHomeData(String accesstoken) async {
    try {
      final response = await ApiService.commonPostDataMethod(
        accesstoken: accesstoken,
        endPoint: 'p1-dashboard',
      );
      if (response.containsKey('error')) {
        print('Error fetching dashboard data: ${response['error']}');
        const Text('No Internet Access');
      } else {
        setState(() {
          homeData = response['response'];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Exception caught during _fetchHomePage: $e');
      const Text('No Internet Access');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Image.asset(
              'images/logo.jpg',
              width: 40,
              height: 40,
            ),
            const SizedBox(width: 10),
            Text(
              'DMK',
              style: kAppNameTitleStyle(),
            ),
            const Spacer(),
            IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const VideoScreen()));
                },
                icon: const Icon(Icons.video_file))
          ],
        ),
      ),
      body: isLoading
          ? _buildLoading()
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
              child: SingleChildScrollView(child: _buildBody()),
            ),
      bottomNavigationBar: const BottomNavBar(index: 0),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPosterTitle('Today Poster', 1),
          _buildTodayPoster(),
          _buildPosterTitle('Quotes', 2),
          _buildQuotesPoster(),
          _buildPosterTitle('Categories', 2),
          _buildCategories(),
        ],
      ),
    );
  }

  Widget _buildPosterTitle(String title, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: kSubTitleStyle(),
        ),
        TextButton(
          onPressed: () {
            if (index == 1) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ViewAllTposter()));
            } else {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ViewAllCategory()));
            }
          },
          child: Row(
            children: [
              Text(
                'View all',
                style: kTextButtonStyle(),
              ),
              const SizedBox(width: 5),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClipRRect(final poster) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => SaveAndDownload(
                      imageUrl: poster['photo'],
                    )));
      },
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          image: DecorationImage(
            image: NetworkImage(poster['photo']),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            // Flexible label
            Align(
              alignment: Alignment.topRight,
              child: _buildTodayPosterLabel(poster['today_titile']),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: _buildTodayPosterLabel(poster['date']),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildTodayPosterLabel(String labelTitle) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 200),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: const BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(8),
          bottomLeft: Radius.circular(8),
        ),
      ),
      child: Text(
        labelTitle,
        style: kTodayPosterLabelStyle(),
        softWrap: true, // Allows the text to wrap
        overflow: TextOverflow.ellipsis, // Truncates if necessary
      ),
    );
  }

  Widget _buildStaticPoster(final poster) {
    return GestureDetector(
      onTap: () {},
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          poster['photo'],
          width: 110,
          height: 110,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTodayPoster() {
    return SizedBox(
        height: 110,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: homeData != null && homeData!['totday_posters'] != null
              ? homeData!['totday_posters'].length
              : 'No Data',
          itemBuilder: (context, index) {
            final poster = homeData!['totday_posters'][index];
            return Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: _buildClipRRect(poster),
            );
          },
        ));
  }

  Widget _buildQuotesPoster() {
    return SizedBox(
        height: 145,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: homeData != null && homeData!['cate_shows_quote'] != null
              ? homeData!['cate_shows_quote'].length
              : 'No Data',
          itemBuilder: (context, index) {
            final poster = homeData!['cate_shows_quote'][index];
            return Padding(
              padding: const EdgeInsets.only(right: 10.0),
              child: Column(
                children: [
                  _buildStaticPoster(poster),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(
                    poster['title'],
                    style: kPosterTitleTextStyle(),
                  )
                ],
              ),
            );
          },
        ));
  }

  Widget _buildCategories() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        childAspectRatio: 0.8,
      ),
      itemCount: homeData != null && homeData!['category_data'] != null
          ? homeData!['category_data'].length
          : 0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final category = homeData!['category_data'][index];
        return Column(
          children: [
            _buildStaticPoster(category),
            const SizedBox(
              height: 3,
            ),
            Flexible(
              child: Text(
                category['title'],
                style: kPosterTitleTextStyle(),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        );
      },
    );
  }
}
