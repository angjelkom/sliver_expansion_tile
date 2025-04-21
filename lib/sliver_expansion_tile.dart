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
    duration: const Duration(milliseconds: 200),
    vsync: this,
    value: _isExpanded ? 1.0 : 0.0,
  );

  late final SliverExpansionTileController _tileController =
      widget.controller ?? SliverExpansionTileController();

  late final Animation<double> _iconTurns = _animationController.drive(
    Tween<double>(begin: 0.0, end: 0.5).chain(CurveTween(curve: Curves.easeIn)),
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
      border: widget.border,
      borderRadius: widget.borderRadius,
      children: widget.children,
    );
  }
}

class _SliverExpansionTile extends MultiChildRenderObjectWidget {
  _SliverExpansionTile({
    required this.title,
    required List<Widget> children,
    required this.animationController,
    required this.controller,
    this.border,
    this.borderRadius = Radius.zero,
  }) : super(children: [title, ...children]);

  final Widget title;
  final AnimationController animationController;
  final SliverExpansionTileController controller;
  final BorderSide? border;
  final Radius borderRadius;

  @override
  RenderSliverExpansionTile createRenderObject(BuildContext context) {
    return RenderSliverExpansionTile(
      animationController: animationController,
      controller: controller,
      border: border,
      borderRadius: borderRadius,
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
      ..borderRadius = borderRadius;
  }
}

class RenderSliverExpansionTile extends RenderSliver
    with
        ContainerRenderObjectMixin<RenderObject, SliverExpansionTileParentData>,
        RenderSliverHelpers {
  RenderSliverExpansionTile({
    required AnimationController animationController,
    required SliverExpansionTileController controller,
    BorderSide? border,
    Radius borderRadius = Radius.zero,
  }) : _animationController = animationController,
       _controller = controller,
       _border = border,
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
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! SliverExpansionTileParentData) {
      child.parentData = SliverExpansionTileParentData();
    }
  }

  @override
  void performLayout() {
    if (firstChild == null) {
      geometry = SliverGeometry.zero;
      return;
    }

    final SliverConstraints constraints = this.constraints;
    double scrollOffset = constraints.scrollOffset;
    double remainingPaintExtent = constraints.remainingPaintExtent;
    double totalExtent = 0.0;
    double paintExtent = 0.0;
    double layoutOffset = 0.0;
    bool hasVisualOverflow = false;

    RenderBox? child = firstChild as RenderBox?;
    while (child != null) {
      final SliverExpansionTileParentData childParentData =
          child.parentData! as SliverExpansionTileParentData;

      child.layout(constraints.asBoxConstraints(), parentUsesSize: true);
      double childExtent = child.size.height;

      if (child != firstChild) {
        childExtent *= _animationController.value;
      }

      double paintOffset = layoutOffset - scrollOffset;
      childParentData.paintOffset = Offset(0, paintOffset);

      totalExtent += childExtent;
      layoutOffset += childExtent;

      paintExtent += childExtent;

      hasVisualOverflow = paintExtent > remainingPaintExtent;

      child = childAfter(child) as RenderBox?;
    }

    paintExtent -= scrollOffset;

    double clampedPaintExtent = paintExtent.clamp(0.0, remainingPaintExtent);

    geometry = SliverGeometry(
      scrollExtent: totalExtent,
      paintExtent: clampedPaintExtent,
      maxPaintExtent: totalExtent,
      hasVisualOverflow: hasVisualOverflow,
      cacheExtent: calculateCacheOffset(
        constraints,
        from: 0.0,
        to: totalExtent,
      ),
    );
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild as RenderBox?;
    final scrollOffset = constraints.scrollOffset;
    final double width = constraints.crossAxisExtent;
    final height = max(
      geometry!.scrollExtent * _animationController.value,
      child!.size.height,
    );

    context.pushClipRRect(
      needsCompositing,
      offset,
      Offset.zero & Size(width, height),
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, -scrollOffset, width, height),
        _borderRadius,
      ),
      (PaintingContext innerContext, Offset innerOffset) {
        final Canvas canvas = innerContext.canvas;

        while (child != null) {
          final SliverExpansionTileParentData childParentData =
              child!.parentData! as SliverExpansionTileParentData;
          if (child == firstChild || _animationController.value > 0) {
            context.paintChild(
              child!,
              childParentData.paintOffset + innerOffset,
            );
          }
          child = childAfter(child!) as RenderBox?;
        }

        if (_border != null) {
          final Path path =
              Path()..addRRect(
                RRect.fromRectAndRadius(
                  Rect.fromLTWH(
                    offset.dx,
                    offset.dy - scrollOffset,
                    width,
                    height,
                  ),
                  _borderRadius,
                ),
              );
          canvas.drawPath(path, _border!.toPaint());
        }
      },
    );
  }

  @override
  void applyPaintTransform(covariant RenderObject child, Matrix4 transform) {
    applyPaintTransformForBoxChild(child as RenderBox, transform);
  }

  @override
  double childMainAxisPosition(covariant RenderObject child) {
    final SliverExpansionTileParentData childParentData =
        child.parentData! as SliverExpansionTileParentData;
    return childParentData.paintOffset.dy;
  }

  @override
  bool hitTestChildren(
    SliverHitTestResult result, {
    required double mainAxisPosition,
    required double crossAxisPosition,
  }) {
    RenderBox? child = lastChild as RenderBox?;

    while (child != null) {
      final hit = hitTestBoxChild(
        BoxHitTestResult.wrap(result),
        child,
        mainAxisPosition: mainAxisPosition,
        crossAxisPosition: crossAxisPosition,
      );

      if (hit) return child == firstChild;
      child = childBefore(child) as RenderBox?;
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
