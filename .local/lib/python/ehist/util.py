import numpy as np

def handle_weights(w,weights):
  #Handle the weights
  if w is not None and weights is not None:
    raise ValueError("you cannont set `w` and `weights` at the same time")
  if weights is None:
    weights = w
  if weights is None:
    weighted = False
    weights = 1
    scaled = False
  elif np.isscalar(weights):
    weighted=False
    scaled = True
  else:
    weighted = True
    scaled = False
    weights = np.array(weights,dtype=float)
  return weights,weighted,scaled

def get_name(obj):
    if hasattr(obj,'name'):
        return obj.name
    else:
        return str(obj)

def auto_int_bins(data, bins=None, range=None):
    if bins is None:
        bins=64

    if range is None:
        range = [ int(min(data)),
                  int(max(data))+1]

    if np.isscalar(bins):
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
        bins=b1

    assert all(issubclass(type(b),np.integer) for b in bins)
    return bins

def auto_axis(data):
  if hasattr(data,'dtype'):
    if np.issubdtype(data.dtype.type,np.integer):
      htype=int
    elif issubclass(data.dtype.type,np.floating):      
      htype=float
    else:
      htype = object
  else:
    if all(np.issubdtype(type(d),np.integer) for d in data):
      htype=int
    elif all(np.issubdtype(type(d),np.floating) for d in data):
      htype=float
    else:
      htype=object
  return htype

block_chars = u' ▏▎▍▌▋▊▉█'
line_char = u'━'
arrow_char = u'→'
pm_char = '±'

def make_bar(y,min_y,max_y,width,blocks):
  if (max_y<=min_y):
    raise ValueError()
  if len(blocks)<2:
    raise ValueError()
  empty_block=blocks[0]    
  frac_blocks=blocks[1:-1]
  full_block=blocks[-1]
  
  if y<=min_y:
    bar=width*empty_block
  elif y>=max_y:
    bar=width*full_block
  else:        
    mul=len(frac_blocks)+1
    xx= round(float(y-min_y)*width*mul/(max_y-min_y))
    mod = int(xx%mul)
    bar = int(xx/mul)*full_block        
    if mod and frac_blocks:
      bar+=frac_blocks[mod-1]
    bar+=(width-len(bar))*empty_block
  assert len(bar)==width            
  return bar

class HorizontalPlot:
    def __init__(self,width=80):
        self.cols=[]
        self.rows=None
        self.width=width

    def add_column(self,col,align="<",t=str,prefix='',postfix=''):
        if self.rows is None:
            self.rows = len(col)
        else:
            assert(self.rows==len(col))

        if t in [float]:
            if np.log10(max(col)) > 5 or np.log10(min(col)) < -2:
                fmt = "{:7.2e}"
            else:
                fmt = "{:0.2f}"
            c = ([fmt.format(r) for r in col])
            align = '>'           
        elif t in [int]:
            align = '>'
            c = [ str(r) for r in col ]     
        else:
            c = [ str(r) for r in col ]                            

        m = max(len(r) for r in c)
        self.cols.append((c,m,align,prefix,postfix))
        
    def get_plot(self,y,min_y,max_y):

        assert (self.rows==len(y))
        bar_width = self.width - sum(m+len(pre)+len(post)+1 for _,m,_,pre,post in self.cols)
        line = self.width*line_char
        
        out = line+'\n'

        for i in range(self.rows):
            out += ' '.join("{}{:{}{}}{}".format(pre,c[i],a,m,post) for c,m,a,pre,post in self.cols)
            out += ' '+make_bar(y[i],min_y,max_y,bar_width,block_chars)
            out +='\n'
        out += line+'\n'            
        return out

