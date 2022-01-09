import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:database_sqlite/models/etudiant.dart';

class DataBaseHelper {
  // Nom de la base de données.
  static const _databaseName = 'database_name.db';
  // Version du schéma de la base de données.
  static const _databaseVersion = 1;

  // constructeur
  DataBaseHelper._();
  // singleto class (Design partern pour une unique instance de la class DataBaseHelper)
  static final DataBaseHelper instance = DataBaseHelper._();

  // création d'un attribut pour une insance la base de donnée sqflite
  // il faut ajouter le signe ? car on n'a juste déclarer la variable _database
  Database? _database;
  // récupérer un et un seul instance de la base de données
  // il faut ajouter le signe ! car le variable _database dans certain cas peut étre null (gestion du null-safety)
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database =
        await initDatabase(); /* initDatabse est une méthode pour initialiser la base de données*/
    return _database!;
  }

  // une méthode pour initialiser la base de données.
  initDatabase() async {
    // création une instance repertoire (Directory) ou est stocker la base de données.
    // qui provient du package path_provider.
    Directory dataDirectory =
        await getApplicationDocumentsDirectory(); // une méthode synchone qui créer le répertoire.
    // définir le chemin d'acces ou sera stocker la base de donnée.
    // avec la method join qui est dans le package import 'package:path/path.dart';
    String dbPath = join(dataDirectory.path, _databaseName);
    //ouvrir la base de donnée avec une version de la base de données.
    //avec la méthode _onCreatDB qui créer une base de données.
    return await openDatabase(dbPath,
        version: _databaseVersion, onCreate: _onCreatDB);
  }

  // cette méthode nous premet de créer notre base données.
  // il nous permet de d'éxecuter le code sql pour créer la base de données
  _onCreatDB(Database db, int version) async {
    // requette sql pour créer la base de données
    String sql = '''
      CREATE TABLE ${Etudiant.tblEtudiant}(
        ${Etudiant.colId} INTEGER PRIMARY KEY AUTOINCREMENT,
        ${Etudiant.colName} TEXT NOT NULL,
        ${Etudiant.colMobile} TEXT NOT NULL
      )
      ''';
    // éxécuter la requette pour créer la base de données.
    await db.execute(sql);
  }

  //insert une étudiant dans la base de donnes
  Future<int> insertEtudiant(Etudiant etudiant) async {
    // définire une instance de la base de données
    Database db = await database;
    // inserer l'étudiant dans la base de données
    // la méthode insert prend en paramettre le nom de la table et les données (etudiant.toMap()).
    return await db.insert(Etudiant.tblEtudiant, etudiant.toMap());
  }

  //récupére tous les étudiants dans la base de données.
  Future<List<Etudiant>> fetchEtudiants() async {
    // définire une instance de la base de données
    Database db = await database;
    // récupérer la list des étudiant dans la base de données
    // avec la méthode query qui prend en paramettre le nom de la table.
    //et qui retourne une List<Map>
    List<Map> etudiants = await db.query(Etudiant.tblEtudiant);
    // ici on retourne soit la liste des étudiant ou soit une liste vide.
    return etudiants.length == 0
        ? []
        : etudiants.map((e) => Etudiant.fromMap(e)).toList();
  }

//mette à jour un étudiant dans la base de donnérs.
//et rétourner l'id comme valeur l'état de la mise à jour
  Future<int> updateEtudiant(Etudiant etudiant) async {
    // définir une instance de la base de données.
    Database db = await database;
    // appeler la méthode update qui prend en paramettre le nom de la table
    // et les données a mettre à jours.
    // avec une clause where sur la colonne pour récupérer l'étudiant concerner.
    return await db.update(Etudiant.tblEtudiant, etudiant.toMap(),
        where: '${Etudiant.colId}=?', whereArgs: [etudiant.id]);
  }

//supprimer un étudiant dans la base de donnérs.
//et rétourner le nombre de ligne affacté.
  Future<int> deleteEtudiant(int id) async {
    // définir une instance de la base de données.
    Database db = await database;
    // appeler la méthode delete qui prend en paramettre le nom de la table.
    // avec une clause where sur la colonne pour récupérer l'étudiant concerner.
    return await db.delete(Etudiant.tblEtudiant,
        where: '${Etudiant.colId}=?', whereArgs: [id]);
  }
}
