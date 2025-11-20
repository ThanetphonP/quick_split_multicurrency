import 'package:flutter/material.dart';
import '../services/fx_service.dart';

class SplitModel extends ChangeNotifier {
  final FxService fx;
  SplitModel(this.fx);

  final TextEditingController totalCtrl = TextEditingController();
  final TextEditingController personCtrl = TextEditingController();
  final List<String> people = [];

  final List<String> currencies = const [
    'THB',
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'CNY',
    'KRW',
    'HKD',
    'SGD',
    'AUD'
  ];
  String baseCurrency = 'THB';
  final Map<String, double> _rateToTHB = {};

  bool loadingRate = false;
  String? error;

  void addPerson() {
    final name = personCtrl.text.trim();
    if (name.isEmpty) return;
    people.add(name);
    personCtrl.clear();
    notifyListeners();
  }

  void removePerson(int i) {
    people.removeAt(i);
    notifyListeners();
  }

  void setBaseCurrency(String c) {
    baseCurrency = c;
    notifyListeners();
  }

  Future<void> loadRateToTHB() async {
    if (baseCurrency == 'THB') return;
    loadingRate = true;
    error = null;
    notifyListeners();
    try {
      final r = await fx.getRate(baseCurrency, 'THB');
      _rateToTHB[baseCurrency] = r;
    } catch (e) {
      error = e.toString();
    } finally {
      loadingRate = false;
      notifyListeners();
    }
  }

  Map<String, dynamic>? compute() {
    final total = double.tryParse(totalCtrl.text.trim());
    if (total == null || total <= 0 || people.isEmpty) return null;

    final grandBase = total;
    final perBase = grandBase / people.length;

    double perTHB;
    double grandTHB;
    if (baseCurrency == 'THB') {
      perTHB = perBase;
      grandTHB = grandBase;
    } else {
      final r = _rateToTHB[baseCurrency];
      if (r == null) return null;
      perTHB = perBase * r;
      grandTHB = grandBase * r;
    }

    return {
      'baseCode': baseCurrency,
      'grandBase': grandBase,
      'grandTHB': grandTHB,
      'perBase': perBase,
      'perTHB': perTHB,
      'n': people.length,
      'names': List<String>.from(people),
    };
  }
}
