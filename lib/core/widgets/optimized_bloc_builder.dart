import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

/// Optimized BlocBuilder with buildWhen for better performance
class OptimizedBlocBuilder<B extends StateStreamable<S>, S>
    extends StatelessWidget {
  final BlocWidgetBuilder<S> builder;
  final bool Function(S previous, S current)? buildWhen;
  final B? bloc;

  const OptimizedBlocBuilder({
    super.key,
    required this.builder,
    this.buildWhen,
    this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, S>(
      bloc: bloc,
      buildWhen: buildWhen ?? (previous, current) => previous != current,
      builder: builder,
    );
  }
}

/// Optimized BlocConsumer with buildWhen and listenWhen
class OptimizedBlocConsumer<B extends StateStreamable<S>, S>
    extends StatelessWidget {
  final BlocWidgetBuilder<S> builder;
  final BlocWidgetListener<S> listener;
  final bool Function(S previous, S current)? buildWhen;
  final bool Function(S previous, S current)? listenWhen;
  final B? bloc;

  const OptimizedBlocConsumer({
    super.key,
    required this.builder,
    required this.listener,
    this.buildWhen,
    this.listenWhen,
    this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<B, S>(
      bloc: bloc,
      buildWhen: buildWhen ?? (previous, current) => previous != current,
      listenWhen: listenWhen,
      builder: builder,
      listener: listener,
    );
  }
}
