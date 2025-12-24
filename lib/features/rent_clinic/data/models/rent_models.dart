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
      id: json['id'] as int,
      userName: json['user_name'] as String,
      profileImage: json['profile_image'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
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
      id: json['id'] as int,
      name: json['name'] as String,
      mimeType: json['mimeType'] as String,
      size: json['size'] as int,
      authorId: json['authorId'] as int?,
      previewUrl: json['previewUrl'] as String,
      fullUrl: json['fullUrl'] as String,
      createdAt: json['createdAt'] as String,
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
      id: json['id'] as int,
      name: json['name'] as String,
      price: json['price'] as String,
      des: json['des'] as String,
      type: json['type'] as String,
      duration: json['duration'] as int,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      governorate: json['governorate'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      gallery: (json['gallery'] as List<dynamic>?)
              ?.map((e) => RentGallery.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      user: RentUser.fromJson(json['user'] as Map<String, dynamic>),
      active: json['active'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
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
      data: (json['data'] as List<dynamic>)
          .map((e) => RentItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      links: RentPaginationLinks.fromJson(json['links'] as Map<String, dynamic>),
      meta: RentPaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
      result: json['result'] as String,
      message: json['message'] as String,
      status: json['status'] as int,
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
      currentPage: json['current_page'] as int,
      from: json['from'] as int,
      lastPage: json['last_page'] as int,
      path: json['path'] as String,
      perPage: json['per_page'] as int,
      to: json['to'] as int,
      total: json['total'] as int,
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
      result: json['result'] as String,
      message: json['message'] as String,
      status: json['status'] as int,
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
      result: json['result'] as String,
      rent: messageData?['rent'] != null
          ? RentItem.fromJson(messageData!['rent'] as Map<String, dynamic>)
          : null,
      message: messageData?['message'] as String? ?? json['message'] as String? ?? '',
      status: json['status'] as int,
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

