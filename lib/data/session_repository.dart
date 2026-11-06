import 'dart:io';

import 'atomic_text_file.dart';
import 'text_draft_store.dart';

class SessionRepository {
  SessionRepository(this.root, {AtomicTextFile? files})
    : files = files ?? AtomicTextFile(),
      drafts = TextDraftStore(root, files: files);
  final Directory root;
  final AtomicTextFile files;
  final TextDraftStore drafts;
  File get _file => File.fromUri(root.uri.resolve('session.xml'));
  Future<bool> exists() async =>
      await _file.exists() || await File('${_file.path}.bak').exists();
  Future<String> read() => files.read(_file);
  Future<String> readDraft() => drafts.read('draft.xml');
  Future<void> saveDraft(String xml) => drafts.save('draft.xml', xml);
  Future<String> readNotes(String id) => drafts.read('$id.md');
  Future<void> saveNotes(String id, String text) => drafts.save('$id.md', text);
  Future<void> flushText() => drafts.flush();

  Future<void> save(String xml) => files.write(_file, xml, backup: true);
}
