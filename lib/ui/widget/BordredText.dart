import 'package:flutter/material.dart';

class BorderedText extends StatefulWidget {
  final TextEditingController textController;
  final int id;
  final double fontSize;
  final FontWeight fontWeight;
  final double strokeWidth;
  final Color textColor;
  final Color strokeColor;

  BorderedText({
    @required this.textController,
    @required this.id,
    this.fontSize,
    this.fontWeight,
    this.strokeWidth,
    this.textColor = Colors.black,
    this.strokeColor = Colors.white,
  });

  @override
  _BorderedTextState createState() => _BorderedTextState();
}

class _BorderedTextState extends State<BorderedText> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Text(
          widget.textController.text,
          style: TextStyle(
            fontSize: widget.fontSize,
            fontWeight: widget.fontWeight,
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = widget.strokeWidth
              ..color = widget.strokeColor,
          ),
        ),
        TextField(
          textAlign: TextAlign.center,
          controller: widget.textController,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'Text ${widget.id}',
            hintStyle: TextStyle(
              color: Colors.blueGrey,
            ),
          ),
          style: TextStyle(
            fontSize: widget.fontSize,
            fontWeight: widget.fontWeight,
            color: widget.textColor,
          ),
          onChanged: (value) {
            setState(() {});
          },
        ),
      ],
    );
  }
}
