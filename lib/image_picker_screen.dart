
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class ImagePickerScreen extends StatefulWidget {
  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {

  final picker = ImagePicker();

  bool initialized = false;

  PickedFile pickedFile;

  File video;

  VideoPlayerController _videoController;

  _pickVideo(ImageSource source) async {
    setState(() {
      initialized = false;
    });

    if (_videoController != null) {
      await _videoController.dispose();
    }

    picker.getVideo(source: source).then((value) {

      if (value == null) {
        return;
      }

      print("getVideo.result ${value.path}");
      (source == ImageSource.gallery ? _normalizeVideoPath(value.path) : Future.value(value.path)).then((path) {
        setState(() {
          pickedFile = value;
          print("path: $path");
          video = File(path);
          initializeVideoPlayer();
        });
      });
    });
  }

  Future<String> _normalizeVideoPath(String path) async {
    print("_normalizeVideoPath $path");
    final input = File(path);
    final targetPath = input.path.replaceFirst("jpg", "mp4");

    await input.copy(targetPath);

    return targetPath;
  }

  initializeVideoPlayer() async {

    _videoController = VideoPlayerController.file(video);
    _videoController.setLooping(true);

    await _videoController.initialize();
    _videoController.play();

    setState(() {
      initialized = true;
    });

  }


  _renderVideo() {
    if (video == null) {
      return Text("No video picked");
    } else if (!initialized) {
      return CircularProgressIndicator();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text("PickedFile.path: ${pickedFile.path}"),
        Text("Video.path: ${video.path}"),
        const SizedBox(height: 16),
        AspectRatio(
          aspectRatio: 1.3,
          child: Center(
            child: AspectRatio(
              aspectRatio: _videoController.value.aspectRatio,
              child: VideoPlayer(_videoController)
            ),
          ),
        ),
      ],
    );

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RaisedButton(
                  child: const Text("Gallery"),
                  onPressed: () => _pickVideo(ImageSource.gallery),
                ),
                RaisedButton(
                  child: const Text("Camera"),
                  onPressed: () => _pickVideo(ImageSource.camera),
                )
              ],
            ),
            const SizedBox(height: 32),
            _renderVideo(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _videoController?.dispose();
  }
}
