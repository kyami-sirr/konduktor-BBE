import matplotlib.pyplot as plt
import numpy as np

# Data untuk plotting
materials = ['Tembaga', 'Aluminium', 'AAAC']

# Nilai relatif terhadap tembaga (dalam persen atau skala perbandingan)
# Massa relatif: Tembaga 100%, Aluminium 49%, AAAC 57%
# Biaya relatif: Tembaga 100%, Aluminium 11%, AAAC 13%
massa_relatif = [100, 49, 57]
biaya_relatif = [100, 11, 13]

x = np.arange(len(materials))
width = 0.35

fig, ax = plt.subplots(figsize=(8, 5))

rects1 = ax.bar(x - width/2, massa_relatif, width, label='Massa Relatif (%)', color='#2b5c8f')
rects2 = ax.bar(x + width/2, biaya_relatif, width, label='Biaya Logam Relatif (%)', color='#d95f02')

ax.set_ylabel('Persentase terhadap Tembaga (%)')
ax.set_title('Perbandingan Massa dan Biaya Logam pada Resistansi DC yang Sama')
ax.set_xticks(x)
ax.set_xticklabels(materials)
ax.legend()

ax.bar_label(rects1, padding=3, fmt='%d%%')
ax.bar_label(rects2, padding=3, fmt='%d%%')

fig.tight_layout()

# Menyimpan gambar
plt.savefig('Gambar_4-7_resistansi_sama.png', dpi=300)
plt.show()
