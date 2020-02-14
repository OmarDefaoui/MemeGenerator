import 'package:meme_generator/model/MemeModel.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    return await openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'Memes.db'),
      // When the database is first created, create a table to store memes.
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE Memes(id INTEGER PRIMARY KEY, name TEXT, url TEXT)",
        );
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 1,
    );
  }

  // Define a function that inserts meme into the database
  Future<void> insertMeme(MemeModel meme) async {
    // Get a reference to the database.
    final Database db = await database;
    await db.insert(
      'Memes',
      meme.toMap(),
    );
  }

  // A method that retrieves all the memes from the memes table.
  Future<List<MemeModel>> getMemes() async {
    // Get a reference to the database.
    final Database db = await database;

    // Query the table for all The memes.
    final List<Map<String, dynamic>> maps = await db.query('Memes');

    // Convert the List<Map<String, dynamic> into a List<memesmodel>.
    return List.generate(maps.length, (i) {
      return MemeModel(
        id: maps[i]['id'],
        name: maps[i]['name'],
        url: maps[i]['url'],
      );
    });
  }

  Future<void> deleteDog(int id) async {
    // Get a reference to the database.
    final db = await database;

    // Remove the meme from the Database.
    await db.delete(
      'Memes',
      // Use a `where` clause to delete a specific meme.
      where: "id = ?",
      // Pass the meme's id as a whereArg to prevent SQL injection.
      whereArgs: [id],
    );
  }
}
