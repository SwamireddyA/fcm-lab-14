import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/payload.dart';
import 'services/fcm_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _fcm = FCMService();

  String _title = 'Campus Board';
  String _assetPath = PayloadValidator.supportedAssets['default']!;
  String _lastHandler = 'none yet';
  String _messageId = '-';
  int _receiptCount = 0;
  String? _diagnostic;
  String _permission = 'checking...';
  String? _token;

  @override
  void initState() {
    super.initState();
    _fcm.initialize(
      onEvent: _handleEvent,
      onToken: (t) {
        if (mounted) setState(() => _token = t);
      },
      onPermission: (s) {
        if (mounted) setState(() => _permission = s);
      },
    );
  }

  void _handleEvent(String handler, RemoteMessage message) {
    if (!mounted) return; // lifetime guard
    final result = PayloadValidator.validate(message.data);
    setState(() {
      _lastHandler = handler;
      _messageId = message.messageId ?? '-';
      _receiptCount++;
      if (result.isValid) {
        _diagnostic = null;
        _assetPath = result.assetPath!;
        _title = message.notification?.title ?? _title;
      } else {
        // Reject: keep previous title/image, show why.
        _diagnostic = result.error;
      }
    });
  }

  @override
  void dispose() {
    _fcm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Cloud Courier')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(_title, key: const Key('title'), style: t.headlineSmall),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(_assetPath, key: const Key('image')),
          ),
          const SizedBox(height: 16),
          if (_diagnostic != null)
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: cs.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(children: [
                Icon(Icons.warning_amber, color: cs.onErrorContainer),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Payload rejected: $_diagnostic',
                      style: TextStyle(color: cs.onErrorContainer)),
                ),
              ]),
            ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _row('Last handler', _lastHandler),
                  _row('Receipts this launch', '$_receiptCount'),
                  _row('Message ID', _messageId),
                  _row('Permission', _permission),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _token == null
                ? null
                : () {
                    Clipboard.setData(ClipboardData(text: _token!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('FCM token copied')),
                    );
                  },
            icon: const Icon(Icons.copy),
            label: Text(_token == null ? 'Getting token...' : 'Copy FCM token'),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                width: 150,
                child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600))),
            Expanded(child: Text(value)),
          ],
        ),
      );
}
