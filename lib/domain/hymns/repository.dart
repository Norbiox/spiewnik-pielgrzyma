import 'package:flutter/widgets.dart';
import 'package:spiewnik_pielgrzyma/domain/hymns/model.dart';
import 'package:spiewnik_pielgrzyma/seed/entity.dart';
import 'package:spiewnik_pielgrzyma/seed/exceptions.dart';

class HymnNotFoundException extends RepositoryException {}

abstract class HymnRepository extends ChangeNotifier {
  Future<Hymn> getById(EntityId hymnId);
  Future<List<Hymn>> getAll();
  void save(Hymn hymn);
}
