import 'dart:ffi';

import 'package:database_sqlite/helper/database_helper.dart';
import 'package:database_sqlite/models/etudiant.dart';
import 'package:flutter/material.dart';

//appYellowColor est la couleur de l'application.
const appYellowColor = Color(0xffFFD401);
//appBackgroundColor est la couleur de fond de l'application.
const appBackgroundColor = Color(0xffF2F2F2);
void main() {
  // la methode run permet de executer l'application MyApp()
  runApp(const MyApp());
}

// la class MyApp définie un StatelessWidget,
//MyApp nous permet de definir notre application
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form & SQLite CRUD', // titre de notre apllicaion
      theme: ThemeData(
        // theme de notre application.
        primaryColor: appYellowColor,
      ),
      // MyHomePage est note premier page charger sur MyApp,
      //c'est notre page d'acceuil avec le titre (title) en paramttre.
      home: const MyHomePage(title: 'Form & SQLite CRUD'),
    );
  }
}

// la classe MyHomePage est la page d'acceuil de notre application MyApp().
// c'est une StatefulWidget
class MyHomePage extends StatefulWidget {
  // c'est le constructeur de la class MyHomePage qui prend en paramettre le titre (title)
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title; // champs la proprieté de notre titre

  // on crée l'état (state) de notre classe MyHomePage par _MyHomePageState.
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // on définie l'attribute _formKey comme clé unique pour manipuler notre formulaire.
  //il provient de GlobalKey<FormState> (Voir le cours aussi.)
  final _formKey = GlobalKey<FormState>();
  //on définit _ctrlName pour controller la valeur du champs name (nomComplet) du formulaire.
  final _ctrlName = TextEditingController();
  //on définit _ctrlMobile pour controller la valeur du champs mobile (téléphone) du formulaire.
  final _ctrlMobile = TextEditingController();
  //on définit notre model Etudiant qui nous permet de récuper le nomComplet et le téléphone de l'étudiant
  Etudiant _etudiant = Etudiant();
  //on définit _listEtudiant une list pour afficher tous les étudiants ajouter dans la base de données.
  List<Etudiant> _listEtudiant = [];
  // on définit _dataBaseHelper pour gerer les operations CRUD de la base de données.
  late DataBaseHelper _dataBaseHelper;

