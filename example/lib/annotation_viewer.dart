import 'package:flutter/material.dart';

import 'annotations.dart';

class AnnotationViewer extends StatelessWidget {
  const AnnotationViewer({super.key, required this.annotation});

  final Annotation annotation;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minWidth: 120,
        minHeight: 50,
        maxWidth: 200,
        maxHeight: 80,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              decoration: BoxDecoration(
                color: _getTypeColor(annotation.type).withAlpha(20),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                ),
              ),
              child: Center(child: typeFactory(annotation.type)),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getTypeName(annotation.type),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${annotation.distanceFromUser.toInt()} m',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget typeFactory(AnnotationType type) {
    String iconText = '📍';
    Color color = _getTypeColor(type);

    switch (type) {
      case AnnotationType.pharmacy:
        iconText = '⚕';
        break;
      case AnnotationType.hotel:
        iconText = '🏨';
        break;
      case AnnotationType.library:
        iconText = '📚';
        break;
    }

    return Text(iconText, style: TextStyle(fontSize: 20, color: color));
  }

  Color _getTypeColor(AnnotationType type) {
    switch (type) {
      case AnnotationType.pharmacy:
        return Colors.red;
      case AnnotationType.hotel:
        return Colors.green;
      case AnnotationType.library:
        return Colors.blue;
    }
  }

  String _getTypeName(AnnotationType type) {
    switch (type) {
      case AnnotationType.pharmacy:
        return 'Pharmacy';
      case AnnotationType.hotel:
        return 'Hotel';
      case AnnotationType.library:
        return 'Library';
    }
  }
}
