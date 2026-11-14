"""Template perhitungan analitik: tembaga vs aluminium vs AAAC.
Dipakai untuk memeriksa hasil simulasi FEMM. Ganti angka bertanda [ISI] dari datasheet/jurnal."""
import math

# ---------- PARAMETER SISTEM (ubah sesuai kasus) ----------
I = 500.0          # arus (A)
L = 1.0            # panjang (m)
W, H = 0.100, 0.010  # busbar lebar x tebal (m)
f = 50.0           # frekuensi (Hz)
T_ref, T_op = 20.0, 70.0   # suhu referensi & kerja (C)
mu0 = 4e-7 * math.pi

# ---------- DATA MATERIAL (nilai tipikal, verifikasi dengan datasheet) ----------
materials = {
    #            rho20 (ohm.m), alpha (1/C), massa jenis (kg/m3), harga (Rp/kg) [ISI]
    "Tembaga":   (1.724e-8, 0.00393, 8960, 0),
    "Aluminium": (2.82e-8,  0.00403, 2700, 0),
    "AAAC":      (3.28e-8,  0.00360, 2690, 0),
}

A = W * H
print(f"Luas penampang = {A*1e6:.0f} mm2, I = {I} A, L = {L} m, f = {f} Hz\n")
print(f"{'Material':10} {'rho@Top':>12} {'R (mOhm)':>10} {'P=I2R (W)':>10} {'Skin (mm)':>10} {'Massa (kg)':>11} {'Biaya (Rp)':>12}")
for nama, (rho20, a, dens, harga) in materials.items():
    rho = rho20 * (1 + a * (T_op - T_ref))
    R = rho * L / A
    P = I**2 * R
    delta = math.sqrt(rho / (math.pi * f * mu0)) * 1000  # mm
    massa = dens * A * L
    print(f"{nama:10} {rho:12.3e} {R*1e3:10.4f} {P:10.2f} {delta:10.2f} {massa:11.2f} {massa*harga:12.0f}")
