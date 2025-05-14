import 'package:flutter/material.dart';
import 'package:smart_assist/config/component/color/colors.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

class Message {
  final String body;
  final bool fromMe;
  final int timestamp;
  final String type;
  final String? mediaUrl;
  final String? id; // Add this field

  Message({
    required this.body,
    required this.fromMe,
    required this.timestamp,
    required this.type,
    this.mediaUrl,
    this.id, // Add this field
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      body: json['body'] ?? '',
      fromMe: json['fromMe'] ?? false,
      timestamp:
          json['timestamp'] ?? (DateTime.now().millisecondsSinceEpoch ~/ 1000),
      type: json['type'] ?? 'chat',
      mediaUrl: json['mediaUrl'],
      id: json['id'], // Parse the ID
    );
  }
}

class WhatsappChat extends StatefulWidget {
  final String chatId;
  final String userName;

  const WhatsappChat({
    super.key,
    required this.chatId,
    required this.userName,
  });

  @override
  State<WhatsappChat> createState() => _WhatsappChatState();
}

class MessageBubble extends StatelessWidget {
  final Message message;
  final String timeString;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.timeString,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.fromMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 3),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.fromMe
              ? const Color.fromARGB(255, 198, 210, 248)
              : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 1),
              blurRadius: 2,
              color: Colors.black.withOpacity(0.1),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (message.type == 'image' && message.mediaUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  message.mediaUrl!,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 150,
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: const Text("Error loading image"),
                  ),
                ),
              ),
            if (message.body.isNotEmpty)
              Text(
                message.body,
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeString,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
                if (message.fromMe) const SizedBox(width: 3),
                if (message.fromMe)
                  const Icon(
                    Icons.done_all,
                    size: 14,
                    color: Color(0xFF34B7F1),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _WhatsappChatState extends State<WhatsappChat> {
  List<Message> messages = [];

  final TextEditingController _messageController = TextEditingController();
  late IO.Socket socket;
  bool isConnected = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    initSocket();
  }

  String formatTimestamp(int timestamp) {
    final DateTime dateTime =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final timeFormat = DateFormat('HH:mm');

    if (messageDate == today) {
      return timeFormat.format(dateTime);
    } else if (messageDate == yesterday) {
      return 'Yesterday, ${timeFormat.format(dateTime)}';
    } else {
      return DateFormat('MMM d, HH:mm').format(dateTime);
    }
  }

  void initSocket() {
    // Check if socket is already connected
    // if (socket != null && socket.connected) {
    //   socket.disconnect();
    // }
    socket = IO.io('wss://dev.smartassistapp.in', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 1000,
    });

    socket.onConnect((_) {
      print('Socket connected');
      if (mounted) {
        setState(() {
          isConnected = true;
        });
      }

      // Request initial messages for the specific chat
      socket.emit('get_messages', widget.chatId);
      print('Requesting messages for chat ID: ${widget.chatId}');
    });

    socket.onDisconnect((_) {
      print('Socket disconnected');
      if (mounted) {
        setState(() {
          isConnected = false;
        });
      }
    });

    socket.onConnectError((error) {
      print('Connection error: $error');
      // Try to reconnect after a delay
      Future.delayed(Duration(seconds: 3), () {
        if (!isConnected && mounted) {
          socket.connect();
        }
      });
    });

    // Listen for new messages
    // socket.on('new_message', (data) {
    //   print('New message received: $data');
    //   if (data != null && mounted) {
    //     try {
    //       final newMessage = Message.fromJson(data);
    //       setState(() {
    //         messages.add(newMessage);
    //       });

    //       // Scroll to the bottom when new message arrives
    //       WidgetsBinding.instance.addPostFrameCallback((_) {
    //         _scrollToBottom();
    //       });
    //     } catch (e) {
    //       print('Error parsing new message: $e');
    //     }
    //   }
    // });

    // Listen for new messages

    socket.on('new_message', (data) {
      print('New message received: $data');
      if (data != null && mounted) {
        try {
          // Extract the message object from the payload
          final messageData = data['message'];
          if (messageData != null) {
            final newMessage = Message.fromJson(messageData);

            // Check if this message belongs to the current chat
            if (data['chatId'] == widget.chatId) {
              setState(() {
                messages.add(newMessage);
              });

              // Scroll to the bottom when new message arrives
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });
            }
          }
        } catch (e) {
          print('Error parsing new message: $e');
        }
      }
    });

    socket.on('new_message', (data) {
      print('New message received: $data');
      if (data != null && mounted) {
        try {
          final messageData = data['message'];
          if (messageData != null) {
            final newMessage = Message.fromJson(messageData);

            // Check if this message belongs to the current chat
            if (data['chatId'] == widget.chatId) {
              // Check if message is already in the list to avoid duplicates
              if (!messages.any((m) => m.id == newMessage.id)) {
                setState(() {
                  messages.add(newMessage);
                });

                // Scroll to bottom
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _scrollToBottom();
                });
              }
            }
          }
        } catch (e) {
          print('Error parsing new message: $e');
        }
      }
    });

    // Listen for message sent confirmation

    socket.on('message_sent', (data) {
      print('Message sent confirmation: $data');
      // Update message status if needed
    });

    // Listen for initial messages from the backend
    // socket.on('chat_messages', (data) {
    //   print('Received initial messages: $data');
    //   if (data != null && mounted) {
    //     try {
    //       final List<Message> initialMessages = (data['messages'] as List)
    //           .map((msg) => Message.fromJson(msg))
    //           .toList();

    //       setState(() {
    //         messages = initialMessages;
    //       });

    //       // Scroll to the bottom after initial messages are loaded
    //       WidgetsBinding.instance.addPostFrameCallback((_) {
    //         _scrollToBottom();
    //       });
    //     } catch (e) {
    //       print('Error parsing chat messages: $e');
    //     }
    //   }
    // });

    socket.onDisconnect((_) {
      print('Socket disconnected');
      if (mounted) {
        setState(() {
          isConnected = false;
        });
      }
    });

    // Listen for errors
    socket.on('wa_error', (data) {
      print('WebSocket error: $data');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${data['message'] ?? 'Unknown error'}')),
      );
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    // Remove all event listeners
    socket.off('connect');
    socket.off('disconnect');
    socket.off('new_message');
    socket.off('chat_messages');
    socket.off('message_sent');
    socket.off('wa_error');
    socket.off('connect_error');

    // Disconnect the socket
    socket.disconnect();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Function to handle socket disconnection
  void disconnectSocket() {
    print('ttttttttttttttttttttttttttttttttttttttttttttttttttttttttt');
    // Disconnect the socket
    socket.disconnect();

    // Optionally update the UI to reflect that the socket is disconnected
    if (mounted) {
      setState(() {
        isConnected = false;
      });
    }

    print('Socket manually disconnected');
  }

  void sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    // Create message payload matching what the backend expects
    final message = {
      'chatId': widget.chatId,
      'message': _messageController.text,
    };

    print('Sending message: ${jsonEncode(message)}');

    // Emit with the correct structure
    socket.emit('send_message', message);

    // Create a local message object for optimistic UI update
    final localMessage = Message(
      body: _messageController.text,
      fromMe: true,
      timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
      type: 'chat',
      mediaUrl: null,
    );

    // Add to local message list (optimistic update)
    setState(() {
      messages.add(localMessage);
    });

    _messageController.clear();

    // Scroll to bottom after sending
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToBottom();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.colorsBlue,
        leadingWidth: 40,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          // onPressed: () => Navigator.pop(context),
          onPressed: () {
            disconnectSocket();
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  isConnected ? 'Online' : 'Connecting...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              isConnected ? Icons.wifi : Icons.wifi_off,
              color: Colors.white,
            ),
            onPressed: () {
              if (!isConnected) {
                // Try to reconnect if disconnected
                socket.connect();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Reconnecting...')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('No messages yet'),
                        if (!isConnected)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Waiting for connection...',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 10),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final showDate = index == 0 ||
                          DateTime.fromMillisecondsSinceEpoch(
                                      messages[index].timestamp * 1000)
                                  .day !=
                              DateTime.fromMillisecondsSinceEpoch(
                                      messages[index - 1].timestamp * 1000)
                                  .day;

                      return Column(
                        children: [
                          if (showDate)
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                DateFormat('EEEE, MMM d').format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      message.timestamp * 1000),
                                ),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.black54),
                              ),
                            ),
                          MessageBubble(
                            message: message,
                            timeString: formatTimestamp(message.timestamp),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
            color: Colors.white,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.emoji_emotions_outlined),
                  color: Colors.grey[600],
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  color: Colors.grey[600],
                  onPressed: () {},
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message',
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: AppColors.colorsBlue,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send),
                    color: Colors.white,
                    onPressed: sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// this code is working fine
