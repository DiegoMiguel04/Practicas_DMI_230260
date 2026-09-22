
import 'package:flutter/material.dart';
import 'package:yes_no_app/domain/entities/message.dart';

class ChatProvider extends ChangeNotifier {
  List<Message> message = [
    Message(text: 'Hola gato', fromWho: FromWho.me ),
    Message(text: 'Ya regresaste a la casa?', fromWho: FromWho.me ),
  ];

  get messageList => null;

  Future<void> sendMessage( String text ) async {
    //

  }
}