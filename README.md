# Konduktor BBE — Studi Komparatif Busbar Tembaga, Aluminium, dan AAAC

Muhammad Yasir Assafa (257002111102) Kelas D
Analisis perbandingan performa tiga material konduktor listrik (**Tembaga**, **Aluminium**, **AAAC**)
pada busbar berpenampang persegi 100 mm × 10 mm yang dialiri arus 500 A pada frekuensi 50 Hz.

Perbandingan dilakukan dari dua sisi yang saling memeriksa:

1. **Perhitungan analitik** (Python, `hitung_konduktor.py`) — resistansi, rugi daya I²R, kedalaman kulit, massa, dan biaya.
2. **Simulasi medan elektromagnetik 2D** (FEMM 4.2, `busbar_femm.lua`) — rugi resistif dan distribusi kerapatan arus
   dengan mempertimbangkan **efek kulit** (*skin effect*).

Hasil akhirnya divisualisasikan sebagai perbandingan massa dan biaya logam (`plot_J.py` → `Gambar_4-7_resistansi_sama.png`).

---

## 1. Kasus yang Dimodelkan

| Parameter | Nilai | Keterangan |
|---|---|---|
| Arus | 500 A (RMS) | amplitudo puncak 707,1 A untuk FEMM AC |
| Frekuensi | 50 Hz | jaringan distribusi Indonesia |
| Penampang busbar | 100 mm × 10 mm = 1000 mm² | empat persegi panjang |
| Panjang / kedalaman model | 1 m (1000 mm) | model *planar* (2D) |
| Suhu kerja | 70 °C | untuk koreksi resistivitas analitik |
| Suhu referensi | 20 °C | titik acuan ρ pada datasheet |
| Material | Tembaga, Aluminium, AAAC | AAAC = *All Aluminium Alloy Conductor* |

### Data material yang dipakai

| Material | ρ₂₀ (Ω·m) | α (1/°C) | Massa jenis (kg/m³) | Konduktivitas FEMM (MS/m) |
|---|---|---|---|---|
| Tembaga | 1,724 × 10⁻⁸ | 0,00393 | 8960 | 58,0 |
| Aluminium | 2,82 × 10⁻⁸ | 0,00403 | 2700 | 35,4 |
| AAAC | 3,28 × 10⁻⁸ | 0,00360 | 2690 | 30,5 |

> Nilai di atas adalah nilai tipikal buku/datasheet. Untuk laporan final, verifikasi ulang terhadap
> datasheet produsen kabel yang dipakai. Kolom harga (Rp/kg) di `hitung_konduktor.py` masih bertanda `[ISI]`
> dan sengaja dibiarkan 0 agar tidak menghasilkan angka biaya yang menyesatkan.

---

## 2. Struktur Repositori

```
.
├── README.md                        # dokumen ini
├── hitung_konduktor.py              # perhitungan analitik (standard library saja)
├── busbar_femm.lua                  # skrip FEMM: bangun geometri, solve AC, ekspor hasil
├── plot_J.py                        # grafik perbandingan massa & biaya (matplotlib)
├── requirements.txt                 # dependensi Python untuk plot_J.py
├── hasil_femm.txt                   # keluaran simulasi: rugi resistif + tegangan tiap material
├── J_Tembaga.txt                    # peta kerapatan arus pada penampang (100 × 20 titik)
├── J_Aluminium.txt
├── J_AAAC.txt
├── busbar_Tembaga.fem               # geometri + hasil model FEMM (dapat dibuka di FEMM)
├── busbar_Aluminium.fem
├── busbar_AAAC.fem
└── Gambar_4-7_resistansi_sama.png   # gambar hasil (300 dpi, siap masuk laporan)
```

File `*.ans` (solusi biner FEMM, ±750 KB per material) **tidak** ikut di-*commit* karena dapat
dibangkitkan ulang dengan menjalankan `busbar_femm.lua`. Lihat `.gitignore`.

---

## 3. Metodologi

### 3.1 Perhitungan analitik (`hitung_konduktor.py`)

