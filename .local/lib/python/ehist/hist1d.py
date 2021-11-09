import numpy as np
from scipy import optimize
from scipy.stats import poisson
from six import string_types

from .util import handle_weights,HorizontalPlot,VerticalPlot
from .axis import AutoAxis,IntAxis,LogIntAxis
import warnings

_logx_warning = False

class Hist1D:
  def __init__(self, points, bins=None, range=None, norm=None, logx=False, t=None,
               w=None, weights=None, label=None, color=None):

    weights,self.weighted,self.scaled = handle_weights(w,weights)

    if self.weighted and isinstance(bins, str):
        raise ValueError("Weights are not supported for dynamic binning: {}".format(bins))

    #remove any NANs and infs
    points = np.array(points)
    nan_cut = np.isfinite(points)
    points = points[nan_cut]
    self.entries = len(points)

    if self.weighted:
      weights = weights[nan_cut]
      assert len(weights) == len(points)

    if logx:
        global _logx_warning
        if not _logx_warning:
            warnings.warn("Hist1D param logx depricated")
            _logx_warning = True 
        t=np.log
    self.x = AutoAxis(points,bins,range,t)

    self.N,x = np.histogram(points,
                            bins=self.x.edges,
                            range=range)
    assert np.all(x==self.x.edges)

    if self.weighted:
      self.H,x = np.histogram(points,
                              weights=weights,
                              bins=self.x.edges,
                              range=range)
      assert all(x==self.x.edges)
      self.Hsq,x = np.histogram(points,
                                weights=weights**2,
                                bins=self.x.edges,
                                range=range)
      assert all(x==self.x.edges)
    else:
      self.H=self.N*weights
            
    assert self.N.dtype==np.int64

    self.A = self.H.astype(float)/self.x.widths
    if self.weighted:
      self.Herr = self.Hsq**0.5        
      self.Aerr = self.Herr/self.x.widths
    else:
      self.Herr=np.array([ self.H[i]/self.N[i]**0.5 if self.N[i]>0 else 0
                           for i in np.arange(len(self.H))])
      self.Aerr=self.Herr/self.x.widths

    if norm:
      norm = float(self.A.sum())
      self.A/=norm
      self.Aerr/=norm

    self.label = label
    self.color = color

  def _get_hist(self,show):
    if show.lower()=="area":
      y=self.A.copy()
      yerr= self.Aerr.copy()            
    elif show.lower()=="height":
      y=self.H.copy()
      yerr=self.Herr.copy()
    elif show.lower() in ["events",'n']:
      y=self.N.copy()
      yerr=np.ones_like(self.N)
    else:
      raise ValueError("Unrecognized value for `show`: '{}'".format(show))
    return y,yerr

  def plot(self,  s='steps',scale = 1,logy=None,ymin=None,show='Area',fmt=None,ax=None,**kwargs):
        import pylab as plt
        from matplotlib import colors

        if ax is None:
          ax = plt.gca()

        y,yerr= self._get_hist(show)
        y = scale*y
        yerr = scale*yerr

        for ss in s.split(','):
            args = { "color" :self.color,
                     "label": self.label}
            args.update(kwargs)
            if ss == 'err':
                cut=y>0
                y1=y[cut]
                yerr1=yerr[cut]
                x1=self.x.pcenters[cut]
                yerr1= yerr1.copy()
                yerr2= yerr1.copy()
            
                if not ymin:
                    if logy:
                        y0=y1-yerr1                    
                        ymin = y0[y0>0].min()
                    else:
                        ymin = 0

                upperlim = y1 - yerr1 <= ymin
                y1[upperlim] = y1[upperlim]+ yerr2[upperlim]
                yerr1[upperlim] = y1[upperlim]-ymin

                p = ax.errorbar(x1,y1,
                                 yerr=[yerr1,yerr2],
                                 ls='none',uplims = upperlim,
                                 **args)

            elif ss=='marker':
                p=ax.plot(self.x.pcenters,y,marker='o',ls='none',**args)
            elif ss.lower().startswith('text'):
                number_type=ss[4:].strip()
                if number_type:            
                    text,_ = self._get_hist(number_type)
                else:
                    text,_=y,yerr
                assert len(text)==len(self.x.pcenters)
                for i in range(len(self.x.pcenters)):
                    if callable(fmt):
                        t=fmt(text[i])
                    elif fmt:
                        t="{:{}}".format(text[i],fmt)
                    else:
                        t=str(text[i])                
                    ax.text(self.x.pcenters[i],y[i],t,**kwargs)
                p=None

            elif ss=='steps':
                args['ds']='steps-pre'
                p = ax.plot(np.r_[self.x.pedges,self.x.pedges[-1]],np.r_[0,y,0],**args)
            else:
                raise Exception("unknown plot type {!r}".format(s))

            if self.color is None and p:
                self.color = p[0].get_color()
        
        self.x.pylab_axis(ax)
        if logy:
            ax.set_yscale('log')
        return self

  def _get_yaxis_text(self,logy):
        if logy:
            mask = self.A > 0
            y=np.zeros_like(self.A)
            y[mask] = np.log(self.A[mask])
            min_y=y[mask].min()
            min_y -= (y.max()-min_y)*.02
            y[np.logical_not(mask)] = min_y
        else:
            y=self.A
            min_y=0
        max_y=max(y)
        yrange=[min_y,max_y]
        return y,min_y,max_y

  def vtext(self,show_area=False,show_count=True,logy=False,width=80):
        y,min_y,max_y = self._get_yaxis_text(logy=logy)
        p = VerticalPlot(width=width)
        return p.get_plot(y,min_y,max_y)

  def htext(self,show_area=False,show_count=True,logy=False,width=80):
        y,min_y,max_y = self._get_yaxis_text(logy=logy)
        lowedges=self.x.bins.copy()[:-1]
        highedges=self.x.bins.copy()[1:]
        if type(self.x) in [ LogIntAxis, IntAxis ]:
            highedges-=1
            t=int
        else:
            t=float
        p = HorizontalPlot(width=width)
        if np.all(highedges==lowedges):
            p.add_column(lowedges,t=t)
            p.add_column(len(lowedges)*[':'])
        else:
            p.add_column(lowedges,t=t,prefix='[')
            p.add_column(highedges,t=t,postfix=']')
        if show_area:
            p.add_column(self.A,t=float)
        if show_area and show_count:
            p.add_column(len(y)*['|'])
        if show_count:
            p.add_column(self.N,t=int)

        return p.get_plot(y,min_y,max_y)

  def interp(self,method='box',**kwargs):
        if method =='box':
            #x should be two of each edge except for the first and last edge
            #x = [ x[0], x[1], x[1], x[2],x[2], ... ,x[-2],x[-2],x[-1] ]
            x = np.ravel(np.matrix([self.x.edges[0:-1],self.x.edges[1:]]).T)
            # y should be each y twice
            y = np.ravel(np.matrix([self.y,self.y]).T)

            return interpolate.interp1d(x,y)

        elif method == 'tri':

            x = np.r_[self.xedges[0],self.x.centers,self.xedges[-1]]
            y = np.r_[0, self.y, 0 ]
            return interpolate.interp1d(x,y)

        elif method == 'poly':

            order = kwargs.get("order",3)
            return np.poly1d(np.polyfit(self.x.centers,self.y,order))

        elif method == 'spline':
            mask = self.yerr>0
            return interpolate.UnivariateSpline(self.x.centers[mask],
                                                self.y[mask],
                                                1/self.yerr[mask],
                                                bbox=[self.xedges[0],self.xedges[-1]],
                                                **kwargs
                                                )
        else:
            raise Exception("Unknown interpolation method {}".format(method))


  def fit(self,func,mask=None,plot=False,**kwargs):
      y,yerr = self._get_hist('area')
      if mask is None:
          mask = y>0
            
      fit = optimize.curve_fit(func,                                   
                               self.x.pcenters[mask],
                               y[mask],
                               sigma=yerr[mask],
                               **kwargs)
      if plot:
        import pylab as plt
        if type(self.x).__name__[:3]=='Log':
            x = np.geomspace(self.x.pedges[0],self.x.pedges[-1],100)
        else:
            x = np.linspace(self.x.pedges[0],self.x.pedges[-1],100)
        plt.plot(x,func(x,*fit[0]),color=self.color)
      return fit

  def fitfunc(self,func,**kwargs):
        params = self.fit(func,**kwargs)

        keywords = dict(zip(inspect.getargspec(func).args[1:],params[0]))
        return params,functools.partial(func,**keywords)

  @staticmethod
  def _poisson_score(p,xedges,y,indef):    
        rate = indef(xedges[1:],p)-indef(xedges[:-1],p)
        return -poisson.logpmf(y,rate).sum()

  def integral_fit(self,iteg,p0,**kwargs):

        if self.weighted:
            raise Exception("integral fit Cannont be performed on Weighted Histogram")


        y,yerr = self._get_hist('area')
        self.fit_integral=iteg
        self.fit_function=None
        self.fit_result = optimize.minimize(self._poisson_score,
                                            p0,
                                            args=(self.x.bins,y,iteg),
                                            **kwargs)
        
        return self.fit_result

  @staticmethod
  def _integrate(p,xedges,y,func):
        rate = np.zeros(len(y),dtype=float)
        for i in range(len(y)):
            rate[i],_ = integrate.quad(func,xedges[i],xedges[i+1],args=(p,))
        return -poisson.logpmf(y,rate).sum()

  def function_fit(self,func,p0,**kwargs):

        if self.weighted:
            raise Exception("integral fit Cannont be performed on Weighted Histogram")

        self.fit_integral=None
        self.fit_function=func
        self.fit_result = optimize.minimize(self._integrate,
                                            p0,
                                            args=(self.xedges,self.y,func),
                                            **kwargs)
        
        return self.fit_result
        
  def brazil_plot(self, ax=None,logy=False,ymin=0.1,residule=False,
                  alpha=(1,2),colors=('#00CC00','#DDDD00')):
        if ax is None:
            ax = plt.gca()
    
        r = self.fit_integral(self.xedges[1:],self.fit_result.x) \
            - self.fit_integral(self.xedges[:-1],self.fit_result.x)

        for i in range(len(alpha))[::-1]:
            ll = poisson.ppf(norm.cdf(-alpha[i]),r)
            ul = poisson.ppf(norm.cdf(+alpha[i]),r)

            if residule:
                ll=(ll-r)/r**0.5
                ul=(ul-r)/r**0.5
            if logy:
                ll[ll==0]=ymin
                ul[ul==0]=ymin
            ax.fill_between(self.xedges[:-1],ll,ul,step='post',
                            color=colors[i],
                            label=r'${}\sigma$'.format(alpha[i]))
        if residule:
            y = (self.y-r)/r**0.5
        else:
            y = self.y
            
        ax.scatter(self.xcenter,y,c='k',label='Counts')
        if logy:
            ax.axis(ymin=ymin)
            ax.semilogy()
    
  def __str__(self):
      return "<{} {} bins={} range=[{:0.2f},{:0.2f}] entries={}>".format(
            self.__class__.__name__,self.x.__class__.__name__,len(self.x.pcenters),
            self.x.edges[0],self.x.edges[-1],self.entries)

