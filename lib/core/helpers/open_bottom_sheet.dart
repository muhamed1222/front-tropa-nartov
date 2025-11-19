import 'package:flutter/material.dart';
import '../../utils/smooth_border_radius.dart';

Future<T?> openBottomSheet<T>(BuildContext context, Widget Function(ScrollController) childBuilder) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black,
    builder: (
      _,
    ) {
      return DraggableScrollableSheet(
        initialChildSize: 1,
        minChildSize: 0.2,
        maxChildSize: 1,
        snap: true,
        snapSizes: const [0.2, 1.0],
        builder: (_, controller) {
          return ClipPath(
            clipper: SmoothBorderClipper(radius: 20),
            child: Container(
            padding: const EdgeInsets.only(left: 14, right: 14, top: 8),
              color: Colors.white,
              child: childBuilder(controller),
            ),
          );
        },
      );
    },
  );
}
