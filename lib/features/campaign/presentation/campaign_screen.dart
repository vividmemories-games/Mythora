import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/assets/game_assets.dart';
import '../../../core/theme/app_theme.dart';
import '../../battle/domain/enemy_def.dart';
import '../../prep/presentation/prep_picker_sheet.dart';
import '../../profile/providers/mock_profile_provider.dart';
import '../data/campaign_repository.dart';
import '../domain/campaign_models.dart';

/// Vertical chapter map (M4): the map art owns the screen and nodes are
/// pins placed along the painted path. Starts scrolled at the first node
/// (bottom) and winds up toward the boss.
class CampaignScreen extends ConsumerWidget {
  const CampaignScreen({super.key});

  /// map_ch_twilight_road.png is 768×2048.
  static const _mapAspect = 768 / 2048;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chapterAsync = ref.watch(campaignChapterProvider);
    final profile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: MythoraColors.ink,
      body: chapterAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load campaign: $e')),
        data: (chapter) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final mapWidth = constraints.maxWidth;
              final mapHeight = mapWidth / _mapAspect;

              return Stack(
                children: [
                  // reverse: true starts at the bottom, where node 1 lives.
                  SingleChildScrollView(
                    reverse: true,
                    child: SizedBox(
                      width: mapWidth,
                      height: mapHeight,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.asset(
                              GameAssets.mapTwilightRoad,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  const ColoredBox(color: MythoraColors.ink),
                            ),
                          ),
                          for (final node in chapter.nodes)
                            _positionPin(
                              context: context,
                              chapter: chapter,
                              node: node,
                              profile: profile,
                              mapWidth: mapWidth,
                              mapHeight: mapHeight,
                            ),
                        ],
                      ),
                    ),
                  ),
                  _MapHeader(chapter: chapter),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _positionPin({
    required BuildContext context,
    required CampaignChapter chapter,
    required CampaignNode node,
    required PlayerProfile profile,
    required double mapWidth,
    required double mapHeight,
  }) {
    final completed = chapter.isCompleted(node.id, profile.completedNodeIds);
    final unlocked = chapter.isUnlocked(node.id, profile.completedNodeIds);
    final isCurrent = unlocked && !completed;

    final (x, y) = _pinAnchor(chapter, node);
    const pinSize = 72.0;
    // Fixed-width slot keeps the circle centered on the anchor even when
    // the name label below is wider than the pin.
    const slotWidth = 160.0;
    return Positioned(
      left: x * mapWidth - slotWidth / 2,
      top: y * mapHeight - pinSize / 2,
      width: slotWidth,
      child: _NodePin(
        node: node,
        completed: completed,
        unlocked: unlocked,
        isCurrent: isCurrent,
        size: pinSize,
        onTap: unlocked ? () => _openNode(context, node) : null,
      ),
    );
  }

  /// Authored coords when present; otherwise evenly spaced slots up the map
  /// so chapters without positions still render.
  (double, double) _pinAnchor(CampaignChapter chapter, CampaignNode node) {
    final x = node.mapX;
    final y = node.mapY;
    if (x != null && y != null) return (x, y);
    final count = chapter.nodes.length;
    final t = count <= 1 ? 0.5 : node.order / (count - 1);
    // Bottom (0.9) → top (0.15), alternating gently around center.
    return (node.order.isEven ? 0.44 : 0.56, 0.9 - 0.75 * t);
  }

  Future<void> _openNode(BuildContext context, CampaignNode node) async {
    if (node.isBoss) {
      final enemy = EnemyCatalog.byId(node.enemyId);
      final ok = await showPrepPickerSheet(
        context,
        bossName: enemy.name,
      );
      if (!ok || !context.mounted) return;
    }
    if (!context.mounted) return;
    context.push('/battle/${node.id}');
  }
}

/// Slim translucent header: back button + chapter title.
class _MapHeader extends StatelessWidget {
  const _MapHeader({required this.chapter});

  final CampaignChapter chapter;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
        child: Row(
          children: [
            Material(
              color: MythoraColors.ink.withValues(alpha: 0.55),
              shape: CircleBorder(
                side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => context.pop(),
                child: const SizedBox(
                  width: 38,
                  height: 38,
                  child: Icon(
                    Icons.arrow_back,
                    size: 20,
                    color: MythoraColors.parchment,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: MythoraColors.ink.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: MythoraColors.softGold.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                chapter.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: MythoraColors.parchment,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NodePin extends StatelessWidget {
  const _NodePin({
    required this.node,
    required this.completed,
    required this.unlocked,
    required this.isCurrent,
    required this.size,
    required this.onTap,
  });

  final CampaignNode node;
  final bool completed;
  final bool unlocked;
  final bool isCurrent;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ringColor = completed
        ? MythoraColors.amber
        : isCurrent
            ? MythoraColors.softGold
            : MythoraColors.muted.withValues(alpha: 0.5);

    Widget portrait = ClipOval(
      child: Image.asset(
        GameAssets.enemy(node.enemyId),
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
        errorBuilder: (_, __, ___) => const ColoredBox(
          color: MythoraColors.deepTeal,
          child: Icon(Icons.flag, color: MythoraColors.parchment),
        ),
      ),
    );

    if (!unlocked) {
      // Desaturate locked encounters.
      portrait = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.2126, 0.7152, 0.0722, 0, 0, //
          0.2126, 0.7152, 0.0722, 0, 0, //
          0.2126, 0.7152, 0.0722, 0, 0, //
          0, 0, 0, 0.7, 0, //
        ]),
        child: portrait,
      );
    }

    final scale = node.isBoss ? 1.2 : 1.0;

    final pin = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _PulseRing(
          enabled: isCurrent,
          child: Container(
            width: size * scale,
            height: size * scale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MythoraColors.ink.withValues(alpha: 0.6),
              border: Border.all(
                color: ringColor,
                width: isCurrent ? 3 : 2,
              ),
              boxShadow: [
                if (isCurrent)
                  BoxShadow(
                    color: MythoraColors.softGold.withValues(alpha: 0.55),
                    blurRadius: 16,
                    spreadRadius: 1,
                  )
                else
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.5),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),
            padding: const EdgeInsets.all(3),
            child: Stack(
              fit: StackFit.expand,
              children: [
                portrait,
                if (!unlocked)
                  const Center(
                    child: Icon(
                      Icons.lock,
                      size: 20,
                      color: MythoraColors.parchment,
                    ),
                  ),
                if (completed)
                  const Positioned(
                    right: 0,
                    bottom: 0,
                    child: Icon(
                      Icons.check_circle,
                      size: 20,
                      color: MythoraColors.amber,
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: MythoraColors.ink.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: ringColor.withValues(alpha: 0.5),
            ),
          ),
          child: Text(
            '${node.order + 1}. ${node.name}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontSize: 11,
                  color:
                      unlocked ? MythoraColors.parchment : MythoraColors.muted,
                ),
          ),
        ),
      ],
    );

    return GestureDetector(onTap: onTap, child: pin);
  }
}

/// Gentle looping pulse to mark the current node.
class _PulseRing extends StatefulWidget {
  const _PulseRing({required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    if (widget.enabled) _controller.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(covariant _PulseRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = Curves.easeInOut.transform(_controller.value);
        return Transform.scale(scale: 1.0 + 0.06 * t, child: child);
      },
      child: widget.child,
    );
  }
}
