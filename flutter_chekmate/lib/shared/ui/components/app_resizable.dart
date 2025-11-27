import 'package:flutter/material.dart';

/// AppResizable - Resizable panels and split views for desktop-like layouts
class AppResizable extends StatefulWidget {
  const AppResizable({
    required this.children, super.key,
    this.direction = Axis.horizontal,
    this.initialSizes,
    this.minSizes,
    this.maxSizes,
    this.onSizeChanged,
    this.dividerThickness = 8.0,
    this.dividerColor,
    this.dividerHoverColor,
    this.showDividerHandle = true,
  });

  final List<Widget> children;
  final Axis direction;
  final List<double>? initialSizes;
  final List<double>? minSizes;
  final List<double>? maxSizes;
  final ValueChanged<List<double>>? onSizeChanged;
  final double dividerThickness;
  final Color? dividerColor;
  final Color? dividerHoverColor;
  final bool showDividerHandle;

  @override
  State<AppResizable> createState() => _AppResizableState();
}

class _AppResizableState extends State<AppResizable> {
  late List<double> _sizes;
  int? _draggingIndex;
  double? _dragStartPosition;
  double? _dragStartSize;

  @override
  void initState() {
    super.initState();
    _initializeSizes();
  }

  void _initializeSizes() {
    if (widget.initialSizes != null && widget.initialSizes!.length == widget.children.length) {
      _sizes = List.from(widget.initialSizes!);
    } else {
      // Equal distribution
      final equalSize = 1.0 / widget.children.length;
      _sizes = List.filled(widget.children.length, equalSize);
    }
  }

  void _onPanStart(DragStartDetails details, int dividerIndex) {
    setState(() {
      _draggingIndex = dividerIndex;
      _dragStartPosition = widget.direction == Axis.horizontal 
          ? details.localPosition.dx 
          : details.localPosition.dy;
      _dragStartSize = _sizes[dividerIndex];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_draggingIndex == null || _dragStartPosition == null || _dragStartSize == null) return;

    final currentPosition = widget.direction == Axis.horizontal 
        ? details.localPosition.dx 
        : details.localPosition.dy;
    
    final delta = currentPosition - _dragStartPosition!;
    final containerSize = widget.direction == Axis.horizontal 
        ? context.size?.width ?? 0
        : context.size?.height ?? 0;
    
    if (containerSize == 0) return;

    final deltaRatio = delta / containerSize;
    final newSize = (_dragStartSize! + deltaRatio).clamp(0.0, 1.0);
    
    // Apply min/max constraints
    final minSize = widget.minSizes != null && widget.minSizes!.length > _draggingIndex! 
        ? widget.minSizes![_draggingIndex!] 
        : 0.1;
    final maxSize = widget.maxSizes != null && widget.maxSizes!.length > _draggingIndex! 
        ? widget.maxSizes![_draggingIndex!] 
        : 0.9;
    
    final constrainedSize = newSize.clamp(minSize, maxSize);
    
    // Adjust adjacent panel
    final nextIndex = _draggingIndex! + 1;
    if (nextIndex < _sizes.length) {
      final sizeDifference = constrainedSize - _sizes[_draggingIndex!];
      final newNextSize = (_sizes[nextIndex] - sizeDifference).clamp(0.0, 1.0);
      
      setState(() {
        _sizes[_draggingIndex!] = constrainedSize;
        _sizes[nextIndex] = newNextSize;
      });
      
      widget.onSizeChanged?.call(_sizes);
    }
  }

  void _onPanEnd(DragEndDetails details) {
    setState(() {
      _draggingIndex = null;
      _dragStartPosition = null;
      _dragStartSize = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return LayoutBuilder(
      builder: (context, constraints) {
        final children = <Widget>[];
        
        for (var i = 0; i < widget.children.length; i++) {
          // Add panel
          final size = widget.direction == Axis.horizontal 
              ? Size(constraints.maxWidth * _sizes[i], constraints.maxHeight)
              : Size(constraints.maxWidth, constraints.maxHeight * _sizes[i]);
          
          children.add(
            SizedBox(
              width: widget.direction == Axis.horizontal ? size.width : null,
              height: widget.direction == Axis.vertical ? size.height : null,
              child: widget.children[i],
            ),
          );
          
          // Add divider (except after last panel)
          if (i < widget.children.length - 1) {
            children.add(
              _ResizableDivider(
                direction: widget.direction,
                thickness: widget.dividerThickness,
                color: widget.dividerColor ?? theme.colorScheme.outline.withOpacity(0.2),
                hoverColor: widget.dividerHoverColor ?? theme.colorScheme.outline.withOpacity(0.4),
                showHandle: widget.showDividerHandle,
                onPanStart: (details) => _onPanStart(details, i),
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                isDragging: _draggingIndex == i,
              ),
            );
          }
        }
        
        return widget.direction == Axis.horizontal 
            ? Row(children: children)
            : Column(children: children);
      },
    );
  }
}

class _ResizableDivider extends StatefulWidget {
  const _ResizableDivider({
    required this.direction,
    required this.thickness,
    required this.color,
    required this.hoverColor,
    required this.showHandle,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
    required this.isDragging,
  });

  final Axis direction;
  final double thickness;
  final Color color;
  final Color hoverColor;
  final bool showHandle;
  final GestureDragStartCallback onPanStart;
  final GestureDragUpdateCallback onPanUpdate;
  final GestureDragEndCallback onPanEnd;
  final bool isDragging;

  @override
  State<_ResizableDivider> createState() => _ResizableDividerState();
}

class _ResizableDividerState extends State<_ResizableDivider> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final isHorizontal = widget.direction == Axis.horizontal;
    
    return MouseRegion(
      cursor: isHorizontal ? SystemMouseCursors.resizeColumn : SystemMouseCursors.resizeRow,
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onPanStart: widget.onPanStart,
        onPanUpdate: widget.onPanUpdate,
        onPanEnd: widget.onPanEnd,
        child: Container(
          width: isHorizontal ? widget.thickness : null,
          height: isHorizontal ? null : widget.thickness,
          color: _isHovering || widget.isDragging ? widget.hoverColor : widget.color,
          child: widget.showHandle ? _buildHandle() : null,
        ),
      ),
    );
  }

