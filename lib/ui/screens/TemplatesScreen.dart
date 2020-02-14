import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:meme_generator/model/MemeModel.dart';
import 'package:meme_generator/ui/widget/CustomCard.dart';

class TemplatesScreen extends StatefulWidget {
  final String url = 'https://api.imgflip.com/get_memes';

  @override
  _TemplatesScreenState createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen>
    with AutomaticKeepAliveClientMixin {
  int _totalItems = 0, _itemToDisplayCount = 25;
  bool isDataLoaded = false, _isLoadingMore = false, _isError = false;
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
    getJsonData();
  }

  @override
  Widget build(BuildContext context) {
    var _width = MediaQuery.of(context).size.width;

    if (_isError)
      //return error form with retry button
      return Container(
        color: Color(0xff323639),
        child: Center(
          child: Text(
            'Error',
            style: TextStyle(
              color: Colors.white,
              fontSize: 40,
            ),
          ),
        ),
      );

    if (isDataLoaded)
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

            return CustomCard(
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

  Future<String> getJsonData() async {
    print('fetch data call');
    var response = await http.get(
      Uri.encodeFull(widget.url),
    );

    var convertDataToJson;
    try {
      convertDataToJson = json.decode(response.body);
    } catch (error) {
      setState(() {
        _isError = true;
      });
      return "error";
    } finally {
      List temp = convertDataToJson['data']['memes'];

      for (var item in temp) {
        data.add(MemeModel(
          id: int.parse(item['id']),
          name: item['name'],
          url: item['url'],
        ));
      }
      _totalItems = data.length;
      print('total items: $_totalItems');
      setState(() {
        isDataLoaded = true;
        _isLoadingMore = false;
      });
    }

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
