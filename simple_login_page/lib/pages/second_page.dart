import 'dart:typed_data';
import 'dart:ui' as ui;
import '../components/app_color.dart';
import 'drawing_point.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'package:image_picker/image_picker.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  State<SecondPage> createState() => _DrawingRoomScreenState();
}

class _DrawingRoomScreenState extends State<SecondPage> {
  final ImagePicker _imagePicker = ImagePicker();
  ui.Image? pickedImage;

  var avaiableColor = [
    Colors.black,
    Colors.red,
    Colors.amber,
    Colors.blue,
    Colors.green,
    Colors.brown,
  ];

  var historyDrawingPoints = <DrawingPoint>[];
  var drawingPoints = <DrawingPoint>[];

  var selectedColor = Colors.black;
  var selectedWidth = 2.0;

  DrawingPoint? currentDrawingPoint;

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await _imagePicker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final imageBytes = await pickedFile.readAsBytes();
        final ByteData data =
            ByteData.sublistView(imageBytes.buffer.asByteData());

        pickedImage = await decodeImageFromList(Uint8List.view(data.buffer));

        setState(() {
          drawingPoints.clear();
        });
      }
    } catch (e) {
      print("Error loading image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
        return false;
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Canvas
            GestureDetector(
              onPanStart: (details) {
                setState(() {
                  currentDrawingPoint = DrawingPoint(
                    id: DateTime.now().microsecondsSinceEpoch,
                    offsets: [
                      details.localPosition,
                    ],
                    color: selectedColor,
                    width: selectedWidth,
                  );

                  if (currentDrawingPoint == null) return;
                  drawingPoints.add(currentDrawingPoint!);
                  historyDrawingPoints = List.of(drawingPoints);
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  if (currentDrawingPoint == null) return;

                  currentDrawingPoint = currentDrawingPoint?.copyWith(
                    offsets: currentDrawingPoint!.offsets
                      ..add(details.localPosition),
                  );
                  drawingPoints.last = currentDrawingPoint!;
                  historyDrawingPoints = List.of(drawingPoints);
                });
              },
              onPanEnd: (_) {
                currentDrawingPoint = null;
              },
              child: CustomPaint(
                painter: DrawingPainter(
                  drawingPoints: drawingPoints,
                ),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
              ),
            ),

            // color pallet
            Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 16,
              right: 16,
              child: SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: avaiableColor.length,
                  separatorBuilder: (_, __) {
                    return const SizedBox(width: 8);
                  },
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedColor = avaiableColor[index];
                        });
                      },
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: avaiableColor[index],
                          shape: BoxShape.circle,
                        ),
                        foregroundDecoration: BoxDecoration(
                          border: selectedColor == avaiableColor[index]
                              ? Border.all(
                                  color: AppColor.primaryColor, width: 4)
                              : null,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // pencil size
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              right: 0,
              bottom: 150,
              child: RotatedBox(
                quarterTurns: 3,
                child: Slider(
                  value: selectedWidth,
                  min: 1,
                  max: 20,
                  onChanged: (value) {
                    setState(() {
                      selectedWidth = value;
                    });
                  },
                ),
              ),
            ),
            if (pickedImage != null)
              CustomPaint(
                painter: ImagePainter(image: pickedImage!),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                ),
              ),
          ],
        ),

        // Undo, Redo buttons
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: "Undo",
              onPressed: () {
                if (drawingPoints.isNotEmpty &&
                    historyDrawingPoints.isNotEmpty) {
                  setState(() {
                    drawingPoints.removeLast();
                  });
                }
              },
              child: const Icon(Icons.undo),
            ),
            const SizedBox(width: 16),
            FloatingActionButton(
              heroTag: "Redo",
              onPressed: () {
                setState(() {
                  if (drawingPoints.length < historyDrawingPoints.length) {
                    final index = drawingPoints.length;
                    drawingPoints.add(historyDrawingPoints[index]);
                  }
                });
              },
              child: const Icon(Icons.redo),
            ),

            // Import image button
            const SizedBox(width: 16),
            FloatingActionButton(
              onPressed: _pickImage,
              tooltip: 'Import Image',
              child: const Icon(Icons.image),
            ),
          ],
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
