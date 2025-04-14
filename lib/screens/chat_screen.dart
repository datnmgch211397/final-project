import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../data/firebase_service/chat_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';


class ChatScreen extends StatefulWidget {
  final String? chatId;
  final String receiverId;

  const ChatScreen({
    required this.chatId,
    required this.receiverId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FirebaseAuth authController = FirebaseAuth.instance;
  final ChatController chatController = ChatController();

  User? loggedInUser;
  String? chatId;
  ValueNotifier<File?> selectedImageFileNotifier = ValueNotifier<File?>(null);
  ValueNotifier<String?> selectedImageUrlNotifier = ValueNotifier<String?>(null);

  @override
  void initState() {
    super.initState();
    chatId = widget.chatId;
    getCurrentUser();
  }

  void getCurrentUser() {
    final user = authController.currentUser;
    if (user != null) {
      setState(() {
        loggedInUser = user;
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      selectedImageFileNotifier.value = File(pickedFile.path);
      final imageUrl = await chatController.uploadImage(selectedImageFileNotifier.value!);
      selectedImageUrlNotifier.value = imageUrl;
    }
  }

  Future<void> _sendMessage() async {
    if (selectedImageUrlNotifier.value != null) {
      if (chatId == null || chatId!.isEmpty) {
        chatId = await chatController.createChatRoom(widget.receiverId);
      }
      if (chatId != null) {
        chatController.sendMessage(
          chatId!,
          selectedImageUrlNotifier.value!,
          widget.receiverId,
          isImage: true,
        );
        selectedImageUrlNotifier.value = null;
        selectedImageFileNotifier.value = null;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController _messageController = TextEditingController();
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(widget.receiverId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final receiverData = snapshot.data!.data() as Map<String, dynamic>;

          return Scaffold(
            backgroundColor: Color(0xFFE9EBF8),
            appBar: AppBar(
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(receiverData['profile']),
                  ),
                  SizedBox(width: 16),
                  Text(receiverData['username']),
                ],
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: chatId != null && chatId!.isNotEmpty
                      ? MessageStream(chatId: chatId!)
                      : Center(
                    child: Text('No messages yet'),
                  ),
                ),
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _pickImage,
                        icon: Icon(
                          Icons.image,
                          color: Color(0xFF3876FD),
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            ValueListenableBuilder<File?>(
                              valueListenable: selectedImageFileNotifier,
                              builder: (context, selectedImageFile, child) {
                                if (selectedImageFile != null) {
                                  return Positioned(
                                    left: 0,
                                    child: Image.file(
                                      selectedImageFile,
                                      height: 50, // Set the height to make the image smaller
                                    ),
                                  );
                                }
                                return SizedBox.shrink();
                              },
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: selectedImageFileNotifier.value != null ? 60 : 0),
                              child: ValueListenableBuilder<File?>(
                                valueListenable: selectedImageFileNotifier,
                                builder: (context, selectedImageFile, child) {
                                  return TextFormField(
                                    controller: _messageController,
                                    decoration: InputDecoration(
                                      hintStyle: TextStyle(color: Colors.grey),
                                      border: InputBorder.none,
                                      hintText: selectedImageFile != null ? '' : 'Enter your message',
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () async {
                          if (_messageController.text.isNotEmpty) {
                            if (chatId == null || chatId!.isEmpty) {
                              chatId = await chatController.createChatRoom(widget.receiverId);
                            }
                            if (chatId != null) {
                              chatController.sendMessage(
                                chatId!,
                                _messageController.text,
                                widget.receiverId,
                              );
                              _messageController.clear();
                            }
                          } else if (selectedImageUrlNotifier.value != null) {
                            await _sendMessage();
                          }
                        },
                        icon: Icon(
                          Icons.send,
                          color: Color(0xFF3876FD),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        }
        return Scaffold(
          appBar: AppBar(),
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

class MessageStream extends StatelessWidget {
  final String chatId;
  const MessageStream({required this.chatId});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        final messages = snapshot.data!.docs;
        List<MessageBubble> messageWidgets = [];
        for (var message in messages) {
          final messageData = message.data() as Map<String, dynamic>;
          final messageText = messageData['message'] ?? '';
          final messageSender = messageData['senderId'] ?? '';
          final timestamp = messageData['timestamp'] ?? FieldValue.serverTimestamp();
          final isImage = messageData['isImage'] ?? false;
          final currentUser = FirebaseAuth.instance.currentUser!.uid;

          final messageWidget = MessageBubble(
            sender: messageSender,
            text: messageText,
            isMe: currentUser == messageSender,
            timestamp: timestamp,
            messageId: message.id,
            chatId: chatId,
            isImage: isImage,
          );
          messageWidgets.add(messageWidget);
        }
        return ListView(
          reverse: true,
          children: messageWidgets,
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String sender;
  final String text;
  final bool isMe;
  final dynamic timestamp;
  final String messageId;
  final String chatId;
  final bool isImage;

  const MessageBubble({
    super.key,
    required this.sender,
    required this.text,
    required this.isMe,
    this.timestamp,
    required this.messageId,
    required this.chatId,
    this.isImage = false,
  });

  @override
  Widget build(BuildContext context) {
    final DateTime messageTime = (timestamp is Timestamp) ? timestamp.toDate() : DateTime.now();
    return GestureDetector(
      onLongPress: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Message Options'),
              content: Text('Choose an action for this message:'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                if (isMe)
                  TextButton(
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chatId)
                          .collection('messages')
                          .doc(messageId)
                          .delete();
                      Navigator.of(context).pop();
                    },
                    child: Text('Delete'),
                  ),
                if (isMe)
                  TextButton(
                    onPressed: () {
                      FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chatId)
                          .collection('messages')
                          .doc(messageId)
                          .update({'message': 'This message has been recalled'});
                      Navigator.of(context).pop();
                    },
                    child: Text('Recall'),
                  ),
              ],
            );
          },
        );
      },
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: isImage
                  ? null
                  : BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    spreadRadius: 2,
                  ),
                ],
                borderRadius: isMe
                    ? BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                )
                    : BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
                color: isMe ? Color(0xFF3876FD) : Colors.white,
              ),
              child: Padding(
                padding: isImage ? EdgeInsets.zero : EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isImage
                        ? Image.network(text, width: 200)
                        : Text(
                      text,
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "${messageTime.hour}:${messageTime.minute}",
                      style: TextStyle(
                        color: isMe ? Colors.white : Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}