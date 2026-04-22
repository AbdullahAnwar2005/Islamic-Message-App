import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alghaya_men_alkhalg/providers/analytics_provider.dart';
import 'package:intl/intl.dart';

class AnalyticsDebugScreen extends ConsumerStatefulWidget {
  const AnalyticsDebugScreen({super.key});

  @override
  ConsumerState<AnalyticsDebugScreen> createState() =>
      _AnalyticsDebugScreenState();
}

class _AnalyticsDebugScreenState extends ConsumerState<AnalyticsDebugScreen> {
  int _queueSize = 0;
  String? _lastFlushTime;
  Timer? _refreshTimer;
  bool _isFlushing = false;
  String _lastStatus = 'Idle';

  @override
  void initState() {
    super.initState();
    _refreshStats();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 2),
      (_) => _refreshStats(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _refreshStats() async {
    if (!mounted) return;
    final service = ref.read(analyticsServiceProvider);
    final size = await service.getQueueSize();
    setState(() {
      _queueSize = size;
    });
  }

  Future<void> _manualFlush() async {
    setState(() {
      _isFlushing = true;
      _lastStatus = 'Flushing...';
    });

    try {
      final service = ref.read(analyticsServiceProvider);
      await service.flush();
      setState(() {
        _lastStatus = 'Flush Complete (Success)';
        _lastFlushTime = DateFormat('HH:mm:ss').format(DateTime.now());
      });
    } catch (e) {
      setState(() {
        _lastStatus = 'Flush Failed: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isFlushing = false);
        _refreshStats();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics Debug')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCard('Queue Status', [
            _row('Pending Events', '$_queueSize'),
            _row('Last Flush Status', _lastStatus),
            _row('Last Flush Time', _lastFlushTime ?? 'Never'),
          ]),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _isFlushing ? null : _manualFlush,
            icon:
                _isFlushing
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Icon(Icons.upload),
            label: Text(_isFlushing ? 'Flushing...' : 'Flush Now'),
            style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Note: Offline events are queued. Manual flush respects connectivity checks.',
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
