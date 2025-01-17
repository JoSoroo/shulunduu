import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'full_screen_image_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Swap',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ImageSwapScreen(),
    );
  }
}

class ImageSwapScreen extends StatefulWidget {
  @override
  _ImageSwapScreen createState() => _ImageSwapScreen();
}

class _ImageSwapScreen extends State<ImageSwapScreen> {
  List<String> _images = [];
  String? _currentImage;
  int _currentIndex = 0;
  Timer? _timer;
  DateTime? _nextSwapTime;
  bool _isAppBarVisible = true;

  @override
  void initState() {
    super.initState();
    if (_images.isNotEmpty) {
      _scheduleNextSwap(); // Зураг солихыг төлөвлөх
    }
  }
// Зураг солигдох цагийг тохируулах
void _scheduleNextSwap() {
  // Хуучин таймер байгаа эсэхийг шалгана
  if (_timer != null) {
    _timer!.cancel(); // Хуучин таймерыг зогсооно
    print('Хуучин таймерыг зогсоолоо.');
  }

  DateTime now = DateTime.now();
  print('Одоо цаг: $now');

  DateTime nextSwap;

  // Өглөөний 10:35 болон шөнийн 10:36 цагийг тохируулах
  DateTime morningSwap = DateTime(now.year, now.month, now.day, 10, 00);
  DateTime midnightSwap = DateTime(now.year, now.month, now.day, 23, 59);

  // Хэрэв одоо цаг 10:35-ээс өмнө бол өглөөний 10:35 цагийг тохируулах
  if (now.isBefore(morningSwap)) {
    nextSwap = morningSwap;
    print('Солигдох цаг ${morningSwap}');
  }
  // Хэрэв одоо цаг 10:36-ээс өмнө бол шөнийн 10:36 цагийг тохируулах
  else if (now.isBefore(midnightSwap)) {
    nextSwap = midnightSwap;
    print('Солигдох цаг ${midnightSwap}');
  }
  else {
    // Хэрэв 10:36-с хойш бол маргаашийн өглөөний 10:35 цагт солигдох
    nextSwap = morningSwap.add(Duration(days: 1));
    print('Солигдох цаг маргааш ${morningSwap}');
  }

  _nextSwapTime = nextSwap; // Солигдох цагийг хадгална

  Duration delay = nextSwap.difference(now); // Дараагийн солих хүртэл хүлээлт
  print('Дараагийн солигдох цагийн хүлээлтийн хугацаа: ${delay.inSeconds} секунд');

  // Таймер үүсгэх
  _timer = Timer(delay, () {
    _swapImage(); // Зураг солигдоно
    _scheduleNextSwap(); // Дараагийн солихыг төлөвлөнө
  });
}

void _swapImage() {
  if (_images.isNotEmpty) {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _images.length; // Дараагийн зургийг авах
      _currentImage = _images[_currentIndex]; // Дараагийн зураг
      print('Зураг солигдлоо: $_currentImage');
    });
  }
}

  Future<void> _pickImages() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    allowMultiple: true, // Олон зураг сонгохыг зөвшөөрнө
  );

  if (result != null) {
    setState(() {
      List<String> newImages = result.paths.where((path) => path != null).cast<String>().toList();
      _images.addAll(newImages);

      if (_currentImage == null && _images.isNotEmpty) {
        _currentImage = _images.first;
      }
      print("Зураг сонгогдлоо: $_images");

      // Зургийг сонгосны дараа цагийг дахин тохируулах
      _scheduleNextSwap(); // Зураг сонгосон тохиолдолд солигдох цагийг дахин тооцох
    });
  } else {
    print("Зураг сонгогдсонгүй");
  }
}

  // Сонгосон зургийг устгах функц
  void _deleteImage(String imagePath) {
    setState(() {
      _images.remove(imagePath);
      if (_images.isNotEmpty) {
        _currentImage = _images.first;
      } else {
        _currentImage = null;
      }
    });
  }

  // Бүх зургийг устгах функц
  void _deleteAllImages() {
    setState(() {
      _images.clear();
      _currentImage = null;
    });
  }

  void _viewImageFullScreen() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => FullScreenImagePage(
        images: _images,                // Бүх зургуудыг дамжуулна
        currentIndex: _currentIndex,    // Одоогийн зургийн индекс
        nextSwapTime: _nextSwapTime,    // Дараагийн солигдох хугацаа
        onSwapImage: _swapImage,        // Зураг солих функц
        scheduleNextSwap: _scheduleNextSwap, // Таймерийг дахин тохируулах функц
      ),
    ),
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
            child: _currentImage != null
                ? Image.file(
                    File(_currentImage!),
                    fit: BoxFit.contain,
                    width: double.infinity,
                    height: double.infinity,
                  )
                : const Text(
                    "Зураг оруулаагүй байна",
                    style: TextStyle(fontSize: 18),
                  ),
          ),
            if (_isAppBarVisible)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AppBar(
                  backgroundColor: Colors.black.withOpacity(0.5),
                  title: Text("Image Swap"),
                  automaticallyImplyLeading: true,
                  actions: [
                     /* if (_currentImage != null)
                        IconButton(
                          onPressed: _viewImageFullScreen,
                          icon: Icon(Icons.fullscreen),
                        ),*/
                      IconButton(onPressed: _pickImages, icon: Icon(Icons.add_photo_alternate)),
                      if (_currentImage != null)
                        IconButton(
                          onPressed: () => _deleteImage(_currentImage!), 
                          icon: Icon(Icons.delete),
                        ),
                      if (_images.isNotEmpty)
                        IconButton(
                          onPressed: _deleteAllImages, 
                          icon: Icon(Icons.delete_forever),
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
