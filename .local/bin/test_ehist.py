#!/usr/bin/env python 
import unittest
import numpy as np
from scipy import stats
from ehist import h1

class TestEHist(unittest.TestCase):
    def test_triangle_fit(self):
        N=1000
        x= stats.triang.ppf(np.linspace(0,1,N),1)
        h=h1(x,bins=100)
        fit = h.fit(lambda x,m,b: m*x+b)
        self.assertAlmostEqual(fit[0][0]/N,2,1)
        self.assertAlmostEqual(fit[0][1]/N,0,2)

    def test_power_law(self):
        e = np.geomspace(1e3,1e5,1000)
        h = h1(e,10,t='log')
        f=h.fit(lambda x,a,b: a*x**b)
        self.assertAlmostEqual(f[0][1],-1,2)
        self.assertAlmostEqual(f[0][0],len(e)/np.log(e[-1]/e[0]),-1)

    def test_zenith(self):
        cz=np.arccos(np.linspace(-1,1,1000))
        h=h1(points=cz,bins=20,t=np.cos)
        f = h.fit(lambda x,m,b:m*x+b)
        self.assertAlmostEqual(f[0][0],0,1)
        self.assertAlmostEqual(f[0][1],len(cz)/2)

    def test_int(self):
        X = np.linspace(0,15,159)[1:-1].astype(int)
        h=h1(points=X,bins=17,t=int)
        f=h.fit(lambda x,m,b: m*x+b)
        self.assertAlmostEqual(f[0][1],len(X)/(X[-1]-X[0]),-1)
        self.assertAlmostEqual(f[0][0],0) 

    def test_log_int(self):
        N = 1001
        x = [ int(N/i)*[i] for i in range(1,N)]
        p = [val for sublist in x for val in sublist]
        h = h1(points=p,t='logint',bins=20)
        f=h.fit(lambda x,a,b: a*x**b)
        self.assertAlmostEqual(f[0][1],-1,0)
        self.assertEqual(h.N[0],1001)
        self.assertEqual(h.N[1],500)
        self.assertEqual(h.N[2],333)
        self.assertEqual(h.N[3],250+200)

    def test_freedman(self):
        x=stats.norm.ppf(np.linspace(0,1,1002)[1:-1])
        h = h1(points=x,bins='freedman')
        f = h.fit(lambda x,a,b,s: a/s/np.sqrt(2*np.pi)*np.exp(-1/2*((x-b)/s)**2))
        self.assertAlmostEqual(f[0][0],len(x),-1)
        self.assertAlmostEqual(f[0][1],0,2)
        self.assertAlmostEqual(f[0][2],1,1)

    def test_freedman(self):
        x=stats.norm.ppf(np.linspace(0,1,1002)[1:-1])
        h = h1(points=x,bins='blocks')
        f = h.fit(lambda x,a,b,s: a/s/np.sqrt(2*np.pi)*np.exp(-1/2*((x-b)/s)**2))
        self.assertAlmostEqual(f[0][0],len(x),-3)
        self.assertAlmostEqual(f[0][1],0,2)
        self.assertAlmostEqual(f[0][2],1,0)

if __name__=='__main__':
    unittest.main()





