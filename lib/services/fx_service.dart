import 'dart:convert';
import 'package:http/http.dart' as http;

class FxService {
  final _c = http.Client();

  /// return rate from -> to (e.g., THB -> JPY). includes 3 fallbacks.
  Future<double> getRate(String from, String to) async {
    if (from == to) return 1.0;

    // 1) exchangerate.host
    var r = await _c.get(Uri.parse('https://api.exchangerate.host/convert?from=$from&to=$to'));
    if (r.statusCode == 200) {
      final j = json.decode(r.body);
      final v = j['result'];
      if (v != null) return (v as num).toDouble();
    }

    // 2) open.er-api.com
    r = await _c.get(Uri.parse('https://open.er-api.com/v6/latest/$from'));
    if (r.statusCode == 200) {
      final j = json.decode(r.body);
      final v = (j['rates'] ?? const {})[to];
      if (v != null) return (v as num).toDouble();
    }

    // 3) frankfurter.dev
    r = await _c.get(Uri.parse('https://api.frankfurter.dev/latest?from=$from&to=$to'));
    if (r.statusCode == 200) {
      final j = json.decode(r.body);
      final v = (j['rates'] ?? const {})[to];
      if (v != null) return (v as num).toDouble();
    }

    throw Exception('ไม่พบอัตราแลกเปลี่ยน $from -> $to');
  }
}
