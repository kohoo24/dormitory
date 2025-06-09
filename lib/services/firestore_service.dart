import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 컬렉션 참조 가져오기
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }

  // 문서 참조 가져오기
  DocumentReference<Map<String, dynamic>> document(String path) {
    return _firestore.doc(path);
  }

  // 컬렉션 스트림 가져오기
  Stream<List<T>> collectionStream<T>({
    required String path,
    required T Function(DocumentSnapshot<Map<String, dynamic>>) converter,
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>>)?
        queryBuilder,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(path);
    if (queryBuilder != null) {
      query = queryBuilder(query);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => converter(doc)).toList();
    });
  }

  // 문서 데이터 설정
  Future<void> setData({
    required String path,
    required Map<String, dynamic> data,
    bool merge = false,
  }) async {
    await _firestore.doc(path).set(data, SetOptions(merge: merge));
  }

  // 문서 데이터 업데이트
  Future<void> updateData({
    required String path,
    required Map<String, dynamic> data,
  }) async {
    await _firestore.doc(path).update(data);
  }

  // 문서 데이터 삭제
  Future<void> deleteData(String path) async {
    await _firestore.doc(path).delete();
  }

  // 문서 데이터 가져오기
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
      String path) async {
    return await _firestore.doc(path).get();
  }

  // 컬렉션 데이터 가져오기
  Future<QuerySnapshot<Map<String, dynamic>>> getCollection(String path) async {
    return await _firestore.collection(path).get();
  }
}
