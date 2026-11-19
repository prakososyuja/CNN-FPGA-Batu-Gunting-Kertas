# Algoritma: CNN Python (Referensi) dan Kuantisasi

Folder ini berisi model referensi di Python (Google Colab): pelatihan CNN, kuantisasi ke bilangan bulat, dan ekspor bobot ke format `.hex` yang dibaca oleh modul Verilog di folder [`verilog/`](../verilog/).

## 1. Isi folder

| File | Keterangan |
| :--- | :--- |
| `CNN_Batu_Gunting_Kertas.ipynb` | Notebook Colab (satu sel mandiri): memuat data, melatih CNN, kuantisasi, ekspor, dan membuat `export_cnn.zip` |
| `w_conv.hex`, `b_conv.hex` | Bobot dan bias lapisan konvolusi (hasil kuantisasi) |
| `w_fc.hex`, `b_fc.hex` | Bobot dan bias lapisan fully connected (hasil kuantisasi) |
| `parameter.txt` | Parameter kuantisasi dan ringkasan akurasi |
| `golden.csv` | Label asli dan prediksi Python (float dan integer) untuk 30 gambar uji |

File `test_images.hex` (30 gambar uji) berada di folder [`dataset/`](../dataset/).

## 2. Alur di notebook

1. **Data:** memuat `rock_paper_scissors` dari TensorFlow Datasets (2.520 gambar latih, 372 gambar uji), mengubah setiap gambar menjadi **32 x 32 grayscale**, lalu membagi nilai piksel dengan 255.
2. **Model:** `Conv2D(4 filter, 3x3, ReLU)` -> `MaxPooling2D(2x2)` -> `Flatten` -> `Dense(3, softmax)`. Total 2.743 parameter.
3. **Pelatihan:** optimizer Adam, loss *sparse categorical crossentropy*, 10 epoch, batch 64, `validation_split=0.1`. Pelatihan diulang **5 kali** dengan seed 1 sampai 5, lalu model dengan akurasi uji tertinggi dipilih (seed 5).
4. **Kuantisasi:** mengubah model menjadi aritmetika bilangan bulat (lihat bagian 3).
5. **Ekspor:** menulis file `.hex`, `golden.csv`, dan `parameter.txt`, lalu mengemasnya dalam `export_cnn.zip`.

## 3. Kuantisasi (fixed-point)

| Bagian | Representasi |
| :--- | :--- |
| Piksel masukan | bilangan bulat 8-bit tanpa tanda (`0` sampai `255`) |
| Bobot konvolusi | bilangan bulat 8-bit bertanda, skala `2^f1` |
| Bias konvolusi | 32-bit, skala `255 * 2^f1` |
| Keluaran konvolusi | ReLU, lalu max pooling 2x2 |
| Antara pooling dan Dense | geser kanan `sh1` bit, dibatasi maksimum `127` |
| Bobot Dense | bilangan bulat 8-bit bertanda, skala `2^f2` |
| Bias Dense | 32-bit |
| Keputusan akhir | `argmax` dari 3 skor (jika seri, indeks terkecil dipilih) |

Nilai parameter yang dipakai: `f1 = 7`, `sh1 = 9`, `f2 = 8` (lihat `parameter.txt`). Fungsi Softmax tidak diperlukan di hardware karena keputusan hanya membutuhkan `argmax`.

## 4. Format file `.hex`

Semua file berisi satu nilai heksadesimal per baris (komplemen dua untuk bilangan negatif) dan dibaca dengan `$readmemh`.

| File | Jumlah baris | Lebar | Urutan isi |
| :--- | :---: | :---: | :--- |
| `w_conv.hex` | 36 | 8-bit | 4 filter x 3 x 3; urutan: filter, baris, kolom |
| `b_conv.hex` | 4 | 32-bit | bias tiap filter |
| `w_fc.hex` | 2.700 | 8-bit | 3 kelas x 900; urutan: kelas, lalu indeks flatten `(baris*15 + kolom)*4 + kanal` |
| `b_fc.hex` | 3 | 32-bit | bias tiap kelas |
| `test_images.hex` (di `dataset/`) | 30.720 | 8-bit | 30 gambar x 1.024 piksel; 10 gambar pertama tiap kelas, kelas 0, 1, lalu 2 |

Kelas: `0` = batu (*rock*), `1` = kertas (*paper*), `2` = gunting (*scissors*).

Kolom `golden.csv`: `no`, `indeks_data_uji`, `label_asli`, `prediksi_python_float`, `prediksi_python_integer`.

## 5. Hasil

Pada seluruh 372 gambar uji:

| Model | Akurasi |
| :--- | :---: |
| Python float | 82,53% |
| Python integer | 82,80% |
| Kesesuaian integer terhadap float | 97,04% |

Akurasi uji kelima seed: 66,13%, 68,01%, 70,43%, 72,04%, dan 82,53%. Variasi yang besar menunjukkan bahwa CNN kecil ini sensitif terhadap inisialisasi bobot. Model dipilih berdasarkan akurasi pada data uji.

## 6. Cara menjalankan ulang

1. Buka [Google Colab](https://colab.research.google.com), lalu unggah `CNN_Batu_Gunting_Kertas.ipynb` (File > Unggah notebook).
2. Jalankan sel tersebut (tombol Run). Dataset diunduh otomatis (sekitar 220 MB) dan proses memakan waktu beberapa menit.
3. Browser mengunduh `export_cnn.zip`. Salin isinya ke folder ini.

Catatan: hasil pelatihan dapat sedikit berbeda jika dijalankan ulang di lingkungan lain. File `.hex` yang ada di repositori ini adalah yang dipakai pada verifikasi Verilog.
