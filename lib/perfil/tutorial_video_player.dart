import 'package:afermar3_tf_ipc/pantallas_iniciales/pantallas.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class TutorialVideoPlayer extends StatefulWidget {
  final String videoPath;

  const TutorialVideoPlayer({
    super.key,
    required this.videoPath,
  });

  @override
  State<TutorialVideoPlayer> createState() => _TutorialVideoPlayerState();
}

class _TutorialVideoPlayerState extends State<TutorialVideoPlayer> {
  late VideoPlayerController _controller;

  bool _isReady = false;

  // Sube este valor si todavía se ven bordes negros.
  // Prueba 1.15, 1.25, 1.35 o 1.45.
  final double _cropZoom = 1.00;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset(widget.videoPath)
      ..initialize().then((_) {
        if (!mounted) return;

        setState(() {
          _isReady = true;
        });
      });

    _controller.setLooping(false);

    _controller.addListener(() {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (!_isReady) return;

    if (_controller.value.isPlaying) {
      _controller.pause();
    } else {
      _controller.play();
    }
  }

  Widget _buildLoading() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        color: TColor.rojo.withOpacity(0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: TColor.rojo.withOpacity(0.08),
        ),
      ),
      child: Center(
        child: Container(
          width: 205,
          height: 365,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.04),
            borderRadius: BorderRadius.circular(34),
          ),
          child: CircularProgressIndicator(
            color: TColor.rojo,
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneFrame() {
    final videoSize = _controller.value.size;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: TColor.rojo.withOpacity(0.045),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: TColor.rojo.withOpacity(0.08),
        ),
      ),
      child: Center(
        child: Container(
          width: 215,
          height: 382,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(34),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 20,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Container(
                    color: Colors.black,
                    child: ClipRect(
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.diagonal3Values(
                          1.18, // zoom horizontal
                          1.02, // zoom vertical
                          1.00,
                        ),
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: videoSize.width,
                            height: videoSize.height,
                            child: VideoPlayer(_controller),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: GestureDetector(
                    onTap: _togglePlay,
                    child: Container(
                      color: Colors.transparent,
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: _controller.value.isPlaying ? 0 : 1,
                          duration: const Duration(milliseconds: 180),
                          child: Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.45),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 12,
                  right: 12,
                  bottom: 12,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: TColor.rojo,
                        bufferedColor: Colors.white.withOpacity(0.35),
                        backgroundColor: Colors.white.withOpacity(0.18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return _buildLoading();
    }

    return _buildPhoneFrame();
  }
}
