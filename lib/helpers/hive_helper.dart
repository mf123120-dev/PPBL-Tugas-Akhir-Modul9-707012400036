import 'package:hive_flutter/hive_flutter.dart';
import '../models/laporan_fasilitas.dart';

late final Box<LaporanFasilitas> boxLaporan;

Future<void> bukaBoxLaporan() async {
  await Hive.initFlutter();
  Hive.registerAdapter(LaporanFasilitasAdapter());
  boxLaporan = await Hive.openBox<LaporanFasilitas>('laporanFasilitasBox');
}

/// Mengembalikan pesan galat, atau null jika berhasil.
Future<String?> tambahLaporan({
  required String kode,
  required String jenis,
  required String lokasi,
}) async {
  final k = kode.trim().toUpperCase();
  if (k.isEmpty || jenis.trim().isEmpty || lokasi.trim().isEmpty) {
    return 'Kode, jenis, dan lokasi wajib diisi';
  }
  if (boxLaporan.containsKey(k)) {
    return 'Kode $k sudah dipakai';
  }
  await boxLaporan.put(
    k,
    LaporanFasilitas(kode: k, jenis: jenis.trim(), lokasi: lokasi.trim()),
  );
  return null;
}

Future<String?> ubahLaporan(
  LaporanFasilitas laporan, {
  required String jenis,
  required String lokasi,
  required String status,
}) async {
  if (jenis.trim().isEmpty || lokasi.trim().isEmpty) {
    return 'Jenis dan lokasi wajib diisi';
  }
  if (!laporan.isInBox) return 'Laporan sudah dihapus';
  laporan
    ..jenis = jenis.trim()
    ..lokasi = lokasi.trim()
    ..status = status;
  await laporan.save();
  return null;
}

Future<void> hapusLaporan(String kode) => boxLaporan.delete(kode);