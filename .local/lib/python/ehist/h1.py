import numpy as np
from six import string_types
from .util import auto_axis,handle_weights,HorizontalPlot,auto_int_bins

class h1:
  def __init__(self, points, bins=None, range=None, norm=None, logx=False,
               w=None, weights=None, label=None, color=None, htype=None):
    self.logx=logx
    if logx:
      points = np.log10(points)
      if range is not None:
        range=np.log10(range)

    if htype==None:
      self.htype=auto_axis(points)
    elif htype in [int,float]:
      self.htype=htype
    else:
      raise ValueError("Invalid htype: {}".format(htype))

    weights,self.weighted,self.scaled = handle_weights(w,weights)

    #remove any NANs and infs
    points = np.array(points)
    nan_cut = np.isfinite(points)
    points = points[nan_cut]
    self.entries = len(points)

    if self.weighted:
      weights = weights[nan_cut]
      assert len(weights) == len(points)            
                
    if isinstance(bins,string_types):
      if bins == 'blocks':
        bins = bayesian_blocks(points)
      #elif bins == 'knuth'::
      #    pass
      #elif bins == 'scott':
      #    pass
      #elif bins == 'freedman':
      #    pass            
      elif bins=='int':
        self.htype=int
      else:
        raise ValueError('Unknown value for `bins`: "{}"'.format(bins))
    elif bins is None:
      bins = 64

    if self.htype==int:
      bins = auto_int_bins(points, bins, range)
              
    self.N,self.xedges = np.histogram(points,
                                      bins=bins,
                                      range=range)

    if self.weighted:
      self.H,x  = np.histogram(points,
                               weights=weights,
                               bins=bins,range=range)
      assert all(x==self.xedges)
      self.Hsq,x = np.histogram(points,
                                weights=weights**2,
                                bins=bins,range=range)
      assert all(x==self.xedges)
    else:
      self.H=self.N*weights
            
    assert self.N.dtype==np.int64

    self.xcenter = (self.xedges[1:]+self.xedges[:-1])/2            
    if self.logx:
      self.xedges = 10**self.xedges
      self.xcenter = 10**self.xcenter

    self.xwidth  = self.xedges[1:]-self.xedges[:-1]

    self.A = self.H.astype(float)/self.xwidth
    if self.weighted:
      self.Herr = self.Hsq**0.5        
      self.Aerr = self.Herr/self.xwidth
    else:
      self.Herr=np.array([ self.H[i]/self.N[i]**0.5 if self.N[i]>0 else 0
                           for i in np.arange(len(self.H))])
      self.Aerr=self.Herr/self.xwidth            

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
    elif show.lower()=="events" or show.lower()=='n':
      y=self.N.copy()
      yerr=np.ones_like(self.N)
    else:
      raise ValueError("Unrecognized value for `show`: '{}'".format(show))
    return y,yerr

  def plot(self,s='steps',scale = 1,logy=None,ymin=None,show='Area',fmt=None,**kwargs):

        import pylab as plt
        from matplotlib import colors

        if self.logx :
            plt.xscale('log')
        if logy:
            plt.yscale('log')

        y,yerr= self._get_hist(show)

        y = scale*y
        yerr = scale*yerr
        
        args = { "color" :self.color,
                 "label": self.label}
        args.update(kwargs)
        
        if s == 'err':
            cut=y>0
            y=y[cut]
            yerr=yerr[cut]
            x=self.xcenter[cut]
            yerr1= yerr.copy()
            yerr2= yerr.copy()
            
            if not ymin:
                if logy:
                    y0=y-yerr                    
                    ymin = y0[y0>0].min()
                else:
                    ymin = 0

            upperlim = y - yerr1 <= ymin
            y[upperlim] = y[upperlim]+ yerr2[upperlim]
            yerr1[upperlim] = y[upperlim]-ymin

            p = plt.errorbar(x,y,
                             yerr=[yerr1,yerr2],
                             ls='none',uplims = upperlim,
                             **args)

        elif s=='marker':
            p=plt.plot(self.xcenter,y,marker='o',ls='none',**args)
            
        elif s.lower().startswith('text'):
            number_type=s[4:].strip()
            if number_type:            
                text,_ = self._get_hist(number_type)
            else:
                text,_=y,yerr
            assert len(text)==len(self.xcenter)
            for i in range(len(self.xcenter)):
                if callable(fmt):
                    t=fmt(text[i])
                elif fmt:
                    t="{:{}}".format(text[i],fmt)
                else:
                    t=str(text[i])                
                plt.text(self.xcenter[i],y[i],t,**kwargs)
            p=None

        elif s=='steps':
          args['ds']='steps-pre'
          p = plt.plot(np.r_[self.xedges,self.xedges[-1]],np.r_[0,y,0],**args)        
        else:
            raise Exception("unknown plot type {!r}".format(s))

        if self.color is None and p:
            self.color = p[0].get_color()
        
        return self


  def plot_text(self,show_area=False,show_count=True,logy=False,width=80):

        if logy:
            y=np.log(self.A)
            min_y=y[np.isfinite(y)].min()
        else:
            y=self.A
            min_y=0
        max_y=max(y)

        yrange=[min_y,max_y]
        
        lowedges=self.xedges[:-1]
        highedges=np.array(self.xedges[1:])
        if self.htype==int:
          highedges-=1

        p = HorizontalPlot(width=width)
        if self.htype == int and all(highedges==lowedges):
            p.add_column(lowedges,t=int)
            p.add_column(len(y)*[':'])
        else:
            p.add_column(lowedges,t=self.htype,prefix='[')
            p.add_column(highedges,t=self.htype,postfix=']')

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
            x = np.ravel(np.matrix([self.xedges[0:-1],self.xedges[1:]]).T)
            # y should be each y twice
            y = np.ravel(np.matrix([self.y,self.y]).T)

            return interpolate.interp1d(x,y)

        elif method == 'tri':

            x = np.r_[self.xedges[0],self.xcenter,self.xedges[-1]]
            y = np.r_[0, self.y, 0 ]
            return interpolate.interp1d(x,y)

        elif method == 'poly':

            order = kwargs.get("order",3)
            return np.poly1d(np.polyfit(self.xcenter,self.y,order))

        elif method == 'spline':
            mask = self.yerr>0
            return interpolate.UnivariateSpline(self.xcenter[mask],
                                                self.y[mask],
                                                1/self.yerr[mask],
                                                bbox=[self.xedges[0],self.xedges[-1]],
                                                **kwargs
                                                )
        else:
            raise Exception("Unknown interpolation method {}".format(method))


  def fit(self,func,mask=None,**kwargs):
        if mask is None:
            #mask = np.ones_like(self.xcenter,dtype=bool)
            mask = self.y>1
            
        return  optimize.curve_fit(func,                                   
                                   self.xcenter[mask],
                                   self.y[mask],
                                   sigma=self.yerr[mask],
                                   **kwargs
        )

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

        self.fit_integral=iteg
        self.fit_function=None
        self.fit_result = optimize.minimize(self._poisson_score,
                                            p0,
                                            args=(self.xedges,self.y,iteg),
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
            self.__class__.__name__,self.htype.__name__,len(self.xcenter),
            self.xedges[0],self.xedges[-1],self.entries)

