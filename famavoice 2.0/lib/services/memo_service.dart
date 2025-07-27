import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:famavoice/models/memo_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MemoService {
  static const String _memoBoxName = 'memos';

  Future<bool> requestPermissions() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      status = await Permission.microphone.request();
    }
    return status.isGranted;
  }

  Future<void> saveMemo(Memo memo) async {
    final box = await Hive.openBox<Memo>(_memoBoxName);
    await box.put(memo.id, memo);
  }

  Future<List<Memo>> loadMemos() async {
    final box = await Hive.openBox<Memo>(_memoBoxName);
    return box.values.toList();
  }

  Future<void> deleteMemo(String memoId, String filePath) async {
    final box = await Hive.openBox<Memo>(_memoBoxName);
    await box.delete(memoId);
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}