Untuk setiap material dihitung:

- Resistivitas terkoreksi suhu: ρ(T) = ρ₂₀ · [1 + α · (T − 20)]
- Resistansi konduktor: R = ρ · L / A
- Rugi daya resistif: P = I² · R
- Kedalaman kulit: δ = √(ρ / (π · f · µ₀))
- Massa konduktor: m = ρ_massa · A · L
- Estimasi biaya: m × harga per kg

### 3.2 Simulasi FEMM (`busbar_femm.lua`)

Model *planar* 2D, satuan milimeter, kedalaman 1000 mm, mesh halus (presisi 1 × 10⁻⁸, sudut minimum 30°):

- Blok busbar diberi properti material dengan konduktivitas σ dan properti rangkaian `bus` (seri, arus puncak).
- Blok udara mengelilingi busbar; batas luar berupa lingkaran berjari-jari 3 × lebar busbar dengan
  potensial vektor magnetik A = 0 (pengganti `mi_makeABC`).
- Setelah `mi_analyze()`, rugi resistif diambil dengan `mo_blockintegral(4)` dan tegangan rangkaian
  dengan `mo_getcircuitproperties("bus")`.
- Distribusi kerapatan arus diekstrak pada grid 100 × 20 titik di dalam penampang (`mo_getpointvalues`),
  lalu disimpan ke `J_<material>.txt` sebagai komponen real dan imajiner.

Output per material: `busbar_<material>.fem` (model) dan satu baris di `hasil_femm.txt`.

---

## 4. Hasil

### 4.1 Rugi resistif hasil simulasi FEMM (`hasil_femm.txt`)

| Material | Arus (A RMS) | Rugi resistif (W) | Relatif terhadap tembaga | V real (V) | V imajiner (V) |
|---|---|---|---|---|---|
| Tembaga | 500 | **5,172** | 100 % | 0,01463 | 0,10845 |
| Aluminium | 500 | **7,834** | +51,5 % | 0,02216 | 0,10943 |
| AAAC | 500 | **8,920** | +72,5 % | 0,02523 | 0,10969 |

Rugi resistif tembaga paling rendah; aluminium 1,5× dan AAAC 1,7× rugi tembaga pada arus yang sama.

### 4.2 Hasil perhitungan analitik pada 70 °C

```
Luas penampang = 1000 mm2, I = 500.0 A, L = 1.0 m, f = 50.0 Hz

Material        rho@Top   R (mOhm)  P=I2R (W)  Skin (mm)  Massa (kg)   Biaya (Rp)
Tembaga       2.063e-08     0.0206       5.16      10.22        8.96            0
Aluminium     3.388e-08     0.0339       8.47      13.10        2.70            0
AAAC          3.870e-08     0.0387       9.68      14.00        2.69            0
```

Kedalaman kulit pada 50 Hz: tembaga ±10,2 mm, aluminium ±13,1 mm, AAAC ±14,0 mm — sebanding dengan
tebal busbar (10 mm), sehingga efek kulit mulai berpengaruh tetapi belum dominan.

### 4.3 Distribusi kerapatan arus (efek kulit)

Diolah dari `J_*.txt` (nilai puncak, A/mm²):

| Material | \|J\| rata-rata | \|J\| maks | \|J\| min | J_maks / J_rata-rata |
|---|---|---|---|---|
| Tembaga | 0,736 | 1,350 | 0,493 | 1,83 |
| Aluminium | 0,730 | 1,077 | 0,574 | 1,48 |
| AAAC | 0,728 | 1,012 | 0,597 | 1,39 |

Rata-rata mendekati nilai seragam teoretis 0,707 A/mm², sedangkan rasio maks/rata-rata menurun dari
tembaga → aluminium → AAAC. Artinya **arus terdorong ke permukaan paling kuat pada tembaga**, karena
kedalaman kulitnya paling kecil dibanding tebal busbar. Inilah sebabnya rugi AC tembaga naik lebih
banyak dibanding perkiraan DC-nya.

