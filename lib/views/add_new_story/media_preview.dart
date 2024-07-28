import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';

class MediaPreviewWidget extends StatefulWidget {
  final File file;
  final bool isVideo;
  final String remote;
  final String id;
  final Image image;

  @override
  MediaPreviewWidget({this.file, this.isVideo, this.remote,this.id,this.image});

  @override
  _MediaPreviewWidgetState createState() => _MediaPreviewWidgetState();
}

class _MediaPreviewWidgetState extends State<MediaPreviewWidget> {
  VideoPlayerController _controller;
  ChewieController _chewieController;

  void initState() {
    super.initState();
    initPlayer();
  }

  initPlayer() async {
    if (widget.isVideo) {
      _controller = VideoPlayerController.file(widget.file);
    } else {
      return;
    }
    await _controller.initialize();

    _chewieController = ChewieController(
      fullScreenByDefault: true,
      videoPlayerController: _controller,
      aspectRatio: _controller.value.aspectRatio,
      autoPlay: true,
      looping: true,
    );
    setState(() {
      _chewieController.play();
    });
  }

  @override
  void dispose() {
    if (widget.isVideo) {
      _controller.dispose();
      _chewieController.dispose();
    }
    super.dispose();
  }

  ImageProvider getImage() {
    if (widget.remote != null) {
      return NetworkImage(widget.remote);
    } else {
      return FileImage(widget.file.absolute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.black,
      body: Container(
          child: !widget.isVideo
      ? PhotoView(
          imageProvider: getImage(),
        )
      : Center(
          child: _controller.value.initialized
              ? GestureDetector(
                  onTap: () {
                    _chewieController.play();
                  },
                  child: Chewie(
                    controller: _chewieController,
                  ),
                )
              : Container(
                  color: Colors.red,
                ),
        ),
        ),
    );
  }
}
