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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Swap',
      theme: ThemeData(
        
        primarySwatch: Colors.blue,
      ),
      home:  ImageSwapScreen(),
    );
  }
}

class ImageSwapScreen extends StatefulWidget {
  @override
  _ImageSwapScreen createState()=> _ImageSwapScreen();
  
}

class _ImageSwapScreen extends State<ImageSwapScreen> {
  List<String> _images = []; // Зургуудын замыг хадгалах жагсаалт
  String? _currentImage; // Одоогийн харуулж буй зураг
  int _currentIndex = 0;
  Timer? _timer; // Таймер
  double _swapDuration = 5.0; // Зураг солих хугацаа (секундээр)

  @override
  void initState() {
    super.initState();
    // Эхэндээ зураг солих хугацааг тохируулах
    _startTimer();
  }

   // Таймер эхлүүлэх
  void _startTimer() {
    if (_timer != null) {
      _timer!.cancel();
    }
    _timer = Timer.periodic(Duration(seconds: _swapDuration.toInt()), _swapImage);
  }

  // Зургийг солих функц
  void _swapImage(Timer timer) {
    //print("Swapping to image at index $_currentIndex: $_currentImage");
  if (_images.isNotEmpty) {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _images.length;
      _currentImage = _images[_currentIndex];
      //print("Swapping to image at index $_currentIndex: $_currentImage");
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
      // Шинэ сонгогдсон замуудыг жагсаалтанд нэмэх
      List<String> newImages = result.paths.where((path) => path != null).cast<String>().toList();
      _images.addAll(newImages);

      //print("All selected images: $_images"); // Консолд сонгосон замуудыг хэвлэх

      // Эхний зургийг харуулах
      if (_currentImage == null && _images.isNotEmpty) {
        _currentImage = _images.first;
      }
    });
  } else {
    print("No images selected");
  }
}
// Сонгосон зургийг устгах функц
void _deleteImage(String imagePath) {
  setState(() {
    _images.remove(imagePath); // _images жагсаалтаас устгах
    if (_images.isNotEmpty) {
      // Хэрэв жагсаалт хоосон биш бол, дараагийн зургийг харуулах
      _currentImage = _images.first;
    } else {
      // Хэрэв зураг устгагдвал харуулах зүйлгүй бол текст харуулах
      _currentImage = null;
    }
  });
}

void _showTimePicker() async {
  double duration = _swapDuration.clamp(3600.0, 43200.0); // Утгыг min болон max-ийн хооронд байлгах

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Зураг солих хугацаа сонгоно уу'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: duration,
                  min: 3600.0, // 1 цаг
                  max: 43200.0, // 12 цаг
                  divisions: 11, // 1 цаг тутам
                  label: _formatDuration(duration.toInt()),
                  onChanged: (value) {
                    setState(() {
                      duration = value;
                    });
                  },
                ),
                Text('Сонгосон хугацаа: ${_formatDuration(duration.toInt())}'),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Диалогыг хаана
              setState(() {
                _swapDuration = duration; // Үндсэн хугацааг шинэчилнэ
                _startTimer(); // Таймерыг дахин эхлүүлнэ
              });
            },
            child: Text('Тохируулах'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Диалогыг хаана
            },
            child: Text('Цуцлах'),
          ),
        ],
      );
    },
  );
}

// Хугацааг цаг, минутын форматаар харуулах функц
String _formatDuration(int seconds) {
  final hours = seconds ~/ 3600;
  final minutes = (seconds % 3600) ~/ 60;

  return '${hours}ц ${minutes}м';
}



// Бүх зургийг устгах функц
void _deleteAllImages() {
  setState(() {
    _images.clear(); // Бүх зургуудыг жагсаалтаас устгах
    _currentImage = null; // Одоогийн зургаа цэвэрлэх
  });
}
void _viewImageFullScreen() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => FullScreenImagePage(
        images: _images,
        initialIndex: _currentIndex,
        swapDuration: _swapDuration, // Таймерын хугацааг дамжуулна
      ),
    ),
  );
}





  @override
  Widget build(BuildContext context) {
    return Scaffold(
  appBar: AppBar(
    title: Text('Image Swap'),
    actions: [
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
        IconButton(
            onPressed: _showTimePicker, 
            icon: Icon(Icons.timer),
          ), 
    ],
  ),
  body: Center(
        child: _currentImage != null
            ? GestureDetector(
                onTap: () => _viewImageFullScreen(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.file(
                      File(_currentImage!),
                      key: ValueKey<String>(_currentImage!),
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 20),
                    Text("Сонгосон зургийг устгах товчийг дарна уу"),
                    SizedBox(height: 20),
                    Text("Зураг солих хугацаа: ${_swapDuration.toInt()} секунд"),
                  ],
                ),
            )
            : Text("Зураг байхгүй байна. Сонгоно уу."),
          ),
  );
  }
}
