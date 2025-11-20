import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/storage_service.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final storage = context.read<StorageService>();
    final all = await storage.readAll();
    setState(() {
      items = all.reversed.toList();
      loading = false;
    });
  }

  Future<void> _clear() async {
    final storage = context.read<StorageService>();
    await storage.clear();
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ประวัติการหารบิล'),
        actions: [
          IconButton(onPressed: _clear, icon: const Icon(Icons.delete_forever))
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
              ? const Center(child: Text('ยังไม่มีประวัติ'))
              : ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final it = items[i];

                    // --- รองรับทั้งโครงสร้างใหม่/เก่า ---
                    final names =
                        ((it['names'] as List?)?.cast<String>() ?? const []);
                    final time = (it['time'] as String?) ?? '';

                    String title() {
                      if (it.containsKey('grandBase')) {
                        final base = it['baseCode'] as String? ?? 'THB';
                        final gb = (it['grandBase'] as num).toDouble();
                        final gthb = (it['grandTHB'] as num).toDouble();
                        final left =
                            'รวม ${gb.toStringAsFixed(2)} $base • คน ${it['n']}';
                        return base == 'THB'
                            ? left
                            : '$left  /  ≈ ${gthb.toStringAsFixed(2)} THB';
                      } else {
                        // data เก่า
                        final g = (it['grand'] as num).toDouble();
                        return 'รวม ${g.toStringAsFixed(2)} THB • คน ${it['n']}';
                      }
                    }

                    String perLine() {
                      if (it.containsKey('perBase')) {
                        final base = it['baseCode'] as String? ?? 'THB';
                        final pb = (it['perBase'] as num).toDouble();
                        final pthb = (it['perTHB'] as num).toDouble();
                        final baseText = 'ต่อคน ${pb.toStringAsFixed(2)} $base';
                        return base == 'THB'
                            ? baseText
                            : '$baseText / ${pthb.toStringAsFixed(2)} THB';
                      } else {
                        // data เก่า
                        final thb = (it['perTHB'] as num).toDouble();
                        final fx = it['perFX'];
                        final code = it['fxCode'];
                        final base = 'ต่อคน ${thb.toStringAsFixed(2)} THB';
                        if (fx != null && code != null) {
                          return '$base / ${(fx as num).toDouble().toStringAsFixed(2)} $code';
                        }
                        return base;
                      }
                    }

                    return ListTile(
                      isThreeLine: true,
                      title: Text(title()),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(perLine()),
                          const SizedBox(height: 4),
                          Text(
                              'รายชื่อ: ${names.isEmpty ? '—' : names.join(', ')}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                      trailing: Text(time.isNotEmpty
                          ? time.substring(0, 16).replaceFirst('T', ' ')
                          : ''),
                    );
                  },
                ),
    );
  }
}
