import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:yes_no_app/domain/entities/message.dart';

class ChatProvider extends ChangeNotifier {
  final ScrollController chatScrollController = ScrollController();

  final List<Message> messageList = [];
  final Random _random = Random();

  Future<void> sendMessage( String text ) async {
    if (text.trim().isEmpty) return;
    final newMessage = Message(text: text, fromWho: FromWho.me);
    messageList.add(newMessage);

    notifyListeners();
    moveScrollToBottom();

    if (_random.nextInt(100) < 20) {
      messageList.add(Message(
        text: 'Tal vez',
        imageUrl: 'https://media1.tenor.com/m/mFlSH_ZAUfsAAAAd/yes-no.gif',
        fromWho: FromWho.her,
      ));
      notifyListeners();
      moveScrollToBottom();
      return;
    }

    try {
      final response = await http.get(Uri.https('yesno.wtf', '/api'));
      debugPrint('HTTP ${response.statusCode}: ${response.body}');
      if (response.statusCode != 200) throw Exception('HTTP ${response.statusCode}');

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final apiAnswer = data['answer'] as String;
      final text = switch (apiAnswer) {
        'yes' => 'S\u00ed',
        'no' => 'No',
        'maybe' => 'Tal vez',
        _ => throw const FormatException('Respuesta desconocida de yesno.wtf'),
      };
      messageList.add(Message(
        text: text,
        imageUrl: data['image'] as String?,
        fromWho: FromWho.her,
      ));
    } catch (error, stackTrace) {
      debugPrint('Error al consultar yesno.wtf: $error');
      debugPrintStack(stackTrace: stackTrace);

      messageList.add(Message(
        text: 'No pude obtener una respuesta. Int\u00e9ntalo de nuevo.',
        fromWho: FromWho.her,
      ));
    }
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
