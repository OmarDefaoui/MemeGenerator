import 'package:flutter/material.dart';

class DraggableWidget extends StatefulWidget {
  final Offset offset;

  DraggableWidget({
    this.offset,
  });

  @override
  _DraggableWidgetState createState() => _DraggableWidgetState();
}

class _DraggableWidgetState extends State<DraggableWidget> {
  Offset offset = Offset(0.0, 0.0);
  @override
  void initState() {
    super.initState();
    offset = widget.offset;
  }

  @override
  Widget build(BuildContext context) {
    double _height = MediaQuery.of(context).size.height;
    return Positioned(
      top: offset.dy,
      left: offset.dx,
      child: Draggable(
        child: Container(
          width: 100,
          height: 100,
          color: Colors.blue,
        ),
        feedback: Container(
          width: 100,
          height: 100,
          color: Colors.blue,
        ),
        onDraggableCanceled: (v, o) {
          setState(() {
            offset = Offset(o.dx, o.dy - (_height / 28.5));
          });
        },
        childWhenDragging: SizedBox.shrink(),
      ),
    );
  }
}
