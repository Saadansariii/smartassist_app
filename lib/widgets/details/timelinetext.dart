import 'package:flutter/material.dart';

class AfterTimelinetext extends StatelessWidget {
  const AfterTimelinetext({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      decoration: BoxDecoration(
        color: Colors.grey,
      ),
      child: Row(
        children: [
          Column(
            children: [Text(' ')],
          )
        ],
      ),
    );
  }
}
