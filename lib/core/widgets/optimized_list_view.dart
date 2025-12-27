import 'package:flutter/material.dart';

/// Optimized ListView with performance settings
class OptimizedListView extends StatelessWidget {
  final List<Widget> children;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final ScrollController? controller;

  const OptimizedListView({
    super.key,
    required this.children,
    this.padding,
    this.physics,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      padding: padding,
      physics: physics ?? const BouncingScrollPhysics(),
      cacheExtent: 500,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      children: children,
    );
  }
}

/// Optimized ListView.builder with performance settings
class OptimizedListViewBuilder extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final ScrollController? controller;

  const OptimizedListViewBuilder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.padding,
    this.physics,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller,
      padding: padding,
      physics: physics ?? const BouncingScrollPhysics(),
      cacheExtent: 500,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}

/// Optimized GridView.builder with performance settings
class OptimizedGridViewBuilder extends StatelessWidget {
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final SliverGridDelegate gridDelegate;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final ScrollController? controller;

  const OptimizedGridViewBuilder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    required this.gridDelegate,
    this.padding,
    this.physics,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: controller,
      padding: padding,
      physics: physics ?? const BouncingScrollPhysics(),
      cacheExtent: 500,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      gridDelegate: gridDelegate,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
    );
  }
}
