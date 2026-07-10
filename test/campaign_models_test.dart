import 'package:flutter_test/flutter_test.dart';
import 'package:mythora/features/campaign/domain/campaign_models.dart';

void main() {
  final chapter = CampaignChapter.fromJson({
    'id': 'twilight_road',
    'title': 'Twilight Road',
    'subtitle': 'Test',
    'nodes': [
      {
        'id': 'node_01',
        'name': 'A',
        'enemyId': 'goblin',
        'coinReward': 35,
        'order': 0,
      },
      {
        'id': 'node_02',
        'name': 'B',
        'enemyId': 'wolf',
        'coinReward': 50,
        'order': 1,
      },
      {
        'id': 'node_03',
        'name': 'C',
        'enemyId': 'shaman',
        'coinReward': 70,
        'order': 2,
      },
    ],
  });

  test('first node always unlocked', () {
    expect(chapter.isUnlocked('node_01', {}), isTrue);
  });

  test('second node locked until first completed', () {
    expect(chapter.isUnlocked('node_02', {}), isFalse);
    expect(chapter.isUnlocked('node_02', {'node_01'}), isTrue);
  });

  test('nodes sorted by order', () {
    expect(chapter.nodes.map((n) => n.id).toList(), [
      'node_01',
      'node_02',
      'node_03',
    ]);
  });
}
