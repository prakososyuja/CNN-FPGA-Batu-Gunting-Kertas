# Klasifikasi Gestur Tangan Batu-Gunting-Kertas Berbasis CNN pada FPGA

**Nama:** Prakoso Syujawanto  
**NIM:** 101022300287  
**Mata kuliah:** Desain SoC dan FPGA (UTS)  
**Tools:** Python (Keras/TensorFlow, Google Colab) dan Verilog HDL (Questa Intel FPGA Edition)

---

## 1. Tujuan Proyek

Merancang arsitektur hardware *Convolutional Neural Network* (CNN) menggunakan **Verilog HDL** untuk mengklasifikasikan gambar gestur tangan **batu (*rock*), kertas (*paper*), dan gunting (*scissors*)**, lalu memverifikasi bahwa keluarannya sesuai dengan model referensi di **Python** (*Hardware-Software Co-Verification*).

Ukuran keberhasilan utama adalah **tingkat kesesuaian keluaran simulasi Verilog terhadap keluaran referensi Python** untuk data masukan yang sama.

---

## 2. Dataset

| Item | Keterangan |
| :--- | :--- |
| Nama | Rock, Paper, Scissors Dataset |
| Pembuat | Laurence Moroney (2019) |
| Sumber | [TensorFlow Datasets: rock_paper_scissors](https://www.tensorflow.org/datasets/catalog/rock_paper_scissors) |
| Jumlah data | 2.520 gambar latih dan 372 gambar uji (30 sampel uji diekspor ke `.hex`) |
| Kelas | 3 (`0`: *rock*, `1`: *paper*, `2`: *scissors*) |
| Ukuran asli | 300 x 300 piksel, RGB |
| Ukuran yang dipakai | **32 x 32 piksel, grayscale** (dikecilkan dari ukuran asli) |
| Kuantisasi input | Piksel 8-bit unsigned (rentang `0` sampai `255`) |

![Contoh Dataset](Hasil%20Objek.png)

---

## 3. Arsitektur CNN

`Input 32x32x1 -> Conv 3x3 (4 filter) + ReLU -> Max Pooling 2x2 -> Flatten -> Dense 3 (Softmax)`

| Layer | Ukuran keluaran | Parameter |
| :--- | :---: | :---: |
| Input (grayscale) | 32 x 32 x 1 | 0 |
| Conv2D, 4 filter 3x3, stride 1, tanpa padding, ReLU | 30 x 30 x 4 | 40 |
| MaxPooling2D 2x2 | 15 x 15 x 4 | 0 |
| Flatten | 900 | 0 |
| Dense 3 neuron, Softmax | 3 | 2.703 |
| **Total** | | **2.743** |

**Parameter Kuantisasi Fixed-Point (`parameter.txt`):** `f1 = 7`, `sh1 = 9`, `f2 = 8`.

---

## 4. Alur Pemrosesan Data

### A. Tahap Software (Python, referensi)
1. Memuat dataset dan mengubah gambar menjadi 32 x 32 grayscale.
2. Melatih 5 kandidat model CNN (optimizer Adam, loss *sparse categorical crossentropy*, 10 epoch) dan memilih model terbaik (`seed 5`).
3. Mengekspor bobot, bias, dan 30 gambar uji (10 per kelas) ke format heksadesimal (`.hex`) beserta referensi hasil (`golden.csv`).

### B. Tahap Hardware (Verilog HDL)
1. **Memori:** memuat piksel gambar uji serta bobot dan bias dari file `.hex` menggunakan `$readmemh`.
2. **Konvolusi + ReLU + MaxPool:** perkalian dan penjumlahan (*MAC*) jendela 3 x 3 dengan 4 filter, aktivasi ReLU, pengambilan nilai maksimum blok 2 x 2, pergeseran kanan `sh1 = 9` bit (`>>> 9`), dan *clamping* pada nilai `127`.
3. **Fully Connected + Argmax:** menghitung skor untuk 3 kelas dan memilih indeks kelas dengan skor tertinggi.
4. **Testbench (`tb_cnn_top.v`):** menguji seluruh 30 sampel gambar uji secara otomatis di Questa Intel FPGA.

---

## 5. Hasil Perbandingan (Python vs Verilog)

| Platform | Akurasi pada 30 Data Uji | Kesesuaian terhadap Python | Status |
| :--- | :---: | :---: | :--- |
| Python Float (referensi) | **86,67%** (26/30) | Baseline | Selesai |
| Python Integer (kuantisasi) | **86,67%** (26/30) | **100,00%** (30/30) | Selesai |
| **Verilog HDL (Simulasi Questa)** | **86,67%** (26/30) | **100,00%** (30/30) | **Selesai (*Bit-Accurate*)** |

Hasil lengkap perbandingan per sampel (30 gambar uji) dan bukti *screenshot* simulasi tersedia di folder [`laporan/`](laporan/).

---

## 6. Struktur Direktori

- [`dataset/`](dataset/) : penjelasan dataset dan data uji gambar (`test_images.hex`).
- [`algorithm/`](algorithm/) : kode training/kuantisasi Google Colab (`CNN_Batu_Gunting_Kertas.ipynb`), file bobot/bias `.hex`, `parameter.txt`, dan `golden.csv`.
- [`verilog/`](verilog/) : modul desain utama (`cnn_top.v`) dan testbench simulasi (`tb_cnn_top.v`).
- [`laporan/`](laporan/) : ringkasan hasil verifikasi dan bukti *screenshot* simulasi Questa (`HasilTranskrip.png`).

---

## 7. Status Pengerjaan

- [x] Menentukan tema dan dataset
- [x] Training CNN di Python dan mencatat akurasi
- [x] Ekspor bobot dan gambar uji ke format hex
- [x] Modul Verilog (konvolusi, ReLU, max pooling, fully connected, argmax)
- [x] Testbench dan simulasi di Questa Intel FPGA
- [x] Perbandingan hasil Python vs Verilog
- [x] Laporan akhir dan pengumpulan di GitHub

---

## 8. Referensi

- Moroney, L. (2019). *Rock, Paper, Scissors Dataset*. [http://laurencemoroney.com/rock-paper-scissors-dataset](http://laurencemoroney.com/rock-paper-scissors-dataset)
- TensorFlow Datasets, katalog `rock_paper_scissors`. [https://www.tensorflow.org/datasets/catalog/rock_paper_scissors](https://www.tensorflow.org/datasets/catalog/rock_paper_scissors)
