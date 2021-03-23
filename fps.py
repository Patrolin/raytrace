from matplotlib import pyplot as plt
from numpy import linspace

monitor_fps = 30
def test(fps):
  x = (monitor_fps/fps) % 1.0
  return (x+0.5) % 1.0 - 0.5

X = [x for x in range(1, 1000)]
Y = [test(x) for x in X]

plt.title(f'{monitor_fps}Hz monitor')
plt.xlabel('fps')
plt.ylabel('VSync drift / frame')
plt.yticks([-0.5, -0.25, 0, 0.25, 0.5])

plt.scatter(X, Y)
plt.plot(X, Y)
plt.show()