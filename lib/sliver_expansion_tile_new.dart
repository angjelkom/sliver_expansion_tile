import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SliverExpansionTileController {
  SliverExpansionTileController();

  _SliverExpansionTileState? _state;

  bool get isExpanded {
    assert(_state != null);
    return _state!._isExpanded;
  }

  void expand() {
    assert(_state != null);
    if (!isExpanded) {
      _state!._toggleExpansion();
    }
  }

  void stop() {
    assert(_state != null);
    _state!._stopAnimation();
  }

  void collapse() {
    assert(_state != null);
    if (isExpanded) {
      _state!._toggleExpansion();
    }
  }

  void toggle() {
    assert(_state != null);
    _state!._toggleExpansion();
  }

  static SliverExpansionTileController of(BuildContext context) {
    final _SliverExpansionTileState? result =
        context.findAncestorStateOfType<_SliverExpansionTileState>();
    return result!._tileController;
  }

  static SliverExpansionTileController? maybeOf(BuildContext context) {
    return context
        .findAncestorStateOfType<_SliverExpansionTileState>()
        ?._tileController;
  }
}

class SliverExpansionTile extends StatefulWidget {
  const SliverExpansionTile({
    required this.title,
    this.titleColor,
    this.subtitle,
    this.leading,
    this.trailing,
    required this.children,
    this.initiallyExpanded = false,
    this.controller,
    this.border,
    this.borderRadius = Radius.zero,
    super.key,
  });

  final Widget title;
  final Color? titleColor;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final List<Widget> children;
  final bool initiallyExpanded;
  final SliverExpansionTileController? controller;
  final BorderSide? border;
  final Radius borderRadius;

  @override
  State<SliverExpansionTile> createState() => _SliverExpansionTileState();
}

class _SliverExpansionTileState extends State<SliverExpansionTile>
    with SingleTickerProviderStateMixin {
  late bool _isExpanded = widget.initiallyExpanded;

  late final AnimationController _animationController = AnimationController(
    duration: const Duration(milliseconds: 2000),
    vsync: this,
    value: _isExpanded ? 1.0 : 0.0,
  );

  late final SliverExpansionTileController _tileController =
      widget.controller ?? SliverExpansionTileController();

  late final Animation<double> _iconTurns = _animationController.drive(
    Tween<double>(
      begin: 0.0,
      end: 0.5,
    ).chain(CurveTween(curve: Curves.easeInOut)),
  );

  @override
  void initState() {
    _tileController._state = this;
    super.initState();
  }

  @override
  void dispose() {
    _tileController._state = null;
    _animationController.dispose();
    super.dispose();
  }

  void _stopAnimation() {
    _animationController.stop();
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse().then<void>((void value) {
          if (!mounted) return;
          setState(() {});
        });
      }
      PageStorage.of(context).writeState(context, _isExpanded);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _SliverExpansionTile(
      title: _ExpansionTileTitle(
        title: widget.title,
        subtitle: widget.subtitle,
        leading: widget.leading,
        trailing:
            widget.trailing ??
            RotationTransition(
              turns: _iconTurns,
              child: const Icon(Icons.expand_more),
            ),
        color: widget.titleColor,
      ),
      animationController: _animationController,
      controller: _tileController,
      isExpanded: _isExpanded,
      border: widget.border,
      borderRadius: widget.borderRadius,
      delegate: SliverChildListDelegate([
        _ExpansionTileTitle(
          title: widget.title,
          subtitle: widget.subtitle,
          leading: widget.leading,
          trailing:
              widget.trailing ??
              RotationTransition(
                turns: _iconTurns,
                child: const Icon(Icons.expand_more),
              ),
          color: widget.titleColor,
        ),
        ...widget.children,
      ]),
    );
  }
}

class _SliverExpansionTile extends SliverMultiBoxAdaptorWidget {
  const _SliverExpansionTile({
    required this.title,
    required this.animationController,
    required this.controller,
    this.isExpanded = false,
    this.border,
    this.borderRadius = Radius.zero,
    required super.delegate,
  });

  final Widget title;
  final AnimationController animationController;
  final SliverExpansionTileController controller;
  final BorderSide? border;
  final Radius borderRadius;
  final bool isExpanded;

  @override
  RenderSliverExpansionTile createRenderObject(BuildContext context) {
    final SliverMultiBoxAdaptorElement element =
        context as SliverMultiBoxAdaptorElement;
    return RenderSliverExpansionTile(
      childManager: element,
      animationController: animationController,
      controller: controller,
      border: border,
      borderRadius: borderRadius,
      isExpanded: isExpanded,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderSliverExpansionTile renderObject,
  ) {
    renderObject
      ..animationController = animationController
      ..controller = controller
      ..border = border
      ..borderRadius = borderRadius
      ..isExpanded = isExpanded;
  }
}

class RenderSliverExpansionTile extends RenderSliverMultiBoxAdaptor {
  RenderSliverExpansionTile({
    required AnimationController animationController,
    required SliverExpansionTileController controller,
    bool isExpanded = false,
    BorderSide? border,
    Radius borderRadius = Radius.zero,
    required super.childManager,
  }) : _animationController = animationController,
       _controller = controller,
       _border = border,
       _isExpanded = isExpanded,
       _borderRadius = borderRadius {
    _animationController.addListener(markNeedsLayout);
  }

