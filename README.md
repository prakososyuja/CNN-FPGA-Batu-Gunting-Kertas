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
