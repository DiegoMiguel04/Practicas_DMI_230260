import 'package:flutter/material.dart';
import 'package:yes_no_app/domain/entities/message.dart';

class ChatProvider extends ChangeNotifier {
  final ScrollController chatScrollController = ScrollController();

  List<Message> messageList = [
    Message(text: 'Hola gato', fromWho: FromWho.me ),
    Message(text: 'Ya regresaste a la casa?', fromWho: FromWho.me ),
    Message(text: 'si', fromWho: FromWho.her ),
    Message(text: 'No molestes', fromWho: FromWho.her ),
  ];

  Future<void> sendMessage( String text ) async {
    if (text.isEmpty) return;
    final newMessage = Message(text: text, fromWho: FromWho.me);
    messageList.add(newMessage);

    notifyListeners();
    moveScrollToBottom();
  }

  Future<void> moveScrollToBottom() async {
    await Future.delayed(const Duration(milliseconds: 100));
    chatScrollController.animateTo(
      chatScrollController.position.maxScrollExtent,
      duration: const Duration( milliseconds: 300 ),
      curve: Curves.easeOut
    );
  }
}