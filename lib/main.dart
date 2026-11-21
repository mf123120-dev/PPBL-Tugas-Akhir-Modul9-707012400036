import 'package:flutter/material.dart';
import 'helpers/filter_helper.dart';
import 'helpers/hive_helper.dart';
import 'pages/halaman_daftar_laporan.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bukaBoxLaporan();
  await FilterHelper.init();
  runApp(const SmartCityApp());
}

class SmartCityApp extends StatelessWidget {
  const SmartCityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pelaporan Fasilitas Kota',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const HalamanDaftarLaporan(),
    );
  }
}