import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SignaturePadWidget extends StatefulWidget {
  final Function(List<Offset?>) onSigned;
  final VoidCallback onClear;

  const SignaturePadWidget({
    Key? key,
    required this.onSigned,
    required this.onClear,
  }) : super(key: key);

  @override
  State<SignaturePadWidget> createState() => _SignaturePadWidgetState();
}

class _SignaturePadWidgetState extends State<SignaturePadWidget> {
  final List<Offset?> _points = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 140,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cardBorder, width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: GestureDetector(
              onPanUpdate: (DragUpdateDetails details) {
                setState(() {
                  RenderBox? renderBox = context.findRenderObject() as RenderBox?;
                  if (renderBox != null) {
                    _points.add(renderBox.globalToLocal(details.globalPosition));
                    widget.onSigned(_points);
                  }
                });
              },
              onPanEnd: (DragEndDetails details) {
                _points.add(null);
                widget.onSigned(_points);
              },
              child: CustomPaint(
                painter: _SignaturePainter(points: _points),
                child: Center(
                  child: _points.isEmpty
                      ? const Text(
                          'Toque e assine aqui com o dedo ou caneta stylus',
                          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                _points.clear();
              });
              widget.onClear();
            },
            icon: const Icon(Icons.clear, size: 16, color: AppColors.brandAccent),
            label: const Text(
              'Limpar Assinatura',
              style: TextStyle(color: AppColors.brandAccent, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  _SignaturePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = AppColors.brandDark
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => true;
}
