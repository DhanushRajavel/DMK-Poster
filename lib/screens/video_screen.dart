import 'package:dmk/components/reusable_button.dart';
import 'package:dmk/constant.dart';
import 'package:dmk/service/api_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  late List<VideoPlayerController> controllers = [];
  late Future<void> _initializeVideoPlayerFuture;
  Map<String, dynamic>? videoData;

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accesstoken = prefs.getString('accesstoken');
    if (accesstoken != null) {
      await _fetchVideos(accesstoken);
    } else {
      setState(() {
        videoData = null; // Ensure videoData is null if no token
      });
    }
  }

  Future<void> _fetchVideos(String accessToken) async {
    try {
      final response = await ApiService.commonPostDataMethod(
          accesstoken: accessToken, endPoint: 'p1-videos');
      if (response.containsKey('error')) {
        print('Error fetching video data: ${response['error']}');
      } else {
        setState(() {
          videoData = response['response'];
  if (videoData != null && videoData!['videos'].isNotEmpty) {
    _initializeVideoUrls(videoData!['videos']);
  } else {
    _initializeVideoPlayerFuture = Future.value(); // Empty future
  }        });
      }
    } catch (e) {
      print('Exception caught during _fetchVideos: $e');
    }
  }

  void _initializeVideoUrls(List<dynamic> videoData) {
    controllers = [];
    for (var video in videoData) {
      final url = video['video'];
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      controllers.add(controller);
    }

    _initializeVideoPlayerFuture = Future.wait(
      controllers.map((controller) => controller.initialize()),
    ).then((_) {
      for (var controller in controllers) {
        controller.setLooping(true);
      }
      setState(() {}); // Rebuild the UI after initialization
    }).catchError((error) {
      print('Error initializing videos: $error');
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    // Dispose all controllers
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Videos',
            style: kSubTitleStyle(),
          ),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: _initializeVideoPlayerFuture == null
              ? const Center(child: Text('Loading videos...'))
              : FutureBuilder(
                  future: _initializeVideoPlayerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (controllers.isEmpty) {
                      return const Center(child: Text('No videos available.'));
                    } else {
                      return ListView.builder(
                        itemCount: controllers.length,
                        itemBuilder: (context, index) {
                          return _buildVideoCard(index);
                        },
                      );
                    }
                  },
                ),
        ));
  }

  Widget _buildVideoCard(int index) {
    return Card(
      color: const Color(0xFFFFECEC),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(10),
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  controllers[index].value.isPlaying
                      ? controllers[index].pause()
                      : controllers[index].play();
                });
              },
              child: AspectRatio(
                aspectRatio: controllers[index].value.aspectRatio,
                child: VideoPlayer(controllers[index]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Text(
                  'Video ${index + 1}', // Change this to a meaningful title
                  style: kSubTitleStyle(),
                ),
                const Spacer(),
                Expanded(
                  child: ReusableButton(
                    title: 'Next',
                    color: const Color(0xFFFF0000),
                    onPressed: () {
                      // Implement your navigation logic here
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