  AnimationController _animationController;

  AnimationController get animationController => _animationController;

  set animationController(AnimationController value) {
    if (_animationController != value) {
      _animationController.removeListener(markNeedsLayout);
      _animationController.dispose();
      _animationController = value;
      _animationController.addListener(markNeedsLayout);
    }
  }

  SliverExpansionTileController _controller;

  SliverExpansionTileController get controller => _controller;

  set controller(SliverExpansionTileController value) {
    if (_controller != value) {
      _controller = value;
    }
  }

  bool _isExpanded = false;

  bool get isExpanded => _isExpanded;

  set isExpanded(bool value) {
    if (_isExpanded != value) {
      _isExpanded = value;
      markNeedsPaint();
    }
  }

  BorderSide? _border;

  BorderSide? get border => _border;

  set border(BorderSide? value) {
    if (_border != value) {
      _border = value;
      markNeedsPaint();
    }
  }

  Radius _borderRadius = Radius.zero;

  Radius get borderRadius => _borderRadius;

  set borderRadius(Radius value) {
    if (_borderRadius != value) {
      _borderRadius = value;
      markNeedsLayout();
    }
  }

  TapGestureRecognizer? _tapRecognizer;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _tapRecognizer = TapGestureRecognizer(debugOwner: this)
      ..onTap = _controller.toggle;
  }

  @override
  void detach() {
    _tapRecognizer?.dispose();
    _tapRecognizer = null;
    super.detach();
  }

