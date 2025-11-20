import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';

class ResultPage extends StatelessWidget {
  final Map<String, dynamic> result;
  const ResultPage({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final baseCode = result['baseCode'] as String;
    final grandBase = (result['grandBase'] as num).toDouble();
    final grandTHB = (result['grandTHB'] as num).toDouble();
    final perBase = (result['perBase'] as num).toDouble();
    final perTHB = (result['perTHB'] as num).toDouble();
    final n = result['n'] as int;
    final names = (result['names'] as List).cast<String>();

    Future<void> saveHistory() async {
      final storage = context.read<StorageService>();
      final items = await storage.readAll();
      final now = DateTime.now().toIso8601String();
      items.add({
        'time': now,
        'n': n,
        'names': names,
        'baseCode': baseCode,
        'grandBase': grandBase,
        'grandTHB': grandTHB,
        'perBase': perBase,
        'perTHB': perTHB,
      });
      await storage.writeAll(items);
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('บันทึกแล้ว')));
      }
    }

    Future<void> postDemo() async {
      final res = await http.post(
        Uri.parse('https://jsonplaceholder.typicode.com/posts'),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: json.encode({
          'title': 'QuickSplit $n คน',
          'body': 'base=$baseCode grand=$grandBase perBase=$perBase '
              'THB grand=$grandTHB perTHB=$perTHB names=$names',
          'userId': 1,
        }),
      );
      if (context.mounted) {
        final ok = res.statusCode >= 200 && res.statusCode < 300;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(ok ? 'POST สำเร็จ' : 'POST ล้มเหลว ${res.statusCode}')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('ผลลัพธ์')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ยอดรวม
            Text('รวม: ${grandBase.toStringAsFixed(2)} $baseCode'
                '${baseCode != 'THB' ? '  /  ≈ ${grandTHB.toStringAsFixed(2)} THB' : ''}'),
            Text('จำนวนคน: $n'),
            const SizedBox(height: 12),

            // ต่อคน (แสดงทั้งสองสกุล)
            Text('ต่อคน ($baseCode): ${perBase.toStringAsFixed(2)}'),
            if (baseCode != 'THB')
              Text('ต่อคน (THB): ${perTHB.toStringAsFixed(2)}'),

            const SizedBox(height: 16),
            Text('รายชื่อ: ${names.join(', ')}'),

            const Spacer(),
            Row(
              children: [
                Expanded(
                    child: FilledButton(
                        onPressed: saveHistory,
                        child: const Text('บันทึกประวัติ'))),
                const SizedBox(width: 8),
                Expanded(
                    child: OutlinedButton(
                        onPressed: postDemo, child: const Text('POST เดโม'))),
              ],
            )
          ],
        ),
      ),
    );
  }
}
