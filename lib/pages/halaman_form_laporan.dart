import 'package:flutter/material.dart';
import '../helpers/hive_helper.dart';
import '../models/laporan_fasilitas.dart';

class HalamanFormLaporan extends StatefulWidget {
  final LaporanFasilitas? laporan;

  const HalamanFormLaporan({super.key, this.laporan});

  @override
  State<HalamanFormLaporan> createState() => _HalamanFormLaporanState();
}

class _HalamanFormLaporanState extends State<HalamanFormLaporan> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _kode;
  late final TextEditingController _jenis;
  late final TextEditingController _lokasi;
  late String _status;

  bool get _modeUbah => widget.laporan != null;

  @override
  void initState() {
    super.initState();
    final laporan = widget.laporan;
    _kode = TextEditingController(text: laporan?.kode ?? '');
    _jenis = TextEditingController(text: laporan?.jenis ?? '');
    _lokasi = TextEditingController(text: laporan?.lokasi ?? '');
    _status = laporan?.status ?? 'Baru';
  }

  @override
  void dispose() {
    _kode.dispose();
    _jenis.dispose();
    _lokasi.dispose();
    super.dispose();
  }

  String? _wajib(String? nilai) =>
      (nilai == null || nilai.trim().isEmpty) ? 'Wajib diisi' : null;

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;

    final galat = _modeUbah
        ? await ubahLaporan(
            widget.laporan!,
            jenis: _jenis.text,
            lokasi: _lokasi.text,
            status: _status,
          )
        : await tambahLaporan(
            kode: _kode.text,
            jenis: _jenis.text,
            lokasi: _lokasi.text,
          );

    if (!mounted) return;
    if (galat != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(galat)));
      return;
    }
    final kode = _modeUbah ? widget.laporan!.kode : _kode.text.trim().toUpperCase();
    Navigator.pop(
      context,
      _modeUbah ? 'Laporan $kode diperbarui' : 'Laporan $kode ditambahkan',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_modeUbah ? 'Ubah Laporan' : 'Tambah Laporan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _kode,
              enabled: !_modeUbah,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Kode laporan',
                hintText: 'contoh: SC01',
              ),
              validator: _wajib,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _jenis,
              decoration: const InputDecoration(
                labelText: 'Jenis masalah',
                hintText: 'contoh: lampu jalan mati',
              ),
              validator: _wajib,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _lokasi,
              decoration: const InputDecoration(
                labelText: 'Lokasi',
                hintText: 'contoh: Jl. Melati',
              ),
              validator: _wajib,
            ),
            const SizedBox(height: 16),
            Text('Status', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            if (_modeUbah)
              Wrap(
                spacing: 8,
                children: [
                  for (final status in daftarStatus)
                    ChoiceChip(
                      label: Text(status),
                      selected: _status == status,
                      onSelected: (_) => setState(() => _status = status),
                    ),
                ],
              )
            else
              const Text('Baru (otomatis untuk laporan baru)'),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _simpan,
              icon: const Icon(Icons.save),
              label: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}