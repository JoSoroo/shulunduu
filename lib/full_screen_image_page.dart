import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';


class FullScreenImagePage extends StatefulWidget {
  final List<String> images;
  final int currentIndex;
  final DateTime? nextSwapTime;
  final VoidCallback onSwapImage;
  final VoidCallback scheduleNextSwap;

  FullScreenImagePage({
    required this.images,
    required this.currentIndex,
    this.nextSwapTime,
    required this.onSwapImage,
    required this.scheduleNextSwap,
  });

  @override
  _FullScreenImagePageState createState() => _FullScreenImagePageState();
}

class _FullScreenImagePageState extends State<FullScreenImagePage> {
  late int _currentIndex; // Дотоод индекс
  Timer? _timer; // `late` биш, `null`-ээр эхлүүлнэ
  bool _isAppBarVisible = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.currentIndex; // Эхний зургийн индексийг тохируулах
    _scheduleNextSwap();
  }

  void _scheduleNextSwap() {
  // Хуучин таймер байгаа эсэхийг шалгана
  if (_timer != null) {
    _timer!.cancel(); // Хуучин таймерыг зогсооно
    print('Хуучин таймерыг зогсоолоо.');
  }
  print('Etseg widget hugatsaag shinejleh');
   widget.scheduleNextSwap(); 
  DateTime now = DateTime.now();
  print('Одоо цаг: $now');

  if (widget.nextSwapTime != null) {
    Duration delay = widget.nextSwapTime!.difference(now);
    print('Дараагийн зураг солих хүртэлх хугацаа: ${delay.inSeconds} секунд');

    // Хугацааны шалгалт
    if (delay.isNegative) {
      // Хэрэв солих хугацаа өнгөрсөн бол дараагийн солигдсон цагийг авч дахин хүлээх
      print('Солих хугацаа өнгөрсөн байна. Таймер үүсгэхгүй.');
      widget.scheduleNextSwap(); // Эцэг виджетийн дараагийн солихыг төлөвлөнө
      return;
    }

    // Таймерыг нэг удаа тохируулна
    _timer = Timer(delay, () {
      print('Таймер ажиллаж дууслаа, зураг солигдоно.');
      widget.onSwapImage(); // Эцэг виджетийн зураг солихыг дуудна
      _swapImage(); // FullScreen доторх зургийг шинэчлэх      
      // Дахин шинэ таймер тохируулна
      _scheduleNextSwap();
    });
  } else {
    // Хэрэв nextSwapTime байхгүй бол хурдан хугацаанд солигдох
    print('nextSwapTime байхгүй байна. Солигдож дуусах цагын хүлээлт байхгүй.');
  }
}



  @override
  void dispose() {
    if (_timer != null) {
      _timer!.cancel(); // Таймер байгаа бол зогсооно
    }
    super.dispose();
  }

  void _swapImage() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.images.length;
      print('FullScreen зургийн индекс солигдлоо: $_currentIndex');
    });
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
