import 'dart:math' as math;

import 'package:fi_you/core/ui/fi_you_glass.dart';
import 'package:fi_you/data/fi_you_repository.dart';
import 'package:fi_you/mock/fi_you_mock_data.dart';
import 'package:flutter/material.dart';

typedef UMapScreen = FiYouUMapScreen;

class GalaxyParentNode {
  const GalaxyParentNode({
    required this.id,
    required this.label,
    required this.score,
    required this.children,
    required this.color,
    required this.icon,
  });

  final String id;
  final String label;
  final double score;
  final List<GalaxyChildNode> children;
  final Color color;
  final IconData icon;
}

class GalaxyChildNode {
  const GalaxyChildNode({
    required this.id,
    required this.label,
    required this.score,
    required this.insight,
    this.evidence = const [],
    this.relatedNodeIds = const [],
  });

  final String id;
  final String label;
  final double score;
  final String insight;
  final List<String> evidence;
  final List<String> relatedNodeIds;
}

class FiYouUMapScreen extends StatefulWidget {
  const FiYouUMapScreen({
    super.key,
    this.isEmpty = false,
    this.onStartQuestion,
    this.onShare,
    this.onOpenGrowthMap,
    this.onOpenRelationMap,
    this.onOpenReport,
    this.bottomPadding = 0,
  });

  final bool isEmpty;
  final VoidCallback? onStartQuestion;
  final VoidCallback? onShare;
  final VoidCallback? onOpenGrowthMap;
  final VoidCallback? onOpenRelationMap;
  final VoidCallback? onOpenReport;
  final double bottomPadding;

  @override
  State<FiYouUMapScreen> createState() => _FiYouUMapScreenState();
}

class _FiYouUMapScreenState extends State<FiYouUMapScreen> {
  String? _selectedParentId;
  String? _selectedChildId;
  double _rotationX = -0.18;
  double _rotationY = 0.18;

  void _rotate(DragUpdateDetails details) {
    setState(() {
      _rotationY += details.delta.dx * 0.012;
      _rotationX = (_rotationX - details.delta.dy * 0.01)
          .clamp(-0.72, 0.72)
          .toDouble();
    });
  }

  void _selectParent(GalaxyParentNode parent) {
    setState(() {
      _selectedParentId = parent.id;
      _selectedChildId = parent.children.isEmpty
          ? null
          : parent.children.first.id;
    });
  }

  void _selectChild(GalaxyChildNode child) {
    setState(() => _selectedChildId = child.id);
  }

