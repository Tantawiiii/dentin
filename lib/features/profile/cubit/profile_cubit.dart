import 'package:bloc/bloc.dart';

import '../data/repo/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _repository;

  ProfileCubit(this._repository) : super(ProfileInitial());

  Future<void> loadProfile() async {
    try {
      emit(ProfileLoading());
      final profileData = await _repository.getProfile();
      emit(ProfileLoaded(
        profileData.doctor,
        profileData.friendsCount,
      ));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}


