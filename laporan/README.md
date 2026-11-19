# Laporan Hasil Verifikasi: Python vs Verilog

Folder ini berisi ringkasan hasil verifikasi CNN klasifikasi gestur tangan batu-gunting-kertas.
Bukti simulasi: [`HasilTranskrip.png`](HasilTranskrip.png) (transkrip Questa Intel Starter FPGA Edition 2024.3).

## 1. Ringkasan

| Platform | Akurasi pada 30 sampel uji | Kesesuaian terhadap Python integer |
| :--- | :---: | :---: |
| Python float (referensi) | 86,67% (26/30) | tidak dihitung |
| Python integer (kuantisasi 8-bit) | 86,67% (26/30) | baseline |
| Verilog (simulasi Questa) | 86,67% (26/30) | **100% (30/30)** |

Prediksi Verilog sama dengan Python integer pada seluruh 30 sampel, dan juga sama dengan Python float pada 30/30 sampel.

## 2. Parameter kuantisasi

`f1 = 7`, `sh1 = 9`, `f2 = 8` (lihat `algorithm/parameter.txt`). Bobot 8-bit bertanda, bias 32-bit, piksel 8-bit tanpa tanda. Keluaran max pooling digeser kanan 9 bit lalu dibatasi maksimum 127.

## 3. Hasil pada seluruh data uji (372 gambar, dari Python)

| Model | Akurasi |
| :--- | :---: |
| Python float | 82,53% |
| Python integer | 82,80% |
| Kesesuaian integer terhadap float | 97,04% |

Angka 86,67% pada tabel ringkasan hanya berlaku untuk 30 sampel yang diekspor (10 per kelas). Akurasi model pada seluruh data uji adalah 82,53% (float).

## 4. Catatan pemilihan model

Pelatihan dilakukan 5 kali dengan seed berbeda (1 sampai 5). Akurasi uji tiap seed: 66,13%, 68,01%, 70,43%, 72,04%, dan 82,53%. Model dengan akurasi uji tertinggi (seed 5) dipilih. Variasi antar-seed yang besar menunjukkan bahwa hasil CNN kecil ini sensitif terhadap inisialisasi bobot dan model dipilih berdasarkan data uji.

## 5. Perbandingan per sampel (30 gambar uji)

Kelas: 0 = batu, 1 = kertas, 2 = gunting.

| No | Label asli | Python float | Python integer | Verilog | Verilog = Python integer | Verilog vs label asli |
| :-: | :-: | :-: | :-: | :-: | :-: | :-: |
| 0 | batu | batu | batu | batu | Ya | Benar |
| 1 | batu | gunting | gunting | gunting | Ya | Salah |
| 2 | batu | batu | batu | batu | Ya | Benar |
| 3 | batu | batu | batu | batu | Ya | Benar |
| 4 | batu | batu | batu | batu | Ya | Benar |
| 5 | batu | kertas | kertas | kertas | Ya | Salah |
| 6 | batu | batu | batu | batu | Ya | Benar |
| 7 | batu | batu | batu | batu | Ya | Benar |
| 8 | batu | gunting | gunting | gunting | Ya | Salah |
| 9 | batu | batu | batu | batu | Ya | Benar |
| 10 | kertas | kertas | kertas | kertas | Ya | Benar |
| 11 | kertas | kertas | kertas | kertas | Ya | Benar |
| 12 | kertas | kertas | kertas | kertas | Ya | Benar |
| 13 | kertas | kertas | kertas | kertas | Ya | Benar |
| 14 | kertas | kertas | kertas | kertas | Ya | Benar |
| 15 | kertas | kertas | kertas | kertas | Ya | Benar |
| 16 | kertas | kertas | kertas | kertas | Ya | Benar |
| 17 | kertas | kertas | kertas | kertas | Ya | Benar |
| 18 | kertas | kertas | kertas | kertas | Ya | Benar |
| 19 | kertas | kertas | kertas | kertas | Ya | Benar |
| 20 | gunting | gunting | gunting | gunting | Ya | Benar |
| 21 | gunting | gunting | gunting | gunting | Ya | Benar |
| 22 | gunting | gunting | gunting | gunting | Ya | Benar |
| 23 | gunting | gunting | gunting | gunting | Ya | Benar |
| 24 | gunting | gunting | gunting | gunting | Ya | Benar |
| 25 | gunting | batu | batu | batu | Ya | Salah |
| 26 | gunting | gunting | gunting | gunting | Ya | Benar |
| 27 | gunting | gunting | gunting | gunting | Ya | Benar |
| 28 | gunting | gunting | gunting | gunting | Ya | Benar |
| 29 | gunting | gunting | gunting | gunting | Ya | Benar |
