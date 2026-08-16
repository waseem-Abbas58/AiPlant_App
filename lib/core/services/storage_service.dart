abstract class StorageService {
  Future<void> write(String key, String value);

  Future<String?> read(String key);

  Future<void> remove(String key);

  Future<bool> contains(String key);

  Future<void> clear();
}

class LocalStorageService implements StorageService {
  LocalStorageService();

  final Map<String, String> _memoryStore = <String, String>{};

  @override
  Future<void> write(String key, String value) async {
    _memoryStore[key] = value;
  }

  @override
  Future<String?> read(String key) async => _memoryStore[key];

  @override
  Future<void> remove(String key) async {
    _memoryStore.remove(key);
  }

  @override
  Future<bool> contains(String key) async => _memoryStore.containsKey(key);

  @override
  Future<void> clear() async {
    _memoryStore.clear();
  }
}
