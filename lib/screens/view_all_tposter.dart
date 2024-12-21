// ignore_for_file: prefer_const_constructors

import 'package:dmk/components/reusable_button.dart';
import 'package:dmk/constant.dart';
import 'package:dmk/screens/save_and_download.dart';
import 'package:dmk/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ViewAllTposter extends StatefulWidget {
  const ViewAllTposter({super.key});

  @override
  State<ViewAllTposter> createState() => _ViewAllTposterState();
}

class _ViewAllTposterState extends State<ViewAllTposter> {
  Map<String, dynamic>? todayPosterDatas;
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
      return _fetchtodayPosterDatas(accesstoken);
    }
  }

  Future<void> _fetchtodayPosterDatas(String accesstoken) async {
    try {
      final response = await ApiService.commonPostDataMethod(
          accesstoken: accesstoken, endPoint: "p1-today-poster");
      if (response.containsKey('error')) {
        debugPrint('Error fetching video data: ${response['error']}');
      } else {
        setState(() {
          todayPosterDatas = response['response'];
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
        scrolledUnderElevation: 0.0,
        title: Text(
          'Today Poster',
          style: kSubTitleStyle(),
        ),
      ),
      body: isLoading
          ? _buildLoading()
          : Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: ListView.builder(
                itemCount: todayPosterDatas != null
                    ? todayPosterDatas!['totday_posters'].length
                    : 0,
                itemBuilder: (context, index) {
                  final poster = todayPosterDatas!['totday_posters'][index];
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
              child: Row(
                children: [
                  Expanded(
                    child: ReusableButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SaveAndDownload(
                                      imageUrl: poster['photo'])));
                        },
                        title: 'Save', color: const Color(0xFFFF0000),),
                  ),
                  SizedBox(width: 10,),
                  Expanded(
                    child: ReusableButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SaveAndDownload(
                                      imageUrl: poster['photo'])));
                        },
                        title: 'Next',color: const Color(0xff000000)),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}
