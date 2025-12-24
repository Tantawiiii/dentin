import '../data/models/rent_models.dart';

abstract class RentState {
  const RentState();
}

class RentInitial extends RentState {}

class RentLoading extends RentState {}

class RentLoaded extends RentState {
  final List<RentItem> rents;
  final bool hasMore;
  final int currentPage;

  const RentLoaded(this.rents, {required this.hasMore, required this.currentPage});
}

class RentLoadingMore extends RentState {
  final List<RentItem> rents;
  final int currentPage;

  const RentLoadingMore(this.rents, this.currentPage);
}

class RentError extends RentState {
  final String message;

  const RentError(this.message);
}

// Details States
class RentDetailsLoading extends RentState {}

class RentDetailsLoaded extends RentState {
  final RentItem rent;

  const RentDetailsLoaded(this.rent);
}

class RentDetailsError extends RentState {
  final String message;

  const RentDetailsError(this.message);
}

// Create States
class RentCreating extends RentState {}

class RentCreated extends RentState {
  final RentItem rent;

  const RentCreated(this.rent);
}

class RentCreateError extends RentState {
  final String message;

  const RentCreateError(this.message);
}

// Contact Seller States
class ContactSellerSending extends RentState {}

class ContactSellerSent extends RentState {}

class ContactSellerError extends RentState {
  final String message;

  const ContactSellerError(this.message);
}

