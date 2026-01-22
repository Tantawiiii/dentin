class RentUser {
  final int id;
  final String userName;
  final String? profileImage;
  final String createdAt;
  final String updatedAt;

  RentUser({
    required this.id,
    required this.userName,
    this.profileImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RentUser.fromJson(Map<String, dynamic> json) {
    return RentUser(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      userName: json['user_name']?.toString() ?? '',
      profileImage: json['profile_image']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}

class RentGallery {
  final int id;
  final String name;
  final String mimeType;
  final int size;
  final int? authorId;
  final String previewUrl;
  final String fullUrl;
  final String createdAt;

  RentGallery({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.size,
    this.authorId,
    required this.previewUrl,
    required this.fullUrl,
    required this.createdAt,
  });

  factory RentGallery.fromJson(Map<String, dynamic> json) {
    return RentGallery(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      mimeType: json['mimeType']?.toString() ?? '',
      size: json['size'] is int ? json['size'] as int : int.tryParse(json['size']?.toString() ?? '0') ?? 0,
      authorId: json['authorId'] is int ? json['authorId'] as int : int.tryParse(json['authorId']?.toString() ?? ''),
      previewUrl: json['previewUrl']?.toString() ?? '',
      fullUrl: json['fullUrl']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
    );
  }
}

class RentItem {
  final int id;
  final String name;
  final String price;
  final String des;
  final String type;
  final int duration;
  final String? startDate;
  final String? endDate;
  final String? governorate;
  final String? city;
  final String? address;
  final List<RentGallery> gallery;
  final RentUser user;
  final bool active;
  final String createdAt;
  final String updatedAt;

  RentItem({
    required this.id,
    required this.name,
    required this.price,
    required this.des,
    required this.type,
    required this.duration,
    this.startDate,
    this.endDate,
    this.governorate,
    this.city,
    this.address,
    required this.gallery,
    required this.user,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RentItem.fromJson(Map<String, dynamic> json) {
    return RentItem(
      id: json['id'] is int ? json['id'] as int : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
      price: json['price']?.toString() ?? '0',
      des: json['des']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      duration: json['duration'] is int
          ? json['duration'] as int
          : int.tryParse(json['duration']?.toString() ?? '0') ?? 0,
      startDate: json['start_date']?.toString(),
      endDate: json['end_date']?.toString(),
      governorate: json['governorate']?.toString(),
      city: json['city']?.toString(),
      address: json['address']?.toString(),
      gallery: (json['gallery'] as List<dynamic>?)
              ?.map((e) => RentGallery.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      user: RentUser.fromJson(json['user'] as Map<String, dynamic>),
      active: json['active'] == true || json['active'] == 1 || json['active'] == "1",
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
}

class RentListResponse {
  final List<RentItem> data;
  final RentPaginationLinks links;
  final RentPaginationMeta meta;
  final String result;
  final String message;
  final int status;

  RentListResponse({
    required this.data,
    required this.links,
    required this.meta,
    required this.result,
    required this.message,
    required this.status,
  });

  factory RentListResponse.fromJson(Map<String, dynamic> json) {
    return RentListResponse(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => RentItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      links: RentPaginationLinks.fromJson(json['links'] as Map<String, dynamic>),
      meta: RentPaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
      result: json['result']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      status: json['status'] is int ? json['status'] as int : int.tryParse(json['status']?.toString() ?? '0') ?? 0,
    );
  }
}

class RentPaginationLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  RentPaginationLinks({
    this.first,
    this.last,
    this.prev,
    this.next,
  });

  factory RentPaginationLinks.fromJson(Map<String, dynamic> json) {
    return RentPaginationLinks(
      first: json['first'] as String?,
      last: json['last'] as String?,
      prev: json['prev'] as String?,
      next: json['next'] as String?,
    );
  }
}

class RentPaginationMeta {
  final int currentPage;
  final int from;
  final int lastPage;
  final String path;
  final int perPage;
  final int to;
  final int total;

  RentPaginationMeta({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory RentPaginationMeta.fromJson(Map<String, dynamic> json) {
    return RentPaginationMeta(
      currentPage: json['current_page'] is int ? json['current_page'] as int : int.tryParse(json['current_page']?.toString() ?? '0') ?? 0,
      from: json['from'] is int ? json['from'] as int : int.tryParse(json['from']?.toString() ?? '0') ?? 0,
      lastPage: json['last_page'] is int ? json['last_page'] as int : int.tryParse(json['last_page']?.toString() ?? '0') ?? 0,
      path: json['path']?.toString() ?? '',
      perPage: json['per_page'] is int ? json['per_page'] as int : int.tryParse(json['per_page']?.toString() ?? '0') ?? 0,
      to: json['to'] is int ? json['to'] as int : int.tryParse(json['to']?.toString() ?? '0') ?? 0,
      total: json['total'] is int ? json['total'] as int : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
    );
  }
}

class RentDetailsResponse {
  final RentItem? data;
  final String result;
  final String message;
  final int status;

  RentDetailsResponse({
    this.data,
    required this.result,
    required this.message,
    required this.status,
  });

  factory RentDetailsResponse.fromJson(Map<String, dynamic> json) {
    return RentDetailsResponse(
      data: json['data'] != null
          ? RentItem.fromJson(json['data'] as Map<String, dynamic>)
          : null,
      result: json['result']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      status: json['status'] is int ? json['status'] as int : int.tryParse(json['status']?.toString() ?? '0') ?? 0,
    );
  }
}

class CreateRentRequest {
  final String name;
  final double price;
  final String des;
  final List<int> gallery;
  final String type;
  final String duration;
  final String? startDate;
  final String? endDate;
  final String? governorate;
  final String? city;
  final String? address;

  CreateRentRequest({
    required this.name,
    required this.price,
    required this.des,
    required this.gallery,
    required this.type,
    required this.duration,
    this.startDate,
    this.endDate,
    this.governorate,
    this.city,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'des': des,
      'gallery': gallery,
      'type': type,
      'duration': duration,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      if (governorate != null) 'governorate': governorate,
      if (city != null) 'city': city,
      if (address != null) 'address': address,
    };
  }
}

class CreateRentResponse {
  final String result;
  final RentItem? rent;
  final String message;
  final int status;

  CreateRentResponse({
    required this.result,
    this.rent,
    required this.message,
    required this.status,
  });

  factory CreateRentResponse.fromJson(Map<String, dynamic> json) {
    final messageData = json['message'] as Map<String, dynamic>?;
    return CreateRentResponse(
      result: json['result']?.toString() ?? '',
      rent: messageData?['rent'] != null
          ? RentItem.fromJson(messageData!['rent'] as Map<String, dynamic>)
          : null,
      message: messageData?['message']?.toString() ?? json['message']?.toString() ?? '',
      status: json['status'] is int ? json['status'] as int : int.tryParse(json['status']?.toString() ?? '0') ?? 0,
    );
  }
}

class ContactSellerRequest {
  final int rentId;
  final String message;

  ContactSellerRequest({
    required this.rentId,
    required this.message,
  });

  Map<String, dynamic> toJson() {
    return {
      'rent_id': rentId,
      'message': message,
    };
  }
}

