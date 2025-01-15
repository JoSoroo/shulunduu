import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

class FullScreenImagePage extends StatefulWidget {
  final List<String> images;
  final int initialIndex;
  final double swapDuration; // Таймерын хугацаа

  const FullScreenImagePage({
    Key? key,
    required this.images,
    required this.initialIndex,
    required this.swapDuration, // Таймерын хугацааг хүлээн авна
  }) : super(key: key);

  @override
  _FullScreenImagePageState createState() => _FullScreenImagePageState();
}

class _FullScreenImagePageState extends State<FullScreenImagePage> {
  late int _currentIndex;
  bool _isAppBarVisible = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _startTimer(); // Таймерыг эхлүүлнэ
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel(); // Хуучин таймерыг зогсооно
    _timer = Timer.periodic(
      Duration(seconds: widget.swapDuration.toInt()), // Таймерыг үндсэн хугацаатай нэгтгэнэ
      (timer) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.images.length;
        });
      },
    );
  }

  void _toggleAppBarVisibility() {
    setState(() {
      _isAppBarVisible = !_isAppBarVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: _toggleAppBarVisibility,
        child: Stack(
          children: [
            Center(
              child: Image.file(
                File(widget.images[_currentIndex]),
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            if (_isAppBarVisible)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppBar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  title: Text("Full Screen Image"),
                  automaticallyImplyLeading: true,
                  actions: [
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
