class CampaignNode {
  const CampaignNode({
    required this.id,
    required this.name,
    required this.enemyId,
    required this.coinReward,
    required this.order,
  });

  final String id;
  final String name;
  final String enemyId;
  final int coinReward;
  final int order;

  factory CampaignNode.fromJson(Map<String, dynamic> json) {
    return CampaignNode(
      id: json['id'] as String,
      name: json['name'] as String,
      enemyId: json['enemyId'] as String,
      coinReward: json['coinReward'] as int,
      order: json['order'] as int,
    );
  }
}

class CampaignChapter {
  const CampaignChapter({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.nodes,
  });

  final String id;
  final String title;
  final String subtitle;
  final List<CampaignNode> nodes;

  factory CampaignChapter.fromJson(Map<String, dynamic> json) {
    final rawNodes = json['nodes'] as List<dynamic>;
    final nodes = rawNodes
        .map((e) => CampaignNode.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return CampaignChapter(
      id: json['id'] as String,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String? ?? '',
      nodes: nodes,
    );
  }

  CampaignNode nodeById(String id) =>
      nodes.firstWhere((n) => n.id == id, orElse: () => nodes.first);

  bool isUnlocked(String nodeId, Set<String> completedNodeIds) {
    final node = nodeById(nodeId);
    if (node.order == 0) return true;
    final prev = nodes.where((n) => n.order == node.order - 1);
    if (prev.isEmpty) return true;
    return completedNodeIds.contains(prev.first.id);
  }

  bool isCompleted(String nodeId, Set<String> completedNodeIds) =>
      completedNodeIds.contains(nodeId);
}
