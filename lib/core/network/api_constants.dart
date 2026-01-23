final class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://back.dentin.cloud';

  static const String register = '/api/application-form';
  static const String login = '/api/user/login';
  static const String media = '/api/media';
  static const String sendOtp = '/api/send-otp';
  static const String verifyOtp = '/api/verify-otp';
  static const String resetPassword = '/api/reset-password';
  static const String postIndex = '/api/post/index';
  static const String postIndexPublic = '/api/post/index-public';
  static const String postCreate = '/api/post';
  static const String createComment = '/api/create-comment';
  static String likePost(int postId) => '/api/posts/$postId/like';
  static String reportPost(int postId) => '/api/posts/$postId/report';
  static String togglePostHidden(int postId) => '/api/post/$postId/is_hidden';
  static String togglePostSaved(int postId) => '/api/post/$postId/is_saved';
  static const String checkAuth = '/api/user/check-auth';
  static String updateUser(int userId) => '/api/user/$userId';
  static String togglePhoneVisibility(int userId) => '/api/user/$userId/is_phone_hidden';

  // Store / Products
  static const String productIndex = '/api/product/index';
  static const String productCreate = '/api/product';
  static String productDetails(int id) => '/api/product/$id';

  // Jobs
  static const String jobIndex = '/api/job/index';
  static const String jobCreate = '/api/job';
  static String jobDetails(int id) => '/api/job/$id';
  static String applyJob(int id) => '/api/jobs/$id/apply';

  // Messages / Chat
  static const String conversations = '/api/conversations';
  static const String chatMessages = '/api/chat/messages';
  static const String sendMessage = '/api/chat/send';
  static const String markAsRead = '/api/messages/mark-as-read';
  static const String uploadFile = '/api/chat/upload-file';

  // Rent Clinic
  static const String rentIndex = '/api/rent/index';
  static const String rentCreate = '/api/rent';
  static String rentDetails(int id) => '/api/rent/$id';
  static const String contactSeller = '/api/rent/contact-seller';

  // Events
  static const String eventIndex = '/api/event/index';
  static String eventDetails(int id) => '/api/event/$id';
}
