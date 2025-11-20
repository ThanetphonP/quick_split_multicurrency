import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/split_model.dart';
import 'result_page.dart';
import 'history_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final m = context.watch<SplitModel>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('QuickSplit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HistoryPage()),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // เปลี่ยนเป็น "ยอดรวม" เฉย ๆ ไม่ผูกสกุล
          TextField(
            controller: m.totalCtrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'ยอดรวม',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: m.personCtrl,
                  decoration: const InputDecoration(
                    labelText: 'เพิ่มชื่อเพื่อน',
                    border: OutlineInputBorder(),
                  ),
                  onSubmitted: (_) => context.read<SplitModel>().addPerson(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: () => context.read<SplitModel>().addPerson(),
                child: const Text('เพิ่ม'),
              )
            ],
          ),
          const SizedBox(height: 8),

          Wrap(
            spacing: 8,
            children: [
              for (int i = 0; i < m.people.length; i++)
                Chip(
                  label: Text(m.people[i]),
                  onDeleted: () => context.read<SplitModel>().removePerson(i),
                )
            ],
          ),
          const Divider(),

          // เลือก "สกุลของยอดรวม"
          Row(
            children: [
              const Text('สกุลเงินของยอดรวม: '),
              const SizedBox(width: 8),
              DropdownButton<String>(
                value: m.baseCurrency,
                items: m.currencies
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) async {
                  if (v == null) return;
                  context.read<SplitModel>().setBaseCurrency(v);
                  await context.read<SplitModel>().loadRateToTHB();
                },
              ),
              const SizedBox(width: 12),
              if (m.loadingRate)
                const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2)),
              if (m.error != null)
                Flexible(
                    child: Text('โหลดเรตไม่สำเร็จ: ${m.error!}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.red)))
            ],
          ),
          const SizedBox(height: 16),

          FilledButton.icon(
            icon: const Icon(Icons.calculate),
            label: const Text('คำนวณ'),
            onPressed: () {
              final data = context.read<SplitModel>().compute();
              if (data == null) {
                showDialog(
                    context: context,
                    builder: (_) => const AlertDialog(
                          title: Text('กรอกข้อมูลไม่ครบ'),
                          content: Text(
                              'กรอกยอดรวม + เพิ่มรายชื่ออย่างน้อย 1 คน '
                              'และถ้าเลือกสกุลไม่ใช่ THB ต้องโหลดเรตสำเร็จก่อน'),
                        ));
                return;
              }
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ResultPage(result: data)));
            },
          ),
        ],
      ),
    );
  }
}
