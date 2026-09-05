import 'dart:async';
import 'package:flutter/material.dart';
import '../supabase.dart';

/// شاشة المحادثة — رسائل فورية عبر Supabase Realtime
/// مع إدارة صحيحة للاشتراك (إلغاؤه عند مغادرة الشاشة)
class SupportChatScreen extends StatefulWidget {
  final Map<String, dynamic> ticket;
  const SupportChatScreen({super.key, required this.ticket});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  List<Map<String, dynamic>> _messages = [];
  late final String _ticketId;
  StreamSubscription<List<Map<String, dynamic>>>? _sub;

  @override
  void initState() {
    super.initState();
    _ticketId = widget.ticket['id'] as String;
    _listen();
  }

  void _listen() {
    // حفظ الاشتراك حتى نتمكن من إلغائه في dispose — يمنع تسريب الذاكرة
    _sub = supabase
        .from('support_messages')
        .stream(primaryKey: ['id'])
        .eq('ticket_id', _ticketId)
        .order('created_at')
        .listen((data) {
          if (!mounted) return;
          setState(() {
            _messages = List<Map<String, dynamic>>.from(data);
          });
          _scrollToEnd();
        });
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.jumpTo(_scroll.position.maxScrollExtent);
      }
    });
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    _ctrl.clear();
    await supabase.from('support_messages').insert({
      'ticket_id': _ticketId,
      'sender': 'user',
      'body': text,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.ticket['subject'] ?? 'الدعم الفني')),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(child: Text('اكتب رسالتك وسنرد عليك قريباً'))
                : ListView.builder(
                    controller: _scroll,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final m = _messages[i];
                      final mine = m['sender'] == 'user';
                      return Align(
                        alignment: mine
                            ? AlignmentDirectional.centerEnd
                            : AlignmentDirectional.centerStart,
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          decoration: BoxDecoration(
                            color: mine
                                ? Theme.of(context).colorScheme.primary
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            m['body'] ?? '',
                            style: TextStyle(
                              color: mine ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: const InputDecoration(
                        hintText: 'اكتب رسالة...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // إلغاء الاشتراك الفوري — هذا هو الإصلاح الحقيقي
    _sub?.cancel();
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }
}