### 4.4 Massa dan biaya pada resistansi DC yang sama

`plot_J.py` menghasilkan `Gambar_4-7_resistansi_sama.png`: untuk resistansi DC yang setara dengan
tembaga, aluminium hanya membutuhkan ±49 % massa dan ±11 % biaya logam, sedangkan AAAC ±57 % massa dan
±13 % biaya. Angka ini berasal dari data harga pembanding di komentar `plot_J.py`; ganti dengan harga
pasar terbaru sebelum dipakai di laporan.

---

## 5. Pembahasan Singkat

- **Tembaga** unggul pada rugi daya dan ukuran (konduktivitas tertinggi, penampang sama menghantarkan
  paling baik), tetapi paling berat dan paling mahal, serta paling terkena efek kulit relatif terhadap
  tebal busbar.
- **Aluminium** rugi ±1,5× tembaga, tetapi massa dan biaya jauh lebih rendah. Untuk aplikasi yang
  mengutamakan biaya dan bobot (panel distribusi, saluran udara), ini kompromi yang menguntungkan.
- **AAAC** sedikit lebih buruk dari aluminium murni pada rugi daya (konduktivitas 30,5 vs 35,4 MS/m),
  tetapi punya kekuatan mekanik lebih tinggi — keunggulannya pada bentang/jarak tumpuan, bukan pada rugi.

Catatan penting saat membandingkan: **FEMM memakai konduktivitas konstan** (setara ρ pada 20 °C) dan
sudah memperhitungkan efek kulit, sedangkan **perhitungan analitik memakai ρ pada 70 °C** tanpa faktor
kulit. Karena itu angka keduanya tidak identik dan tidak boleh dibandingkan langsung — samakan dulu
asumsi suhunya bila ingin perbandingan apple-to-apple.

---

## 6. Cara Menjalankan

### 6.1 Perhitungan analitik (tanpa dependensi)

```bash
python3 hitung_konduktor.py
```

Ubah `I`, `L`, `W`, `H`, `f`, `T_op`, dan tabel `materials` di bagian atas skrip untuk kasus lain.

### 6.2 Simulasi FEMM

Prasyarat: **FEMM 4.2** terpasang (Windows; di Linux dapat dijalankan lewat Wine atau versi build Linux).

1. Buka FEMM → `File` → `Open Lua Script…` → pilih `busbar_femm.lua`.
2. Skrip otomatis membuat tiga dokumen (satu per material), menyelesaikan solve AC 50 Hz, lalu menulis:
   - `hasil_femm.txt` — rugi resistif dan tegangan tiap material,
   - `J_Tembaga.txt`, `J_Aluminium.txt`, `J_AAAC.txt` — peta kerapatan arus,
   - `busbar_<material>.fem` dan `busbar_<material>.ans` — model dan solusinya.
3. Jalankan dari dalam folder ini agar semua file hasil tertulis di tempat yang sama
   (path di skrip bersifat relatif).
4. Bila baru mengubah parameter, uji dulu dengan satu material (ubah `for i = 1, 3` menjadi `for i = 1, 1`)
   agar tidak menunggu tiga kali solve untuk kesalahan yang sama.

### 6.3 Grafik massa dan biaya

```bash
python3 -m pip install -r requirements.txt
python3 plot_J.py
```

Menghasilkan `Gambar_4-7_resistansi_sama.png` (300 dpi).

---

## 7. Asumsi dan Keterbatasan

- Model 2D *planar*, kedalaman 1000 mm; efek ujung, sambungan baut, dan konveksi panas diabaikan.
- Tidak ada analisis termal kopel: suhu 70 °C hanya dipakai untuk koreksi resistivitas, bukan hasil hitung.
- Konduktivitas FEMM dianggap konstan (tanpa koreksi suhu).
- Rugi histeresis/eddy pada material feromagnetik di sekitar busbar tidak dimodelkan.
- Data harga logam adalah nilai pembanding relatif, bukan hasil survei pasar.

---
