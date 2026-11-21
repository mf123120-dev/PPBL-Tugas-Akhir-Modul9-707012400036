import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../helpers/filter_helper.dart';
import '../helpers/hive_helper.dart';
import '../models/laporan_fasilitas.dart';
import 'halaman_form_laporan.dart';

class HalamanDaftarLaporan extends StatefulWidget {
  const HalamanDaftarLaporan({super.key});

  @override
  State<HalamanDaftarLaporan> createState() => _HalamanDaftarLaporanState();
}

class _HalamanDaftarLaporanState extends State<HalamanDaftarLaporan> {
  String _filter = FilterHelper.muat();

  Future<void> _gantiFilter(String status) async {
    await FilterHelper.simpan(status);
    setState(() => _filter = status);
  }

  Future<void> _resetFilter() async {
    await FilterHelper.reset();
    setState(() => _filter = FilterHelper.semua);
  }

  void _tampilkanPesan(String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  Future<void> _bukaForm([LaporanFasilitas? laporan]) async {
    final pesan = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => HalamanFormLaporan(laporan: laporan)),
    );
    if (!mounted || pesan == null) return;
    _tampilkanPesan(pesan);
  }

  Future<void> _konfirmasiHapus(LaporanFasilitas laporan) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus laporan?'),
        content: Text(
            'Laporan ${laporan.kode} (${laporan.jenis}) akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (yakin != true) return;
    final kode = laporan.kode;
    await hapusLaporan(kode);
    if (!mounted) return;
    _tampilkanPesan('Laporan $kode dihapus');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan Fasilitas Kota'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_off),
            tooltip: 'Reset filter',
            onPressed: _resetFilter,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              children: [
                for (final status in FilterHelper.pilihan)
                  ChoiceChip(
                    label: Text(status),
                    selected: _filter == status,
                    onSelected: (_) => _gantiFilter(status),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<Box<LaporanFasilitas>>(
              valueListenable: boxLaporan.listenable(),
              builder: (context, box, _) {
                final semua = box.values.toList()
                  ..sort((a, b) => a.kode.compareTo(b.kode));
                final daftar = _filter == FilterHelper.semua
                    ? semua
                    : semua.where((l) => l.status == _filter).toList();

                if (daftar.isEmpty) {
                  return Center(
                    child: Text(_filter == FilterHelper.semua
                        ? 'Belum ada laporan'
                        : 'Tidak ada laporan berstatus $_filter'),
                  );
                }
                return ListView.builder(
                  itemCount: daftar.length,
                  itemBuilder: (context, index) {
                    final laporan = daftar[index];
                    return Card(
                      child: ListTile(
                        title: Text('${laporan.kode} • ${laporan.jenis}'),
                        subtitle: Text(
                            'Lokasi: ${laporan.lokasi}\nStatus: ${laporan.status}'),
                        isThreeLine: true,
                        onTap: () => _bukaForm(laporan),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          tooltip: 'Hapus',
                          onPressed: () => _konfirmasiHapus(laporan),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bukaForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}