import 'dart:math';

import 'package:dmk/components/reusable_button.dart';
import 'package:dmk/constant.dart';
import 'package:dmk/service/api_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaveAndDownload extends StatefulWidget {
  SaveAndDownload(
      {super.key, this.imageUrl, this.createPostImage, this.isCroppedPost});
  final String? imageUrl;
  Uint8List? createPostImage;
  bool? isCroppedPost;
  @override
  State<SaveAndDownload> createState() => _SaveAndDownloadState();
}

class _SaveAndDownloadState extends State<SaveAndDownload> {
  String? imageUrl;
  String? frameUrl;
  final GlobalKey _globalKey = GlobalKey();
  Map<String, dynamic>? frameData;
  bool isLoading = true;
  int? randomFileNameNum;
  Uint8List? createPostImage;
  bool? isCroppedPost;

  @override
  void initState() {
    super.initState();
    String? updatedUrl = widget.imageUrl;
    createPostImage = widget.createPostImage;
    isCroppedPost = widget.isCroppedPost;
    if (updatedUrl != null) {
      imageUrl = updatedUrl.replaceAll("thumb_", "");
    } else {
      imageUrl = '';
    }
    _loadUserData();
  }

  Random random = Random();

  Future<void> _loadUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final accesstoken = prefs.getString('accesstoken');
    if (accesstoken != null) {
      await _fetchFrameData(accesstoken);
    } else {
      print('No access token found');
    }
  }

  Future<void> _fetchFrameData(String accesstoken) async {
    try {
      final response = await ApiService.commonPostDataMethod(
          accesstoken: accesstoken, endPoint: 'p1-get-my-frame');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Download Image',
          style: kSubTitleStyle(),
        ),
      ),
      body: isLoading ? _buildLoading() : _buildBody(),
    );
  }

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildBody() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPosterShower(),
          const SizedBox(height: 20),
          _buildButton(),
          const SizedBox(height: 18),
          Text(
            'Frame',
            style: kSubTitleStyle(),
          ),
          const SizedBox(height: 18),
          _buildFrames()
        ],
      ),
    );
  }

  Widget _buildButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ReusableButton(
            onPressed: _saveMergedImage,
            title: 'Download',
            color: const Color(0xFFFF0000),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ReusableButton(
            onPressed: () {},
            color: const Color(0xFFFF0000),
            title: 'Share',
          ),
        ),
      ],
    );
  }

  Widget _buildPosterShower() {
    return RepaintBoundary(
      key: _globalKey,
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isCroppedPost == true && createPostImage != null)
              // Display the cropped image using Image.memory
              Image.memory(
                createPostImage!,
                width: 370,
                height: 370,
                fit: BoxFit.cover,
              )
            else if (imageUrl != null && imageUrl!.isNotEmpty)
              // Display the image from URL using Image.network
              Image.network(
                imageUrl!,
                width: 370,
                height: 370,
                fit: BoxFit.cover,
              ),
            // Overlay the frame image if available
            if (frameUrl != null && frameUrl!.isNotEmpty)
              Image.network(
                frameUrl!,
                width: 370,
                height: 370,
                fit: BoxFit.cover,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrames() {
    if (frameData == null || frameData!['request_data'] == null) {
      return Center(
        child: Text(
          'No Frames Available',
          style: kPosterTitleTextStyle(),
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          mainAxisExtent: 120,
        ),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: frameData!['request_data'].length,
        itemBuilder: (BuildContext context, int index) {
          final frames = frameData!['request_data'][index];
          return _buildClipRRect(frames);
        },
      ),
    );
  }

  Future<void> _saveMergedImage() async {
    try {
      final boundary = _globalKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) {
        throw Exception('Boundary not found');
      }
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      setState(() {
        randomFileNameNum = random.nextInt(100000);
      });
      final filePath = '${directory.path}/Dmk_${randomFileNameNum}.png';
      File mergedImageFile = File(filePath);
      await mergedImageFile.writeAsBytes(pngBytes);

      final SaveResult result = await SaverGallery.saveFile(
        filePath: filePath,
        fileName: 'Dmk_${randomFileNameNum}.png',
        skipIfExists: true,
      );

      if (result.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image saved to gallery successfully!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save image to gallery.')),
        );
      }
    } catch (e) {
      print('Error saving image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error saving image.')),
      );
    }
  }

  Widget _buildClipRRect(final poster) {
    return GestureDetector(
      onTap: () {
        setState(() {
          frameUrl = poster['photo'];
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            poster['photo'],
            height: 120,
            width: 120,
          ),
        ),
      ),
    );
  }
}
