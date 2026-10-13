/* import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {

  static const name = 'progress_screen';

  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _ControlledProgressIndicator extends StatelessWidget {
  const _ControlledProgressIndicator();

  @override 
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator( value: 0.5, strokeWidth: 2, backgroundColor: Color.black12,),
          const SizedBox(width: 20,),
          Expanded(
            child: LinealProgressIndicator(value: 0.5,)
          ),
        ],
      ),
    );
  }
}
*/