import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';
import 'package:dmk/service/api_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';

class DownloadVideoScreen extends StatefulWidget {
  const DownloadVideoScreen({super.key});

  @override
  State<DownloadVideoScreen> createState() => _DownloadVideoScreenState();
}

class _DownloadVideoScreenState extends State<DownloadVideoScreen> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  final String videoUrl =
      'https://thondanapp.com/video/2gptovYFc0SrO7lTcjJQDJE5PhzZCrQQatijnJfa.mp4';
  String frameUrl = 'https://thondanapp.com/fram2.png';

  String? mergedFilePath;
  bool isLoading = false;
  int? randomFileNameNum;
  Map<String, dynamic>? frameData;
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accesstoken');
    if (accessToken != null) {
      await _fetchVideos(accessToken);
    } else {
      print('No AccessToken Found');
    }
  }

  Future<void> _fetchVideos(String accessToken) async {
    try {
      final response = await ApiService.commonPostDataMethod(
          accesstoken: accessToken, endPoint: 'p1-get-my-frame');
      if (response.containsKey('error')) {
        print('Error fetching dashboard data: ${response['error']}');
      } else {
        setState(() {
          frameData = response['response'];
          isLoading = false;
          if (frameData != null &&
              frameData!['request_data'] != null &&
              frameData!['request_data'].isNotEmpty) {
            frameUrl = frameData!['request_data'][0]['photo'];
          }
        });
      }
    } catch (e) {
      print('Exception caught during _fetchFrameData: $e');
    }
  }

  Future<void> _mergeVideoAndImage() async {
    setState(() => isLoading = true);
    try {
      final directory = await getTemporaryDirectory();
      final randomNum = Random().nextInt(10000);
      final outputFilePath = '${directory.path}/dmk_video$randomNum.mp4';

      final command =
          '-i "$videoUrl" -i "$frameUrl" -filter_complex "[1:v]scale=1080:1080[overlay];[0:v][overlay]overlay=10:10" "$outputFilePath"';

      await FFmpegKit.executeAsync(command, (session) async {
        final returnCode = await session.getReturnCode();
        if (ReturnCode.isSuccess(returnCode)) {
          setState(() => mergedFilePath = outputFilePath);
          await _saveToGallery(outputFilePath, randomNum);
        } else {
          print('Merging failed: ${await session.getLogs()}');
        }
      });
    } catch (e) {
      print('Error during merging: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _saveToGallery(String filePath, int randomNum) async {
    if (await File(filePath).exists()) {
      final result = await SaverGallery.saveFile(
        filePath: filePath,
        fileName: 'dmk_video$randomNum.mp4',
        skipIfExists: true,
        androidRelativePath: 'Movies',
      );
      print('Video saved to gallery: $result');
    } else {
      print('File not found for saving!');
    }
  }

  Widget _buildVideoPlayer() {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error loading video: ${snapshot.error}'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Videos',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Card(
                color: Colors.blue.shade300,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(10),
                          ),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _controller.value.isPlaying
                                    ? _controller.pause()
                                    : _controller.play();
                              });
                            },
                            child: _buildVideoPlayer(),
                          ),
                        ),
                        Image.network(frameUrl),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'World Lung Day',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '30:00 sec',
                                style: TextStyle(color: Colors.grey),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed:
                                    isLoading ? null : _mergeVideoAndImage,
                                icon: const Icon(Icons.download),
                                label: const Text('Download'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isLoading)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}