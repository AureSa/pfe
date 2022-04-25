import numpy as np
import matplotlib.pyplot as plt

Ne = 800    # nombre de neurones exitateur 
Ni = 200     # nombre de neurones inibiteur


re = np.random.rand(Ne, 1)
ri = np.random.rand(Ni, 1)

ae = 0.02 * np.ones((Ne, 1))
ai = 0.02 + 0.08 * ri
a = np.concatenate((ae, ai), axis = 0)

be = 0.2 * np.ones((Ne, 1))
bi = 0.25 - 0.05 * ri
b = np.concatenate((be, bi), axis = 0)

ce = -65 + 15 * (re ** 2)
ci = -65*np.ones((Ni, 1))
c = np.concatenate((ce, ci), axis = 0)

de = 8-6*(re**2)
di = 2*np.ones((Ni, 1))
d = np.concatenate((de, di), axis = 0)

se = 0.5*np.random.rand(Ne+Ni, Ne)
si = -np.random.rand(Ne+Ni, Ni)
s = np.concatenate((se, si), axis=1)

v = -65*np.ones((Ne+Ni, 1))
u = b*v

v1 = []
u1 = []
i1 = []

time = []
firings = []
firingsp = []

for t in range(1, 100):

    Ie = 5*np.random.randn(Ne, 1)
    Ii = 2*np.random.randn(Ni, 1)
    I = np.concatenate((Ie, Ii), axis = 0)

    fired = np.nonzero(v>=30)[0]
    for f in fired:
        time.append(t)
        firings.append(f)

    v[fired] = c[fired]
    u[fired] = u[fired]+d[fired]

    I = (np.sum(s[:, fired], axis=1) + I[:, 0]).reshape((Ne+Ni, 1))

    
    v = v+0.5*(0.04*v**2+5*v+140-u+I)
    v = v+0.5*(0.04*v**2+5*v+140-u+I)
    u = u+a*(b*v-u)

    v1.append(v[0])
    u1.append(u[0])
    i1.append(I[0])


plt.plot(range(1, 100), v1)
plt.plot(range(1, 100), u1)
plt.plot(range(1, 100), i1)
plt.show()
