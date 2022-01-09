//la classe étudiant ici représent notre model.
class Etudiant {
  //on définit ici tblEtudiant, qui représent le nom de la table Etudiant de la base de données.
  static const tblEtudiant = 'etudiants';
  //on définit ici colId, qui représent le nom de la colone id de la table Etudiant.
  static const colId = 'id';
  //on définit ici colName qui représent le nom de la colone name de la table Etudiant.
  static const colName = 'name';
  //on définit ici colMobile qui représent le nom de la colone mobile de la table Etudiant.
  static const colMobile = 'mobile';

  //on définit un construteur pour la class Etudiant.
  Etudiant({this.id, this.name, this.mobile});
  //on définit les propriéte id, name et mobile de l'object Etudiant.
  int? id;
  String? name;
  String? mobile;
  //on définit une méthode fromMap pour convertire les données de l'étudiant d'un map à l'objet Etudiant
  // elle prend en paramettre le map et le convertie en étudiant.
  Etudiant.fromMap(Map<dynamic, dynamic> map) {
    id = map[colId];
    name = map[colName];
    mobile = map[colMobile];
  }
  //on définit une méthode toMap pour convertire les données de l'étudiant à un map.
  //elle retourne un map
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{colName: name, colMobile: mobile};
    if (id != null) {
      map[colId] = id;
    }
    return map;
  }
}
