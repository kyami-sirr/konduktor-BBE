-- Template FEMM 4.2: busbar penampang persegi, magnetik AC 50 Hz (efek kulit + rugi I2R)
-- Cara pakai: buka FEMM > File > Open Lua Script > pilih file ini.
-- Hasil ditulis ke hasil_femm.txt. Cek dulu dengan 1 material sebelum loop penuh.

I_rms = 500            -- arus efektif/RMS (A), samakan dengan hitung_konduktor.py
I   = I_rms * sqrt(2)   -- FEMM AC memakai amplitudo PUNCAK, bukan RMS
f   = 50       -- frekuensi (Hz)
W   = 100      -- lebar busbar (mm)
H   = 10       -- tebal busbar (mm)
D   = 1000     -- kedalaman/panjang (mm)
-- konduktivitas dalam MS/m (verifikasi dengan datasheet)
mats = { {"Tembaga", 58.0}, {"Aluminium", 35.4}, {"AAAC", 30.5} }

out = openfile("hasil_femm.txt", "w")
write(out, "Material\tArus(A)\tRugi_resistif(W)\tTegangan_re\tTegangan_im\n")

for i = 1, 3 do
  nama = mats[i][1]
  newdocument(0)                                   -- 0 = magnetics
  mi_probdef(f, "millimeters", "planar", 1e-8, D, 30)
  mi_addmaterial("Udara", 1, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0)
  mi_addmaterial(nama, 1, 1, 0, 0, mats[i][2], 0, 0, 1, 0, 0, 0)
  mi_addcircprop("bus", I, 1)                      -- 1 = seri

  -- geometri busbar
  mi_drawrectangle(-W/2, -H/2, W/2, H/2)
  mi_addblocklabel(0, 0)
  mi_selectlabel(0, 0)
  mi_setblockprop(nama, 0, 1, "bus", 0, 1, 1)
  mi_clearselected()

  -- udara + batas terbuka (ABC)
  mi_addblocklabel(0, W)
  mi_selectlabel(0, W)
  mi_setblockprop("Udara", 1, 0, "<None>", 0, 0, 0)
  mi_clearselected()
  -- batas luar: lingkaran dengan potensial A = 0 (tanpa mi_makeABC)
  R = 3*W
  mi_addboundprop("A0", 0, 0, 0, 0, 0, 0, 0, 0, 0)
  mi_addnode(-R, 0)
  mi_addnode(R, 0)
  mi_addarc(R, 0, -R, 0, 180, 2)
  mi_addarc(-R, 0, R, 0, 180, 2)
  mi_selectarcsegment(0, R)
  mi_selectarcsegment(0, -R)
  mi_setarcsegmentprop(2, "A0", 0, 0)
  mi_clearselected()

  mi_saveas("busbar_" .. nama .. ".fem")
  mi_analyze()
  mi_loadsolution()

  mo_groupselectblock(1)
  rugi = mo_blockintegral(4)                       -- 4 = resistive losses (W)
  mo_clearblock()
  cur, volt, flux = mo_getcircuitproperties("bus") -- arus, tegangan, fluks
  write(out, nama .. "\t" .. I_rms .. "\t" .. rugi .. "\t" .. re(volt) .. "\t" .. im(volt) .. "\n")

  -- ekstraksi kerapatan arus J (amplitudo puncak, A/mm2) pada grid titik di penampang busbar
  nx = 100
  ny = 20
  dx = W / nx
  dy = H / ny
  jf = openfile("J_" .. nama .. ".txt", "w")
  write(jf, "x_mm\ty_mm\tJre\tJim\n")
  for ix = 1, nx do
    for iy = 1, ny do
      px = -W/2 + (ix - 0.5) * dx
      py = -H/2 + (iy - 0.5) * dy
      A_, B1_, B2_, sg_, en_, H1_, H2_, Je_, Js_ = mo_getpointvalues(px, py)
      Jt = Je_ + Js_
      write(jf, px .. "\t" .. py .. "\t" .. re(Jt) .. "\t" .. im(Jt) .. "\n")
    end
  end
  closefile(jf)

  mo_close()
  mi_close()
end
closefile(out)
messagebox("Selesai. Lihat hasil_femm.txt")
