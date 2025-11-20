import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pages/home_page.dart';
import 'services/fx_service.dart';
import 'services/storage_service.dart';
import 'models/split_model.dart';

void main() {
  runApp(const QuickSplitApp());
}

class QuickSplitApp extends StatelessWidget {
  const QuickSplitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => FxService()),
        Provider(create: (_) => StorageService()..init()),
        ChangeNotifierProvider(create: (ctx) => SplitModel(ctx.read<FxService>())),
      ],
      child: MaterialApp(
        title: 'QuickSplit',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
        home: const HomePage(),
      ),
    );
  }
}