  void _resetGalaxy() {
    setState(() {
      _selectedParentId = null;
      _selectedChildId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final repository = FiYouRepositoryScope.of(context);
    final parents = _GalaxyData.fromRepository(repository);
    final selectedParent = _selectedParentId == null
        ? null
        : parents.firstWhere(
            (node) => node.id == _selectedParentId,
            orElse: () => parents.first,
          );
    GalaxyChildNode? selectedChild;
    if (selectedParent != null && selectedParent.children.isNotEmpty) {
      selectedChild = selectedParent.children.firstWhere(
        (node) => node.id == _selectedChildId,
        orElse: () => selectedParent.children.first,
      );
    }
    final radarAxes = _RadarAxis.fromContext(
      parents: parents,
      selectedParent: selectedParent,
      selectedChild: selectedChild,
      relatedNodes: selectedChild == null
          ? const []
          : _relatedNodes(parents, selectedChild),
    );
    final bottomSpace = math.max(widget.bottomPadding, 24.0);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 18, 20, bottomSpace + 132),
              sliver: SliverList(
                delegate: SliverChildListDelegate.fixed([
                  const _Header(),
                  const SizedBox(height: 18),
                  if (widget.isEmpty)
                    _EmptyState(onStartQuestion: widget.onStartQuestion)
                  else ...[
                    _GalaxyPanel(
                      parents: parents,
                      selectedParent: selectedParent,
                      selectedChildId: selectedChild?.id,
                      rotationX: _rotationX,
                      rotationY: _rotationY,
                      onRotate: _rotate,
                      onParentTap: _selectParent,
                      onChildTap: _selectChild,
                      onRootTap: selectedParent == null ? null : _resetGalaxy,
                      onShare: widget.onShare,
                    ),
                    const SizedBox(height: 14),
                    _AnalysisPanel(
                      parent: selectedParent,
                      child: selectedChild,
                      relatedNodes: selectedChild == null
                          ? const []
                          : _relatedNodes(parents, selectedChild),
                    ),
                    if (selectedParent != null) ...[
                      const SizedBox(height: 14),
                      _RadarSummaryPanel(axes: radarAxes),
                    ],
                    if (selectedParent == null) ...[
                      const SizedBox(height: 12),
                      _PremiumExtensionSection(
                        onOpenGrowthMap: widget.onOpenGrowthMap,
                        onOpenRelationMap: widget.onOpenRelationMap,
                        onOpenReport: widget.onOpenReport,
                      ),
                    ],
                    const SizedBox(height: 14),
                    _QuestionCta(onStartQuestion: widget.onStartQuestion),
                  ],
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<GalaxyChildNode> _relatedNodes(
    List<GalaxyParentNode> parents,
    GalaxyChildNode selected,
  ) {
    final allChildren = parents.expand((parent) => parent.children).toList();
    final explicit = allChildren
        .where((child) => selected.relatedNodeIds.contains(child.id))
        .toList();
    if (explicit.isNotEmpty) {
      return explicit.take(3).toList();
    }
    return allChildren.where((child) => child.id != selected.id).toList()..sort(
      (a, b) => (a.score - selected.score).abs().compareTo(
        (b.score - selected.score).abs(),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.bubble_chart_outlined,
              color: _UMapColors.cyan,
              size: 24,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'U-Map',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  height: 1.15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        Text(
          'Update : 2026.06.22',
          style: TextStyle(
            color: _UMapColors.textMuted,
            fontSize: 11.2,
            height: 1.2,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _GalaxyPanel extends StatefulWidget {
  const _GalaxyPanel({
    required this.parents,
    required this.selectedParent,
    required this.selectedChildId,
    required this.rotationX,
    required this.rotationY,
    required this.onRotate,
    required this.onParentTap,
    required this.onChildTap,
    required this.onRootTap,
    this.onShare,
  });

  final List<GalaxyParentNode> parents;
  final GalaxyParentNode? selectedParent;
  final String? selectedChildId;
  final double rotationX;
  final double rotationY;
  final GestureDragUpdateCallback onRotate;
  final ValueChanged<GalaxyParentNode> onParentTap;
  final ValueChanged<GalaxyChildNode> onChildTap;
  final VoidCallback? onRootTap;
  final VoidCallback? onShare;

  @override
  State<_GalaxyPanel> createState() => _GalaxyPanelState();
}

class _GalaxyPanelState extends State<_GalaxyPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _twinkleController;

  @override
  void initState() {
    super.initState();
    _twinkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4600),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _twinkleController.stop();
    } else if (!_twinkleController.isAnimating) {
      _twinkleController.repeat();
    }
  }

  @override
  void dispose() {
    _twinkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    return _GlassPanel(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  '나를 중심으로 연결된 현재의 우주',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              FiYouLiquidIconButton(
                icon: const Icon(Icons.ios_share_rounded),
                label: '공유',
                onPressed: widget.onShare,
                size: 36,
                radius: 18,
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 360,
            width: double.infinity,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final projection = _GalaxyProjection(
                  size: constraints.biggest,
                  rotationX: widget.rotationX,
                  rotationY: widget.rotationY,
                  parents: widget.parents,
                  selectedParent: widget.selectedParent,
                );
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: widget.onRotate,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _twinkleController,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: _GalaxyPainter(
                                projection: projection,
                                phase: disableAnimations
                                    ? 0
                                    : _twinkleController.value,
                              ),
                            );
                          },
                        ),
                      ),
                      ...projection.parentPoints.map(
                        (point) => _ProjectedNodeButton(
                          point: point,
                          selected: point.id == widget.selectedParent?.id,
                          label: point.label,
                          icon: point.icon,
                          color: point.color,
                          onTap: () => widget.onParentTap(point.parent!),
                        ),
                      ),
                      ...projection.childPoints.map(
                        (point) => _ProjectedNodeButton(
                          point: point,
                          selected: point.id == widget.selectedChildId,
                          label: point.label,
                          color: point.color,
                          small: true,
                          onTap: () => widget.onChildTap(point.child!),
                        ),
                      ),
                      Positioned(
                        left:
                            projection.root.dx - projection.coreSize.width / 2,
                        top:
                            projection.root.dy - projection.coreSize.height / 2,
                        child: _CoreNode(
                          parent: widget.selectedParent,
                          onTap: widget.onRootTap,
                          size: projection.coreSize,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          if (widget.selectedParent == null)
            const _GalaxyHint()
          else ...[
            _BackHint(color: widget.selectedParent!.color),
            const SizedBox(height: 10),
            _ChildRail(
              parent: widget.selectedParent!,
              selectedChildId: widget.selectedChildId,
              onSelected: widget.onChildTap,
            ),
          ],
        ],
      ),
    );
  }
}

class _ProjectedNodeButton extends StatelessWidget {
  const _ProjectedNodeButton({
    required this.point,
    required this.selected,
    required this.label,
    required this.color,
    required this.onTap,
    this.icon,
    this.small = false,
  });

  final _ProjectedNode point;
  final bool selected;
  final String label;
  final Color color;
  final IconData? icon;
  final VoidCallback onTap;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final width = (small ? 82.0 : 96.0) * point.scale;
    final height = (small ? 46.0 : 58.0) * point.scale;
    final opacity = selected
        ? 1.0
        : (0.42 + point.depth * 0.42).clamp(0.34, 0.86).toDouble();
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      left: point.offset.dx - width / 2,
      top: point.offset.dy - height / 2,
      width: width,
      height: height,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: opacity,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: Size(width * 0.96, height * 1.08),
                    painter: _NodeAuraPainter(color: color, selected: selected),
                  ),
                  AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: selected ? 1.08 : 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon ?? Icons.auto_awesome_rounded,
                          color: selected ? Colors.white : color,
                          size: (small ? 15 : 19) * point.scale,
                          shadows: [
                            Shadow(
                              color: color.withValues(
                                alpha: selected ? 0.64 : 0.24,
                              ),
                              blurRadius: selected ? 13 : 5,
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Flexible(
                          child: Text(
                            label,
                            maxLines: small ? 2 : 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: (small ? 10.6 : 11.6) * point.scale,
                              height: 1.05,
                              fontWeight: FontWeight.w900,
                              shadows: [
                                Shadow(
                                  color: color.withValues(
                                    alpha: selected ? 0.64 : 0.28,
                                  ),
                                  blurRadius: selected ? 11 : 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (selected) ...[
                          const SizedBox(height: 3),
                          Container(
                            width: 22 * point.scale,
                            height: 2,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.82),
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.46),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NodeAuraPainter extends CustomPainter {
  const _NodeAuraPainter({required this.color, required this.selected});

  final Color color;
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCenter(
      center: center,
      width: size.width,
      height: size.height,
    );
    canvas.drawOval(
      rect,
      Paint()
        ..blendMode = BlendMode.screen
        ..shader = RadialGradient(
          colors: [
            color.withValues(alpha: selected ? 0.2 : 0.105),
            color.withValues(alpha: selected ? 0.085 : 0.04),
            Colors.transparent,
          ],
          stops: const [0, 0.46, 1],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _NodeAuraPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.selected != selected;
  }
}

class _CoreNode extends StatelessWidget {
  const _CoreNode({required this.size, this.parent, this.onTap});

  final Size size;
  final GalaxyParentNode? parent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final parent = this.parent;
    return Tooltip(
      message: onTap == null ? 'U-Map Root' : '큰 영역으로 돌아가기',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: parent == null
              ? const Center(
                  child: SizedBox(
                    width: 42,
                    height: 42,
                    child: CustomPaint(painter: _CoreStarPainter()),
                  ),
                )
              : _SelectedParentCore(parent: parent),
        ),
      ),
    );
  }
}

class _SelectedParentCore extends StatelessWidget {
  const _SelectedParentCore({required this.parent});

  final GalaxyParentNode parent;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            parent.icon,
            color: Colors.white,
            size: 28,
            shadows: [
              Shadow(
                color: parent.color.withValues(alpha: 0.9),
                blurRadius: 18,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            parent.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.1,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(
                  color: parent.color.withValues(alpha: 0.9),
                  blurRadius: 16,
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: 34,
            height: 2,
            decoration: BoxDecoration(
              color: parent.color,
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: parent.color.withValues(alpha: 0.9),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CoreStarPainter extends CustomPainter {
  const _CoreStarPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final glow = Paint()
      ..blendMode = BlendMode.screen
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.86),
          _UMapColors.gold.withValues(alpha: 0.34),
          _UMapColors.primarySoft.withValues(alpha: 0.13),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: size.width / 2));
    canvas.drawCircle(center, size.width / 2, glow);

    final rayPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.78)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.8);
    canvas.drawLine(
      center.translate(-15, 0),
      center.translate(15, 0),
      rayPaint,
    );
    canvas.drawLine(
      center.translate(0, -15),
      center.translate(0, 15),
      rayPaint,
    );

    final core = Path()
      ..moveTo(center.dx, center.dy - 9)
      ..quadraticBezierTo(
        center.dx + 2.8,
        center.dy - 2.8,
        center.dx + 9,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx + 2.8,
        center.dy + 2.8,
        center.dx,
        center.dy + 9,
      )
      ..quadraticBezierTo(
        center.dx - 2.8,
        center.dy + 2.8,
        center.dx - 9,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx - 2.8,
        center.dy - 2.8,
        center.dx,
        center.dy - 9,
      )
      ..close();
    canvas.drawPath(core, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _CoreStarPainter oldDelegate) => false;
}

class _ChildRail extends StatelessWidget {
  const _ChildRail({
    required this.parent,
    required this.selectedChildId,
    required this.onSelected,
  });

  final GalaxyParentNode parent;
  final String? selectedChildId;
  final ValueChanged<GalaxyChildNode> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: parent.children.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final child = parent.children[index];
          final selected = child.id == selectedChildId;
          return _PillButton(
            label: child.label,
            color: parent.color,
            selected: selected,
            onTap: () => onSelected(child),
          );
        },
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.16)
                : Colors.white.withValues(alpha: 0.045),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected
                  ? color.withValues(alpha: 0.72)
                  : Colors.white.withValues(alpha: 0.15),
            ),
          ),
          child: Center(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: selected ? Colors.white : _UMapColors.textSoft,
                fontSize: 12.2,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GalaxyHint extends StatelessWidget {
  const _GalaxyHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: FiYouGlass.ctaGlassV5(
        radius: FiYouGlass.glassRadiusSmall,
        borderColor: _UMapColors.cyan,
      ),
      child: const Row(
        children: [
          Icon(Icons.touch_app_rounded, color: _UMapColors.cyan, size: 18),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              '큰 영역을 선택하면 작은 성향 신호가 열려요.',
              style: TextStyle(
                color: _UMapColors.textSoft,
                fontSize: 12.4,
                height: 1.3,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackHint extends StatelessWidget {
  const _BackHint({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: FiYouGlass.ctaGlassV5(
        radius: FiYouGlass.glassRadiusSmall,
        borderColor: color,
      ),
      child: Row(
        children: [
          Icon(Icons.keyboard_return_rounded, color: color, size: 18),
          const SizedBox(width: 9),
          const Expanded(
            child: Text(
              '뒤로가기 = 코어 탭',
              style: TextStyle(
                color: _UMapColors.textSoft,
                fontSize: 12.4,
                height: 1.3,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisPanel extends StatelessWidget {
  const _AnalysisPanel({
    required this.parent,
    required this.child,
    required this.relatedNodes,
  });

  final GalaxyParentNode? parent;
  final GalaxyChildNode? child;
  final List<GalaxyChildNode> relatedNodes;

  @override
  Widget build(BuildContext context) {
    final parent = this.parent;
    final child = this.child;
    if (parent == null || child == null) {
      return const _OverviewAnalysisPanel();
    }

    return _GlassPanel(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(parent.icon, color: parent.color, size: 22),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  '${parent.label} · ${child.label}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                child.score.round().toString(),
                style: TextStyle(
                  color: parent.color,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            child.insight,
            style: const TextStyle(
              color: _UMapColors.textSoft,
              fontSize: 13.3,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const _SectionLabel('연결 노드'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final related in relatedNodes.take(3))
                _MiniChip(label: related.label, color: parent.color),
            ],
          ),
          const SizedBox(height: 14),
          _GrowthHint(color: parent.color, label: child.label),
        ],
      ),
    );
  }
}

class _OverviewAnalysisPanel extends StatelessWidget {
  const _OverviewAnalysisPanel();

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Row(
            children: [
              Icon(
                Icons.bubble_chart_outlined,
                color: _UMapColors.cyan,
                size: 22,
              ),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'U-Map Root · 나',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(
            '현재 지도는 10개의 큰 영역으로 시작해요. 하나를 선택하면 기록에서 이어진 작은 성향 신호가 열리고, 선택한 영역 안에서 User의 흐름이 표시됩니다.',
            style: TextStyle(
              color: _UMapColors.textSoft,
              fontSize: 13.3,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: _UMapColors.cyan,
        fontSize: 12.5,
        height: 1,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.8,
          height: 1,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _GrowthHint extends StatelessWidget {
  const _GrowthHint({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: FiYouGlass.ctaGlassV5(
        radius: FiYouGlass.glassRadiusSmall,
        borderColor: color,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.north_east_rounded, color: color, size: 18),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              '$label 흐름이 잘 드러나는 순간을 한 문장으로 남기면 다음 U-Map이 더 섬세해질 수 있어요.',
              style: const TextStyle(
                color: _UMapColors.textSoft,
                fontSize: 12.2,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarSummaryPanel extends StatelessWidget {
  const _RadarSummaryPanel({required this.axes});

  final List<_RadarAxis> axes;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '요약 레이더',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              height: 1.2,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            '작은 성향 신호의 흐름을 모아 만든 보조 지도예요.',
            style: TextStyle(
              color: _UMapColors.textMuted,
              fontSize: 12.2,
              height: 1.35,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 250,
            width: double.infinity,
            child: CustomPaint(painter: _UMapRadarPainter(axes)),
          ),
        ],
      ),
    );
  }
}

class _PremiumExtensionSection extends StatelessWidget {
  const _PremiumExtensionSection({
    this.onOpenGrowthMap,
    this.onOpenRelationMap,
    this.onOpenReport,
  });

  final VoidCallback? onOpenGrowthMap;
  final VoidCallback? onOpenRelationMap;
  final VoidCallback? onOpenReport;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ActionTile(
          title: 'Journy',
          subtitle: '성장 흐름의 단서를 조금 더 깊게 열어봐요.',
          icon: Icons.trending_up_rounded,
          color: _UMapColors.gold,
          starCost: 30,
          onTap: onOpenGrowthMap,
        ),
        const SizedBox(height: 10),
        _ActionTile(
          title: 'Relation Map',
          subtitle: '관계 안에서 반복되는 흐름의 단서를 살펴봐요.',
          icon: Icons.people_alt_rounded,
          color: _UMapColors.cyan,
          starCost: 30,
          onTap: onOpenRelationMap,
        ),
        const SizedBox(height: 10),
        _ActionTile(
          title: '상세 리포트',
          subtitle: 'U-Map의 노드와 기록 근거를 리포트로 정리해요.',
          icon: Icons.article_outlined,
          color: _UMapColors.emerald,
          starCost: 50,
          onTap: onOpenReport,
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.starCost,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final int starCost;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FiYouGlassSurface(
      padding: const EdgeInsets.all(15),
      radius: FiYouGlass.glassRadiusSmall,
      borderColor: color,
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _UMapColors.textMuted,
                    fontSize: 12.2,
                    height: 1.32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _StarUseButton(label: title, cost: starCost),
        ],
      ),
    );
  }
}

class _StarUseButton extends StatelessWidget {
  const _StarUseButton({required this.label, required this.cost});

  final String label;
  final int cost;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: '$label Star 소비',
      child: FiYouLiquidButton(
        label: '$cost Star',
        icon: const Icon(Icons.star_rounded),
        onPressed: () {},
        width: 92,
        height: 34,
        radius: 999,
        fontSize: 11.5,
        foregroundColor: _UMapColors.gold,
        borderColor: _UMapColors.gold,
        borderWidth: 1.15,
        accentColor: _UMapColors.gold,
        accentStrength: 0.38,
        iconSize: 14,
        horizontalPadding: 10,
      ),
    );
  }
}

class _QuestionCta extends StatelessWidget {
  const _QuestionCta({this.onStartQuestion});

  final VoidCallback? onStartQuestion;

  @override
  Widget build(BuildContext context) {
    return FiYouLiquidButton(
      label: '탐구 시작하기',
      icon: const Icon(Icons.auto_awesome_rounded),
      onPressed: onStartQuestion,
      height: FiYouControlTokens.buttonRegularHeight,
      fontSize: FiYouControlTokens.buttonRegularFont,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.onStartQuestion});

  final VoidCallback? onStartQuestion;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '아직 우주를 그릴 단서가 부족해요.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            '질문과 Diary 기록이 쌓이면 작은 성향 신호가 생기고, 그 신호들이 U-Map으로 연결돼요.',
            style: TextStyle(
              color: _UMapColors.textSoft,
              fontSize: 13.5,
              height: 1.45,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          _QuestionCta(onStartQuestion: onStartQuestion),
        ],
      ),
    );
  }
}

class _GlassPanel extends StatefulWidget {
  const _GlassPanel({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  State<_GlassPanel> createState() => _GlassPanelState();
}

class _GlassPanelState extends State<_GlassPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    return FiYouGlassSurface(
      padding: EdgeInsets.zero,
      borderColor: _UMapColors.radarStroke,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _UMapCardStarfieldPainter(
                phase: disableAnimations ? 0 : _controller.value,
              ),
            ),
          ),
          if (!disableAnimations)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _UMapCardStarfieldPainter(
                      phase: _controller.value,
                      twinkleOnly: true,
                    ),
                  );
                },
              ),
            ),
          Padding(
            padding: widget.padding ?? const EdgeInsets.all(18),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}

class _UMapCardStarfieldPainter extends CustomPainter {
  const _UMapCardStarfieldPainter({
    required this.phase,
    this.twinkleOnly = false,
  });

  final double phase;
  final bool twinkleOnly;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    if (!twinkleOnly) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.28, -0.34),
            radius: 1.05,
            colors: [
              _UMapColors.cyan.withValues(alpha: 0.03),
              _UMapColors.primary.withValues(alpha: 0.018),
              Colors.transparent,
            ],
            stops: const [0, 0.46, 1],
          ).createShader(rect),
      );
    }

    final count = twinkleOnly ? 50 : 100;
    for (var index = 0; index < count; index++) {
      final seed = twinkleOnly ? index * 3 + 1 : index;
      final angle = _unit(seed, 12.9898) * math.pi * 2;
      final spread = math.pow(_unit(seed, 78.233), 0.68).toDouble();
      final depth = _unit(seed, 37.719);
      final rayLimit = _rayLimit(size, angle);
      final distance = rayLimit * (0.06 + spread * 0.92);
      final drift = (_unit(seed, 19.313) - 0.5) * 9 * depth;
      final x =
          size.width / 2 +
          math.cos(angle) * distance +
          math.cos(angle + math.pi / 2) * drift;
      final y =
          size.height / 2 +
          math.sin(angle) * distance +
          math.sin(angle + math.pi / 2) * drift;
      final wave = math.sin(
        (phase * (0.8 + depth * 1.4) + depth) * math.pi * 2,
      );
      final twinkle = math.pow((wave + 1) / 2, 3).toDouble();
      final baseAlpha = twinkleOnly ? 0.03 : 0.03;
      final alpha = baseAlpha + twinkle * (twinkleOnly ? 0.12 : 0.04);
      final radius =
          (twinkleOnly ? 0.36 : 0.28) + depth * (twinkleOnly ? 0.62 : 0.4);
      final center = Offset(x, y);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..blendMode = BlendMode.screen
          ..color = Colors.white.withValues(alpha: alpha),
      );
      if (twinkleOnly && index % 11 == 0 && twinkle > 0.78) {
        final length = 1.4 + twinkle * 2.0;
        final stroke = Paint()
          ..blendMode = BlendMode.screen
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 0.42
          ..color = Colors.white.withValues(alpha: alpha * 0.46);
        canvas.drawLine(
          center.translate(-length, 0),
          center.translate(length, 0),
          stroke,
        );
        canvas.drawLine(
          center.translate(0, -length),
          center.translate(0, length),
          stroke,
        );
      }
    }
  }

  double _unit(int index, double salt) {
    return (math.sin(index * salt) * 43758.5453).abs() % 1;
  }

  double _rayLimit(Size size, double angle) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final cosA = math.cos(angle);
    final sinA = math.sin(angle);
    final xLimit = cosA.abs() < 0.001
        ? double.infinity
        : (cosA > 0 ? size.width - cx : cx) / cosA.abs();
    final yLimit = sinA.abs() < 0.001
        ? double.infinity
        : (sinA > 0 ? size.height - cy : cy) / sinA.abs();
    return math.min(xLimit, yLimit);
  }

  @override
  bool shouldRepaint(covariant _UMapCardStarfieldPainter oldDelegate) {
    return oldDelegate.phase != phase || oldDelegate.twinkleOnly != twinkleOnly;
  }
}

class _GalaxyPainter extends CustomPainter {
  const _GalaxyPainter({required this.projection, required this.phase});

  final _GalaxyProjection projection;
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final root = projection.root;
    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = Colors.white.withValues(alpha: 0.08);
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 0.9;

    for (final orbit in [0.58, 0.82, 1.06]) {
      final rect = Rect.fromCenter(
        center: root,
        width: size.shortestSide * orbit,
        height: size.shortestSide * orbit * 0.38,
      );
      canvas.save();
      canvas.translate(root.dx, root.dy);
      canvas.rotate(-0.18);
      canvas.translate(-root.dx, -root.dy);
      canvas.drawOval(rect, orbitPaint);
      canvas.restore();
    }

    for (final point in projection.parentPoints) {
      linePaint.color = point.color.withValues(
        alpha: point.selected ? 0.28 : 0.11,
      );
      linePaint.strokeWidth = point.selected ? 1.5 : 0.8;
      canvas.drawLine(root, point.offset, linePaint);
    }

    for (final point in projection.childPoints) {
      linePaint.color = point.color.withValues(alpha: 0.22);
      linePaint.strokeWidth = point.selected ? 1.4 : 0.75;
      canvas.drawLine(root, point.offset, linePaint);
    }

    for (var i = 0; i < 42; i++) {
      final angle = i * 2.399 + projection.rotationY;
      final radius = size.shortestSide * (0.13 + (i % 9) * 0.018);
      final ySquash = 0.48 + (i % 4) * 0.05;
      final twinklePhase = phase * (0.75 + (i % 6) * 0.16) + i * 0.137;
      final wave = math.sin(twinklePhase * math.pi * 2);
      final twinkle = math.pow((wave + 1) / 2, 3).toDouble();
      final alpha = 0.055 + twinkle * 0.07;
      final dotRadius = 0.34 + (i % 3) * 0.08 + twinkle * 0.14;
      final center = Offset(
        root.dx + math.cos(angle) * radius,
        root.dy + math.sin(angle) * radius * ySquash,
      );
      canvas.drawCircle(
        center,
        dotRadius,
        Paint()
          ..blendMode = BlendMode.screen
          ..color = Colors.white.withValues(alpha: alpha),
      );
      if (i % 19 == 0 && twinkle > 0.88) {
        final length = 1.0 + twinkle * 1.2;
        final glintPaint = Paint()
          ..blendMode = BlendMode.screen
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 0.34
          ..color = Colors.white.withValues(alpha: alpha * 0.3);
        canvas.drawLine(
          center.translate(-length, 0),
          center.translate(length, 0),
          glintPaint,
        );
        canvas.drawLine(
          center.translate(0, -length),
          center.translate(0, length),
          glintPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GalaxyPainter oldDelegate) {
    return oldDelegate.projection != projection || oldDelegate.phase != phase;
  }
}

class _GalaxyProjection {
  _GalaxyProjection({
    required this.size,
    required this.rotationX,
    required this.rotationY,
    required this.parents,
    required this.selectedParent,
  }) {
    root = Offset(size.width / 2, size.height * 0.49);
    coreSize = selectedParent == null
        ? const Size(42, 42)
        : const Size(112, 78);
    parentPoints = _projectParents();
    childPoints = _projectChildren();
  }

  final Size size;
  final double rotationX;
  final double rotationY;
  final List<GalaxyParentNode> parents;
  final GalaxyParentNode? selectedParent;
  late final Offset root;
  late final Size coreSize;
  late final List<_ProjectedNode> parentPoints;
  late final List<_ProjectedNode> childPoints;

  List<_ProjectedNode> _projectParents() {
    if (selectedParent != null) {
      return const [];
    }
    final radius = math.min(size.width, size.height) * 0.37;
    final points = <_ProjectedNode>[];
    for (var index = 0; index < parents.length; index++) {
      final parent = parents[index];
      final angle = rotationY + index * math.pi * 2 / parents.length;
      final base = _Vec3(
        math.cos(angle),
        math.sin(angle) * 0.55,
        math.sin(angle),
      );
      final rotated = _rotateX(base, rotationX);
      final depth = ((rotated.z + 1) / 2).clamp(0.0, 1.0).toDouble();
      final scale = 0.76 + depth * 0.24;
      final offset = Offset(
        root.dx + rotated.x * radius,
        root.dy + rotated.y * radius,
      );
      points.add(
        _ProjectedNode(
          id: parent.id,
          label: parent.label,
          offset: offset,
          scale: scale,
          depth: depth,
          color: parent.color,
          icon: parent.icon,
          selected: false,
          parent: parent,
        ),
      );
    }
    points.sort((a, b) => a.depth.compareTo(b.depth));
    return points;
  }

  List<_ProjectedNode> _projectChildren() {
    final selectedParent = this.selectedParent;
    if (selectedParent == null) {
      return const [];
    }
    final children = selectedParent.children;
    if (children.isEmpty) {
      return const [];
    }
    final radius = math.min(size.width, size.height) * 0.35;
    return [
      for (var index = 0; index < children.length; index++)
        _ProjectedNode(
          id: children[index].id,
          label: children[index].label,
          offset: Offset(
            root.dx +
                math.cos(
                      rotationY * 0.38 + index * math.pi * 2 / children.length,
                    ) *
                    radius,
            root.dy +
                math.sin(
                      rotationY * 0.38 + index * math.pi * 2 / children.length,
                    ) *
                    radius *
                    0.56,
          ),
          scale: 0.9,
          depth: 0.72,
          color: selectedParent.color,
          selected: false,
          child: children[index],
        ),
    ];
  }

  _Vec3 _rotateX(_Vec3 point, double angle) {
    final y = point.y * math.cos(angle) - point.z * math.sin(angle);
    final z = point.y * math.sin(angle) + point.z * math.cos(angle);
    return _Vec3(point.x, y, z);
  }
}

class _ProjectedNode {
  const _ProjectedNode({
    required this.id,
    required this.label,
    required this.offset,
    required this.scale,
    required this.depth,
    required this.color,
    required this.selected,
    this.icon,
    this.parent,
    this.child,
  });

  final String id;
  final String label;
  final Offset offset;
  final double scale;
  final double depth;
  final Color color;
  final bool selected;
  final IconData? icon;
  final GalaxyParentNode? parent;
  final GalaxyChildNode? child;
}

class _Vec3 {
  const _Vec3(this.x, this.y, this.z);

  final double x;
  final double y;
  final double z;
}

class _UMapRadarPainter extends CustomPainter {
  const _UMapRadarPainter(this.axes);

  final List<_RadarAxis> axes;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 + 2);
    final radius = math.min(size.width, size.height) * 0.33;
    final dataRadius = radius * 0.88;

    for (var step = 1; step <= 5; step++) {
      final path = _polygonPath(center, radius * step / 5, axes.length);
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = _UMapColors.radarStroke.withValues(alpha: 0.075),
      );
    }

    final dataPath = Path();
    for (var index = 0; index < axes.length; index++) {
      final angle = -math.pi / 2 + index * math.pi * 2 / axes.length;
      final value = axes[index].value ?? 0;
      final point = Offset(
        center.dx + math.cos(angle) * dataRadius * value / 100,
        center.dy + math.sin(angle) * dataRadius * value / 100,
      );
      if (index == 0) {
        dataPath.moveTo(point.dx, point.dy);
      } else {
        dataPath.lineTo(point.dx, point.dy);
      }
    }
    dataPath.close();
    canvas.drawPath(
      dataPath,
      Paint()
        ..style = PaintingStyle.fill
        ..shader = RadialGradient(
          colors: [
            _UMapColors.primary.withValues(alpha: 0.34),
            _UMapColors.cyan.withValues(alpha: 0.11),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    canvas.drawPath(
      dataPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeJoin = StrokeJoin.round
        ..color = _UMapColors.primarySoft.withValues(alpha: 0.64),
    );

    for (var index = 0; index < axes.length; index++) {
      final axis = axes[index];
      final angle = -math.pi / 2 + index * math.pi * 2 / axes.length;
      final axisEnd = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      canvas.drawLine(
        center,
        axisEnd,
        Paint()
          ..color = _UMapColors.radarStroke.withValues(alpha: 0.08)
          ..strokeWidth = 1,
      );
      canvas.drawCircle(
        axisEnd,
        axis.value == null ? 2.6 : 3.8,
        Paint()
          ..color = axis.color.withValues(
            alpha: axis.value == null ? 0.22 : 0.45,
          ),
      );
      final label = Offset(
        center.dx + math.cos(angle) * (radius + 29),
        center.dy + math.sin(angle) * (radius + 29),
      );
      _drawText(
        canvas,
        label,
        axis.value == null
            ? '${axis.label}\n탐구 중'
            : '${axis.label}\n${axis.value!.round()}',
        axis.color,
      );
    }
  }

  Path _polygonPath(Offset center, double radius, int count) {
    final path = Path();
    for (var index = 0; index < count; index++) {
      final angle = -math.pi / 2 + index * math.pi * 2 / count;
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      if (index == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    return path..close();
  }

  void _drawText(Canvas canvas, Offset anchor, String text, Color color) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 10.4,
          height: 1.1,
          fontWeight: FontWeight.w900,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: 54);
    painter.paint(
      canvas,
      Offset(anchor.dx - painter.width / 2, anchor.dy - painter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _UMapRadarPainter oldDelegate) {
    return oldDelegate.axes != axes;
  }
}

class _RadarAxis {
  const _RadarAxis(this.label, this.value, this.color);

  final String label;
  final double? value;
  final Color color;

  static List<_RadarAxis> fromContext({
    required List<GalaxyParentNode> parents,
    required GalaxyParentNode? selectedParent,
    required GalaxyChildNode? selectedChild,
    required List<GalaxyChildNode> relatedNodes,
  }) {
    if (selectedParent == null) {
      return fromParents(parents);
    }

    final orderedChildren = <GalaxyChildNode>[
      ?selectedChild,
      ...relatedNodes,
      ...selectedParent.children,
    ];
    final uniqueChildren = <GalaxyChildNode>[];
    final seen = <String>{};
    for (final child in orderedChildren) {
      if (seen.add(child.id)) {
        uniqueChildren.add(child);
      }
    }

    return [
      for (var index = 0; index < _contextColors.length; index++)
        if (index < uniqueChildren.length)
          _RadarAxis(
            uniqueChildren[index].label,
            uniqueChildren[index].score,
            _contextColors[index],
          )
        else
          _RadarAxis('탐구 중', null, _contextColors[index]),
    ];
  }

  static List<_RadarAxis> fromParents(List<GalaxyParentNode> parents) {
    const groups = [
      ('성향', ['personality'], Color(0xFF7DD3FC)),
      ('가치', ['values'], Color(0xFF6EE7B7)),
      ('동기', ['motivation'], Color(0xFFF7C948)),
      ('감정', ['emotion', 'stress'], Color(0xFFC4B5FD)),
      ('관계', ['relationship'], Color(0xFF93C5FD)),
      ('판단', ['decision', 'self-image'], Color(0xFFFF9F7D)),
      ('실행', ['behavior'], Color(0xFF34D399)),
      ('방향성', ['life-direction'], Color(0xFF8B5CF6)),
    ];
    return [
      for (final group in groups)
        _RadarAxis(
          group.$1,
          _averageScore(
            parents
                .where((parent) => group.$2.contains(parent.id))
                .expand((parent) => parent.children)
                .map((child) => child.score)
                .toList(),
          ),
          group.$3,
        ),
    ];
  }

  static double _averageScore(List<double> scores) {
    if (scores.isEmpty) {
      return 0;
    }
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  static const _contextColors = [
    Color(0xFF7DD3FC),
    Color(0xFF6EE7B7),
    Color(0xFFF7C948),
    Color(0xFFC4B5FD),
    Color(0xFF93C5FD),
    Color(0xFFFF9F7D),
    Color(0xFF34D399),
    Color(0xFF8B5CF6),
  ];
}

abstract final class _GalaxyData {
  static List<GalaxyParentNode> fromRepository(FiYouRepository repository) {
    final axes = repository.axes.isEmpty ? axisSummaries : repository.axes;
    final sourceAxes = axes.isEmpty ? _fallbackAxes : axes;
    final insight = repository.todayInsight;
    final specs = _parentSpecs;

    return [
      for (var parentIndex = 0; parentIndex < specs.length; parentIndex++)
        _buildParent(
          spec: specs[parentIndex],
          parentIndex: parentIndex,
          axes: sourceAxes,
          insight: insight,
        ),
    ];
  }

  static GalaxyParentNode _buildParent({
    required _ParentSpec spec,
    required int parentIndex,
    required List<AxisSummary> axes,
    required ClueInsight insight,
  }) {
    final children = <GalaxyChildNode>[];
    final childCount = 5 + _stableInt('${spec.id}-$parentIndex', 11);
    for (var offset = 0; offset < childCount; offset++) {
      final axis = axes[(parentIndex + offset * 3) % axes.length];
      final source = insight.sources.isEmpty
          ? axis.recentSource
          : insight.sources[(parentIndex + offset) % insight.sources.length];
      final id = '${spec.id}-${axis.label.hashCode}-$offset';
      final scoreJitter = _stableInt('$id-score', 19) - 9;
      children.add(
        GalaxyChildNode(
          id: id,
          label: _childLabel(axis, offset, axes.length),
          score: (axis.value * 100 + scoreJitter).clamp(1, 100).toDouble(),
          insight: _insightText(spec.label, axis),
          evidence: [
            axis.clue,
            source,
            '${axis.recordCount}개 기록 · ${axis.recentSource}',
          ],
        ),
      );
    }

    final linked = [
      for (var index = 0; index < children.length; index++)
        GalaxyChildNode(
          id: children[index].id,
          label: children[index].label,
          score: children[index].score,
          insight: children[index].insight,
          evidence: children[index].evidence,
          relatedNodeIds: [
            children[(index + 1) % children.length].id,
            children[(index + 2) % children.length].id,
          ],
        ),
    ];

    return GalaxyParentNode(
      id: spec.id,
      label: spec.label,
      score: _RadarAxis._averageScore(
        linked.map((child) => child.score).toList(),
      ),
      children: linked,
      color: spec.color,
      icon: spec.icon,
    );
  }

  static String _insightText(String parentLabel, AxisSummary axis) {
    return '$parentLabel 영역에서는 ${axis.copy} 이 흐름은 고정된 모습이 아니라, 최근 응답과 Diary 기록에서 반복된 단서를 연결해 만든 현재 지도예요.';
  }

  static String _childLabel(AxisSummary axis, int offset, int sourceCount) {
    if (offset < sourceCount) {
      return axis.label;
    }
    return '${axis.label} 단서 ${(offset ~/ sourceCount) + 1}';
  }

  static int _stableInt(String seed, int modulo) {
    var hash = 0;
    for (final codeUnit in seed.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7fffffff;
    }
    return hash % modulo;
  }

  static const _parentSpecs = [
    _ParentSpec(
      'personality',
      '성격',
      Icons.psychology_alt_rounded,
      Color(0xFF7DD3FC),
    ),
    _ParentSpec('values', '가치관', Icons.diamond_outlined, Color(0xFF6EE7B7)),
    _ParentSpec('motivation', '동기', Icons.bolt_rounded, Color(0xFFF7C948)),
    _ParentSpec('emotion', '감정패턴', Icons.water_drop_rounded, Color(0xFFC4B5FD)),
    _ParentSpec('stress', '스트레스 반응', Icons.spa_rounded, Color(0xFFFB7185)),
    _ParentSpec(
      'relationship',
      '인간관계',
      Icons.people_alt_rounded,
      Color(0xFF93C5FD),
    ),
    _ParentSpec('decision', '의사결정', Icons.tune_rounded, Color(0xFFFF9F7D)),
    _ParentSpec(
      'self-image',
      '자아상',
      Icons.person_search_rounded,
      Color(0xFFA78BFA),
    ),
    _ParentSpec('behavior', '행동패턴', Icons.route_rounded, Color(0xFF34D399)),
    _ParentSpec(
      'life-direction',
      '삶의 방향',
      Icons.north_east_rounded,
      Color(0xFF8B5CF6),
    ),
  ];

  static const _fallbackAxes = [
    AxisSummary(
      label: '탐색 흐름',
      value: 0.5,
      copy: '아직 충분한 기록이 없어 기본 탐색 흐름으로 표시돼요.',
      icon: Icons.auto_awesome_rounded,
      color: Color(0xFF7DD3FC),
      recordCount: 0,
      recentSource: '기본 지도',
      clue: '질문과 Diary가 쌓이면 실제 탐험 신호로 이어져요.',
    ),
  ];
}

class _ParentSpec {
  const _ParentSpec(this.id, this.label, this.icon, this.color);

  final String id;
  final String label;
  final IconData icon;
  final Color color;
}

abstract final class _UMapColors {
  static const textSoft = Color(0xFFB7C0D7);
  static const textMuted = Color(0xFF7F8AA6);
  static const primary = Color(0xFF8B5CF6);
  static const primarySoft = Color(0xFFC4B5FD);
  static const radarStroke = Color(0xFFA8A0D8);
  static const cyan = Color(0xFF7DD3FC);
  static const emerald = Color(0xFF34D399);
  static const gold = Color(0xFFF7C948);
}
