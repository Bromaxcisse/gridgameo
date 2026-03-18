import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract final class SaveData {
  static const _highestSectorKey = 'highestUnlockedSector';
  static const _ratingsPrefix = 'efficiencyRating_';

  static Future<void> saveEfficiencyRating(int sector, int rating) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentBest = prefs.getInt('$_ratingsPrefix$sector') ?? 0;
      if (rating > currentBest) {
        await prefs.setInt('$_ratingsPrefix$sector', rating);
      }
      final highestUnlocked = prefs.getInt(_highestSectorKey) ?? 1;
      if (sector >= highestUnlocked) {
        await prefs.setInt(_highestSectorKey, sector + 1);
      }
    } catch (e) {
      debugPrint('SaveData.saveEfficiencyRating failed: $e');
    }
  }

  static Future<int> getHighestUnlockedSector() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_highestSectorKey) ?? 1;
    } catch (e) {
      debugPrint('SaveData.getHighestUnlockedSector failed: $e');
      return 1;
    }
  }

  static Future<int> getEfficiencyRating(int sector) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('$_ratingsPrefix$sector') ?? 0;
    } catch (e) {
      debugPrint('SaveData.getEfficiencyRating failed: $e');
      return 0;
    }
  }

  static Future<Map<int, int>> getAllEfficiencyRatings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ratings = <int, int>{};
      for (int i = 1; i <= 50; i++) {
        final rating = prefs.getInt('$_ratingsPrefix$i');
        if (rating != null) {
          ratings[i] = rating;
        }
      }
      return ratings;
    } catch (e) {
      debugPrint('SaveData.getAllEfficiencyRatings failed: $e');
      return {};
    }
  }
}
