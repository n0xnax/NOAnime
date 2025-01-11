import 'dart:io';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:noanime_app/model/model.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:noanime_app/services/scraper_provider.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ServerPage extends ConsumerStatefulWidget {
  const ServerPage({super.key, required this.episode});
  final Episode episode;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ServerPageState();
}

class _ServerPageState extends ConsumerState<ServerPage> {
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      platform = TargetPlatform.android;
    } else {
      platform = TargetPlatform.iOS;
    }

    // Initialize the controller with a placeholder or null
    _controller = VideoPlayerController.network(''); // Initialize with a dummy URL
    _chewieController = ChewieController(
      allowMuting: false,
      videoPlayerController: _controller!,
      autoPlay: false,
      looping: false,
      allowedScreenSleep: false,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  double progress = 0;
  late String _localPath;
  late bool _permissionReady;
  late TargetPlatform? platform;

  final bool _isDownloading = false;
  final String _progress = '';

  Future<void> downloadVideo(String url) async {
    _permissionReady = await _checkPermission();
    print(_permissionReady);
    await _prepareSaveDir();

    debugPrint('downloading');

    final dio = Dio();

    try {
      Response response = await dio.get(url, options: Options(responseType: ResponseType.stream));
      String? originalFileName;
      if (response.headers.value('content-disposition') != null) {
        RegExp regExp = RegExp(r'filename="([^"]+)"');
        Match? match = regExp.firstMatch(response.headers.value('content-disposition')!);
        if (match != null) {
          originalFileName = match.group(1);
        }
      }
      originalFileName ??= url.split('/').last;
      // if(originalFile)

      String filePath = '$_localPath/$originalFileName';
      /*    TODOimplementing downlaod with dio
      await dio.download(
        url,
        filePath,
        onReceiveProgress: (count, total) {
          setState(() {
            progress = count / total;
          });
        },
      );
        
*/

      final taskId = await FlutterDownloader.enqueue(
        url: url,
        headers: {}, // optional: header send with url (auth token etc)
        savedDir: _localPath,
        showNotification: true, // show download progress in status bar (for Android)
        openFileFromNotification: true, // click on notification to open downloaded file (for Android)
      );

      print('complete download');
    } catch (e) {
      print(e);
    }
  }

  VideoPlayerController? _controller;
  late ChewieController _chewieController;
  List<Video> _linkList = [];
  var _isLoadingVideo = false;

  Future<bool> _checkPermission() async {
    if (platform == TargetPlatform.android) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Future<void> _prepareSaveDir() async {
    _localPath = (await _findLocalPath())!;

    print(_localPath);
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
      print('created');
    }
  }

  Future<String?> _findLocalPath() async {
    if (platform == TargetPlatform.android) {
      return "/storage/emulated/0/Download/noanime";
    } else {
      var directory = await getApplicationDocumentsDirectory();
      return '${directory.path}${Platform.pathSeparator}Download';
    }
  }

  void playVideo(String url) async {
    // Dispose of the current controller
    await _controller?.dispose();
    // Create a new controller with the fetched video URL
    _controller = VideoPlayerController.network(url);

    setState(() {
      _isLoadingVideo = true;
    });

    await _controller?.initialize();

    setState(() {
      _isLoadingVideo = false;
      _chewieController = ChewieController(
        videoPlayerController: _controller!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowedScreenSleep: false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var asyncVideos = ref.watch(getVideosProvider(widget.episode.infoSrc));
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
      body: SafeArea(
        child: Column(children: [
          Center(
            child: _chewieController.videoPlayerController.value.isInitialized
                ? AspectRatio(
                    aspectRatio: _chewieController.videoPlayerController.value.aspectRatio,
                    child: Chewie(
                      controller: _chewieController,
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.tertiary]),
                    ),
                    child: _isLoadingVideo
                        ? AspectRatio(
                            aspectRatio: 16 / 9,
                            child: Center(
                                child: SpinKitFoldingCube(
                              color: Theme.of(context).colorScheme.tertiary,
                            )),
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
                                      'اختر السيرفر والجودة',
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
                  ),
          ),
          asyncVideos.when(
            data: (data) {
              Map<String, List<Video>> servers = {};
              for (var video in data) {
                String serverName = video.quality.substring(0, video.quality.indexOf(':')).trim();
                servers.putIfAbsent(serverName, () => []);
                servers[serverName]!.add(video);
              }
              var index = 0;
              List<DropdownMenuItem<String>> dropdownItems = servers.keys.map((key) {
                index++;
                return DropdownMenuItem(
                  // alignment: Alignment.centerRight,
                  value: key,
                  child: Text(
                    ' Server $index',
                  ),
                );
              }).toList();
              if (_linkList.isEmpty) {
                setState(() {
                  if (servers.isNotEmpty) {
                    _linkList = servers[dropdownItems[0].value]!;
                  }
                });
              }
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        alignment: Alignment.centerRight,
                        dropdownColor: Theme.of(context).colorScheme.primary,
                        value: dropdownItems.isEmpty ? 'empty' : dropdownItems[0].value,
                        items: dropdownItems,
                        onChanged: (value) {
                          setState(() {
                            _linkList = servers[value]!;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _linkList.length,
                          itemBuilder: (context, index) {
                            var video = _linkList[index];

                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              trailing: IconButton.filled(
                                icon: Icon(
                                  Icons.download,
                                  color: Theme.of(context).colorScheme.onPrimary,
                                ),
                                onPressed: _isDownloading
                                    ? null
                                    : () {
                                        downloadVideo(video.url);
                                      },
                              ),
                              title: Text(video.quality.substring(video.quality.indexOf(':') + 1).trim()),
                              onTap: () {
                                playVideo(video.url);
                              },
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
              ).animate().fade();
            },
            error: (error, stackTrace) {
              return Center(child: Text('Error: $error'));
            },
            loading: () {
              return SizedBox(
                height: 400,
                child: Center(
                    child: SpinKitFoldingCube(
                  color: Theme.of(context).colorScheme.primary,
                )),
              );
            },
          ),
          Opacity(
            opacity: progress == 0 ? 0 : 1,
            child: LinearPercentIndicator(
              width: MediaQuery.of(context).size.width,
              lineHeight: 20.0,
              animationDuration: 2500,
              percent: double.parse(progress.toStringAsFixed(2)),
              center: Text((progress * 100).round().toString()),
              barRadius: const Radius.circular(20),
              progressColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        ]),
      ),
    );
  }
}
