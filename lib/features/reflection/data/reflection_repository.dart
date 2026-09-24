import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/local_storage_service.dart';
import '../models/reflection_model.dart';

abstract class IReflectionRepository {
  Future<List<ReflectionModel>> getReflections(String userId);
  Future<void> saveReflection(ReflectionModel reflection);
}

class ReflectionRepository implements IReflectionRepository {
  final FirebaseFirestore _firestore;
  final LocalStorageService _localStorage;

  ReflectionRepository({
    FirebaseFirestore? firestore,
    required LocalStorageService localStorage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _localStorage = localStorage;

  CollectionReference<Map<String, dynamic>> _reflectionsRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('reflections');
  }

  @override
  Future<List<ReflectionModel>> getReflections(String userId) async {
    try {
      final snapshot = await _reflectionsRef(userId).orderBy('date', descending: true).get();
      final list = snapshot.docs.map((doc) => ReflectionModel.fromJson(doc.data())).toList();

      await _localStorage.saveReflectionsToCache(userId, list);
      return list;
    } catch (_) {
      return _localStorage.getCachedReflections(userId);
    }
  }

  @override
  Future<void> saveReflection(ReflectionModel reflection) async {
    // 1. Cache locally
    final currentList = _localStorage.getCachedReflections(reflection.userId);
    final existingIdx = currentList.indexWhere((r) => r.id == reflection.id);
    if (existingIdx >= 0) {
      currentList[existingIdx] = reflection;
    } else {
      currentList.insert(0, reflection);
    }
    await _localStorage.saveReflectionsToCache(reflection.userId, currentList);

    // 2. Sync to Firestore
    try {
      await _reflectionsRef(reflection.userId).doc(reflection.id).set(reflection.toJson());
    } catch (_) {}
  }
}
