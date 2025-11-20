# QuickSplit (Multi-currency, No Service/Tip)

- หารบิลเท่ากัน + เลือกสกุล: THB, USD, EUR, GBP, JPY, CNY, KRW, HKD, SGD, AUD
- ดึงอัตราแลกเปลี่ยนแบบมี fallback 3 ชั้น (exchangerate.host → open.er-api.com → frankfurter.dev)
- บันทึกประวัติในเครื่อง
- ปุ่ม POST เดโม (JSONPlaceholder)

## Run
```bash
flutter create .
flutter pub get
flutter run
```
