import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/material.dart';
import 'package:meme_generator/Constants/AdmobId.dart';
import 'package:meme_generator/ui/screens/CollageScreen.dart';
import 'package:meme_generator/ui/screens/FavoriteScreen.dart';
import 'package:meme_generator/ui/screens/PhotoGalleryScreen.dart';
import 'package:meme_generator/ui/screens/TemplatesScreen.dart';
import 'package:meme_generator/utils/AdBuilder.dart';
import 'package:meme_generator/utils/PermissionsHandler.dart';
import 'package:meme_generator/utils/ShowAction.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController _pageController;
  static var _tabPages = <Widget>[
    TemplatesScreen(),
    Provider<PermissionsHandler>(
      create: (context) => PermissionsHandler(),
      child: CollageScreen(),
    ),
    PhotoGalleryScreen(),
    FavoriteScreen(),
  ];
  static var _tabs = <TabData>[
    TabData(
      iconData: Icons.all_out,
      title: "All",
    ),
    TabData(
      iconData: Icons.border_all,
      title: "Collage",
    ),
    TabData(
      iconData: Icons.collections,
      title: "Gallery",
    ),
    TabData(
      iconData: Icons.favorite_border,
      title: "Favorite",
    ),
  ];
  int _currentTab = 0;

  InterstitialAd _interstitialAd;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    //_initAds();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
    _interstitialAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meme Maker'),
        backgroundColor: Theme.of(context).backgroundColor,
        actions: <Widget>[
          customPopUpMenu(),
        ],
      ),
      body: PageView(
        physics: new NeverScrollableScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentTab = index;
          });
        },
        controller: _pageController,
        children: _tabPages,
      ),
      bottomNavigationBar: FancyBottomNavigation(
        initialSelection: _currentTab,
        tabs: _tabs,
        barBackgroundColor: Color(0xff323639),
        textColor: Colors.white,
        onTabChangedListener: (position) {
          setState(() {
            _currentTab = position;
          });
          _pageController.animateToPage(
            position,
            duration: Duration(milliseconds: 200),
            curve: Curves.easeIn,
          );
        },
      ),
    );
  }

  _initAds() {
    Future.delayed(const Duration(seconds: 2), () {
      FirebaseAdMob.instance.initialize(appId: admobAppId);
      _interstitialAd = createInterstitialAd(1)
        ..load()
        ..show();
    });
  }
}
