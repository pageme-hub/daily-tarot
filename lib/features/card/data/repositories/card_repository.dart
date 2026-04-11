import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/supabase/supabase_client.dart';
import '../../../../core/utils/logger.dart';
import '../models/tarot_card.dart';

/// 타로 카드 데이터 저장소
///
/// 로드 순서:
/// 1. Supabase 연결 가능 → Supabase에서 fetch (app_id = 'daily_tarot')
///    성공 시 Hive에 캐싱
/// 2. Supabase 실패 또는 미연결 → Hive 캐시 확인
/// 3. Hive 캐시 없음 → 로컬 JSON fallback (assets/data/tarot_cards.json)
class CardRepository {
  static const String _kLocalAssetPath = 'assets/data/tarot_cards.json';
  static const String _kSupabaseTable = 'tarot_cards';
  static const String _kAppId = 'daily_tarot';
  static const String _kCacheBoxName = 'card_data_cache';
  static const String _kCacheKey = 'all_cards';

  Box<String>? _cacheBox;

  Future<Box<String>> _getBox() async {
    if (_cacheBox != null && _cacheBox!.isOpen) return _cacheBox!;
    _cacheBox = await Hive.openBox<String>(_kCacheBoxName);
    return _cacheBox!;
  }

  /// 78장 카드 전체 로드
  Future<List<TarotCard>> fetchAllCards() async {
    // 1차: Supabase 시도
    if (SupabaseClientManager.isInitialized) {
      try {
        final response = await SupabaseClientManager.client
            .from(_kSupabaseTable)
            .select()
            .eq('app_id', _kAppId)
            .order('id')
            .timeout(const Duration(seconds: 5));

        final cards = (response as List<dynamic>)
            .map((json) => TarotCard.fromJson(json as Map<String, dynamic>))
            .toList();

        if (cards.isNotEmpty) {
          Logger.info('CardRepository: Supabase에서 ${cards.length}장 로드 완료');
          // Hive에 캐싱 (오프라인 대응)
          await _cacheCards(cards);
          return cards;
        }
      } catch (e) {
        Logger.error('CardRepository: Supabase 로드 실패: $e');
      }
    }

    // 2차: Hive 캐시
    final cached = await _loadFromHiveCache();
    if (cached != null && cached.isNotEmpty) {
      Logger.info('CardRepository: Hive 캐시에서 ${cached.length}장 로드');
      return cached;
    }

    // 3차: 로컬 JSON fallback
    return _loadFromLocalAsset();
  }

  /// Hive에 카드 데이터 캐싱
  Future<void> _cacheCards(List<TarotCard> cards) async {
    try {
      final box = await _getBox();
      final jsonList = cards.map((c) => c.toJson()).toList();
      await box.put(_kCacheKey, json.encode(jsonList));
      Logger.info('CardRepository: Hive 캐싱 완료 (${cards.length}장)');
    } catch (e) {
      Logger.error('CardRepository: Hive 캐싱 실패: $e');
    }
  }

  /// Hive 캐시에서 카드 데이터 로드
  Future<List<TarotCard>?> _loadFromHiveCache() async {
    try {
      final box = await _getBox();
      final cached = box.get(_kCacheKey);
      if (cached == null) return null;

      final jsonList = json.decode(cached) as List<dynamic>;
      return jsonList
          .map((j) => TarotCard.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      Logger.error('CardRepository: Hive 캐시 로드 실패: $e');
      return null;
    }
  }

  /// 로컬 JSON 에셋에서 카드 데이터 로드 (최종 fallback)
  Future<List<TarotCard>> _loadFromLocalAsset() async {
    try {
      final jsonString = await rootBundle.loadString(_kLocalAssetPath);
      final jsonList = json.decode(jsonString) as List<dynamic>;
      final cards = jsonList
          .map((json) => TarotCard.fromJson(json as Map<String, dynamic>))
          .toList();
      Logger.info('CardRepository: 로컬 JSON에서 ${cards.length}장 로드 완료');
      return cards;
    } catch (e) {
      Logger.error('CardRepository: 로컬 JSON 로드 실패: $e');
      return [];
    }
  }
}
