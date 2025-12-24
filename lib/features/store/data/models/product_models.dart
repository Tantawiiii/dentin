class ProductResponse {
  final List<Product> data;
  final PaginationLinks? links;
  final PaginationMeta? meta;
  final String result;
  final String message;
  final int status;

  ProductResponse({
    required this.data,
    this.links,
    this.meta,
    required this.result,
    required this.message,
    required this.status,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      data: (json['data'] as List<dynamic>?)
              ?.map((e) => Product.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      links: json['links'] != null
          ? PaginationLinks.fromJson(json['links'] as Map<String, dynamic>)
          : null,
      meta: json['meta'] != null
          ? PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>)
          : null,
      result: json['result'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
    );
  }
}

class PaginationLinks {
  final String? first;
  final String? last;
  final String? prev;
  final String? next;

  PaginationLinks({this.first, this.last, this.prev, this.next});

  factory PaginationLinks.fromJson(Map<String, dynamic> json) {
    return PaginationLinks(
      first: json['first'],
      last: json['last'],
      prev: json['prev'],
      next: json['next'],
    );
  }
}

class PaginationMeta {
  final int currentPage;
  final int from;
  final int lastPage;
  final String path;
  final int perPage;
  final int to;
  final int total;

  PaginationMeta({
    required this.currentPage,
    required this.from,
    required this.lastPage,
    required this.path,
    required this.perPage,
    required this.to,
    required this.total,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] ?? 1,
      from: json['from'] ?? 0,
      lastPage: json['last_page'] ?? 1,
      path: json['path'] ?? '',
      perPage: json['per_page'] ?? 10,
      to: json['to'] ?? 0,
      total: json['total'] ?? 0,
    );
  }

  bool get hasMorePages => currentPage < lastPage;
}

class Product {
  final int id;
  final String name;
  final double price;
  final double discount;
  final num priceAfterDiscount;
  final String? description;
  final bool isNew;
  final List<ProductGallery> gallery;
  final ProductUser user;
  final bool active;
  final String createdAt;
  final String updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.discount,
    required this.priceAfterDiscount,
    required this.description,
    required this.isNew,
    required this.gallery,
    required this.user,
    required this.active,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: double.tryParse(json['price']?.toString() ?? '') ?? 0.0,
      discount: double.tryParse(json['discount']?.toString() ?? '') ?? 0.0,
      priceAfterDiscount:
          num.tryParse(json['price_after_discount']?.toString() ?? '0') ?? 0,
      description: json['des'],
      isNew: json['is_new'] == true ||
          json['is_new'] == 1 ||
          json['is_new'] == '1',
      gallery: (json['gallery'] as List<dynamic>?)
              ?.map((e) => ProductGallery.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      user: ProductUser.fromJson(json['user'] as Map<String, dynamic>),
      active: json['active'] == true ||
          json['active'] == 1 ||
          json['active'] == '1',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class ProductUser {
  final int id;
  final String userName;
  final String profileImage;
  final String createdAt;
  final String updatedAt;

  ProductUser({
    required this.id,
    required this.userName,
    required this.profileImage,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductUser.fromJson(Map<String, dynamic> json) {
    return ProductUser(
      id: json['id'] ?? 0,
      userName: json['user_name'] ?? '',
      profileImage: json['profile_image'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class ProductGallery {
  final int id;
  final String name;
  final String mimeType;
  final int size;
  final int? authorId;
  final String previewUrl;
  final String fullUrl;
  final String createdAt;

  ProductGallery({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.size,
    this.authorId,
    required this.previewUrl,
    required this.fullUrl,
    required this.createdAt,
  });

  factory ProductGallery.fromJson(Map<String, dynamic> json) {
    return ProductGallery(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      mimeType: json['mimeType'] ?? '',
      size: json['size'] ?? 0,
      authorId: json['authorId'],
      previewUrl: json['previewUrl'] ?? '',
      fullUrl: json['fullUrl'] ?? '',
      createdAt: json['createdAt'] ?? '',
    );
  }
}

class CreateProductRequest {
  final String name;
  final num price;
  final num discount;
  final String description;
  final int image;
  final bool isNew;

  CreateProductRequest({
    required this.name,
    required this.price,
    required this.discount,
    required this.description,
    required this.image,
    required this.isNew,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'discount': discount,
      'des': description,
      'image': image,
      'is_new': isNew ? 1 : 0,
    };
  }
}

class CreateProductResponse {
  final Product? data;
  final String? message;

  CreateProductResponse({
    this.data,
    this.message,
  });

  factory CreateProductResponse.fromJson(Map<String, dynamic> json) {
    // Backend may return:
    // { result: "Success", data: null, message: { message: "...", product: { ... } }, status: 200 }
    // or put the product directly under "data".
    Product? product;
    final dataField = json['data'];
    if (dataField is Map<String, dynamic>) {
      product = Product.fromJson(dataField);
    } else {
      final messageField = json['message'];
      if (messageField is Map<String, dynamic>) {
        final productField = messageField['product'];
        if (productField is Map<String, dynamic>) {
          product = Product.fromJson(productField);
        }
      }
    }

    String? message;
    final rawMessage = json['message'];
    if (rawMessage is String) {
      message = rawMessage;
    } else if (rawMessage is Map<String, dynamic>) {
      message = rawMessage['message']?.toString();
    }

    return CreateProductResponse(
      data: product,
      message: message,
    );
  }
}

class ProductDetailsResponse {
  final String result;
  final Product data;
  final String message;
  final int status;

  ProductDetailsResponse({
    required this.result,
    required this.data,
    required this.message,
    required this.status,
  });

  factory ProductDetailsResponse.fromJson(Map<String, dynamic> json) {
    return ProductDetailsResponse(
      result: json['result'] ?? '',
      data: Product.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
    );
  }
}


