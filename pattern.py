from random import random
from itertools import combinations
import numpy
from numpy.linalg import norm
from math import prod
from scipy.optimize import least_squares, differential_evolution, dual_annealing
from matplotlib import pyplot as plt

def triplet_error(xy1, xy2, xy3):
  v1 = numpy.array(xy1)
  v2 = numpy.array(xy2)
  v3 = numpy.array(xy3)
  v12 = v2 - v1
  v13 = v3 - v1
  v23 = v2 - v1
  if (norm(v12) == 0 or norm(v13) == 0 or norm(v23) == 0):
    return numpy.inf
  #v1p = v1 + ((numpy.dot(v13, v12) / norm(v12)**2) * v12)
  #vp3 = v1p - v3
  #if norm(vp3) == 0: return 0
  return 1 / min(norm(v12), norm(v13), norm(v23))

def combination_error(X):
  return max(
      max(triplet_error(c[0], c[1], c[2]), triplet_error(c[0], c[2], c[1]), triplet_error(c[1], c[2], c[0]))
      for c in combinations(X, 3))

def position_error(X):
  def f(xy1, xy2):
    v1 = numpy.array(xy1)
    v2 = numpy.array(xy2)
    v12 = v2 - v1
    return norm(v12)
  
  x = min(f(c[0], c[1]) for c in combinations(X, 2))
  return 1 / x if x != 0 else numpy.inf

def center_error(X):
  return max(((x[0] - 0.5)**2 + (x[1] - 0.5)**2)**.5 for x in X)

def cos_error(X):
  m = 0.0
  for c in combinations(X, 2):
    v1 = numpy.array(c[0])
    v2 = numpy.array(c[1])
    v12 = v2 - v1
    for d in combinations(X, 2):
      if not (c[0] == d[0] and c[1] == d[1]):
        v3 = numpy.array(d[0])
        v4 = numpy.array(d[1])
        v34 = v4 - v3
        if norm(v12) == 0 or norm(v34) == 0:
          return 1.0
        curr = numpy.dot(v12, v34) / norm(v12) / norm(v34)
        if curr > m:
          m = curr
  return m

def approximate(N):
  def unpack(Xa):
    return [(Xa[i], Xa[i + 1]) for i in range(0, 2 * N, 2)]
  
  def mul(*args):
    return prod((x + 1e-5) for x in args)
  
  def f(Xa):
    X = unpack(Xa)
    return mul(cos_error(X), position_error(X), center_error(X))
  
  #Xa = least_squares(f, x0=[random() for i in range(2 * N)], bounds=(0, 1), loss='huber')
  #Xa = differential_evolution(f, bounds=[(0, 1) for i in range(2 * N)])
  Xa = dual_annealing(f, x0=[random() for i in range(2 * N)], bounds=[(0, 1) for i in range(2 * N)])
  return unpack(Xa.x)

V = approximate(6)
X = [x[0] for x in V]
Y = [x[1] for x in V]

print(V)
plt.xlim(0, 1)
plt.ylim(0, 1)
plt.scatter(X, Y)
plt.show()

# 1 / 4N
# [(0.009988254656015938, 0.364206857014334), (0.9148537487816373, 0.22336424172686575), (0.08258592283759514, 0.6368711909718934), (0.6360655917586908, 0.0790852269361606), (0.9924534225017041, 0.5012555213316741), (0.16898260739775384, 0.15971888733549378), (0.8369378729589498, 0.7018913099847794), (0.3613661917397155, 0.7813133225544453)]
