import 'package:shared_preferences/shared_preferences.dart';

class FilterHelper {
  FilterHelper._();
  static const _key = 'filter_status_laporan';
  static const semua = 'Semua';
  static const pilihan = ['Semua', 'Baru', 'Diproses', 'Selesai'];
  static late final SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String muat() {
    final nilai = _prefs.getString(_key);
    return pilihan.contains(nilai) ? nilai! : semua;
  }

  static Future<void> simpan(String status) async {
    await _prefs.setString(_key, status);
  }

  static Future<void> reset() async {
    await _prefs.remove(_key);
  }
}