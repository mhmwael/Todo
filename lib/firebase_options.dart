import 'package:firebase_core/firebase_core.dart'
    show
        FirebaseOptions;

class DefaultFirebaseOptions {
  static const FirebaseOptions
  web = FirebaseOptions(
    apiKey: 'AIzaSyAM6BfvkPTx9epxGL_kFTsUT8yGovMdUYo',
    appId: '1:808340284474:web:fb6e01ea2fdfcd776c4103',
    messagingSenderId: '808340284474',
    projectId: 'todo-77ff2',
    authDomain: 'todo-77ff2.firebaseapp.com',
    storageBucket: 'todo-77ff2.firebasestorage.app',
    measurementId: 'G-24JK4DWCMW',
  );

  static const FirebaseOptions
  android = FirebaseOptions(
    apiKey: 'AIzaSyDZ_t6q3GelMvhjfUDgLshaiNXKgUAasbM',
    appId: '1:808340284474:android:0f74db8b5ac42aa96c4103',
    messagingSenderId: '808340284474',
    projectId: 'todo-77ff2',
    storageBucket: 'todo-77ff2.firebasestorage.app',
  );

  static const FirebaseOptions
  ios = FirebaseOptions(
    apiKey: 'AIzaSyBDKdiKMjbQ5PXeUW4QW4rb84w6c95EZVk',
    appId: '1:808340284474:ios:5afa34bde921ba6b6c4103',
    messagingSenderId: '808340284474',
    projectId: 'todo-77ff2',
    storageBucket: 'todo-77ff2.firebasestorage.app',
    iosBundleId: 'com.example.prrroj',
  );

  static const FirebaseOptions
  macos = FirebaseOptions(
    apiKey: 'AIzaSyBDKdiKMjbQ5PXeUW4QW4rb84w6c95EZVk',
    appId: '1:808340284474:ios:5afa34bde921ba6b6c4103',
    messagingSenderId: '808340284474',
    projectId: 'todo-77ff2',
    storageBucket: 'todo-77ff2.firebasestorage.app',
    iosBundleId: 'com.example.prrroj',
  );

  static const FirebaseOptions
  windows = FirebaseOptions(
    apiKey: 'AIzaSyAM6BfvkPTx9epxGL_kFTsUT8yGovMdUYo',
    appId: '1:808340284474:web:e4d2bcd2ced790fd6c4103',
    messagingSenderId: '808340284474',
    projectId: 'todo-77ff2',
    authDomain: 'todo-77ff2.firebaseapp.com',
    storageBucket: 'todo-77ff2.firebasestorage.app',
    measurementId: 'G-J762LT7C3C',
  );

  static const FirebaseOptions
  linux = FirebaseOptions(
    apiKey: 'AIzaSyAM6BfvkPTx9epxGL_kFTsUT8yGovMdUYo',
    appId: '1:808340284474:web:fb6e01ea2fdfcd776c4103',
    messagingSenderId: '808340284474',
    projectId: 'todo-77ff2',
    authDomain: 'todo-77ff2.firebaseapp.com',
    storageBucket: 'todo-77ff2.firebasestorage.app',
    measurementId: 'G-24JK4DWCMW',
  );

  static FirebaseOptions
  get currentPlatform {
    return web;
  }
}
