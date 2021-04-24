import numpy as np
import math as m
from .bayesian_blocks import bayesian_blocks, freedman_bin_width, scott_bin_width, knuth_bin_width

class IntAxis:
    def bin_spacing(self, points, bins):
        range = [np.min(points),np.max(points)]
        assert np.issubdtype(range[0], np.integer)
        assert np.issubdtype(range[1], np.integer)
        range[1]+=1
        binsize=int(np.ceil((range[1]-range[0])/bins))

        #first try to align the bins 
        l1=binsize*int(range[0]/binsize)
        u1=binsize*int(np.ceil(range[1]/binsize))
        b1=np.arange(l1,u1+1,binsize)

        #if that crates too many bins start at the first bin instead
        if len(b1)>bins+1:    
            l2=int(range[0])
            u2=l2+bins*binsize
            b1=np.arange(l2,u2+1,binsize)

        assert(len(b1)<=bins+1)
        assert all(issubclass(type(b),np.integer) for b in b1)
        b1[0]=range[0]
        b1[-1]=range[1]
        self.bins = b1

    def finish(self):
        assert np.issubdtype(self.bins.dtype.type,np.integer)
        self.widths = self.bins[1:]-self.bins[:-1]
        if np.all(self.widths==1):
            self.pcenters = self.bins[:-1]
            self.pedges = self.bins - 0.5
            self.edges = self.bins - 0.5
        else:
            self.pcenters = (self.bins[1:]+self.bins[:-1])/2
            self.pedges = self.bins
            self.edges = self.bins

    def pylab_axis(self,ax):
        from matplotlib.ticker import FixedLocator

        if np.all(self.widths==1):
            ax.xaxis.set_tick_params(which='major',length=0)
            x = self.pcenters
        else:
            x = self.bins

        ax.xaxis.set_minor_locator(FixedLocator(self.pedges))
        if self.pedges.size > 10:
            xi = list(range(0,int(0.9*len(x)),max(1,len(x)//5)))+[len(x)-1]
        else:
            xi = range(len(x))
        ax.xaxis.set_major_locator(FixedLocator(x[xi]))

    def uniform(self):
        return np.arange(self.bins[0],self.bins[-1])


class LogIntAxis:
    def bin_spacing(self,points,bins):
        range = [np.min(points),np.max(points)]
        assert np.issubdtype(range[0], np.integer)
        assert np.issubdtype(range[1], np.integer)
        range[1]+=1
        b0,counts = np.unique( (np.geomspace(range[0],range[1],bins)+.5).astype(int),return_counts=True)
        repeated_bins = np.argwhere(counts>=2)
        if repeated_bins.size:
            last_repeater = b0[np.argwhere(counts>=2)[-1][0]]
            first_half = np.arange(range[0],last_repeater)
            second_half = np.geomspace(last_repeater,range[1],bins-len(first_half))+0.5
            second_half = second_half.astype(int)
            second_half = np.unique(second_half)
            b1 = np.r_[first_half,second_half]
        else:
            b1 = b2
        assert(len(b1)<=bins+1)
        assert all(issubclass(type(b),np.integer) for b in b1)
        assert b1[0]==range[0]
        assert b1[-1]==range[1]
        self.bins = b1

    def finish(self):
        assert np.issubdtype(self.bins.dtype.type,np.integer)
        self.widths = self.bins[1:]-self.bins[:-1]
        self.pcenters = np.sqrt(self.bins[1:]*self.bins[:-1])
        self.pedges = self.bins
        self.edges = self.bins-0.5
    def pylab_axis(self,ax):
        ax.set_xscale('log')

    def uniform(self):
        return np.arange(self.bins[0],self.bins[-1])

class LinearAxis:
    def bin_spacing(self,points,bins):
        range = [np.min(points),np.max(points)]
        self.bins = np.linspace(range[0],range[1],bins+1)

    def finish(self):
        self.edges = self.bins
        self.widths = self.edges[1:]-self.edges[:-1]
        self.pcenters = (self.edges[1:]+self.edges[:-1])/2
        self.pedges = self.edges
    def pylab_axis(self,ax):
        pass
    def uniform(self):
        if len(self.bins)>=100:
            return self.bins
        else:
            return np.linspace(self.bins[0],self.bins[-1],100)

class LogAxis:
    def bin_spacing(self,points,bins):
        range = [np.min(points[points>0]),np.max(points)]
        self.bins = np.geomspace(range[0],range[1],bins+1)

    def finish(self):
        self.edges = self.bins
        self.widths = self.edges[1:]-self.edges[:-1]
        self.pcenters = np.sqrt(self.edges[1:]*self.edges[:-1])
        self.pedges=self.edges

    def pylab_axis(self,ax):
        ax.set_xscale('log')

    def uniform(self):
        if len(self.bins)>=100:
            return self.bins
        else:
            return np.geomspace(self.bins[0],self.bins[-1],100)

class ZenithAxis:
    def bin_spacing(self,points,bins):
        range = [np.min(points),np.max(points)]
        #coerse the values to common edges
        if range[0] < .1:
            range[0]= 0
        if range[1] >= np.pi/2-0.1 and range[1] <=np.pi/2:
            range[1] = np.pi/2
        if range[1] >= np.pi-0.1 and range[1] <=np.pi:
            range[1] = np.pi

        self.range=range
        self.cosbins = np.linspace(np.cos(self.range[0]),np.cos(self.range[1]),bins+1)
        self.bins = np.arccos(self.cosbins)

    def finish(self):
        self.edges = self.bins
        self.widths = self.cosbins[:-1]-self.cosbins[1:]
        self.pcenters = (self.cosbins[1:]+self.cosbins[:-1])/2
        self.pedges = self.cosbins

    def pylab_axis(self,ax):
        from matplotlib.ticker import FixedLocator

        span = self.range[1]-self.range[0]
        if span > np.deg2rad(span):
            major = np.array([0,45,60,75,90,105,120,135,180])
        else:
            major = np.array([0,30,45,60,75,90,105,120,135,150,180])
        rmajor =  np.deg2rad(major)
        cut=(rmajor >= self.range[0]*.99)&( rmajor<=self.range[1]*1.0001)
        minor = range(0,181,5)
        ax.xaxis.set_ticks(np.cos(rmajor[cut]))
        ax.xaxis.set_ticklabels(str(m)+'°' for m in major[cut])
        ax.xaxis.set_minor_locator(FixedLocator(np.cos(np.deg2rad(minor))))

    def uniform(self):
        if len(self.bins)>=100:
            return self.bins
        else:
            return np.cos(np.linspace(self.bins[0],self.bins[-1],100))

def AutoAxis(points,bins,range,t):
    if t is None:
        if np.issubdtype(points.dtype.type,np.integer):
            t=int
        elif issubclass(points.dtype.type,np.floating):      
            t=float
        else:
            raise ValueError("don't know what to do with points dtype={}".format(points.dtype))

    if t in [int,'int']:
        ax = IntAxis()
    elif t in ['logint']:
        ax = LogIntAxis()
    elif t in [np.log,np.log10,m.log,m.log10,'log']:
        ax = LogAxis()
    elif t in [np.cos,m.cos,'cos']:
        ax = ZenithAxis()
    elif t in [float,None]:
        ax = LinearAxis()
    else:
        raise ValueError

    if isinstance(bins, str):
        if bins == 'blocks':
            bins = bayesian_blocks(points)
        elif bins == 'knuth':
            da, bins = knuth_bin_width(points, True)
        elif bins == 'scott':
            da, bins = scott_bin_width(points, True)
        elif bins == 'freedman':
            da, bins = freedman_bin_width(points, True)
        else:
            raise ValueError(f"unrecognized bin code: '{bins}'")
    elif bins is None:
        bins = 64

    if np.isscalar(bins):
        ax.bin_spacing(points,bins)
    else:
        ax.bins = bins

    ax.finish()
    return ax


