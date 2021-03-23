from math import *

bitdepth_per_channel = 2
channels = 4

bits = bitdepth_per_channel*channels
values_per_channel = 2**bitdepth_per_channel
with open('bitdepth.ppm', 'w+') as f:
  f.write('P3')
  values = (2**bits)**.5
  f.write(f'\n{values//1} {values//1}')
  f.write(f'\n{values_per_channel-1}')
  for G in range(values_per_channel):
    for R in range(values_per_channel):
      for B in range(values_per_channel):
        for alpha in range(values_per_channel):
          f.write(f'\n{R} {G} {B}')

# horrible shading for non-mixtures
# GIMP shows green as ridicilously bright