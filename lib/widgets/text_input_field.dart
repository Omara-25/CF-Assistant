import 'package:flutter/material.dart';

class TextInputField extends StatefulWidget {
  final Function(String) onSubmitted;

  const TextInputField({
    Key? key,
    required this.onSubmitted,
  }) : super(key: key);

  @override
  State<TextInputField> createState() => _TextInputFieldState();
}

class _TextInputFieldState extends State<TextInputField> {
  final TextEditingController _controller = TextEditingController();

  void _handleSubmit() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onSubmitted(_controller.text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Type a message...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
        suffixIcon: IconButton(
          icon: const Icon(Icons.send, size: 20),
          onPressed: _handleSubmit,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ),
      onSubmitted: (_) => _handleSubmit(),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}