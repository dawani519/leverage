import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Import for image picking

class ChatInput extends StatefulWidget {
  final Function(String) onSendPressed;
  final Function(String) onImageSelected; // Function to handle image selection

  const ChatInput({
    Key? key,
    required this.onSendPressed,
    required this.onImageSelected, // Add this line for image handling
  }) : super(key: key);

  @override
  _ChatInputState createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;
  final ImagePicker _imagePicker = ImagePicker();

  void _handleSend() {
    final messageText = _controller.text.trim();
    if (messageText.isEmpty) return;
    widget.onSendPressed(messageText);
    _controller.clear();
    setState(() => _isTyping = false);
  }

  Future<void> _handleImageSelection() async {
    final XFile? pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      widget.onImageSelected(pickedFile.path); // Pass the selected image to the handler
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.attach_file),
            onPressed: _handleImageSelection, // Directly call image selection handler
          ),
          Expanded(
            child: TextField(
              controller: _controller,
              onChanged: (value) {
                setState(() => _isTyping = value.isNotEmpty);
              },
              decoration: const InputDecoration(
                hintText: "Type a message...",
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              _isTyping ? Icons.send : Icons.mic,
              color: _isTyping ? Colors.blue : Colors.grey,
            ),
            onPressed: _isTyping ? _handleSend : null,
          ),
        ],
      ),
    );
  }
}
