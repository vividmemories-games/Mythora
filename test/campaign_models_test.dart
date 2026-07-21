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

  test('map coordinates parse when valid and normalized', () {
    final node = CampaignNode.fromJson({
      'id': 'node_01',
      'name': 'A',
      'enemyId': 'goblin',
      'coinReward': 35,
      'order': 0,
      'mapX': 0.46,
      'mapY': 0.9,
    });
    expect(node.mapX, 0.46);
    expect(node.mapY, 0.9);
  });

  test('missing or out-of-range map coordinates fall back to null', () {
    final missing = CampaignNode.fromJson({
      'id': 'node_01',
      'name': 'A',
      'enemyId': 'goblin',
      'coinReward': 35,
      'order': 0,
    });
    expect(missing.mapX, isNull);
    expect(missing.mapY, isNull);

    final invalid = CampaignNode.fromJson({
      'id': 'node_02',
      'name': 'B',
      'enemyId': 'wolf',
      'coinReward': 50,
      'order': 1,
      'mapX': 1.4,
      'mapY': -0.2,
    });
    expect(invalid.mapX, isNull);
    expect(invalid.mapY, isNull);
  });

  test('boss_sighting and warchief mark isBoss', () {
    final boss = CampaignNode.fromJson({
      'id': 'node_05',
      'name': 'Warchief',
      'enemyId': 'warchief',
      'coinReward': 120,
      'order': 4,
      'kind': 'boss_sighting',
    });
    expect(boss.isBoss, isTrue);
    final trash = CampaignNode.fromJson({
      'id': 'node_01',
      'name': 'A',
      'enemyId': 'goblin',
      'coinReward': 35,
      'order': 0,
    });
    expect(trash.isBoss, isFalse);
  });
}
