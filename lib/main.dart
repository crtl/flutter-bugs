import 'dart:async';

import 'package:flutter/material.dart';
//import "video_player_custom.dart" as custom;
import 'package:video_player/video_player.dart' as custom;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

typedef VideoControllerFactory = custom.VideoPlayerController Function();

class _MyHomePageState extends State<MyHomePage> {

  bool shouldProduceBug = false;

  final _videos = [
    () => custom.VideoPlayerController.network("https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4"),
    () => custom.VideoPlayerController.network("https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4"),
    () => custom.VideoPlayerController.network("https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4"),
    () => custom.VideoPlayerController.network("https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4"),
  ];

  int _currentIndex = -1;

  custom.VideoPlayerController _previousController;
  custom.VideoPlayerController _activeController;

  final StreamController<custom.VideoPlayerController> _streamController = StreamController.broadcast();


  _incrementIndex() {
    _currentIndex++;

    if (_currentIndex >= _videos.length) {
      _currentIndex = 0;
    }
  }

  _changeVideoBug() async {
    _incrementIndex();

    _previousController = _activeController;
    _activeController = _videos[_currentIndex]();

    if (_previousController != null) {
      await _previousController.dispose();
    }

    _initializeVideo(_activeController);
  }

  _changeVideoWorkaround() async {
    _incrementIndex();

    _previousController = _activeController;
    _activeController = _videos[_currentIndex]();

    if (_previousController != null) {
      _previousController.pause();
    }

    _initializeVideo(_activeController).then((_) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        _previousController?.dispose();
      });
    });

  }

  _changeVideo() {
    if (shouldProduceBug) {
      _changeVideoBug();
    } else {
      _changeVideoWorkaround();
    }
  }

  Future _initializeVideo(custom.VideoPlayerController controller) {
    return controller.initialize().then((_) {
      controller.play();
      _streamController.add(controller);
    });
  }

  @override
  void initState() {
    super.initState();

    _changeVideo();
  }

  @override
  void dispose() {
    super.dispose();

    _activeController?.dispose();
    _streamController.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: StreamBuilder<custom.VideoPlayerController>(
          stream: _streamController.stream,
          builder: (_, snapshot) {
            print("buildPlayer ${snapshot.data?.dataSource}");
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }

            return AspectRatio(
              aspectRatio: snapshot.data.value.aspectRatio,
              child: custom.VideoPlayer(snapshot.data)
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _changeVideo,
        tooltip: 'Change video',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
