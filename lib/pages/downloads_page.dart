import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noanime_app/main.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

Future<void> requestPermissions() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    await Permission.storage.request();
  }
}

Future<Directory> getDownloadsDirectoryPath() async {
  Directory? downloadsDirectory;
  if (Platform.isAndroid) {
    downloadsDirectory = Directory('/storage/emulated/0/Download/noanime');
  } else if (Platform.isIOS) {
    downloadsDirectory = await getApplicationDocumentsDirectory();
  } else {
    downloadsDirectory = await getDownloadsDirectory();
  }
  bool isAvailable = await downloadsDirectory!.exists();

  if (!isAvailable) {
    await downloadsDirectory.create();
  }

  return downloadsDirectory;
}

Future<List<FileSystemEntity>> readFilesFromDownloads() async {
  Directory downloadsDirectory = await getDownloadsDirectoryPath();
  return downloadsDirectory.listSync(); // List all files in the directory
}

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  List<FileSystemEntity>? files;
  late ChewieController _chewieController;
  late VideoPlayerController _controller;
  bool _isVideoLoading = false;

  @override
  void initState() {
    super.initState();
    requestPermissions().then((_) {
      readFilesFromDownloads().then((value) {
        setState(() {
          files = value;
        });
      });
    });

    // Initialize with a dummy URL to avoid late initialization error
    _controller = VideoPlayerController.network('');
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: false,
      looping: false,
      allowFullScreen: true,
      allowedScreenSleep: false,
    );
  }

  void playVideo(File file) async {
    // Dispose of the current controller
    _chewieController.dispose(); // Dispose the ChewieController
    await _controller.dispose(); // Dispose the VideoPlayerController

    // Create a new controller with the fetched video file
    _controller = VideoPlayerController.file(file);

    setState(() {
      _isVideoLoading = true;
    });

    await _controller.initialize();

    setState(() {
      _isVideoLoading = false;
      _chewieController = ChewieController(
        videoPlayerController: _controller,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowedScreenSleep: false,
      );
    });
  }

  @override
  void dispose() {
    _chewieController.dispose(); // Dispose the ChewieController
    _controller.dispose(); // Dispose the VideoPlayerController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'NOA',
                style: GoogleFonts.pixelifySans().copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: Theme.of(context).textTheme.headlineSmall!.fontSize,
                ),
              ),
              TextSpan(
                text: 'nime',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
        ),
      ),
      body: files == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _chewieController.videoPlayerController.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _chewieController.videoPlayerController.value.aspectRatio,
                        child: Chewie(
                          controller: _chewieController,
                        ),
                      )
                    : AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Theme.of(context).colorScheme.primary.withAlpha(100),
                              Theme.of(context).colorScheme.tertiary.withAlpha(100),
                            ]),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(
                                Icons.play_circle,
                                size: 200,
                                color: Theme.of(context).colorScheme.secondary.withAlpha(200),
                              ),
                              Text(
                                  textAlign: TextAlign.center,
                                  'مشغل الفيديو',
                                  style: GoogleFonts.lemonada().copyWith(
                                    fontWeight: FontWeight.bold,
                                    foreground: Paint()
                                      ..shader = LinearGradient(
                                        colors: <Color>[
                                          Theme.of(context).colorScheme.secondary,
                                          Theme.of(context).colorScheme.primary,
                                        ],
                                      ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                                    shadows: [
                                      const Shadow(
                                        blurRadius: 15.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        offset: Offset(1.0, 0.5),
                                      ),
                                    ],
                                    fontSize: Theme.of(context).textTheme.headlineSmall!.fontSize,
                                  )

                                  /* Theme.of(context).textTheme.headlineMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  foreground: Paint()
                                    ..shader = LinearGradient(
                                      colors: <Color>[
                                        Theme.of(context).colorScheme.secondary,
                                        Theme.of(context).colorScheme.primary,
                                      ],
                                    ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                                  shadows: [
                                    Shadow(
                                      blurRadius: 15.0,
                                      color: const Color.fromARGB(255, 0, 0, 0),
                                      offset: Offset(1.0, 0.5),
                                    ),
                                  ],
                                ),*/
                                  ),
                            ],
                          ),
                        ),
                      ),
                const SizedBox(
                  height: 8,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'قائمة الحلقات التي تم تنزيلها',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: files!.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).colorScheme.primaryFixed,
                              width: 1,
                            ),
                          ),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.play_arrow,
                            color: Theme.of(context).colorScheme.primaryFixed,
                          ),
                          onTap: () {
                            playVideo(File(files![index].path));
                          },
                          title: Text(files![index].path.split('/').last),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
