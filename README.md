# Klasifikasi Gestur Tangan Batu-Gunting-Kertas Berbasis CNN pada FPGA

**Nama:** Prakoso Syujawanto
**NIM:** 101022300287
**Mata kuliah:** Desain SoC dan FPGA (UTS)  
**Tools:** Python (Keras/TensorFlow, Google Colab) dan Verilog HDL (Quartus / ModelSim / Questa Intel FPGA)

---

## 1. Tujuan Proyek

Merancang arsitektur hardware *Convolutional Neural Network* (CNN) menggunakan **Verilog HDL** untuk mengklasifikasikan gambar gestur tangan **batu, gunting, dan kertas**, lalu memverifikasi bahwa keluarannya sesuai dengan model referensi di **Python** (*Hardware-Software Co-Verification*).

Ukuran keberhasilan bukan akurasi mutlak, tetapi **tingkat kesesuaian keluaran Verilog terhadap keluaran Python** untuk data masukan yang sama.

---

## 2. Dataset

| Item | Keterangan |
| :--- | :--- |
| Nama | Rock, Paper, Scissors Dataset |
| Pembuat | Laurence Moroney (2019) |
| Sumber | [TensorFlow Datasets: rock_paper_scissors](https://www.tensorflow.org/datasets/catalog/rock_paper_scissors) |
| Jumlah data | 2.520 gambar latih dan 372 gambar uji |
| Kelas | 3 (batu, gunting, kertas) |
| Ukuran asli | 300 x 300 piksel, RGB |
| Ukuran yang dipakai | **32 x 32 piksel, grayscale** (dikecilkan dari ukuran asli) |
| Normalisasi | Nilai piksel dibagi 255 (rentang 0 sampai 1) |

Dataset dimuat otomatis lewat `tensorflow_datasets` sehingga tidak perlu diunggah ke repositori ini. Folder `dataset/` berisi penjelasan dan beberapa gambar contoh.

---

## 3. Arsitektur CNN

```
Input 32x32x1 -> Conv 3x3 (4 filter) + ReLU -> Max Pooling 2x2 -> Flatten -> Dense 3 (Softmax)
```

| Layer | Ukuran keluaran | Parameter |
| :--- | :---: | :---: |
| Input (grayscale) | 32 x 32 x 1 | 0 |
| Conv2D, 4 filter 3x3, stride 1, tanpa padding, ReLU | 30 x 30 x 4 | 40 |
| MaxPooling2D 2x2 | 15 x 15 x 4 | 0 |
| Flatten | 900 | 0 |
| Dense 3 neuron, Softmax | 3 | 2.703 |
| **Total** | | **2.743** |

Arsitektur sengaja dibuat kecil agar realistis untuk diwujudkan sebagai hardware di FPGA.

---

## 4. Alur Pemrosesan Data

### A. Tahap Software (Python, referensi)

1. Memuat dataset dan mengubah gambar menjadi 32 x 32 grayscale.
2. Melatih CNN (optimizer Adam, loss *sparse categorical crossentropy*).
3. Menghitung akurasi pada data uji sebagai **akurasi referensi Python**.
4. Mengekspor bobot, bias, dan beberapa gambar uji ke format *fixed-point* / heksadesimal (`.hex`) untuk dibaca modul Verilog.

### B. Tahap Hardware (Verilog HDL)

1. **Memori:** memuat piksel gambar uji serta bobot dan bias dari file hex.
2. **Konvolusi (MAC):** perkalian dan penjumlahan jendela 3 x 3 dengan setiap filter.
3. **ReLU:** keluaran negatif diubah menjadi 0.
4. **Max Pooling:** mengambil nilai terbesar dari blok 2 x 2.
5. **Fully Connected + Argmax:** menghitung skor 3 kelas dan memilih kelas dengan skor tertinggi.
6. **Testbench:** memberi gambar uji ke modul dan mencatat kelas hasil prediksi.

---

## 5. Hasil Perbandingan (Python vs Verilog)

| Platform | Akurasi pada data uji | Kesesuaian terhadap Python | Status |
| :--- | :---: | :---: | :--- |
| Python (referensi) | [isi setelah training] % | 100% (baseline) | Sedang dikerjakan |
| Verilog (simulasi) | [isi setelah simulasi] % | [isi] % | Belum dimulai |

---

## 6. Struktur Direktori

* `dataset/` : penjelasan dataset dan gambar contoh.
* `python/` : kode training CNN dan skrip ekspor bobot / gambar uji.
* `verilog/` : modul desain (`.v`), testbench (`_tb.v`), dan file memori hex.
* `laporan/` : laporan lengkap, hasil simulasi, dan analisis perbandingan.

---

## 7. Cara Menjalankan Bagian Python

1. Buka [Google Colab](https://colab.research.google.com) dan buat notebook baru.
2. Salin kode dari folder `python/` ke sel-sel notebook.
3. Jalankan sel secara berurutan dari atas ke bawah.
4. Catat nilai akurasi yang tampil, lalu masukkan ke tabel pada bagian 5.

---

## 8. Status Pengerjaan

- [x] Menentukan tema dan dataset
- [ ] Training CNN di Python dan mencatat akurasi
- [ ] Ekspor bobot dan gambar uji ke format hex
- [ ] Modul Verilog (konvolusi, ReLU, max pooling, fully connected, argmax)
- [ ] Testbench dan simulasi
- [ ] Perbandingan hasil Python vs Verilog
- [ ] Laporan akhir

---

## 9. Referensi

* Moroney, L. (2019). *Rock, Paper, Scissors Dataset*. http://laurencemoroney.com/rock-paper-scissors-dataset
* TensorFlow Datasets, katalog `rock_paper_scissors`. https://www.tensorflow.org/datasets/catalog/rock_paper_scissors
* Fatichah, C. *Pengantar Deep Learning: Convolutional Neural Network* (materi kuliah), Institut Teknologi Sepuluh Nopember.
