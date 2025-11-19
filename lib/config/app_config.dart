import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  // IP адрес вашего компьютера в локальной сети
  // Замените на актуальный IP, если он изменится
  static const String serverIp = '192.168.1.48';
  static const int serverPort = 8001;
  
  // Базовый URL API
  // Для iOS симулятора используйте: 'http://localhost:8001'
  // Для Android эмулятора используйте: 'http://10.0.2.2:8001'
  // Для реального устройства используйте IP вашего компьютера: 'http://192.168.0.103:8001'
  static String get baseUrl {
    // В режиме разработки
    if (kDebugMode) {
      if (Platform.isIOS) {
        // Для iOS симулятора используем localhost (симулятор имеет доступ к localhost Mac)
        // Для реальных iOS устройств нужно будет использовать IP адрес Mac: http://$serverIp:$serverPort
        return 'http://localhost:$serverPort';
      } else if (Platform.isAndroid) {
        // Android эмулятор использует специальный адрес
        return 'http://10.0.2.2:$serverPort';
      }
    }
    
    // Для production используем IP адрес сервера
    return 'http://$serverIp:$serverPort';
  }

  // Таймауты для HTTP запросов (в секундах)
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 60); // Увеличено до 60 секунд
}

// class AppConfig {
//   static String get baseUrl {
//     return 'http://10.0.2.2:8001';
//   }

//   static const Duration connectTimeout = Duration(seconds: 1);
//   static const Duration receiveTimeout = Duration(seconds: 10);
// }