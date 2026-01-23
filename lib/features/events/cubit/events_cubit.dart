import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repo/event_repository.dart';
import '../data/models/event_models.dart';
import 'events_state.dart';

class EventsCubit extends Cubit<EventsState> {
  final EventRepository _repository;

  EventsCubit(this._repository) : super(EventsInitial());

  List<Event> _events = [];

  List<Event> get events => _events;

  Future<void> loadEvents() async {
    emit(EventsLoading());

    try {
      final response = await _repository.getEvents(page: 1, perPage: 100);
      _events = response.data.where((event) => event.active).toList();
      emit(EventsLoaded(_events));
    } catch (e) {
      emit(EventsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
