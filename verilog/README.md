# Verilog: Modul CNN dan Testbench

Folder ini berisi implementasi CNN klasifikasi gestur tangan batu-gunting-kertas dalam Verilog HDL, beserta testbench untuk simulasi. Aritmetikanya bilangan bulat dan mengikuti model "Python integer" di folder [`algorithm/`](../algorithm/).

## 1. Isi folder

| File | Keterangan |
| :--- | :--- |
| `cnn_top.v` | Modul utama: Conv 3x3 + ReLU, Max Pooling 2x2, Fully Connected, Argmax |
| `tb_cnn_top.v` | Testbench: memuat bobot dan 30 gambar uji, menjalankan inferensi satu per satu, lalu menampilkan prediksi dan skor |

## 2. Arsitektur yang diwujudkan

`Input 32x32 -> Conv 3x3 (4 filter) + ReLU -> Max Pooling 2x2 -> Flatten (900) -> Dense 3 -> Argmax`

### Antarmuka `cnn_top`

| Port | Arah | Lebar | Keterangan |
| :--- | :---: | :---: | :--- |
| `clk` | masuk | 1 | Clock |
| `rst_n` | masuk | 1 | Reset asinkron, aktif rendah |
| `start` | masuk | 1 | Memulai inferensi |
| `done` | keluar | 1 | Bernilai 1 saat hasil siap |
| `pred_class` | keluar | 2 | Kelas hasil prediksi: 0 = batu, 1 = kertas, 2 = gunting |
| `score0`, `score1`, `score2` | keluar | 64 (bertanda) | Skor tiap kelas sebelum argmax |

Parameter `SH1` (bawaan `9`) adalah jumlah geser kanan antara max pooling dan Dense, sesuai `sh1` di `algorithm/parameter.txt`. Jika model dilatih ulang, nilai ini harus disesuaikan.

### Memori internal

| Memori | Ukuran | Isi |
| :--- | :---: | :--- |
| `img_mem` | 1.024 x 8-bit | Gambar masukan 32 x 32 (tanpa tanda) |
| `w_conv_mem` | 36 x 8-bit | Bobot konvolusi (bertanda) |
| `b_conv_mem` | 4 x 32-bit | Bias konvolusi |
| `w_fc_mem` | 2.700 x 8-bit | Bobot Dense (bertanda) |
| `b_fc_mem` | 3 x 32-bit | Bias Dense |
| `pool_mem` | 900 x 8-bit | Hasil max pooling (0 sampai 127) |

### Mesin keadaan (FSM)

| State | Tugas |
| :--- | :--- |
| `S_IDLE` | Menunggu `start` |
| `S_CONV` | Konvolusi 3x3 + bias, ReLU, max pooling 2x2, geser kanan `SH1`, batas atas 127, simpan ke `pool_mem` |
| `S_FC` | Menghitung 3 skor dari 900 fitur |
| `S_ARG` | Memilih kelas dengan skor tertinggi (jika seri, indeks terkecil dipilih) |
| `S_DONE` | Menaikkan `done` |

Urutan flatten: `(baris*15 + kolom)*4 + filter`, sama dengan urutan pada Keras.

## 3. Catatan desain

`cnn_top.v` adalah **model perilaku (*behavioral*) untuk simulasi**. Seluruh konvolusi dan lapisan Dense dihitung dengan loop `for` di dalam satu tepi clock, sehingga modul ini ditujukan untuk memverifikasi fungsi dan keluaran, bukan untuk disintesis ke FPGA. Versi yang dapat disintesis memerlukan penjadwalan dengan unit MAC yang dipakai bergantian dan memori bertipe blok RAM.

## 4. Testbench

- Clock 100 MHz (periode 10 ns).
- Bobot, bias, dan 30 gambar uji dibaca dengan `$readmemh`.
- Untuk setiap gambar: 1.024 piksel disalin ke `img_mem`, `start` dinaikkan satu clock, lalu menunggu `done`.
- Keluaran per gambar: nomor, kelas prediksi, dan tiga skor.
- Testbench tidak membandingkan hasil secara otomatis. Pencocokan dengan `algorithm/golden.csv` dilakukan dengan membaca transkrip (lihat [`laporan/`](../laporan/)).

## 5. Cara menjalankan di Questa Intel FPGA Edition

1. Buat project baru, lalu tambahkan `cnn_top.v` dan `tb_cnn_top.v`.
2. Salin lima file berikut ke **folder tempat simulasi dijalankan** (folder project), karena testbench memanggilnya dengan nama file saja:
   `w_conv.hex`, `b_conv.hex`, `w_fc.hex`, `b_fc.hex` (dari `algorithm/`) dan `test_images.hex` (dari `dataset/`).
3. Compile kedua file (Compile > Compile All).
4. Mulai simulasi pada modul `tb_cnn_top` (Simulate > Start Simulation).
5. Pada transkrip, ketik `run -all`.

## 6. Hasil simulasi

Prediksi Verilog sama dengan Python integer dan Python float pada **30 dari 30** gambar uji, dan benar terhadap label asli pada 26 dari 30 gambar (86,67%). Bukti ada pada [`laporan/HasilTranskrip.png`](../laporan/HasilTranskrip.png), dan tabel per sampel ada di [`laporan/README.md`](../laporan/README.md).
