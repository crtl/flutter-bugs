
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerScreen extends StatefulWidget {
  @override
  _ImagePickerScreenState createState() => _ImagePickerScreenState();
}

class _ImagePickerScreenState extends State<ImagePickerScreen> {

  _pickVideo() async {
    final file = await ImagePicker.pickVideo(source: ImageSource.gallery);

    print("ImagePickerScreen._pickVideo.video = ${file.path}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: RaisedButton(
          child: const Text("Pick video"),
          onPressed: _pickVideo,
        ),
      ),
    );
  }
}
