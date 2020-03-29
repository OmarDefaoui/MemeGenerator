import 'package:flutter/foundation.dart';
import 'package:meme_generator/database/DBProvider.dart';
import 'package:meme_generator/model/MemeModel.dart';

class DBHelper with ChangeNotifier {
  bool isSavedToFavorite = false;
  DBProvider db;
  DBHelper() {
    db = DBProvider.db;
  }
  Future<void> checkIfExistsInFavorite(int id) async {
    print('check favorite call');

    try {
      bool _isExists = await db.isMemeExists(id);
      if (_isExists) {
        isSavedToFavorite = true;
        notifyListeners();
      }
    } catch (e) {}
  }

  Future<void> saveToFavorite(MemeModel memeModel) async {
    print('save to favorite call');

    try {
      await db.insertMeme(memeModel);
      isSavedToFavorite = true;
      notifyListeners();
    } catch (e) {}
  }

  Future<void> removeFromFavorite(int id) async {
    print('remove from favorite call');

    try {
      await db.deleteMeme(id);
      isSavedToFavorite = false;
      notifyListeners();
    } catch (e) {}
  }
}
