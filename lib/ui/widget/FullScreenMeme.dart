import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:meme_generator/model/MemeModel.dart';

class FullScreenMeme extends StatelessWidget {
  final MemeModel memeModel;
  FullScreenMeme({this.memeModel});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Hero(
        tag: memeModel.url,
        child: CachedNetworkImage(
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            child: Image.asset('assets/loading-1.gif'),
            color: Color(0xFF21242D),
            alignment: Alignment.center,
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
          imageUrl: memeModel.url,
        ),
      ),
    );
  }
}
