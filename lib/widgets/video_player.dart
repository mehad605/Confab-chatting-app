import 'package:pod_player/pod_player.dart';
import 'package:flutter/material.dart';

class PlayVideoFromNetwork extends StatefulWidget {
  const PlayVideoFromNetwork({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  State<PlayVideoFromNetwork> createState() => _PlayVideoFromNetworkState();
}

class _PlayVideoFromNetworkState extends State<PlayVideoFromNetwork> {
  late final PodPlayerController controller;

  @override
  void initState() {
    controller = PodPlayerController(
      playVideoFrom: PlayVideoFrom.network(
        widget.videoUrl,
      ),
    )..initialise();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PodVideoPlayer(
        controller: controller,
        matchVideoAspectRatioToFrame: true,
        matchFrameAspectRatioToVideo: true,
      ),
    );
  }
}
