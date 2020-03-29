import 'package:flutter/material.dart';

class DraggableWidget extends StatefulWidget {
  final Offset offset;
  final int id;

  DraggableWidget({
    this.offset,
    this.id,
  });

  @override
  _DraggableWidgetState createState() => _DraggableWidgetState();
}

class _DraggableWidgetState extends State<DraggableWidget> {
  Offset offset = Offset(0.0, 0.0);
  final TextEditingController _textEditingController = TextEditingController();
  double _width, _height;

  @override
  void initState() {
    super.initState();
    offset = widget.offset;
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;

    return Positioned(
      top: offset.dy,
      left: offset.dx,
      child: Draggable(
        child: _textBox(),
        feedback: _textBox(),
        onDraggableCanceled: (v, o) {
          setState(() {
            offset = Offset(o.dx, o.dy - (_height / 28.5));
          });
        },
        childWhenDragging: SizedBox.shrink(),
      ),
    );
  }

  Widget _textBox() {
    return Container(
      width: _width / 2,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 10),
      // color: Colors.red,
      child: Material(
        color: Colors.transparent,
        child: TextField(
          controller: _textEditingController,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Text ${widget.id}',
            hintStyle: TextStyle(
              color: Colors.blueGrey,
            ),
          ),
          style: TextStyle(
            fontSize: _width / 10,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
      ),
    );
  }
}