  // la méthode initState() est appelé à la création de widget MyHomePage().
  // dans cette méthode on initialise toutes les valeur par défauts.
  @override
  void initState() {
    super.initState();
    // la méthode setState() de flutter permet de changer l'état (valeur) des variables définie dans un widget
    setState(() {
      // on initialie l'instant de la base de données.
      _dataBaseHelper = DataBaseHelper.instance;
    });

    _refreshEtudiantList(); // on initialise la liste des étudiant provenant de la base de données.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          appBackgroundColor, // couleur du fond d'écran de notre page
      appBar: AppBar(
        title: Center(
            child: Text(
          widget.title,
          style: TextStyle(color: appYellowColor),
        )), //couleur et titre notre page
        backgroundColor: Colors.white,
      ),
      body: Center(
        // on définit ici le corps de notre page qui est un colone
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          // on définit ici les enfants du colones qui sont un formulaire (_form) et une liste (_list)
          children: <Widget>[_form(), _list()],
        ),
      ),
    );
  }

  //on définit la méthode _form qui renvoie un conteneur et nous permet définir notre formalaire.
  _form() => Container(
      color: Colors.white,
      //fair padding vertical et horizontal de 15 et 30
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
      //définir le formulaire comme enfant du conteneur
      child: Form(
          //_formKey est la clé unique du formulaire qui vient de GlobalKey<FormState>()
          key: _formKey,
          //on utilise Column comme enfant du formulaire qui représent le formulaire sous form de colone
          child: Column(
            //on définit les enfants du formulair avec le children
            children: <Widget>[
              //on définit le champ Nom Complet du formulaire.
              TextFormField(
                  //la proprieté controller avec _ctrlName ici permet de gérer les valeur de ce champ Nom Complet.
                  controller: _ctrlName,
                  //decoration pour décorer notre champs
                  decoration: InputDecoration(labelText: 'Nom Complet: '),
                  //onSaved recupere la valeur chaisi par l'utilisateur et le mets dans le model etudiant.name
                  onSaved: (val) => setState(() => _etudiant.name = val),
                  //validator premet de valider le champs de la formulaire, ici on test si la valeur n'est pas null.
                  validator: (val) =>
                      (val!.length == 0 ? 'Ce champs est obligatoire' : null)),
              TextFormField(
                controller: _ctrlMobile,
                decoration: InputDecoration(labelText: 'Téléphone: '),
                onSaved: (val) => setState(() => _etudiant.mobile = val),
                validator: (val) => (val!.length < 9
                    ? 'minimun 9 carractères est requises'
                    : null),
              ),
              Container(
                  margin: EdgeInsets.all(10.0),
                  //on définit un elevatedButton comme button d'enregistrement du formulaire
                  child: ElevatedButton(
                    child: Text('Enregistrer'),
                    //onPressed éxécute la méthode _save() définit ci-dessous qui premet de valider le formulaire
                    //et  enregistrer les données saisie par l'utilisateur.
                    onPressed: () => _save(),
                    //sytle nous premet de mettre un style sur notre button
                    style: ElevatedButton.styleFrom(
                        primary: appYellowColor,
                        onPrimary: Colors.white,
                        textStyle:
                            TextStyle(color: Colors.white, fontSize: 25)),
                  ))
            ],
          )));
  //ici on définit la méthode _save()
  _save() async {
    // la variable form ici nous permet de récupérer l'état de notre formulaire.
    // les valeurs saisie par l'utilisateur dans les champs.
    var form = _formKey.currentState;
    //ici on test si notre formulaire est valide
    // c'est si le validator ne retourne pas d'erreur.
    if (form!.validate()) {
      //ici on enregistre le formulaire.
      form.save();
      //ici on test si c'est un nouveau enregistrement.
      // c'est a dire si l'étudiant n'a pas id (_etudiant.id == null)
      if (_etudiant.id == null) {
        //ici on fait appelle a l'instance _dataBaseHelper de la base de donnée SQLite.
        //et on utilise la méthode insertEtudiant pour inserer un nouveau étudiant.
        await _dataBaseHelper.insertEtudiant(_etudiant);
      } else {
        //ici on fait appelle a l'instance _dataBaseHelper de la base de donnée SQLite.
        //et on utilise la méthode updateEtudiant pour metter a jour un étudiant existant.
        await _dataBaseHelper.updateEtudiant(_etudiant);
      }
      //on appele la méthode _refreshEtudiantList() pour affichier
      //la liste des étudiants qui vient d'etre inserer ou mis a jour.
      _refreshEtudiantList();
      //on appele la méthode _resetForm() pour réinitialiser le formulaire, pour vider les champs de saisie.
      _resetForm();
    }
    //on juste afficher le nom de l'étudiant dans la console pour être sure que c'est bien récupérer.
    print(_etudiant.name);
  }

  //ici définit la méthode _resetForm() qui réinitialise le formulaire et vider tout les champes de saisie.
  _resetForm() {
    setState(() {
      _formKey.currentState!.reset(); //réinitialiser le formulaire.
      //vider le champs de saisie de Nom Complet grace au controlleur _ctrlNam
      _ctrlName.clear();
      //vider le champs de saisie de Téléphone grace au controlleur _ctrlMobile
      _ctrlMobile.clear();
      // mettre l'id de l'étudiant à null.
      _etudiant.id = null;
    });
  }

  // on définit ici la méthode _refreshEtudiantList() qui permet récupére les étudiant qui sont dans le BD.
  _refreshEtudiantList() async {
    //ici on fait appelle a l'instance _dataBaseHelper de la base de donnée SQLite.
    //et on utilise la méthode fetchEtudiants pour récupérer la liste des étudiants.
    List<Etudiant> e = await _dataBaseHelper.fetchEtudiants();
    // avec la méthode setState() ici on change l'état de à la variable _listEtudiant  définit ci-dessu
    setState(() {
      //on passe liste e, le résultat da la requette provenant da la BD à _listEtudiant.
      _listEtudiant = e;
    });
  }

  // ici on définit la méthode _list() pour lister les étudiant déja créer.
  //on utilise le widget Expanded pour qu'il prend tous l'espace qui reste sur l'écran.
  _list() => Expanded(
      //on définit une carte (widget Card) pour représent les éléments de la liste sous forme de carte
      child: Card(
          margin: EdgeInsets.fromLTRB(20, 30, 20, 0),
          //on définit un ListView pour afficher la liste.
          child: ListView.builder(
            //la méthode itemBuilder nous premet de construire les élément (item) de la liste.
            itemBuilder: (context, index) {
              //on définit un colone ou les enfants seront les éléments (item) de la liste.
              return Column(children: <Widget>[
                // on définit un widget ListTile qui est l'élément (item) de liste.
                ListTile(
                  // dans ce ListTile on a un leading qui définit l'icone en form de cercle jaune dans l'affichage.
                  leading: Icon(Icons.account_circle,
                      color: appYellowColor, size: 40),
                  //on définit le titre qui est le nom complet de l'étudiant récupérer a partie de la liste
                  //_listEtudiant et à l'index index (_listEtudiant[index].name), on a mit le style de couleur jaune.
                  title: Text(_listEtudiant[index].name!.toUpperCase(),
                      style: TextStyle(
                        color: appYellowColor,
                        fontWeight: FontWeight.bold,
                      )),
                  //on définit le sous titre qui représente le téléphone de l'étudiant récupérer a partie de la liste
                  //_listEtudiant et à l'index index (_listEtudiant[index].mobile).
                  subtitle: Text(_listEtudiant[index].mobile!),
                  // le trailing premet de définir les action du ListTile,
                  // c'est le button icone de suppression qui afficher tout a fait a droite.
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete_sweep,
                      color: appYellowColor,
                    ),
                    // la méthode onPressend du icon button lorsqu'on clique dessus, nous premet de supprimer l'enregistrement.
                    onPressed: () async {
                      //on fait appelle à la base de données et on utilise la méthode deleteEtudiant pour supprimer l'étudiant.
                      await _dataBaseHelper
                          .deleteEtudiant(_listEtudiant[index].id!.toInt());
                      // on réinitialise le formulaire.
                      _resetForm();
                      // et on rafraichie la liste des étudiants.
                      _refreshEtudiantList();
                    },
                  ),
                  //onTap est une méthode de ListTile qui premet clique sur un élément de la liste
                  //ici lorqu'on tape sur un élément de la liste, on remplir le formulaire a partie
                  //des informations de cette élément choisie.
                  onTap: () {
                    setState(() {
                      //on choisie l'étudiant
                      _etudiant = _listEtudiant[index];
                      //on remplie a nouveau le champs nom complet à partie de l'élément choisie.
                      _ctrlName.text = _listEtudiant[index].name.toString();
                      //on remplie a nouveau le champs téléphone à partie de l'élément choisie.
                      _ctrlMobile.text = _listEtudiant[index].mobile.toString();
                    });
                  },
                ),
                //Divider est widget qui premet d'affichier les ligne de séparation horizontale sur la liste.
                //il premet de séparer les élements de la liste.
                Divider(
                  height: 5,
                )
              ]);
            },
            //itemcount est le nombre d'éléments de la liste, c'est a dire la taille de la liste (_listEtudiant.length)
            itemCount: _listEtudiant.length,
          )));
}
