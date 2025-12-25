import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/constant/app_colors.dart';
import '../../../core/di/inject.dart' as di;
import '../../../core/services/storage_service.dart';
import '../cubit/chat_cubit.dart';
import '../cubit/chat_state.dart';
import '../data/models/chat_user_model.dart';
import '../data/models/chat_message_model.dart';
import '../widgets/chat_messages_shimmer.dart';
import 'widgets/chat_app_bar_title.dart';
import 'widgets/chat_empty_messages_view.dart';
import 'widgets/chat_typing_indicator.dart';
import 'widgets/chat_message_item.dart';
import 'widgets/chat_quick_replies_bar.dart';
import 'widgets/chat_emoji_picker.dart';
import 'widgets/chat_input_area.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatUser receiverUser;

  const ChatDetailScreen({super.key, required this.receiverUser});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();
  late ChatCubit _chatCubit;
  int? _currentUserId;
  bool _showEmojis = false;
  bool _isUploading = false;
  Timer? _typingTimer;

  static const List<String> _doctorQuickReplies = [
    "What are your symptoms?",
    "When did the symptoms start?",
    "Do you have any allergies?",
    "Are you taking any medications?",
    "Can you describe the pain?",
    "I'll review your test results",
  ];

  static const List<String> _patientQuickReplies = [
    "I need to schedule an appointment",
    "Can you explain the diagnosis?",
    "What are the treatment options?",
    "Are there any side effects?",
    "When should I follow up?",
    "Thank you doctor",
  ];

  static const List<String> _quickEmojis = [
    '😊',
    '👍',
    '❤️',
    '😂',
    '😍',
    '🙏',
    '👏',
    '🔥',
    '🎉',
    '🤔',
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _chatCubit = di.sl<ChatCubit>();
    final storageService = di.sl<StorageService>();
    final userData = storageService.getUserData();
    _currentUserId = userData?.id;

    if (_currentUserId != null) {
      _chatCubit.loadMessages(widget.receiverUser.id);
    }

    _messageController.addListener(_onTextChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  void _onTextChanged() {
    _typingTimer?.cancel();

    if (_messageController.text.isNotEmpty) {
      _chatCubit.sendTypingIndicator(widget.receiverUser.id, true);
      _typingTimer = Timer(const Duration(seconds: 2), () {
        _chatCubit.sendTypingIndicator(widget.receiverUser.id, false);
      });
    } else {
      _chatCubit.sendTypingIndicator(widget.receiverUser.id, false);
    }
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _typingTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animate = true}) {
    if (!_scrollController.hasClients) return;

    if (animate) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  String _formatTime(String? dateTime) {
    if (dateTime == null) return '';
    try {
      final date = DateTime.parse(dateTime);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return '';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes == 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    final i = (bytes / k).floor();
    return '${(bytes / (k * i)).toStringAsFixed(2)} ${sizes[i]}';
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty || _currentUserId == null) {
      return;
    }

    _chatCubit.sendMessage(
      _messageController.text.trim(),
      widget.receiverUser.id,
    );
    _messageController.clear();
    _scrollToBottom(animate: false);
  }

  Future<void> _pickImage() async {
    try {
      final status = await Permission.photos.request();
      if (!status.isGranted) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Permission denied')));
        }
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null && _currentUserId != null) {
        setState(() => _isUploading = true);
        final file = File(image.path);
        final fileSize = await file.length();

        await _chatCubit.sendFile(
          filePath: image.path,
          receiverId: widget.receiverUser.id,
          fileName: image.name,
          fileSize: fileSize,
          isImage: true,
        );

        if (mounted) {
          setState(() => _isUploading = false);
          _scrollToBottom(animate: false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null &&
          result.files.single.path != null &&
          _currentUserId != null) {
        setState(() => _isUploading = true);
        final file = File(result.files.single.path!);
        final fileSize = await file.length();

        await _chatCubit.sendFile(
          filePath: result.files.single.path!,
          receiverId: widget.receiverUser.id,
          fileName: result.files.single.name,
          fileSize: fileSize,
          isImage: false,
        );

        if (mounted) {
          setState(() => _isUploading = false);
          _scrollToBottom(animate: false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking file: $e')));
      }
    }
  }

  void _sendEmoji(String emoji) {
    if (_currentUserId == null) return;
    _chatCubit.sendMessage(emoji, widget.receiverUser.id);
    setState(() => _showEmojis = false);
    _scrollToBottom(animate: false);
  }

  void _sendQuickReply(String reply) {
    _messageController.text = reply;
    _messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: reply.length),
    );
    FocusScope.of(context).requestFocus(FocusNode());
  }

  String _getUserType() {
    final storageService = di.sl<StorageService>();
    final userData = storageService.getUserData();

    if (userData?.hasClinic == true ||
        (userData?.specialization != null &&
            userData!.specialization!.isNotEmpty)) {
      return 'doctor';
    }
    return 'patient';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final userType = _getUserType();
    final quickReplies = userType == 'doctor'
        ? _doctorQuickReplies
        : _patientQuickReplies;

    return BlocProvider.value(
      value: _chatCubit,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: ChatAppBarTitle(
            receiverUser: widget.receiverUser,
            chatCubit: _chatCubit,
          ),
          backgroundColor: AppColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: BlocConsumer<ChatCubit, ChatState>(
          listener: (context, state) {
            if (state is MessagesLoaded) {
              Future.microtask(() => _scrollToBottom());
            }
          },
          builder: (context, state) {
            if (state is MessagesLoading) {
              return const ChatMessagesShimmer();
            }

            if (state is MessagesError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.message,
                      style: TextStyle(color: AppColors.error, fontSize: 14.sp),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        if (_currentUserId != null) {
                          _chatCubit.loadMessages(widget.receiverUser.id);
                        }
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            List<ChatMessage> messages = [];
            if (state is MessagesLoaded) {
              messages = state.messages;
            } else if (state is MessageSent) {
              messages = state.messages;
            } else if (state is MessageSending) {
              messages = state.messages;
            } else if (state is MessageSendError) {
              messages = state.messages;
            } else if (state is ConversationsLoaded) {
              messages = _chatCubit.messages;
            }

            return Column(
              children: [
                Expanded(
                  child: messages.isEmpty
                      ? ChatEmptyMessagesView(
                          receiverName: widget.receiverUser.userName,
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            if (_currentUserId != null) {
                              await _chatCubit.refreshMessages(
                                widget.receiverUser.id,
                              );
                            }
                          },
                          color: AppColors.primary,
                          backgroundColor: AppColors.surface,
                          strokeWidth: 2.5,
                          child: ListView.builder(
                            controller: _scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: EdgeInsets.all(16.w),
                            cacheExtent: 1000,
                            itemCount:
                                messages.length + (_chatCubit.isTyping ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == messages.length &&
                                  _chatCubit.isTyping) {
                                return const ChatTypingIndicator();
                              }

                              final message = messages[index];
                              return ChatMessageItem(
                                key: ValueKey(
                                  '${message.id}_${message.timestamp}',
                                ),
                                message: message,
                                currentUserId: _currentUserId,
                                formatTime: _formatTime,
                                formatFileSize: _formatFileSize,
                              );
                            },
                          ),
                        ),
                ),
                if (quickReplies.isNotEmpty)
                  ChatQuickRepliesBar(
                    quickReplies: quickReplies,
                    onReplyTap: _sendQuickReply,
                  ),
                if (_showEmojis)
                  ChatEmojiPicker(emojis: _quickEmojis, onEmojiTap: _sendEmoji),
                ChatInputArea(
                  messageController: _messageController,
                  isUploading: _isUploading,
                  showEmojis: _showEmojis,
                  onSend: _sendMessage,
                  onAttach: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (context) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(
                                Icons.image,
                                color: AppColors.primary,
                              ),
                              title: const Text('Pick Image'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage();
                              },
                            ),
                            ListTile(
                              leading: const Icon(
                                Icons.insert_drive_file,
                                color: AppColors.primary,
                              ),
                              title: const Text('Pick File'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickFile();
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  onEmojiToggle: () {
                    setState(() => _showEmojis = !_showEmojis);
                  },
                  state: state,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
