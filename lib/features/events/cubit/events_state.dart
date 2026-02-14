import '../data/models/event_models.dart';

abstract class EventsState {}

class EventsInitial extends EventsState {}

class EventsLoading extends EventsState {}

class EventsLoaded extends EventsState {
  final List<Event> events;

  EventsLoaded(this.events);
}

class EventsError extends EventsState {
  final String message;

  EventsError(this.message);
}
