import 'package:flutter/material.dart';
import 'package:get/get.dart';

// ══════════════════════════════════════════════════════════════════════════════
// Modèles
// ══════════════════════════════════════════════════════════════════════════════

enum MessageType { text, booking, image }

class ChatMessage {
  final String id;
  final String text;
  final bool isOwner;       // true = moi (propriétaire), false = joueur
  final DateTime timestamp;
  final MessageType type;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.isOwner,
    required this.timestamp,
    this.type = MessageType.text,
    this.isRead = true,
  });
}

class ChatConversation {
  final String id;
  final String playerName;
  final String teamName;
  final String avatarInitials;
  final Color avatarColor;
  final String lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final List<ChatMessage> messages;

  const ChatConversation({
    required this.id,
    required this.playerName,
    required this.teamName,
    required this.avatarInitials,
    required this.avatarColor,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
    required this.messages,
  });
}

// ══════════════════════════════════════════════════════════════════════════════
// Controller liste des conversations
// ══════════════════════════════════════════════════════════════════════════════

class ChatController extends GetxController {
  final conversations = <ChatConversation>[].obs;
  final searchQuery   = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMockConversations();
  }

  void _loadMockConversations() {
    conversations.value = [
      ChatConversation(
        id: '1',
        playerName: 'Mamadou Diallo',
        teamName: 'Lions FC',
        avatarInitials: 'MD',
        avatarColor: const Color(0xFF1565C0),
        lastMessage: 'Est-ce que le terrain est dispo samedi matin ?',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
        unreadCount: 2,
        messages: [
          ChatMessage(
            id: 'm1',
            text: 'Bonjour ! Est-ce que le Terrain Alpha est disponible samedi à 10h ?',
            isOwner: false,
            timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
          ),
          ChatMessage(
            id: 'm2',
            text: 'Bonjour Mamadou ! Oui, le créneau 10h-11h est libre ce samedi.',
            isOwner: true,
            timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
          ),
          ChatMessage(
            id: 'm3',
            text: 'Est-ce que le terrain est dispo samedi matin ?',
            isOwner: false,
            timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
            isRead: false,
          ),
        ],
      ),
      ChatConversation(
        id: '2',
        playerName: 'Ibrahima Ndiaye',
        teamName: 'AS Médina',
        avatarInitials: 'IN',
        avatarColor: const Color(0xFF006F39),
        lastMessage: 'Merci pour la confirmation 👍',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 1)),
        unreadCount: 0,
        messages: [
          ChatMessage(
            id: 'm1',
            text: 'On a réservé le Terrain Beta pour demain 12h. C\'est confirmé ?',
            isOwner: false,
            timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          ChatMessage(
            id: 'm2',
            text: 'Oui c\'est confirmé ! Le terrain sera prêt pour vous. Bonne séance !',
            isOwner: true,
            timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
          ),
          ChatMessage(
            id: 'm3',
            text: 'Merci pour la confirmation 👍',
            isOwner: false,
            timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ],
      ),
      ChatConversation(
        id: '3',
        playerName: 'Fatou Diop',
        teamName: 'Ladies FC',
        avatarInitials: 'FD',
        avatarColor: const Color(0xFFF59E0B),
        lastMessage: 'D\'accord, on annule pour vendredi alors',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 3)),
        unreadCount: 1,
        messages: [
          ChatMessage(
            id: 'm1',
            text: 'Bonsoir ! Peut-on annuler notre réservation de vendredi ?',
            isOwner: false,
            timestamp: DateTime.now().subtract(const Duration(hours: 4)),
          ),
          ChatMessage(
            id: 'm2',
            text: 'Bonsoir Fatou. Oui, vous pouvez annuler jusqu\'à 24h avant. Le remboursement sera traité sous 48h.',
            isOwner: true,
            timestamp: DateTime.now().subtract(const Duration(hours: 3, minutes: 30)),
          ),
          ChatMessage(
            id: 'm3',
            text: 'D\'accord, on annule pour vendredi alors',
            isOwner: false,
            timestamp: DateTime.now().subtract(const Duration(hours: 3)),
            isRead: false,
          ),
        ],
      ),
      ChatConversation(
        id: '4',
        playerName: 'Cheikh Mbaye',
        teamName: 'Star Club',
        avatarInitials: 'CM',
        avatarColor: const Color(0xFF9333EA),
        lastMessage: 'Super terrain, on reviendra !',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        unreadCount: 0,
        messages: [
          ChatMessage(
            id: 'm1',
            text: 'Super terrain, on reviendra !',
            isOwner: false,
            timestamp: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      ),
    ];
  }

  List<ChatConversation> get filteredConversations {
    if (searchQuery.value.isEmpty) return conversations;
    final q = searchQuery.value.toLowerCase();
    return conversations.where((c) {
      return c.playerName.toLowerCase().contains(q) ||
             c.teamName.toLowerCase().contains(q);
    }).toList();
  }

  int get totalUnread =>
      conversations.fold(0, (sum, c) => sum + c.unreadCount);

  void setSearch(String q) => searchQuery.value = q;
}

// ══════════════════════════════════════════════════════════════════════════════
// Controller conversation individuelle
// ══════════════════════════════════════════════════════════════════════════════

class ConversationController extends GetxController {
  final ChatConversation conversation;
  final messages    = <ChatMessage>[].obs;
  final textInput   = ''.obs;
  final isSending   = false.obs;
  final scrollController = ScrollController();
  late final TextEditingController textController;

  ConversationController({required this.conversation});

  @override
  void onInit() {
    super.onInit();
    textController = TextEditingController();
    messages.value = List.from(conversation.messages);
    // Marquer comme lus
    _markAllRead();
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  void _markAllRead() {
    messages.value = messages.map((m) => ChatMessage(
      id: m.id,
      text: m.text,
      isOwner: m.isOwner,
      timestamp: m.timestamp,
      type: m.type,
      isRead: true,
    )).toList();
  }

  void onTextChanged(String value) => textInput.value = value;

  Future<void> sendMessage() async {
    final text = textInput.value.trim();
    if (text.isEmpty) return;

    isSending.value = true;
    textController.clear();
    textInput.value = '';

    final msg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      isOwner: true,
      timestamp: DateTime.now(),
    );
    messages.add(msg);

    // Scroll vers le bas
    await Future.delayed(const Duration(milliseconds: 100));
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    isSending.value = false;
  }

  String formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String formatLastSeen(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'à l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    return 'Hier';
  }

  // Réponse rapide — messages pré-définis
  List<String> get quickReplies => [
    'Oui, c\'est confirmé !',
    'Désolé, ce créneau est pris.',
    'Je vous rappelle dans 5 min.',
    'Merci de votre confiance !',
  ];
}
