import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../services/filament_service.dart';
import '../models/filament.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text:
          'Hi! I can help you manage your filament inventory.\n\nTry commands like:\n• "Add 2 spools of PLA silk gold by Polymaker at 120"\n• "Finished the blue eSun"\n• "Update the green spool to PETG"',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a command...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _sendMessage,
                  mini: true,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final theme = Theme.of(context);

    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isUser
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                fontSize: 10,
                color: message.isUser
                    ? theme.colorScheme.onPrimary.withValues(alpha: 0.7)
                    : theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    _messageController.clear();
    _scrollToBottom();

    _processCommand(text);
  }

  void _processCommand(String command) async {
    final parsed = AIService.parseNaturalLanguageCommand(command);

    if (parsed == null) {
      _addBotMessage(
          'Sorry, I didn\'t understand that command. Try:\n• "Add X spools of [material] [color] by [brand] at [price]"\n• "Finished the [color] spool"\n• "Update [color] to [material]"');
      return;
    }

    switch (parsed['action']) {
      case 'add':
        await _handleAddCommand(parsed);
        break;
      case 'remove':
        await _handleRemoveCommand(parsed);
        break;
      case 'update':
        await _handleUpdateCommand(parsed);
        break;
      default:
        _addBotMessage('Unknown command action');
    }
  }

  Future<void> _handleAddCommand(Map<String, dynamic> parsed) async {
    try {
      final info = AIService.parseFilamentDescription(parsed['description']);
      final quantity = parsed['quantity'] as int;
      final cost = parsed['cost'] as double;

      final filament = Filament(
        id: FilamentService.generateId(),
        brand: info['brand'],
        material: info['material'],
        subType: info['subType'],
        weight: info['weight'],
        colorName: info['colorName'],
        colorHex: info['colorHex'],
        quantity: quantity,
        cost: cost,
        amsCompatible: info['amsCompatible'],
        lastUpdated: DateTime.now(),
      );

      await FilamentService.addFilament(filament);

      _addBotMessage(
          'Added $quantity spool(s) of ${info['brand']} ${info['material']} ${info['colorName']} at ₪$cost each to your inventory! ✅');
    } catch (e) {
      _addBotMessage('Error adding filament: $e');
    }
  }

  Future<void> _handleRemoveCommand(Map<String, dynamic> parsed) async {
    final description = parsed['description'] as String;
    final filaments = FilamentService.search(description);

    if (filaments.isEmpty) {
      _addBotMessage(
          'Could not find any filaments matching "$description". Please be more specific.');
      return;
    }

    if (filaments.length > 1) {
      _addBotMessage(
          'Found ${filaments.length} matching filaments. Please be more specific:\n${filaments.map((f) => '• ${f.brand} ${f.colorName}').join('\n')}');
      return;
    }

    final filament = filaments.first;
    final newQty = filament.quantity - 1;

    if (newQty <= 0) {
      await FilamentService.deleteFilament(filament.id);
      _addBotMessage(
          'Removed ${filament.brand} ${filament.colorName} from inventory (quantity reached 0). 🗑️');
    } else {
      await FilamentService.updateQuantity(filament.id, -1);
      _addBotMessage(
          'Updated ${filament.brand} ${filament.colorName} quantity to $newQty. ✅');
    }
  }

  Future<void> _handleUpdateCommand(Map<String, dynamic> parsed) async {
    _addBotMessage(
        'Update functionality is in development. For now, please manually edit the filament from the home screen.');
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
