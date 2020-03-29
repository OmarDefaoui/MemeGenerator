import 'package:flutter/material.dart';
import 'package:meme_generator/database/DBHelper.dart';
import 'package:meme_generator/model/MemeModel.dart';
import 'package:meme_generator/ui/widget/DraggableWidget.dart';
import 'package:meme_generator/ui/widget/FullScreenMeme.dart';
import 'package:meme_generator/utils/PermissionsHandler.dart';
import 'package:meme_generator/utils/SaveToGallery.dart';
import 'package:meme_generator/utils/ShareImage.dart';
import 'package:meme_generator/utils/ShowAction.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';

class ImageCreatorScreen extends StatefulWidget {
  final MemeModel memeModel;
  ImageCreatorScreen({
    this.memeModel,
  });

  @override
  _ImageCreatorScreenState createState() => _ImageCreatorScreenState();
}

class _ImageCreatorScreenState extends State<ImageCreatorScreen>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  ScreenshotController screenshotController = ScreenshotController();

  //contains meme, and the required draggable widget
  List<Widget> _listStack = [];

  @override
  void initState() {
    super.initState();
    //_checkIfExistsInFavorite();
    Future.microtask(
      () => Provider.of<DBHelper>(context, listen: false)
          .checkIfExistsInFavorite(widget.memeModel.id),
    );

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    //add required textbox to list of widget, to display them in a stack widget
    int boxCount = widget.memeModel.boxCount;
    for (int i = 0; i < boxCount; i++) {
      _listStack.add(
        DraggableWidget(
          offset: Offset(0, 64),
          id: boxCount - i,
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SaveToGallery>(
          create: (context) => SaveToGallery(),
        ),
        ChangeNotifierProvider<ShareImage>(
          create: (context) => ShareImage(),
        ),
        Provider<PermissionsHandler>(
          create: (context) => PermissionsHandler(),
        ),
      ],
      child: Scaffold(
        //to avoid moving widgets when the keywboard was shown
        resizeToAvoidBottomInset: false,
        backgroundColor: Theme.of(context).backgroundColor,
        body: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Stack(
                children: <Widget>[
                  //the main screen, wich contains the meme, and the text boxex
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: GestureDetector(
                      onTap: () {
                        if (_animationController.isCompleted) {
                          _animationController.reverse();
                        } else {
                          _animationController.forward();
                        }
                      },
                      child: Stack(
                        children: <Widget>[
                          Screenshot(
                            controller: screenshotController,
                            child: FullScreenMeme(
                              memeModel: widget.memeModel,
                            ),
                          ),
                          Stack(
                            children: _listStack,
                          ),
                        ],
                      ),
                    ),
                  ),
                  //the custom top and bottom appbar
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Transform.translate(
                          offset: Offset(0, -_animationController.value * 100),
                          child: Container(
                            height: 64.0,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(8.0),
                                bottomRight: Radius.circular(8.0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor,
                                  blurRadius: 2.0,
                                ),
                              ],
                            ),
                            child: Container(
                              padding: const EdgeInsets.only(left: 8.0),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  IconButton(
                                    icon: Icon(Icons.arrow_back),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  customPopUpMenu(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(0, _animationController.value * 64),
                          child: Container(
                            height: 64.0,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16.0),
                                topRight: Radius.circular(16.0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context).primaryColor,
                                  blurRadius: 2.0,
                                ),
                              ],
                            ),
                            child:
                                Consumer3<SaveToGallery, ShareImage, DBHelper>(
                              builder: (context, providerSave, providerShare,
                                      providerDB, child) =>
                                  Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: providerSave.isLoading ||
                                        providerShare.isLoading
                                    ? Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        mainAxisSize: MainAxisSize.max,
                                        children: <Widget>[
                                          IconButton(
                                            icon: Icon(
                                              providerSave.isSavedToGallery
                                                  ? Icons.check_circle_outline
                                                  : Icons.save,
                                            ),
                                            onPressed: () => providerSave
                                                .askForPermissionToSave(
                                              context,
                                              screenshotController,
                                            ),
                                          ),
                                          Row(
                                            children: <Widget>[
                                              IconButton(
                                                icon: providerDB
                                                        .isSavedToFavorite
                                                    ? Icon(
                                                        Icons.favorite,
                                                        color: Colors.red,
                                                      )
                                                    : Icon(
                                                        Icons.favorite_border),
                                                onPressed: () => providerDB
                                                        .isSavedToFavorite
                                                    ? providerDB
                                                        .removeFromFavorite(
                                                            widget.memeModel.id)
                                                    : providerDB.saveToFavorite(
                                                        widget.memeModel),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.share),
                                                onPressed: () =>
                                                    providerShare.shareImage(
                                                        screenshotController),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