// class MessageBubble extends StatelessWidget {
//   final Message message;
//   final String timeString;

//   const MessageBubble({
//     Key? key,
//     required this.message,
//     required this.timeString,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     print('Message: ${message.body}, Time: $timeString'); // Debugging line
//     return Align(
//       alignment: message.fromMe ? Alignment.centerRight : Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 3),
//         constraints: BoxConstraints(
//           maxWidth: MediaQuery.of(context).size.width * 0.75,
//         ),
//         decoration: BoxDecoration(
//           color: message.fromMe
//               ? const Color.fromARGB(255, 198, 210, 248)
//               : Colors.white,
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: [
//             BoxShadow(
//               offset: const Offset(0, 1),
//               blurRadius: 2,
//               color: Colors.black.withOpacity(0.1),
//             ),
//           ],
//         ),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.end,
//           children: [
//             if (message.type == 'image' && message.mediaUrl != null)
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(6),
//                 child: Image.network(
//                   message.mediaUrl!,
//                   width: double.infinity,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) => Container(
//                     height: 150,
//                     color: Colors.grey[300],
//                     alignment: Alignment.center,
//                     child: const Text("Error loading image"),
//                   ),
//                 ),
//               ),
//             if (message.body.isNotEmpty)
//               Text(
//                 message.body,
//                 style: const TextStyle(fontSize: 16),
//               ),
//             const SizedBox(height: 2),
//             Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   timeString,
//                   style: TextStyle(
//                     fontSize: 11,
//                     color: Colors.grey[600],
//                   ),
//                 ),
//                 if (message.fromMe) const SizedBox(width: 3),
//                 if (message.fromMe)
//                   const Icon(
//                     Icons.done_all,
//                     size: 14,
//                     color: const Color(0xFF34B7F1),
//                   ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _WhatsappChatState extends State<WhatsappChat> {
//   List<Message> messages = [];
//   final TextEditingController _messageController = TextEditingController();
//   late IO.Socket socket;
//   bool isConnected = false;

//   @override
//   void initState() {
//     super.initState();
//     initSocket();
//   }

//   String formatTimestamp(int timestamp) {
//     final DateTime dateTime =
//         DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
//     final now = DateTime.now();
//     final today = DateTime(now.year, now.month, now.day);
//     final yesterday = today.subtract(const Duration(days: 1));
//     final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

//     final timeFormat = DateFormat('HH:mm');

//     if (messageDate == today) {
//       return timeFormat.format(dateTime);
//     } else if (messageDate == yesterday) {
//       return 'Yesterday, ${timeFormat.format(dateTime)}';
//     } else {
//       return DateFormat('MMM d, HH:mm').format(dateTime);
//     }
//   }

//   // Fix the socket initialization to better handle connection and events
//   void initSocket() {
//     socket = IO.io('wss://dev.smartassistapp.in', <String, dynamic>{
//       'transports': ['websocket'],
//       'autoConnect': true,
//     });

//     socket.onConnect((_) {
//       print('Socket connected');
//       if (mounted) {
//         setState(() {
//           isConnected = true;
//         });
//       }

//       // Request initial messages for the specific chat
//       socket.emit('get_messages', widget.chatId);
//       print('Requesting messages for chat ID: ${widget.chatId}');
//     });

//     socket.onDisconnect((_) {
//       print('Socket disconnected');
//       if (mounted) {
//         setState(() {
//           isConnected = false;
//         });
//       }
//     });

//     // Listen for new messages
//     socket.on('new_message', (data) {
//       print('New message received: $data');
//       if (data != null) {
//         try {
//           final newMessage = Message.fromJson(data);
//           if (mounted) {
//             setState(() {
//               messages.add(newMessage);
//             });
//           }
//         } catch (e) {
//           print('Error parsing new message: $e');
//         }
//       }
//     });

//     // Listen for message sent confirmation
//     socket.on('message_sent', (data) {
//       print('Message sent confirmation: $data');
//       // You could update UI here if needed, like adding a check mark
//     });

//     // Listen for initial messages from the backend
//     socket.on('chat_messages', (data) {
//       print('Received initial messages: $data');
//       try {
//         final List<Message> initialMessages = (data['messages'] as List)
//             .map((msg) => Message.fromJson(msg))
//             .toList();
//         if (mounted) {
//           setState(() {
//             messages = initialMessages;
//           });
//         }
//       } catch (e) {
//         print('Error parsing chat messages: $e');
//       }
//     });

//     // Listen for errors
//     socket.on('wa_error', (data) {
//       print('WebSocket error: $data');
//       // You could show an error toast/snackbar here
//     });
//   }

//   // void initSocket() {
//   //   socket = IO.io('wss://dev.smartassistapp.in', <String, dynamic>{
//   //     'transports': ['websocket'],
//   //     'autoConnect': true,
//   //   });

//   //   socket.onConnect((_) {
//   //     print('Socket connected');
//   //     if (mounted) {
//   //       setState(() {
//   //         isConnected = true;
//   //       });
//   //     }

//   //     // Request initial messages for the specific chat
//   //     socket.emit('get_messages', widget.chatId);
//   //   });

//   //   // socket.onDisconnect((_) {
//   //   //   print('Socket disconnected');
//   //   //   if (mounted) {
//   //   //     setState(() {
//   //   //       isConnected = false;
//   //   //     });
//   //   //   }
//   //   // });

//   //   // Listen for new messages
//   //   socket.on('new_message', (data) {
//   //     print('New message received: $data');
//   //     final newMessage = Message.fromJson(data);
//   //     if (mounted) {
//   //       setState(() {
//   //         messages.add(newMessage); // Add the new message to the list
//   //       });
//   //     }
//   //   });

//   //   // Listen for initial messages from the backend (if emitted)
//   //   socket.on('chat_messages', (data) {
//   //     print('Received initial messages: $data');
//   //     final List<Message> initialMessages = (data['messages'] as List)
//   //         .map((msg) => Message.fromJson(msg))
//   //         .toList();
//   //     if (mounted) {
//   //       setState(() {
//   //         messages = initialMessages;
//   //       });
//   //     }
//   //   });
//   // }

//   // void initSocket() {
//   //   socket = IO.io('wss://dev.smartassistapp.in', <String, dynamic>{
//   //     'transports': ['websocket'],
//   //     'autoConnect': true,
//   //   });

//   //   socket.onConnect((_) {
//   //     print('Socket connected');
//   //     if (mounted) {
//   //       setState(() {
//   //         isConnected = true;
//   //       });
//   //     }

//   //     // Request initial messages for the specific chat
//   //     socket.emit('get_messages', widget.chatId);
//   //     print(widget.chatId);
//   //     print('thsi is chartid..................');
//   //   });

//   //   socket.onDisconnect((_) {
//   //     print('Socket disconnected');
//   //     if (mounted) {
//   //       setState(() {
//   //         isConnected = false;
//   //       });
//   //     }
//   //   });

//   //   socket.on('new_message', (data) {
//   //     print('New message received: $data'); // Debugging line
//   //     final newMessage = Message.fromJson(data);
//   //     setState(() {
//   //       messages.add(newMessage); // Add the new message to the list
//   //     });
//   //   });

//   //   socket.on('chat_messages', (data) {
//   //     print('Received initial messages: $data'); // Debugging line
//   //     final List<Message> initialMessages = (data['messages'] as List)
//   //         .map((msg) => Message.fromJson(msg))
//   //         .toList();
//   //     setState(() {
//   //       messages = initialMessages;
//   //     });
//   //   });
//   // }

//   // @override
//   // void dispose() {
//   //   socket.disconnect(); // Disconnect socket when leaving the screen
//   //   super.dispose();
//   // }

//   @override
//   void dispose() {
//     // First remove all event listeners to prevent callbacks after disposal
//     socket.off('connect');
//     socket.off('disconnect');
//     socket.off('new_message');
//     socket.off('chat_messages');
//     socket.off('message_sent');
//     socket.off('wa_error');

//     // Then disconnect the socket
//     socket.disconnect();
//     _messageController.dispose();
//     super.dispose();
//   }

//   // void sendMessage() {
//   //   if (_messageController.text.trim().isEmpty) return;

//   //   final message = {
//   //     'body': _messageController.text,
//   //     // 'fromMe': true,
//   //     // 'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
//   //     // 'type': 'chat',
//   //   };

//   //   socket.emit('send_message', {
//   //     'chatId': widget.chatId,
//   //     'body': message['body'],

//   //   });

//   //   print('Sending message (formatted):');
//   //   print(jsonEncode(message));

//   //   print('msgggggggggggggggggggggggggggggggggggggggggggggggggggggggggggg');
//   //   print(message);

//   //   // Add to local message list (optimistic update)
//   //   setState(() {
//   //     messages.add(Message.fromJson(message));
//   //   });

//   //   _messageController.clear();
//   // }
//   void sendMessage() {
//     if (_messageController.text.trim().isEmpty) return;

//     // Create message payload matching what the backend expects
//     final message = {
//       'chatId': widget.chatId,
//       'message': _messageController
//           .text, // Changed from 'body' to 'message' to match backend
//     };

//     print('Sending message: ${jsonEncode(message)}');

//     // Emit with the correct structure
//     socket.emit('send_message', message);

//     // Create a local message object for optimistic UI update
//     final localMessage = Message(
//       body: _messageController.text,
//       fromMe: true,
//       timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000,
//       type: 'chat',
//       mediaUrl: null,
//     );

//     // Add to local message list (optimistic update)
//     setState(() {
//       messages.add(localMessage);
//     });

//     _messageController.clear();
//   }
//   // @override
//   // void dispose() {
//   //   socket.disconnect();
//   //   super.dispose();
//   // }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: AppColors.colorsBlue,
//         leadingWidth: 40,
//         leading: IconButton(
//           icon:
//               const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Row(
//           children: [
//             const SizedBox(width: 10),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   widget.userName,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 Text(
//                   isConnected ? 'Online' : 'Offline',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.white.withOpacity(0.8),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: messages.isEmpty
//                 ? const Center(child: Text('No messages yet'))
//                 : ListView.builder(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 10, horizontal: 10),
//                     itemCount: messages.length,
//                     itemBuilder: (context, index) {
//                       final message = messages[index];
//                       final showDate = index == 0 ||
//                           DateTime.fromMillisecondsSinceEpoch(
//                                       messages[index].timestamp * 1000)
//                                   .day !=
//                               DateTime.fromMillisecondsSinceEpoch(
//                                       messages[index - 1].timestamp * 1000)
//                                   .day;

//                       return Column(
//                         children: [
//                           if (showDate)
//                             Container(
//                               margin: const EdgeInsets.symmetric(vertical: 10),
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 15, vertical: 5),
//                               decoration: BoxDecoration(
//                                 color: Colors.grey[300],
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               child: Text(
//                                 DateFormat('EEEE, MMM d').format(
//                                   DateTime.fromMillisecondsSinceEpoch(
//                                       message.timestamp * 1000),
//                                 ),
//                                 style: const TextStyle(
//                                     fontSize: 12, color: Colors.black54),
//                               ),
//                             ),
//                           MessageBubble(
//                             message: message,
//                             timeString: formatTimestamp(message.timestamp),
//                           ),
//                         ],
//                       );
//                     },
//                   ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
//             color: Colors.white,
//             child: Row(
//               children: [
//                 IconButton(
//                   icon: const Icon(Icons.emoji_emotions_outlined),
//                   color: Colors.grey[600],
//                   onPressed: () {},
//                 ),
//                 IconButton(
//                   icon: const Icon(Icons.attach_file),
//                   color: Colors.grey[600],
//                   onPressed: () {},
//                 ),
//                 Expanded(
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 15),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[200],
//                       borderRadius: BorderRadius.circular(25),
//                     ),
//                     child: TextField(
//                       controller: _messageController,
//                       decoration: const InputDecoration(
//                         hintText: 'Type a message',
//                         border: InputBorder.none,
//                       ),
//                       maxLines: null,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 Container(
//                   decoration: const BoxDecoration(
//                     color: AppColors.colorsBlue,
//                     shape: BoxShape.circle,
//                   ),
//                   child: IconButton(
//                     icon: const Icon(Icons.send),
//                     color: Colors.white,
//                     onPressed: sendMessage,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
