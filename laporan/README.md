# Implementasi CNN Pengenalan Angka (MNIST) pada Verilog & Python

**Mata Kuliah:** Desain SoC dan FPGA  
**Nama:** Prakoso Syujawanto  
**NIM:** 101022300287  

---

## 1. Tujuan Proyek
Melakukan perancangan arsitektur hardware *Convolutional Neural Network* (CNN) menggunakan **Verilog HDL** untuk klasifikasi citra angka tulisan tangan (dataset MNIST 0–9), serta memverifikasi kesamaan outputnya terhadap model referensi software menggunakan **Python** (*Hardware-Software Co-Verification*).

---

## 2. Alur Pemrosesan Data (Step-by-Step)

### A. Tahap Software (Python - Golden Reference)
1. **Input Citra:** Memuat citra grayscale berukuran `28 x 28` piksel dari dataset MNIST (label 0–9 berupa *one-hot encoding*).
2. **Feature Extraction (Convolution & ReLU):** Menerapkan filter konvolusi `3 x 3` dengan *stride* 1 dan *padding* untuk mengekstrak *feature map*, dilanjutkan fungsi aktivasi ReLU $f(x) = \max(0, x)$.
3. **Downsampling (Max Pooling):** Mengurangi dimensi *feature map* menggunakan jendela `2 x 2` (*stride* 2) untuk mengambil nilai fitur paling dominan.
4. **Klasifikasi (Flatten & Fully Connected):** Meratakan (*flatten*) matriks fitur menjadi vektor 1D, diteruskan ke *Dense Layer* dan fungsi aktivasi *Softmax* untuk menentukan prediksi kelas angka (0–9).
5. **Ekspor Parameter:** Menyimpan nilai bobot (*weights*), *bias*, dan data piksel citra uji ke format numerik (*fixed-point*/heksadesimal) untuk dibaca oleh modul Verilog.

### B. Tahap Hardware (Verilog HDL - Questa Intel FPGA)
1. **Inisialisasi Memori (ROM/RAM):** Memuat data piksel citra uji (`28 x 28`) serta parameter bobot dan bias hasil training Python ke dalam register/memori Verilog.
2. **Modul Konvolusi (MAC Unit):** Melakukan operasi perkalian dan penjumlahan (*Multiply-Accumulate*) secara sekuensial/paralel antara jendela piksel citra dengan kernel filter `3 x 3`.
3. **Modul Aktivasi ReLU:** Melakukan komparasi nilai hasil konvolusi; jika bernilai negatif (bit tanda = 1), output diubah menjadi `0`.
4. **Modul Max Pooling:** Membandingkan blok data `2 x 2` dari output ReLU dan meneruskan nilai maksimumnya.
5. **Modul Fully Connected & Komparator Output:** Menghitung skor akhir untuk 10 kelas angka (0–9) dan menentukan kelas prediksi berdasarkan nilai skor tertinggi (*argmax*).

---

## 3. Hasil Perbandingan Akurasi (Python vs Verilog)

| Platform | Akurasi terhadap Dataset | Tingkat Kesesuaian terhadap Python | Status |
| :--- | :---: | :---: | :--- |
| **Python (Referensi)** | *Dalam pengujian (%)* | 100% (Baseline) | Selesai / Berjalan |
| **Verilog (Simulasi Questa)** | *Dalam pengujian (%)* | *Target 100% match* | On Progress |

---

## 4. Struktur Direktori
* `python/` : Kode pelatihan model CNN (Keras/TensorFlow) dan skrip konversi bobot/citra uji.
* `verilog/` : Modul desain CNN (`.v`), *testbench* (`_tb.v`), dan file memori bobot/input.
* `laporan/` : Laporan lengkap, hasil *waveform* simulasi Questa, dan analisis perbandingan output.
