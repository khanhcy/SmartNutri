import 'package:cloud_firestore/cloud_firestore.dart';

/// User-facing text when a Firestore write fails from the app.
String firestoreWriteErrorMessage(Object error) {
  if (error is FirebaseException) {
    if (error.code == 'permission-denied') {
      return 'Không thể lưu. Kiểm tra quyền Firestore Rules trên Firebase.';
    }
    if (error.code == 'unavailable') {
      return 'Mạng không ổn định. Vui lòng thử lại.';
    }
  }
  return 'Không thể lưu lúc này. Vui lòng thử lại.';
}