  @override
  void performLayout() {
    childManager
      ..didStartLayout()
      ..setDidUnderflow(false);

    final SliverConstraints constraints = this.constraints;
    final BoxConstraints childConstraints = constraints.asBoxConstraints();
    double scrollOffset = constraints.scrollOffset;

    double originalRemainingPaintExtent = constraints.remainingPaintExtent;
    double remainingPaintExtent = originalRemainingPaintExtent;

    if (originalRemainingPaintExtent == 0.0) {
      if (childCount > 0) {
        collectGarbage(1, 0);
      }
      geometry = SliverGeometry.zero;
      childManager.didFinishLayout();
      return;
    }

    if (firstChild == null) {
      if (!addInitialChild()) {
        geometry = SliverGeometry.zero;
        childManager.didFinishLayout();
        return;
      }
    }

    if (!_isExpanded) {
      if (childCount > 1) {
        collectGarbage(1, childCount - 1);

        if (firstChild == null) {
          if (!addInitialChild()) {
            geometry = SliverGeometry.zero;
            childManager.didFinishLayout();
            return;
          }
        }
      }
    }

    double totalExtent = 0.0;
    double layoutOffset = -scrollOffset;
    bool hasVisualOverflow = false;

    RenderBox header = firstChild!;

    header.layout(childConstraints, parentUsesSize: true);

    final SliverMultiBoxAdaptorParentData? childParentData =
        header.parentData as SliverMultiBoxAdaptorParentData?;
    childParentData?.layoutOffset = layoutOffset;

    double headerExtent = paintExtentOf(header);

    totalExtent += headerExtent;
    layoutOffset += headerExtent;

    RenderBox? earliestChildWithLayout = header;
    RenderBox? child = childAfter(header);

    remainingPaintExtent = min(
      headerExtent + originalRemainingPaintExtent * _animationController.value,
      originalRemainingPaintExtent,
    );

    int total = 1;
    // print(
    //   'childOffset: ${childScrollOffset(header)}, remaining: $remainingPaintExtent, original: $originalRemainingPaintExtent',
    // );
    //
    RenderBox? leadingGarbageChild;
    RenderBox? trailingGarbageChild;
    int totalChildren = childManager.childCount;

    if (layoutOffset < 0) {
      leadingGarbageChild = header;
    } else if (layoutOffset > remainingPaintExtent) {
      trailingGarbageChild = header;
    }

    while (child != null) {
      child.layout(childConstraints, parentUsesSize: true);

      final SliverMultiBoxAdaptorParentData? childParentData =
          child.parentData as SliverMultiBoxAdaptorParentData?;

      childParentData?.layoutOffset = layoutOffset;

      double childExtent = paintExtentOf(child);

      if (child == firstChild) {
        headerExtent = childExtent;
      }
      if (layoutOffset < 0) {
        leadingGarbageChild = child;
      } else if (layoutOffset > remainingPaintExtent) {
        trailingGarbageChild = child;
      }
      // print(
      //   'layoutOffset: $layoutOffset, remainingPaintExtent: $remainingPaintExtent',
      // );

      totalExtent += childExtent;
      layoutOffset += childExtent;
      earliestChildWithLayout = child;
      total++;

      child = childAfter(child);
    }

    int leadingGarbage =
        leadingGarbageChild != null
            ? calculateLeadingGarbage(
              firstIndex: indexOf(leadingGarbageChild) + 1,
            )
            : 0;

    int trailingGarbage =
        trailingGarbageChild != null
            ? calculateTrailingGarbage(
              lastIndex: indexOf(trailingGarbageChild) - 1,
            )
            : 0;

    // print(
    //   'leading: $leadingGarbage, $leadingGarbageChild, trailing: $trailingGarbage, $trailingGarbageChild',
    // );

    collectGarbage(leadingGarbage, trailingGarbage);

    if (firstChild == null) {
      geometry = SliverGeometry.zero;
      childManager.didFinishLayout();
      return;
    }
    print('total: $totalChildren, count: $childCount');

    while (_isExpanded &&
        layoutOffset < remainingPaintExtent &&
        childCount < totalChildren) {
      print('its inserting, $layoutOffset, $remainingPaintExtent');
      child = insertAndLayoutChild(
        constraints.asBoxConstraints(),
        parentUsesSize: true,
        after: earliestChildWithLayout,
      );
      if (child == null) {
        break;
      }

      final SliverMultiBoxAdaptorParentData? childParentData =
          child.parentData as SliverMultiBoxAdaptorParentData?;

      childParentData?.layoutOffset = layoutOffset;

      double childExtent = paintExtentOf(child);

      totalExtent += childExtent;
      layoutOffset += childExtent;
      earliestChildWithLayout = child;
      total++;
    }

    final double paintExtent = calculatePaintOffset(
      constraints,
      from: childScrollOffset(firstChild!) ?? 0.0,
      to: totalExtent,
    );

    hasVisualOverflow = paintExtent > remainingPaintExtent;

    double clampedPaintExtent = paintExtent.clamp(0.0, remainingPaintExtent);

    // print('total: $total');
    geometry = SliverGeometry(
      scrollExtent: totalExtent,
      paintExtent: clampedPaintExtent,
      maxPaintExtent: totalExtent,
      hasVisualOverflow: hasVisualOverflow,
      // cacheExtent: calculateCacheOffset(
      //   constraints,
      //   from: childScrollOffset(firstChild!) ?? 0.0,
      //   to: totalExtent,
      // ),
    );

    childManager.didFinishLayout();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    final scrollOffset = constraints.scrollOffset;
    final double width = constraints.crossAxisExtent;
    final height = geometry!.paintExtent;
    final borderHeight = geometry!.scrollExtent;

    final bounds = Offset.zero & Size(width, height);
    final clipRRect = RRect.fromRectAndRadius(bounds, _borderRadius);

    context.pushClipRRect(needsCompositing, offset, bounds, clipRRect, (
      PaintingContext innerContext,
      Offset innerOffset,
    ) {
      while (child != null) {
        final SliverMultiBoxAdaptorParentData? childParentData =
            child!.parentData as SliverMultiBoxAdaptorParentData?;

        innerContext.paintChild(
          child!,
          innerOffset + Offset(0, childParentData?.layoutOffset ?? 0),
        );
        child = childAfter(child!);
      }

      if (_border != null) {
        // print(
        //   'geometry: $geometry, offset: $offset, inner: $innerOffset, height: $height',
        // );
        final Path path =
            Path()..addRRect(
              RRect.fromRectAndRadius(
                Rect.fromLTWH(
                  innerOffset.dx,
                  innerOffset.dy - scrollOffset,
                  width,
                  borderHeight,
                ),
                _borderRadius,
              ),
            );
        innerContext.canvas.drawPath(path, _border!.toPaint());
      }
    });
  }

  @override
  void applyPaintTransform(covariant RenderObject child, Matrix4 transform) {
    applyPaintTransformForBoxChild(child as RenderBox, transform);
  }

  @override
  double childMainAxisPosition(covariant RenderObject child) {
    final SliverMultiBoxAdaptorParentData? childParentData =
        child.parentData as SliverMultiBoxAdaptorParentData?;
    return childParentData?.layoutOffset ?? 0;
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    RenderBox? child = lastChild;

    while (child != null) {
      final hit = hitTestBoxChild(
        BoxHitTestResult.wrap(result),
        child,
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition,
      );

      if (hit) return child == firstChild;
      child = childBefore(child);
    }

    return false;
  }

  @override
  void handleEvent(PointerEvent event, SliverHitTestEntry entry) {
    if (event is PointerDownEvent) {
      _tapRecognizer?.addPointer(event);
    }
  }
}

class SliverExpansionTileParentData extends SliverPhysicalParentData
    with ContainerParentDataMixin<RenderObject> {}

class _ExpansionTileTitle extends StatelessWidget {
  const _ExpansionTileTitle({
    required this.title,
    this.subtitle,
    this.color,
    this.leading,
    this.trailing,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(16.0),
      color: color,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (leading != null) leading!,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DefaultTextStyle(
                style: textTheme.bodyLarge!.apply(color: colorScheme.onSurface),
                child: title,
              ),
              if (subtitle != null)
                DefaultTextStyle(
                  style: textTheme.bodyMedium!.apply(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  child: subtitle!,
                ),
            ],
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
