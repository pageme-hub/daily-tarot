// Template from mumchit-quote — 앱별 커스터마이징 필요 시 TODO 확인
import 'package:shared_preferences/shared_preferences.dart';

/// SharedPreferences 래퍼 클래스
///
/// 로컬 저장소에 데이터를 저장하고 불러오는 기능을 제공합니다.
/// 싱글톤 패턴으로 구현되어 앱 전체에서 하나의 인스턴스만 사용합니다.
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();

  /// 싱글톤 인스턴스에 접근하는 getter
  static LocalStorageService get instance => _instance;

  factory LocalStorageService() => _instance;

  LocalStorageService._internal();

  SharedPreferences? _prefs;

  /// SharedPreferences 초기화
  ///
  /// 앱 시작 시 한 번 호출해야 합니다.
  Future<void> init() async {
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      rethrow;
    }
  }

  /// String 값 가져오기
  Future<String?> getString(String key) async {
    try {
      if (_prefs == null) {
        await init();
      }
      return _prefs?.getString(key);
    } catch (e) {
      return null;
    }
  }

  /// String 값 저장하기
  Future<bool> setString(String key, String value) async {
    try {
      if (_prefs == null) {
        await init();
      }
      return await _prefs?.setString(key, value) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// int 값 가져오기
  Future<int?> getInt(String key) async {
    try {
      if (_prefs == null) {
        await init();
      }
      return _prefs?.getInt(key);
    } catch (e) {
      return null;
    }
  }

  /// int 값 저장하기
  Future<bool> setInt(String key, int value) async {
    try {
      if (_prefs == null) {
        await init();
      }
      return await _prefs?.setInt(key, value) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// bool 값 가져오기
  Future<bool?> getBool(String key) async {
    try {
      if (_prefs == null) {
        await init();
      }
      return _prefs?.getBool(key);
    } catch (e) {
      return null;
    }
  }

  /// bool 값 저장하기
  Future<bool> setBool(String key, bool value) async {
    try {
      if (_prefs == null) {
        await init();
      }
      return await _prefs?.setBool(key, value) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// 특정 키의 값 제거
  Future<bool> remove(String key) async {
    try {
      if (_prefs == null) {
        await init();
      }
      return await _prefs?.remove(key) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// String 리스트 값 가져오기
  Future<List<String>?> getStringList(String key) async {
    try {
      if (_prefs == null) {
        await init();
      }
      return _prefs?.getStringList(key);
    } catch (e) {
      return null;
    }
  }

  /// String 리스트 값 저장하기
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      if (_prefs == null) {
        await init();
      }
      return await _prefs?.setStringList(key, value) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// 모든 데이터 삭제
  Future<bool> clear() async {
    try {
      if (_prefs == null) {
        await init();
      }
      return await _prefs?.clear() ?? false;
    } catch (e) {
      return false;
    }
  }
}
