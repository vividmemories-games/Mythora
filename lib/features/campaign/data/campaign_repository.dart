import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/campaign_models.dart';

final campaignChapterProvider = FutureProvider<CampaignChapter>((ref) async {
  final raw = await rootBundle.loadString('assets/levels/twilight_road.json');
  final json = jsonDecode(raw) as Map<String, dynamic>;
  return CampaignChapter.fromJson(json);
});
