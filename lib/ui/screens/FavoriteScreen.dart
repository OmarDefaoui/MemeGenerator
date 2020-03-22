import 'package:flutter/material.dart';
import 'package:meme_generator/database/DBProvider.dart';
import 'package:meme_generator/model/MemeModel.dart';
import 'package:meme_generator/ui/widget/MemeCard.dart';

class FavoriteScreen extends StatefulWidget {
  @override
  _FavoriteScreenState createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen>
    with AutomaticKeepAliveClientMixin {
  int _totalItems = 0, _itemToDisplayCount = 25;
  bool _isDataLoaded = false, _isLoadingMore = false;
  List<MemeModel> data = List<MemeModel>();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if ((_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent) &&
          !_isLoadingMore) {
        _isLoadingMore = true;
        _loadMore();
      }
    });
    getFavoriteMemes();
  }

  @override
  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width;

    if (_totalItems == 0)
      //no data to show
      return Container(
        color: Color(0xff323639),
        child: Center(
          child: Text(
            'Empty List',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30,
            ),
          ),
        ),
      );

    if (_isDataLoaded)
      return Container(
        color: Color(0xff323639),
        child: GridView.builder(
          physics: BouncingScrollPhysics(),
          controller: _scrollController,
          addAutomaticKeepAlives: true,
          padding: EdgeInsets.all(4.0),
          itemCount: _itemToDisplayCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.8,
          ),
          itemBuilder: (context, index) {
            MemeModel memeModel = data[index];

            return MemeCard(
              memeModel: memeModel,
              width: _width,
            );
          },
        ),
      );
    else
      //show progress bar while loading data
      return Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
        color: Color(0xff323639),
      );
  }

  Future<String> getFavoriteMemes() async {
    print('fetch data call');

    //data.addAll(convertDataToJson['data']['memes']);
    DBProvider db = DBProvider.db;
    data = await db.getMemes();

    _totalItems = data.length;
    print('total items: $_totalItems');

    if (_totalItems < 25) _itemToDisplayCount = _totalItems;

    setState(() {
      _isDataLoaded = true;
      _isLoadingMore = false;
    });

    return "Success";
  }

  _loadMore() {
    bool _canLoadMore = (_totalItems - _itemToDisplayCount) >= 25;

    if (_canLoadMore) {
      print('load more');
      setState(() {
        _itemToDisplayCount += 25;
      });
    }
    _isLoadingMore = false;
  }

  @override
  bool get wantKeepAlive => true;
}
