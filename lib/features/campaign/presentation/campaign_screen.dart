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

/// Chapter campaign: one act map at a time (5 pins), with act dots to switch.
class CampaignScreen extends ConsumerStatefulWidget {
  const CampaignScreen({super.key});

  @override
  ConsumerState<CampaignScreen> createState() => _CampaignScreenState();
}

class _CampaignScreenState extends ConsumerState<CampaignScreen> {
  /// Portrait act maps are 1024×1536.
  static const _mapAspect = 1024 / 1536;

  String? _selectedActId;

  @override
  Widget build(BuildContext context) {
    final chapterAsync = ref.watch(campaignChapterProvider);
    final profile = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: MythoraColors.ink,
      body: chapterAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load campaign: $e')),
        data: (chapter) {
          final current = chapter.currentAct(profile.completedNodeIds);
          final selectedId = _selectedActId ?? current.id;
          final act = chapter.acts.any((a) => a.id == selectedId)
              ? chapter.actById(selectedId)
              : current;

          return LayoutBuilder(
            builder: (context, constraints) {
              final mapWidth = constraints.maxWidth;
              // Fill the phone at minimum so the path never sits above a
              // black void. Taller than the screen → scrollable strip.
              final naturalHeight = mapWidth / _mapAspect;
              final mapHeight = naturalHeight < constraints.maxHeight
                  ? constraints.maxHeight
                  : naturalHeight;
              final frontier = chapter.frontierOrder(profile.completedNodeIds);
              final actDone =
                  chapter.isActCompleted(act, profile.completedNodeIds);
              final fogTopY = actDone ? 0.0 : _fogStartY(act, frontier);

              final mapLayer = SizedBox(
                width: mapWidth,
                height: mapHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Positioned.fill(
                      child: Image.asset(
                        act.mapAsset,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                        errorBuilder: (_, __, ___) =>
                            const ColoredBox(color: MythoraColors.ink),
                      ),
                    ),
                    if (fogTopY > 0)
                      Positioned(
                        left: 0,
                        right: 0,
                        top: 0,
                        height: fogTopY * mapHeight,
                        child: const IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Color(0x000B1C24),
                                  Color(0x990B1C24),
                                  Color(0xCC0B1C24),
                                ],
                                stops: [0.0, 0.35, 1.0],
                              ),
                            ),
                          ),
                        ),
                      ),
                    for (final node in act.nodes)
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
              );

              return Stack(
                fit: StackFit.expand,
                children: [
                  if (mapHeight <= constraints.maxHeight + 0.5)
                    mapLayer
                  else
                    SingleChildScrollView(
                      reverse: true,
                      child: mapLayer,
                    ),
                  _MapHeader(
                    chapter: chapter,
                    act: act,
                    acts: chapter.acts,
                    completed: profile.completedNodeIds,
                    onSelectAct: (id) {
                      final next = chapter.actById(id);
                      if (!chapter.isActUnlocked(
                          next, profile.completedNodeIds)) {
                        return;
                      }
                      setState(() => _selectedActId = id);
                    },
                  ),
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
    final fog = chapter.fogTier(node, profile.completedNodeIds);

    final (x, y) = _pinAnchor(actNodeCount: 5, node: node);
    const pinSize = 64.0;
    const slotWidth = 150.0;
    return Positioned(
      left: x * mapWidth - slotWidth / 2,
      top: y * mapHeight - pinSize / 2,
      width: slotWidth,
      child: _NodePin(
        node: node,
        completed: completed,
        unlocked: unlocked,
        isCurrent: isCurrent,
        fog: fog,
        size: pinSize,
        onTap: unlocked ? () => _openNode(context, node) : null,
      ),
    );
  }

  /// Fog blanket starts just above the N+1 pin (or current if no peek).
  double _fogStartY(CampaignAct act, int frontierOrder) {
    final peekOrder = frontierOrder + 1;
    CampaignNode? anchor;
    for (final n in act.nodes) {
      if (n.order == peekOrder) {
        anchor = n;
        break;
      }
    }
    if (anchor == null) {
      for (final n in act.nodes) {
        if (n.order == frontierOrder) {
          anchor = n;
          break;
        }
      }
    }
    anchor ??= act.nodes.isEmpty ? null : act.nodes.first;
    if (anchor == null) return 0.45;
    final y = anchor.mapY ?? 0.5;
    // Cover everything above the peek pin (smaller y = higher on map).
    return (y - 0.06).clamp(0.0, 1.0);
  }

  (double, double) _pinAnchor({
    required int actNodeCount,
    required CampaignNode node,
  }) {
    final x = node.mapX;
    final y = node.mapY;
    if (x != null && y != null) return (x, y);
    final local = node.order % actNodeCount;
    final t = actNodeCount <= 1 ? 0.5 : local / (actNodeCount - 1);
    return (local.isEven ? 0.44 : 0.56, 0.88 - 0.70 * t);
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

class _MapHeader extends StatelessWidget {
  const _MapHeader({
    required this.chapter,
    required this.act,
    required this.acts,
    required this.completed,
    required this.onSelectAct,
  });

  final CampaignChapter chapter;
  final CampaignAct act;
  final List<CampaignAct> acts;
  final Set<String> completed;
  final ValueChanged<String> onSelectAct;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Material(
                  color: MythoraColors.ink.withValues(alpha: 0.55),
                  shape: CircleBorder(
                    side:
                        BorderSide(color: Colors.white.withValues(alpha: 0.12)),
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
                Flexible(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: MythoraColors.ink.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: MythoraColors.softGold.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      '${chapter.title} · ${act.title}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: MythoraColors.parchment,
                          ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final a in acts) ...[
                  if (a.index > 0) const SizedBox(width: 8),
                  _ActDot(
                    act: a,
                    selected: a.id == act.id,
                    unlocked: chapter.isActUnlocked(a, completed),
                    completed: chapter.isActCompleted(a, completed),
                    onTap: () => onSelectAct(a.id),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActDot extends StatelessWidget {
  const _ActDot({
    required this.act,
    required this.selected,
    required this.unlocked,
    required this.completed,
    required this.onTap,
  });

  final CampaignAct act;
  final bool selected;
  final bool unlocked;
  final bool completed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = switch (act.index) {
      0 => 'I',
      1 => 'II',
      2 => 'III',
      _ => 'IV',
    };
    final border = selected
        ? MythoraColors.softGold
        : completed
            ? MythoraColors.amber
            : MythoraColors.muted.withValues(alpha: 0.45);
    return Material(
      color: MythoraColors.ink.withValues(alpha: unlocked ? 0.65 : 0.35),
      shape: StadiumBorder(
          side: BorderSide(color: border, width: selected ? 2 : 1)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: unlocked ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color:
                      unlocked ? MythoraColors.parchment : MythoraColors.muted,
                ),
              ),
              if (!unlocked) ...[
                const SizedBox(width: 4),
                const Icon(Icons.lock, size: 12, color: MythoraColors.muted),
              ] else if (completed) ...[
                const SizedBox(width: 4),
                const Icon(Icons.check, size: 12, color: MythoraColors.amber),
              ],
            ],
          ),
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
    required this.fog,
    required this.size,
    required this.onTap,
  });

  final CampaignNode node;
  final bool completed;
  final bool unlocked;
  final bool isCurrent;
  final MapFogTier fog;
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

    if (!unlocked || fog != MapFogTier.clear) {
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

    final scale = node.isBoss ? 1.15 : 1.0;
    final opacity = switch (fog) {
      MapFogTier.clear => 1.0,
      MapFogTier.peek => 0.72,
      MapFogTier.shrouded => 0.22,
    };
    final showLabel = fog != MapFogTier.shrouded;
    final showLock = !unlocked && fog == MapFogTier.clear;

    final pin = Opacity(
      opacity: opacity,
      child: Column(
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
                  color: ringColor.withValues(
                    alpha: fog == MapFogTier.shrouded ? 0.35 : 1,
                  ),
                  width: isCurrent ? 3 : 2,
                ),
                boxShadow: [
                  if (isCurrent)
                    BoxShadow(
                      color: MythoraColors.softGold.withValues(alpha: 0.55),
                      blurRadius: 16,
                      spreadRadius: 1,
                    )
                  else if (fog != MapFogTier.shrouded)
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
                  if (showLock)
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
          if (showLabel) ...[
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
                node.isBoss
                    ? '${node.order + 1}. Boss'
                    : fog == MapFogTier.peek
                        ? '${node.order + 1}. ???'
                        : '${node.order + 1}. ${node.name}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 10,
                      color: unlocked
                          ? MythoraColors.parchment
                          : MythoraColors.muted,
                    ),
              ),
            ),
          ],
        ],
      ),
    );

    return IgnorePointer(
      ignoring: fog == MapFogTier.shrouded || !unlocked,
      child: GestureDetector(onTap: onTap, child: pin),
    );
  }
}

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
