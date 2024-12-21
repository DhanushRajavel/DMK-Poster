import 'dart:typed_data';

import 'package:dmk/components/bottom_nav_bar.dart';
import 'package:dmk/constant.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:io';
import 'package:dmk/screens/save_and_download.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';

class CreateScreen extends StatefulWidget {
  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  List<AssetEntity> images = [];
  Uint8List? previewImage;

  @override
  void initState() {
    super.initState();
    loadGalleryPhotos();
  }

  Future<void> loadGalleryPhotos() async {
    final PermissionState result = await PhotoManager.requestPermissionExtend();
    if (result.isAuth) {
      // Load albums and photos
      List<AssetPathEntity> albums = await PhotoManager.getAssetPathList(
        type: RequestType.image,
      );
      List<AssetEntity> media = await albums[0]
          .getAssetListPaged(page: 0, size: 100); // Fetch up to 100 photos

      if (media.isNotEmpty) {
        final firstImage = await media[0].thumbnailDataWithSize(
            const ThumbnailSize(1080, 1080)); // High-res thumbnail
        setState(() {
          images = media;
          previewImage = firstImage;
        });
      }
    } else {
      // Handle permission denial
      PhotoManager.openSetting();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        title: Text("Create Post", style: kSubTitleStyle()),
        actions: [
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildNextButton(() {
                _cropImage();
                //   Navigator.push(
                // context,
                // MaterialPageRoute(
                //     builder: (context) => ImageCropperScreen(getPreviewImage: previewImage,)));
              }, 'Next'))
        ],
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the first image in the preview
            previewImage != null
                ? Image.memory(previewImage!,
                    width: 370, height: 370, fit: BoxFit.cover)
                : Container(
                    width: 370,
                    height: 370,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
            const SizedBox(height: 15),
            Text('Gallery', style: kSubTitleStyle()),
            const SizedBox(height: 15),
            Expanded(child: _buildGalleryPhotos()),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(index: 2),
    );
  }

  Widget _buildGalleryPhotos() {
    return images.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, // 3 images per row
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              return FutureBuilder<Uint8List?>(
                future: images[index].thumbnailDataWithSize(const ThumbnailSize(
                    400, 400)), // Improved thumbnail quality
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done &&
                      snapshot.data != null) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          previewImage = snapshot.data!;
                        });
                      },
                      child: Image.memory(snapshot.data!, fit: BoxFit.cover),
                    );
                  }
                  return Container(color: Colors.grey[300]);
                },
              );
            },
          );
  }

  Future<void> _cropImage() async {
    if (previewImage != null) {
      try {
        // Save the Uint8List to a temporary file
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/temp_image.png');
        await tempFile.writeAsBytes(previewImage!);

        // Pass the file path to the cropImage method
        CroppedFile? cropped = await ImageCropper().cropImage(
          sourcePath: tempFile.path,
          compressFormat: ImageCompressFormat.png,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.square,
              lockAspectRatio: false,
              aspectRatioPresets: [
                CropAspectRatioPreset.square,
              ],
            ),
          ],
        );

        if (cropped != null) {
          // If cropping is successful, update the preview image
          final croppedBytes = await File(cropped.path).readAsBytes();
          setState(() {
            previewImage = croppedBytes;
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SaveAndDownload(
                          isCroppedPost: true,
                          createPostImage: previewImage,
                        )));
          });
        }
      } catch (e) {
        print('Error during cropping: $e');
        // Navigate back on error if necessary
      }
    }
  }

  Widget _buildNextButton(Function() onPressed, String title) {
    return ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF0000),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          child: Text(
            title,
            style: kButtonTextStyle(),
          ),
        ));
  }
}
