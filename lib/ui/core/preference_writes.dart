class PreferenceWrites<T> {
  PreferenceWrites(this.save);

  final Future<void> Function(T) save;
  Future<void> _pending = Future.value();
  int _revision = 0;

  Future<void> get pending => _pending;

  Future<void> enqueue(T value, void Function(Object error) onError) {
    final revision = ++_revision;
    return _pending = _pending.then((_) async {
      try {
        await save(value);
      } catch (error) {
        if (revision == _revision) onError(error);
      }
    });
  }
}
