import 'package:flutter/material.dart';
import '../models/gamification.dart';
import '../models/achievement.dart';
import '../models/challenge.dart';
import '../models/leaderboard.dart';
import '../services/api/gamification_api.dart';

class GamificationProvider extends ChangeNotifier {
  Gamification? profile;
  List<Achievement> achievements = [];
  List<Challenge> activeChallenges = [];
  LeaderboardData? leaderboard;
  bool isLoading = false;
  String? error;

  Future<void> loadAll() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        GamificationApi.getProfile(),       // {data: {profile: {...}}}
        GamificationApi.getAchievements(),  // {data: {achievements: [], summary: {}}}
        GamificationApi.getChallenges(),    // {data: {challenges: [], summary: {}}}
        GamificationApi.getLeaderboard(),   // {data: {leaderboard: [], my_rank: {}}}
      ]);

      // Profile → data.profile
      final profileOuter = results[0]['data'] ?? results[0];
      final profileData = profileOuter['profile'] ?? profileOuter;
      profile = Gamification.fromJson(profileData);

      // Achievements → data.achievements
      final achievementOuter = results[1]['data'] ?? results[1];
      final achievementList = achievementOuter['achievements'] ?? achievementOuter;
      achievements = (achievementList is List)
          ? achievementList.map((a) => Achievement.fromJson(a)).toList()
          : [];

      // Challenges → data.challenges
      final challengeOuter = results[2]['data'] ?? results[2];
      final challengeList = challengeOuter['challenges'] ?? challengeOuter;
      activeChallenges = (challengeList is List)
          ? challengeList.map((c) => Challenge.fromJson(c)).toList()
          : [];

      // Leaderboard → data.leaderboard + data.my_rank
      final leaderboardOuter = results[3]['data'] ?? results[3];
      leaderboard = LeaderboardData.fromJson(leaderboardOuter);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadLeaderboard() async {
    try {
      final response = await GamificationApi.getLeaderboard();
      final outer = response['data'] ?? response;
      leaderboard = LeaderboardData.fromJson(outer);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}
