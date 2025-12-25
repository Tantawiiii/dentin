import 'chat_user_model.dart';

enum MessageType { text, image, file, product }

class ChatMessage {
  final int id;
  final String body;
  final String createdAt;
  final ChatUser sender;
  final ChatUser receiver;
  final bool? isRead;
  final MessageType? type;
  final String? fileUrl;
  final String? fileName;
  final int? fileSize;
  final Map<String, dynamic>? productInfo;
  final int? timestamp;

  ChatMessage({
    required this.id,
    required this.body,
    required this.createdAt,
    required this.sender,
    required this.receiver,
    this.isRead,
    this.type,
    this.fileUrl,
    this.fileName,
    this.fileSize,
    this.productInfo,
    this.timestamp,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    MessageType? messageType;
    if (json['type'] != null) {
      switch (json['type'].toString().toLowerCase()) {
        case 'image':
          messageType = MessageType.image;
          break;
        case 'file':
          messageType = MessageType.file;
          break;
        case 'product':
          messageType = MessageType.product;
          break;
        default:
          messageType = MessageType.text;
      }
    }

    return ChatMessage(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      body: json['body'] ?? '',
      createdAt: json['created_at'] ?? json['createdAt'] ?? '',
      sender: json['sender'] != null
          ? (json['sender'] is Map<String, dynamic>
              ? ChatUser.fromJson(json['sender'] as Map<String, dynamic>)
              : ChatUser(
                  id: json['sender_id'] ?? 0,
                  userName: json['sender_name'] ?? 'User',
                  profileImage: json['sender_image'],
                  createdAt: '',
                  updatedAt: '',
                ))
          : ChatUser(
              id: json['sender_id'] ?? 0,
              userName: json['sender_name'] ?? 'User',
              profileImage: json['sender_image'],
              createdAt: '',
              updatedAt: '',
            ),
      receiver: json['receiver'] != null
          ? (json['receiver'] is Map<String, dynamic>
              ? ChatUser.fromJson(json['receiver'] as Map<String, dynamic>)
              : ChatUser(
                  id: json['receiver_id'] ?? 0,
                  userName: '',
                  profileImage: null,
                  createdAt: '',
                  updatedAt: '',
                ))
          : ChatUser(
              id: json['receiver_id'] ?? 0,
              userName: '',
              profileImage: null,
              createdAt: '',
              updatedAt: '',
            ),
      isRead: json['is_read'] ?? json['isRead'] ?? false,
      type: messageType,
      fileUrl: json['file_url'] ?? json['fileUrl'],
      fileName: json['file_name'] ?? json['fileName'],
      fileSize: json['file_size'] ?? json['fileSize'],
      productInfo: json['product_info'] ?? json['productInfo'],
      timestamp: json['timestamp'] is int
          ? json['timestamp']
          : int.tryParse(json['timestamp']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    String? typeString;
    if (type != null) {
      switch (type!) {
        case MessageType.image:
          typeString = 'image';
          break;
        case MessageType.file:
          typeString = 'file';
          break;
        case MessageType.product:
          typeString = 'product';
          break;
        default:
          typeString = 'text';
      }
    }

    return {
      'id': id,
      'body': body,
      'created_at': createdAt,
      'sender': sender.toJson(),
      'receiver': receiver.toJson(),
      'is_read': isRead,
      if (typeString != null) 'type': typeString,
      if (fileUrl != null) 'file_url': fileUrl,
      if (fileName != null) 'file_name': fileName,
      if (fileSize != null) 'file_size': fileSize,
      if (productInfo != null) 'product_info': productInfo,
      if (timestamp != null) 'timestamp': timestamp,
    };
  }
}
