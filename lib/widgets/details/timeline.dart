import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';

class Timeline extends StatelessWidget {
  final bool isFirst;
  final bool isLast;
  final Widget startChild;
  final Widget endChild;
  final bool showIndicator;
  final bool showBeforeLine;
  final IconData? icon;

  const Timeline({
    super.key,
    required this.isFirst,
    required this.isLast,
    required this.startChild,
    required this.endChild,
    this.showIndicator = false,
    this.showBeforeLine = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TimelineTile(
      alignment: TimelineAlign.manual,
      lineXY: 0.2, // Adjust alignment of the line
      isFirst: isFirst,
      isLast: isLast,
      beforeLineStyle: LineStyle(
        color: showBeforeLine ? Colors.grey : Colors.transparent,
        thickness: showBeforeLine ? 2 : 0,
      ),
      afterLineStyle: LineStyle(
        color: Colors.grey, // Keep the after-line consistent
        thickness: 2,
      ),
      indicatorStyle: showIndicator
          ? IndicatorStyle(
              width: 30,
              height: 30,
              color: Colors.blue, // Default indicator color
              iconStyle: icon != null
                  ? IconStyle(
                      iconData: icon!,
                      color: Colors.white,
                      fontSize: 16,
                    )
                  : null,
            )
          : const IndicatorStyle(
              width: 0,
              color: Colors.transparent,
            ),
      startChild: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10), // Add spacing here
        child: Align(
          alignment: Alignment.centerLeft,
          child: startChild,
        ),
      ),
      endChild: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10), // Add spacing here
        child: Align(
          alignment: Alignment.centerLeft,
          child: endChild,
        ),
      ),
    );
  }
}
