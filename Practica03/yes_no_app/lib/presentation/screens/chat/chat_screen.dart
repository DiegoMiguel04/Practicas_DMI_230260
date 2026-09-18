import 'package:flutter/material.dart';
import '../../widgets/chat/my_message_bubble.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: CircleAvatar(
            backgroundImage: NetworkImage(
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQUBf1YpZy9ejF0Jp6xTi-0K7s_gbh7DbRqLjGxtZ9yOw&s=10"
            ),
          ),
        ),
        title: const Text("Gato"),
        centerTitle: false,
      ),
      body: _ChatView()
    );
  }
}

class _ChatView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Expanded(child: ListView.builder(
              itemCount: 20,
              itemBuilder: (context, index) {
                return const MyMessageBubble();
              }
            )),
        
            
            Text("Hola mundo"),
          ],
        ),
      ),
    );
  }
}
