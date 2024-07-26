// ignore_for_file: unused_import, unused_field, avoid_print

import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:simple_login_page/pages/menu_page.dart';
import 'dart:io';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'; // Add this import

import '../components/app_color.dart';
import 'drawing_point.dart';

class SecondPage extends StatefulWidget {
  final File? pickedImageFile;

  const SecondPage({Key? key, this.pickedImageFile}) : super(key: key);

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  ui.Image? pickedImage;
  final GlobalKey _globalKey = GlobalKey();
  final TransformationController _controller = TransformationController();
  bool _isImageLoaded = false;

  var availableColor = [
    Colors.black,
    Colors.red,
    Colors.amber,
    Colors.blue,
    Colors.green,
    Colors.brown,
  ];

  var drawingPoints = <DrawingPoint>[];
  var undoneDrawingPoints = <DrawingPoint>[];

  var selectedColor = Colors.black;
  var selectedWidth = 2.0;

  DrawingPoint? currentDrawingPoint;

  @override
  void initState() {
    super.initState();
    if (widget.pickedImageFile != null) {
      _loadImage(widget.pickedImageFile!);
    }
  }

  Future<void> _loadImage(File file) async {
    try {
      final imageBytes = await file.readAsBytes();
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      setState(() {
        pickedImage = frame.image;
        _isImageLoaded = true;
        drawingPoints.clear();
      });
    } catch (e) {
      print("Error loading image: $e");
    }
  }

  Future<void> _saveToGallery() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage();
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      Uint8List pngBytes = byteData!.buffer.asUint8List();

      final result = await ImageGallerySaver.saveImage(pngBytes);
      print(result);
    } catch (e) {
      print("Error saving image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Draw'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MenuPage()),
            );
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: _globalKey,
              child: GestureDetector(
                onPanStart: (details) {
                  setState(() {
                    drawingPoints.add(
                      DrawingPoint(
                        color: selectedColor,
                        width: selectedWidth,
                        offsets: [details.localPosition],
                      ),
                    );
                    undoneDrawingPoints.clear();
                  });
                },
                onPanUpdate: (details) {
                  setState(() {
                    drawingPoints.last.offsets.add(details.localPosition);
                  });
                },
                onPanEnd: (details) {
                  setState(() {
                    undoneDrawingPoints.clear();
                  });
                },
                child: Stack(
                  children: [
                    if (_isImageLoaded)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: ImagePainter(image: pickedImage!),
                        ),
                      ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: DrawingPainter(drawingPoints: drawingPoints),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.color_lens, color: selectedColor),
                onPressed: _pickColor,
              ),
              IconButton(
                icon: Icon(Icons.brush, size: selectedWidth),
                onPressed: _pickWidth,
              ),
              IconButton(
                icon: const Icon(Icons.undo),
                onPressed: () {
                  setState(() {
                    if (drawingPoints.isNotEmpty) {
                      undoneDrawingPoints.add(drawingPoints.removeLast());
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.redo),
                onPressed: () {
                  setState(() {
                    if (undoneDrawingPoints.isNotEmpty) {
                      drawingPoints.add(undoneDrawingPoints.removeLast());
                    }
                  });
                },
              ),
              FloatingActionButton(
                heroTag: "SaveToGallery",
                onPressed: _saveToGallery,
                tooltip: 'Save to Gallery',
                child: const Icon(Icons.save),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick Color'),
        content: BlockPicker(
          pickerColor: selectedColor,
          onColorChanged: (color) {
            setState(() {
              selectedColor = color;
            });
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _pickWidth() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick Width'),
        content: SingleChildScrollView(
          child: Column(
            children: List.generate(10, (index) {
              return ListTile(
                leading: Icon(Icons.brush, size: index.toDouble() + 1),
                title: Text('Width ${(index + 1).toString()}'),
                onTap: () {
                  setState(() {
                    selectedWidth = index.toDouble() + 1;
                  });
                  Navigator.of(context).pop();
                },
              );
            }),
          ),
        ),
      ),
    );
  }
}

class DrawingPainter extends CustomPainter {
  final List<DrawingPoint> drawingPoints;

  DrawingPainter({required this.drawingPoints});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw white background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.white);

    // Draw the drawing points
    for (var drawingPoint in drawingPoints) {
      final paint = Paint()
        ..color = drawingPoint.color
        ..isAntiAlias = true
        ..strokeWidth = drawingPoint.width
        ..strokeCap = StrokeCap.round;

      for (var i = 0; i < drawingPoint.offsets.length; i++) {
        var notLastOffset = i != drawingPoint.offsets.length - 1;

        if (notLastOffset) {
          final current = drawingPoint.offsets[i];
          final next = drawingPoint.offsets[i + 1];
          canvas.drawLine(current, next, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ImagePainter extends CustomPainter {
  final ui.Image image;

  ImagePainter({required this.image});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
