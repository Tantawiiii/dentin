import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/repo/rent_repository.dart';
import '../data/models/rent_models.dart';
import 'rent_state.dart';

class RentCubit extends Cubit<RentState> {
  final RentRepository _repository;

  RentCubit(this._repository) : super(RentInitial());

  List<RentItem> _rents = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  List<RentItem> get rents => _rents;
  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> loadRents({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _rents = [];
    }

    if (_currentPage == 1) {
      emit(RentLoading());
    }

    try {
      final response = await _repository.getRents(page: _currentPage);
      if (refresh || _currentPage == 1) {
        _rents = response.data;
      } else {
        _rents.addAll(response.data);
      }

      _hasMore = response.meta.currentPage < response.meta.lastPage;
      _currentPage++;

      emit(
        RentLoaded(_rents, hasMore: _hasMore, currentPage: _currentPage - 1),
      );
    } catch (e) {
      emit(RentError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> loadMoreRents() async {
    if (!_hasMore || _isLoadingMore) return;

    _isLoadingMore = true;
    emit(RentLoadingMore(_rents, _currentPage));

    try {
      final response = await _repository.getRents(page: _currentPage);
      _rents.addAll(response.data);
      _hasMore = response.meta.currentPage < response.meta.lastPage;
      _currentPage++;

      emit(
        RentLoaded(_rents, hasMore: _hasMore, currentPage: _currentPage - 1),
      );
    } catch (e) {
      emit(
        RentLoaded(_rents, hasMore: _hasMore, currentPage: _currentPage - 1),
      );
    } finally {
      _isLoadingMore = false;
    }
  }

  Future<void> loadRentDetails(int id) async {
    emit(RentDetailsLoading());
    try {
      final response = await _repository.getRentDetails(id);
      if (response.data != null) {
        emit(RentDetailsLoaded(response.data!));
      } else {
        emit(RentDetailsError('Rent details not found'));
      }
    } catch (e) {
      emit(RentDetailsError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> createRent(CreateRentRequest request) async {
    emit(RentCreating());
    try {
      final response = await _repository.createRent(request);
      if (response.rent != null) {
        emit(RentCreated(response.rent!));
        // Refresh the list
        await loadRents(refresh: true);
      } else {
        emit(RentCreateError(response.message));
      }
    } catch (e) {
      emit(RentCreateError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> contactSeller(ContactSellerRequest request) async {
    emit(ContactSellerSending());
    try {
      await _repository.contactSeller(request);
      emit(ContactSellerSent());
    } catch (e) {
      emit(ContactSellerError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}