  Widget _buildHandle() {
    final isHorizontal = widget.direction == Axis.horizontal;
    
    return Center(
      child: Container(
        width: isHorizontal ? 2 : 20,
        height: isHorizontal ? 20 : 2,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}

/// AppSplitView - Two-panel split view with resizable divider
class AppSplitView extends StatelessWidget {
  const AppSplitView({
    required this.left, required this.right, super.key,
    this.direction = Axis.horizontal,
    this.initialRatio = 0.5,
    this.minRatio = 0.1,
    this.maxRatio = 0.9,
    this.onRatioChanged,
    this.dividerThickness = 8.0,
    this.dividerColor,
    this.showDividerHandle = true,
  });

  final Widget left;
  final Widget right;
  final Axis direction;
  final double initialRatio;
  final double minRatio;
  final double maxRatio;
  final ValueChanged<double>? onRatioChanged;
  final double dividerThickness;
  final Color? dividerColor;
  final bool showDividerHandle;

  @override
  Widget build(BuildContext context) {
    return AppResizable(
      direction: direction,
      initialSizes: [initialRatio, 1.0 - initialRatio],
      minSizes: [minRatio, 1.0 - maxRatio],
      maxSizes: [maxRatio, 1.0 - minRatio],
      onSizeChanged: (sizes) => onRatioChanged?.call(sizes[0]),
      dividerThickness: dividerThickness,
      dividerColor: dividerColor,
      showDividerHandle: showDividerHandle,
      children: [left, right],
    );
  }
}

/// AppTripleSplitView - Three-panel split view
class AppTripleSplitView extends StatelessWidget {
  const AppTripleSplitView({
    required this.left, required this.center, required this.right, super.key,
    this.direction = Axis.horizontal,
    this.initialRatios = const [0.25, 0.5, 0.25],
    this.onRatiosChanged,
    this.dividerThickness = 8.0,
    this.dividerColor,
    this.showDividerHandle = true,
  });

  final Widget left;
  final Widget center;
  final Widget right;
  final Axis direction;
  final List<double> initialRatios;
  final ValueChanged<List<double>>? onRatiosChanged;
  final double dividerThickness;
  final Color? dividerColor;
  final bool showDividerHandle;

  @override
  Widget build(BuildContext context) {
    return AppResizable(
      direction: direction,
      initialSizes: initialRatios,
      onSizeChanged: onRatiosChanged,
      dividerThickness: dividerThickness,
      dividerColor: dividerColor,
      showDividerHandle: showDividerHandle,
      children: [left, center, right],
    );
  }
}

/// AppResizablePanel - Individual resizable panel with constraints
class AppResizablePanel extends StatelessWidget {
  const AppResizablePanel({
    required this.child, super.key,
    this.minSize = 100,
    this.maxSize = double.infinity,
    this.flex = 1,
    this.canResize = true,
  });

  final Widget child;
  final double minSize;
  final double maxSize;
  final int flex;
  final bool canResize;

  @override
  Widget build(BuildContext context) {
    if (!canResize) {
      return child;
    }

    return Flexible(
      flex: flex,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: minSize,
          maxWidth: maxSize,
          minHeight: minSize,
          maxHeight: maxSize,
        ),
        child: child,
      ),
    );
  }
}

/// AppCollapsiblePanel - Panel that can be collapsed/expanded
class AppCollapsiblePanel extends StatefulWidget {
  const AppCollapsiblePanel({
    required this.child, required this.isCollapsed, super.key,
    this.onToggle,
    this.collapsedSize = 0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.direction = Axis.horizontal,
  });

  final Widget child;
  final bool isCollapsed;
  final VoidCallback? onToggle;
  final double collapsedSize;
  final Duration animationDuration;
  final Axis direction;

  @override
  State<AppCollapsiblePanel> createState() => _AppCollapsiblePanelState();
}

class _AppCollapsiblePanelState extends State<AppCollapsiblePanel> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    if (!widget.isCollapsed) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AppCollapsiblePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isCollapsed != oldWidget.isCollapsed) {
      if (widget.isCollapsed) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final size = widget.collapsedSize + 
            (1.0 - widget.collapsedSize) * _animation.value;
        
        return widget.direction == Axis.horizontal
            ? SizedBox(
                width: size * 300, // Base width
                child: widget.child,
              )
            : SizedBox(
                height: size * 300, // Base height
                child: widget.child,
              );
      },
    );
  }
}
