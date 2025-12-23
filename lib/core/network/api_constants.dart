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
  static const String checkAuth = '/api/user/check-auth';

}
