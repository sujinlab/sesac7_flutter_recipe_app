import 'dart:async';

import 'package:flutter_recipe_app/di/di_setup.dart';
import 'package:uuid/uuid.dart';

const uuid = Uuid();

class FakeStreamController<T> {
  final _controller = StreamController<T>.broadcast();
  Stream<T> get stream => _controller.stream;
  void add(T data) {
    _controller.add(data);
  }

  void close() {
    _controller.close();
  }
}

class MockFirebaseFirestore {
  final Map<String, MockCollectionReference> _collections = {};

  MockCollectionReference collection(String collectionPath) {
    _collections.putIfAbsent(collectionPath, () => MockCollectionReference());
    return _collections[collectionPath]!;
  }
}

class MockCollectionReference {
  final Map<String, MockDocumentReference> _documents = {};

  MockDocumentReference doc([String? path]) {
    final docId = path ?? uuid.v4();
    _documents.putIfAbsent(docId, () => MockDocumentReference());
    return _documents[docId]!;
  }

  MockQuery<Map<String, dynamic>> orderBy(
    Object field, {
    bool descending = false,
  }) {
    return MockQuery(this, field as String, descending);
  }
}

class MockQuery<T extends Object?> {
  final MockCollectionReference _collection;
  final String _orderByField;
  final bool _descending;
  final FakeStreamController<MockQuerySnapshot> _controller =
      FakeStreamController();
  MockQuery(this._collection, this._orderByField, this._descending);

  Stream<MockQuerySnapshot> snapshots({
    bool includeMetadataChanges = false,
  }) {
    return _controller.stream;
  }

  void addDocument(Map<String, dynamic> data) {
    final docId = data['id'] as String;
    final docRef = _collection.doc(docId);
    docRef.data = data;
    final docs = _collection._documents.values
        .where((d) => d.data != null)
        .map((d) => MockQueryDocumentSnapshot(d.data!))
        .toList();
    docs.sort(
      (a, b) => _descending
          ? b.data[_orderByField].compareTo(a.data[_orderByField])
          : a.data[_orderByField].compareTo(b.data[_orderByField]),
    );
    _controller.add(MockQuerySnapshot(docs));
  }
}

class MockDocumentReference {
  Map<String, dynamic>? data;
  final Map<String, MockCollectionReference> _subCollections = {};

  MockCollectionReference collection(String collectionPath) {
    _subCollections.putIfAbsent(
      collectionPath,
      () => MockCollectionReference(),
    );
    return _subCollections[collectionPath]!;
  }

  Future<void> set(Map<String, dynamic> data, [SetOptions? options]) {
    this.data = data;
    final parentCollectionRef = _parentCollection();
    final parentQuery = parentCollectionRef.orderBy(
      'timestamp',
      descending: true,
    );
    parentQuery.addDocument(data);
    return Future.value();
  }

  MockCollectionReference _parentCollection() {
    return getIt<MockFirebaseFirestore>()._collections.values.first;
  }
}

class MockQuerySnapshot {
  final List<MockQueryDocumentSnapshot> docs;
  MockQuerySnapshot(this.docs);
}

class MockQueryDocumentSnapshot {
  final Map<String, dynamic> _data;
  MockQueryDocumentSnapshot(this._data);

  Map<String, dynamic> get data => _data;
}

class SetOptions {}
