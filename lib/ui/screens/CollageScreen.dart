import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:meme_generator/ui/widget/CollageImageCard.dart';
import 'package:meme_generator/utils/PermissionsHandler.dart';
import 'package:meme_generator/utils/SaveToGallery.dart';
import 'package:meme_generator/utils/ShareImage.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:permission_handler/permission_handler.dart';

class CollageScreen extends StatefulWidget {
  @override
  _CollageScreenState createState() => _CollageScreenState();
}

class _CollageScreenState extends State<CollageScreen> {
  double _width, _height = 0;
  ScreenshotController screenshotController = ScreenshotController();

  InterstitialAd _interstitialAd;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<PermissionsHandler>(context, listen: false)
            .askForPermission(
          context: context,
          permissions: [PermissionGroup.storage],
          text:
              'This permission is required to select and save images to gallery.',
        ));
  }

  @override
  void dispose() {
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _width = MediaQuery.of(context).size.width;
    _height = MediaQuery.of(context).size.height;

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SaveToGallery>(
          create: (context) => SaveToGallery(),
        ),
        ChangeNotifierProvider<ShareImage>(
          create: (context) => ShareImage(),
        ),
      ],
      child: Scaffold(
        body: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            children: <Widget>[
              Screenshot(
                controller: screenshotController,
                child: Container(
                  width: _width,
                  height: _width,
                  child: SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Wrap(
                      children: <Widget>[
                        CollageImageCard(index: 0),
                        CollageImageCard(index: 1),
                        CollageImageCard(index: 2),
                        CollageImageCard(index: 3),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: _width / 16,
              ),
              Consumer2<SaveToGallery, ShareImage>(
                builder: (context, providerSave, providerShare, child) =>
                    Container(
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.bottomCenter,
                  child: providerSave.isLoading || providerShare.isLoading
                      ? CircularProgressIndicator()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            RaisedButton(
                              child: Text(
                                providerSave.isSavedToGallery
                                    ? 'Saved'
                                    : "Save to gallery",
                              ),
                              onPressed: () => providerSave
                                  .saveImageToGallery(screenshotController),
                            ),
                            RaisedButton(
                              child: Text(
                                "Share",
                              ),
                              onPressed: () => providerShare
                                  .shareImage(screenshotController),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  onBottom(Widget child) => Positioned.fill(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: child,
        ),
      );
}
