import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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

  @override
  void initState() {
    super.initState();
    _loadImagesFromStorage(); // Апп нээгдэх үед зургийг ачаалах
    if (_images.isNotEmpty) {
      _scheduleNextSwap(); // Зураг солихыг төлөвлөх
    }
  }

  Future<void> _loadImagesFromStorage() async {
    print('loadaa loadimage duudagdlaa');
    // Зөвшөөрөл авах
    print('loadaa zowshoorol hvselee');
    PermissionStatus status =
        await Permission.storage.request(); // Хадгалалтын зөвшөөрлийг хүсэх
    print('Зөвшөөрлийн хариу: $status');

    if (status.isGranted) {
      print('Зөвшөөрөл олгогдлоо.');
      // File Manager-аас файлуудыг унших
      Directory directory =
          Directory('/storage/emulated/0/'); // Android root directory
      List<FileSystemEntity> files = directory.listSync(recursive: true);
      List<String> jpgFiles = files
          .whereType<File>()
          .where((file) =>
              file.path.toLowerCase().endsWith('.png') ||
              file.path.toLowerCase().endsWith('.jpg'))
          .map((file) => file.path)
          .toList();
      print('loadaa $jpgFiles зурагууд');
      String? morningImage = jpgFiles.firstWhere(
        (path) => path.toLowerCase().contains('morning'),
        orElse: () => '',
      );
      String? nightImage = jpgFiles.firstWhere(
        (path) => path.toLowerCase().contains('night'),
        orElse: () => '',
      );
      setState(() {
        _images = jpgFiles; // Зургийн жагсаалтад нэмэх
        if (_images.isNotEmpty) {
          DateTime now = DateTime.now();
          if (now.hour >= 10 && now.hour < 24) {
            _currentImage = morningImage != '' ? morningImage : null;
          } else {
            _currentImage = nightImage != '' ? nightImage : null;
          }
        }
        print('Ehnii zurag $_currentImage');
        _scheduleNextSwap(); // Зураг солигдох цагийг төлөвлөх
      });

      print("Ачаалагдсан зургууд: $_images");
    } else if (status.isDenied) {
      print("Зөвшөөрөл татгалзсан.");
    } else if (status.isPermanentlyDenied) {
      print("Зөвшөөрөл бүрэн хаагдсан. Апп тохиргоог нээнэ.");
      openAppSettings();
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

    DateTime morningSwap = DateTime(now.year, now.month, now.day, 10, 00);
    DateTime midnightSwap = DateTime(now.year, now.month, now.day, 23, 58);

    if (now.isBefore(morningSwap)) {
      nextSwap = morningSwap;
      print('Солигдох цаг ${morningSwap}');
    } else if (now.isBefore(midnightSwap)) {
      nextSwap = midnightSwap;
      print('Солигдох цаг ${midnightSwap}');
    } else {
      DateTime tomorrow = now.add(Duration(days: 1));
      nextSwap = DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 00);
      print('Солигдох цаг маргааш: $nextSwap');
    }

    _nextSwapTime = nextSwap; // Солигдох цагийг хадгална

    Duration delay = nextSwap.difference(now); // Дараагийн солих хүртэл хүлээлт
    print(
        'Дараагийн солигдох цагийн хүлээлтийн хугацаа: ${delay.inSeconds} секунд');

    // Таймер үүсгэх
    _timer = Timer(delay, () {
      _swapImage(); // Зураг солигдоно
      _scheduleNextSwap(); // Дараагийн солихыг төлөвлөнө
    });
  }

  void _swapImage() {
    DateTime now = DateTime.now();
    setState(() {
      if (now.hour >= 10 && now.hour < 24) {
        _currentImage = _images.firstWhere(
          (path) => path.toLowerCase().contains('morning'),
          orElse: () => _currentImage!,
        );
      } else {
        _currentImage = _images.firstWhere(
          (path) => path.toLowerCase().contains('night'),
          orElse: () => _currentImage!,
        );
      }
      print('Зураг солигдлоо: $_currentImage');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
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
          ],
        ),
      ),
    );
  }
}
