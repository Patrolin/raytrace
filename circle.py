from matplotlib import pyplot as plt
from numpy import zeros, float64
from random import random
from math import *

def white():
  return random(), random()

def blue(i, j, i_max, j_max):
  x, y = .5, .5
  #x, y = white()
  return (i+x)/i_max, (j+y)/j_max

def circle(x, y):
  theta = 2*pi * x
  r = y
  #r = y**.5
  return r*cos(theta), r*sin(theta)

i_max = 9
j_max = 1
N = i_max*j_max
X = zeros((N,), float64)
Y = zeros((N,), float64)

for i in range(i_max):
  for j in range(j_max):
    k = i*(j_max) + j
    X[k], Y[k] = circle(*blue(i+0.125, j, i_max, j_max))

print(X)

plt.title(f'')
plt.xlabel('')
plt.ylabel('')
plt.xlim(-1.1, 1.1)
plt.ylim(-1.1, 1.1)

plt.scatter(X, Y)
#plt.plot(X, Y)
plt.show()