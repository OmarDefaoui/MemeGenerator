import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:meme_generator/ui/screens/ImageCreatorScreen.dart';

//card where we display memes
class CustomCard extends StatelessWidget {
  final String imageUrl;
  final double width;
  CustomCard({
    @required this.imageUrl,
    @required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Container(
          width: width / 3,
          height: width * 0.75,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: InkWell(
              child: Hero(
                tag: imageUrl,
                child: CachedNetworkImage(
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    child: Image.asset('assets/loading-1.gif'),
                    color: Color(0xFF21242D),
                    alignment: Alignment.center,
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  imageUrl: imageUrl,
                ),
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ImageCreatorScreen(url: imageUrl),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
