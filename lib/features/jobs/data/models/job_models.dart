class JobResponse {
  final List<Job> data;
  final PaginationLinks? links;
  final PaginationMeta? meta;
  final String result;
  final String message;
  final int status;

  JobResponse({
    required this.data,
    this.links,
    this.meta,
    required this.result,
    required this.message,
    required this.status,
  });

  factory JobResponse.fromJson(Map<String, dynamic> json) {
    return JobResponse(
      data:
          (json['data'] as List<dynamic>?)
              ?.map((e) => Job.fromJson(e as Map<String, dynamic>))
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

class Job {
  final int id;
  final Company company;
  final String title;
  final String location;
  final String type;
  final String salary;
  final bool available;
  final bool active;
  final String description;
  final String image;
  final String responsibilities;
  final String requirements;
  final String benefits;
  final int applicationsCount;
  final String createdAt;

  Job({
    required this.id,
    required this.company,
    required this.title,
    required this.location,
    required this.type,
    required this.salary,
    required this.available,
    required this.active,
    required this.description,
    required this.image,
    required this.responsibilities,
    required this.requirements,
    required this.benefits,
    required this.applicationsCount,
    required this.createdAt,
  });

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'] ?? 0,
      company: Company.fromJson(
        json['company'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      type: json['type'] ?? '',
      salary: json['salary']?.toString() ?? '',
      available:
          json['available'] == true ||
          json['available'] == 1 ||
          json['available'] == '1',
      active:
          json['active'] == true ||
          json['active'] == 1 ||
          json['active'] == '1',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      responsibilities: json['responsibilities'] ?? '',
      requirements: json['requirements'] ?? '',
      benefits: json['benefits'] ?? '',
      applicationsCount: json['applications_count'] ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class Company {
  final String? name;
  final String? size;
  final String? industry;
  final String? founded;
  final String? website;
  final String? location;

  Company({
    this.name,
    this.size,
    this.industry,
    this.founded,
    this.website,
    this.location,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      name: json['name'] as String?,
      size: json['size'] as String?,
      industry: json['industry'] as String?,
      founded: json['founded']?.toString(),
      website: json['website'] as String?,
      location: json['location'] as String?,
    );
  }
}

class JobDetailsResponse {
  final String result;
  final Job data;
  final String message;
  final int status;

  JobDetailsResponse({
    required this.result,
    required this.data,
    required this.message,
    required this.status,
  });

  factory JobDetailsResponse.fromJson(Map<String, dynamic> json) {
    return JobDetailsResponse(
      result: json['result'] ?? '',
      data: Job.fromJson(json['data'] as Map<String, dynamic>),
      message: json['message'] ?? '',
      status: json['status'] ?? 0,
    );
  }
}

class ApplyJobResponse {
  final String result;
  final String message;
  final int status;

  ApplyJobResponse({
    required this.result,
    required this.message,
    required this.status,
  });

  factory ApplyJobResponse.fromJson(Map<String, dynamic> json) {
    return ApplyJobResponse(
      result: json['result'] ?? '',
      message: json['message']?.toString() ?? '',
      status: json['status'] ?? 0,
    );
  }
}

class CreateJobRequest {
  final String companyName;
  final String? companySize;
  final String? companyIndustry;
  final String? companyFounded;
  final String? companyWebsite;
  final String? companyLocation;
  final String title;
  final String location;
  final String type;
  final String salary;
  final int? image;
  final bool available;
  final String description;
  final String? responsibilities;
  final String? requirements;
  final String? benefits;

  CreateJobRequest({
    required this.companyName,
    this.companySize,
    this.companyIndustry,
    this.companyFounded,
    this.companyWebsite,
    this.companyLocation,
    required this.title,
    required this.location,
    required this.type,
    required this.salary,
    this.image,
    this.available = true,
    required this.description,
    this.responsibilities,
    this.requirements,
    this.benefits,
  });

  Map<String, dynamic> toJson() {
    return {
      'company_name': companyName,
      if (companySize != null) 'company_size': companySize,
      if (companyIndustry != null) 'company_industry': companyIndustry,
      if (companyFounded != null) 'company_founded': companyFounded,
      if (companyWebsite != null) 'company_website': companyWebsite,
      if (companyLocation != null) 'company_location': companyLocation,
      'title': title,
      'location': location,
      'type': type,
      'salary': salary,
      if (image != null && image! > 0) 'image': image,
      'available': available,
      'description': description,
      if (responsibilities != null) 'responsibilities': responsibilities,
      if (requirements != null) 'requirements': requirements,
      if (benefits != null) 'benefits': benefits,
    };
  }
}

class CreateJobResponse {
  final String result;
  final CreateJobData? data;
  final String message;
  final int status;

  CreateJobResponse({
    required this.result,
    this.data,
    required this.message,
    required this.status,
  });

  factory CreateJobResponse.fromJson(Map<String, dynamic> json) {
    CreateJobData? jobData;

    if (json['message'] != null && json['message'] is Map) {
      final messageData = json['message'] as Map<String, dynamic>;
      if (messageData['job'] != null) {
        jobData = CreateJobData.fromJson(
          messageData['job'] as Map<String, dynamic>,
        );
      }
    }

    return CreateJobResponse(
      result: json['result'] ?? '',
      data: jobData,
      message: json['message'] is Map
          ? (json['message'] as Map)['message']?.toString() ?? ''
          : json['message']?.toString() ?? '',
      status: json['status'] ?? 0,
    );
  }
}

class CreateJobData {
  final int id;
  final Company company;
  final String title;
  final String location;
  final String type;
  final String salary;
  final bool available;
  final bool active;
  final String description;
  final String image;
  final String responsibilities;
  final String requirements;
  final String benefits;
  final int applicationsCount;
  final String createdAt;

  CreateJobData({
    required this.id,
    required this.company,
    required this.title,
    required this.location,
    required this.type,
    required this.salary,
    required this.available,
    required this.active,
    required this.description,
    required this.image,
    required this.responsibilities,
    required this.requirements,
    required this.benefits,
    required this.applicationsCount,
    required this.createdAt,
  });

  factory CreateJobData.fromJson(Map<String, dynamic> json) {
    return CreateJobData(
      id: json['id'] ?? 0,
      company: Company.fromJson(
        json['company'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      title: json['title'] ?? '',
      location: json['location'] ?? '',
      type: json['type'] ?? '',
      salary: json['salary']?.toString() ?? '',
      available:
          json['available'] == true ||
          json['available'] == 1 ||
          json['available'] == '1',
      active:
          json['active'] == true ||
          json['active'] == 1 ||
          json['active'] == '1',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      responsibilities: json['responsibilities'] ?? '',
      requirements: json['requirements'] ?? '',
      benefits: json['benefits'] ?? '',
      applicationsCount: json['applications_count'] ?? 0,
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}
