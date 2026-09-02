import 'package:flutter/material.dart';
import '../device_session.dart';
import '../supabase.dart';
import 'support_chat_screen.dart';

/// شاشة الدعم: قائمة محادثات المستخدم + زر إنشاء محادثة جديدة
class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  List<Map<String, dynamic>> _tickets = [];
  bool _loading = true;
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final deviceId = await DeviceSession.deviceId();
    _userName = await DeviceSession.userName();

    final res = await supabase
        .from('support_tickets')
        .select()
        .eq('device_id', deviceId)
        .order('created_at', ascending: false);

    if (!mounted) return;
    setState(() {
      _tickets = List<Map<String, dynamic>>.from(res);
      _loading = false;
    });
  }

  Future<void> _newTicket() async {
    final nameCtrl = TextEditingController(text: _userName);
    final subjectCtrl = TextEditingController();

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(
                labelText: 'اسمك',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: subjectCtrl,
              decoration: const InputDecoration(
                labelText: 'موضوع المشكلة',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('بدء المحادثة'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
    if (ok != true) return;

    final subject = subjectCtrl.text.trim();
    if (subject.isEmpty) return;

    final deviceId = await DeviceSession.deviceId();
    final name = nameCtrl.text.trim();
    await DeviceSession.setUserName(name);

    final inserted = await supabase
        .from('support_tickets')
        .insert({
          'device_id': deviceId,
          'user_name': name,
          'subject': subject,
        })
        .select()
        .single();

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SupportChatScreen(ticket: Map<String, dynamic>.from(inserted)),
      ),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الدعم الفني')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _newTicket,
        icon: const Icon(Icons.add),
        label: const Text('محادثة جديدة'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _tickets.isEmpty
              ? const Center(
                  child: Text('لا توجد محادثات بعد'),
                )
              : ListView.builder(
                  itemCount: _tickets.length,
                  itemBuilder: (_, i) {
                    final t = _tickets[i];
                    final open = t['status'] == 'open';
                    return ListTile(
                      leading: const Icon(Icons.support_agent),
                      title: Text(t['subject'] ?? ''),
                      subtitle: Text(open ? 'مفتوحة' : 'مغلقة'),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SupportChatScreen(ticket: t),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
