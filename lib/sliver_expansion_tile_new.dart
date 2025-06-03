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

  double _minExpandHeight = 0.0;

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
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! SliverExpansionTileParentData) {
      child.parentData = SliverExpansionTileParentData();
    }
  }

  SliverExpansionTileParentData calculateParentData(RenderBox child) {
    final SliverExpansionTileParentData childParentData = child.data;

    if (!childParentData.needsLayout) {
      return childParentData.calculate(scrollOffset: constraints.scrollOffset);
      // return childParentData;
    }

    // final prevParentData =
    //     childParentData.previousSibling?.parentData
    //         as SliverExpansionTileParentData?;

    return childParentData.calculate(
      childExtent: paintExtentOf(child),
      scrollOffset: constraints.scrollOffset,
    );
    // childParentData.childExtent = paintExtentOf(child);
    // childParentData.layoutOffset = prevParentData?.nextLayoutOffset ?? 0;
    // childParentData.nextLayoutOffset =
    //     childParentData.layoutOffset! + childParentData.childExtent!;
    // childParentData.scrollOffset = constraints.scrollOffset;
    // // print('calc: $childParentData');
    // childParentData.totalExtent =
    //     (prevParentData?.totalExtent ?? 0) + childParentData.childExtent!;
    // return childParentData;
  }

  SliverExpansionTileParentData calculatePrevParentData(RenderBox child) {
    final SliverExpansionTileParentData childParentData = child.data;

    if (!childParentData.needsLayout) {
      // childParentData.scrollOffset = constraints.scrollOffset;
      return childParentData.calculate(
        scrollOffset: constraints.scrollOffset,
        leading: true,
      );
    }

    // final nextParentData =
    //     childParentData.nextSibling?.parentData
    //         as SliverExpansionTileParentData?;

    childParentData.calculate(
      childExtent: paintExtentOf(child),
      scrollOffset: constraints.scrollOffset,
      leading: true,
    );
    print('prev child parent: $childParentData');
    // childParentData.childExtent = paintExtentOf(child);
    // childParentData.layoutOffset =
    //     nextParentData.layoutOffset! - childParentData.childExtent!;
    // childParentData.nextLayoutOffset =
    //     childParentData.layoutOffset! + childParentData.childExtent!;
    // childParentData.scrollOffset = constraints.scrollOffset;
    // // print('calc: $childParentData');
    // childParentData.totalExtent =
    //     (nextParentData.totalExtent ?? 0) + childParentData.childExtent!;
    // print('prev parent: $childParentData');
    return childParentData;
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
    bool hasVisualOverflow = false;

    if (originalRemainingPaintExtent == 0.0) {
      if (childCount > 0) {
        collectGarbage(1, 0);
      }
      geometry = SliverGeometry.zero;
      childManager.didFinishLayout();
      return;
    }
    // if (!_isExpanded) {
    //   if (childCount > 1) {
    //     collectGarbage(1, childCount - 1);
    //   }
    // }
    if (firstChild == null) {
      if (!addInitialChild(layoutOffset: -scrollOffset)) {
        geometry = SliverGeometry.zero;
        childManager.didFinishLayout();
        return;
      }
    }

    RenderBox? earliestChildWithLayout = lastChild;
    RenderBox? child = firstChild!;

    int total = 1;
    RenderBox? leadingGarbageChild;
    RenderBox? trailingGarbageChild;
    int totalChildren = childManager.childCount;

    // print('layout from here');
    // while (child != null) {
    //   // print('yes I will layout');
    //   // child.layout(childConstraints, parentUsesSize: true);

    //   // final SliverExpansionTileParentData? childParentData =
    //   //     child.parentData as SliverExpansionTileParentData?;

    //   // layoutOffset = childParentData?.layoutOffset ?? layoutOffset;

    //   // childParentData?.layoutOffset ??= layoutOffset;

    //   // double childExtent = childParentData?.childExtent ?? paintExtentOf(child);

    //   // childParentData?.childExtent ??= childExtent;

    //   // if (!_isExpanded && child == firstChild) {
    //   //   _minExpandHeight = childExtent;
    //   // }
    //   // if (layoutOffset > remainingPaintExtent) {
    //   //   trailingGarbageChild = child;
    //   // }
    //   // totalExtent += childExtent;
    //   // layoutOffset += childExtent;
    //   // earliestChildWithLayout = child;
    //   // total++;

    //   // if (layoutOffset < 0) {
    //   //   leadingGarbageChild = child;
    //   // }
    //   // child = childAfter(child);

    //   final SliverExpansionTileParentData? childParentData =
    //       child.parentData as SliverExpansionTileParentData?;
    //   print(
    //     'child layout: ${childParentData?.layoutOffset}, index: ${indexOf(child)}',
    //   );
    //   final childExtent = childParentData?.childExtent ?? 0.0;
    //   layoutOffset =
    //       (childParentData?.layoutOffset ?? layoutOffset) + childExtent;
    //   totalExtent += childExtent;
    //   earliestChildWithLayout = child;
    //   child = childAfter(child);
    // }
    while (child != null) {
      child.layout(childConstraints, parentUsesSize: true);
      // if (_isExpanded && scrollOffset > 0 || child == firstChild) {
      calculateParentData(child);

      if (child == firstChild) {
        print('its first again');
        remainingPaintExtent = min(
          max(
            firstChild!.childExtent,
            originalRemainingPaintExtent * _animationController.value,
          ),
          originalRemainingPaintExtent,
        );
      }

      print('child: ${child.data}, re: $remainingPaintExtent');
      if (child.data.layoutOffset > remainingPaintExtent ||
          !_isExpanded && child.data.layoutOffset == remainingPaintExtent) {
        trailingGarbageChild = child;
      }

      // print(
      //   'indexOf: ${indexOf(child)}, updated parent data: $childParentData',
      // );
      // }
      final prevChild = child;
      child = childAfter(child);
      if (child != null) {
        if (child.data.nextLayoutOffset < 0) {
          leadingGarbageChild = prevChild;
        }
        // final nextChild = childAfter(child);
      }
    }

    // print(
    //   'early: ${leadingGarbageChild != null ? indexOf(leadingGarbageChild!) : null}',
    // );
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

    print(
      'leading: $leadingGarbage, $leadingGarbageChild, trailing: $trailingGarbage, $trailingGarbageChild',
    );

    collectGarbage(leadingGarbage, trailingGarbage);

    if (firstChild == null) {
      geometry = SliverGeometry.zero;
      childManager.didFinishLayout();
      return;
    }
    final secondChild = childAfter(firstChild!);
    final firstChildIndex = indexOf(firstChild!);
    print('first: ${firstChildIndex} ${firstChild!.nextLayoutOffset},');
    while (firstChildIndex > 0 && firstChild!.nextLayoutOffset >= 0) {
      print('adding leading child');
      insertAndLayoutLeadingChild(childConstraints, parentUsesSize: true);

      calculatePrevParentData(firstChild!);
    }
    print('remainging: $remainingPaintExtent');

    // print('insert from here');

    double layoutOffset = lastChild!.nextLayoutOffset;
    while (_isExpanded &&
        layoutOffset < remainingPaintExtent &&
        childCount < totalChildren) {
      child = insertAndLayoutChild(
        constraints.asBoxConstraints(),
        parentUsesSize: true,
        after: lastChild,
      );
      print('new child: $child');
      if (child == null) {
        break;
      }

      final childParentData = calculateParentData(child);

      // print('index: ${indexOf(child)}, childParentData: $childParentData');

      layoutOffset = childParentData!.nextLayoutOffset!;
      earliestChildWithLayout = child;
      total++;
    }

    print('total: $childCount, $totalChildren');
    // print('earliest: $earliestChildWithLayout');
    final totalExtent = lastChild!.totalExtent;

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
    print('borderHeight: $borderHeight');

    final bounds = Offset.zero & Size(width, height);
    final clipRRect = RRect.fromRectAndRadius(bounds, _borderRadius);

    context.pushClipRRect(needsCompositing, offset, bounds, clipRRect, (
      PaintingContext innerContext,
      Offset innerOffset,
    ) {
      while (child != null) {
        final SliverExpansionTileParentData? childParentData =
            child!.parentData as SliverExpansionTileParentData?;

        innerContext.paintChild(
          child!,
          innerOffset + Offset(0, childParentData?.layoutOffset ?? 0),
        );
        child = childAfter(child!);
      }

      if (_border != null) {
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
    final SliverExpansionTileParentData? childParentData =
        child.parentData as SliverExpansionTileParentData?;
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

class SliverExpansionTileParentData extends SliverMultiBoxAdaptorParentData {
  double _childExtent = 0.0;

  double _layoutOffset = 0.0;
  double _scrollOffset = 0.0;

  bool _needsLayout = true;

  @override
  double get layoutOffset => _layoutOffset - _scrollOffset;
  double get nextLayoutOffset => layoutOffset + _childExtent;
  double get childExtent => _childExtent;
  double get totalExtent => _layoutOffset + _childExtent;
  bool get needsLayout => _needsLayout;

  SliverExpansionTileParentData calculate({
    double? childExtent,
    double? scrollOffset,
    bool leading = false,
  }) {
    _childExtent = childExtent ?? _childExtent;
    _scrollOffset = scrollOffset ?? _scrollOffset;

    if (!_needsLayout) {
      return this;
    }

    if (leading) {
      final nextParentData =
          nextSibling?.parentData as SliverExpansionTileParentData?;

      print('leading: $nextParentData');
      _layoutOffset = (nextParentData?._layoutOffset ?? 0) - _childExtent;
    } else {
      final prevParentData =
          previousSibling?.parentData as SliverExpansionTileParentData?;

      _layoutOffset =
          (prevParentData?._layoutOffset ?? 0) +
          (prevParentData?._childExtent ?? 0);
    }
    _needsLayout = false;
    return this;
  }

  @override
  String toString() {
    return 'index: $index; layoutOffset: $_layoutOffset; childExtent: $_childExtent; nextLayoutOffset: $nextLayoutOffset; totalExtent: $totalExtent, scrollOffset: $_scrollOffset';
  }
}

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

extension SliverExpansionTileParentDataExtension on RenderBox {
  SliverExpansionTileParentData get data =>
      parentData as SliverExpansionTileParentData;

  double get layoutOffset => data.layoutOffset;
  double get nextLayoutOffset => data.nextLayoutOffset;
  double get childExtent => data.childExtent;
  double get totalExtent => data.totalExtent;
}
