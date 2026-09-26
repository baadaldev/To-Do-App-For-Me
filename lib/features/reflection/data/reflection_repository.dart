import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../core/services/local_storage_service.dart';
import '../models/reflection_model.dart';

abstract class IReflectionRepository {
  Future<List<ReflectionModel>> getReflections(String userId);
  Future<void> saveReflection(ReflectionModel reflection);
}

class ReflectionRepository implements IReflectionRepository {
  FirebaseFirestore? _firestore;
  final LocalStorageService _localStorage;

  ReflectionRepository({
    FirebaseFirestore? firestore,
    required LocalStorageService localStorage,
  })  : _firestore = firestore,
        _localStorage = localStorage;

  FirebaseFirestore? get _firestoreInstance {
    try {
      _firestore ??= FirebaseFirestore.instance;
      return _firestore;
    } catch (e) {
      debugPrint('FirebaseFirestore unavailable in reflection repo: $e');
      return null;
    }
  }

  CollectionReference<Map<String, dynamic>>? _reflectionsRef(String userId) {
    try {
      return _firestoreInstance?.collection('users').doc(userId).collection('reflections');
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ReflectionModel>> getReflections(String userId) async {
    final ref = _reflectionsRef(userId);
    if (ref == null) {
      return _localStorage.getCachedReflections(userId);
    }

    try {
      final snapshot = await ref
          .orderBy('date', descending: true)
          .get()
          .timeout(const Duration(seconds: 3));
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

    // 2. Sync to Firestore in background
    final ref = _reflectionsRef(reflection.userId);
    if (ref != null) {
      try {
        await ref
            .doc(reflection.id)
            .set(reflection.toJson())
            .timeout(const Duration(seconds: 3));
      } catch (_) {}
    }
  }
}
