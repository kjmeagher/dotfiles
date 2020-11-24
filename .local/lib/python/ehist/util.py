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

block_chars = u' ▏▎▍▌▋▊▉█'
line_char = u'━'
arrow_char = u'→'
pm_char = '±'

vertical_blocks= u' ▁▂▃▄▅▆▇█'
vertical_line  = u'┃'

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
            a = np.log10(max(np.abs(col)))>5
            b = min(np.abs(col))!=0
            c = np.log10(min(np.abs(col[col!=0]))) < -2
            if a or (b and c):
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


class VerticalPlot:
    def __init__(self,width=80,height=25):
        #self.cols=[]
        #self.rows=None
        self.width=width
        self.height=height

    def get_plot(self,y,min_y,max_y):

        rep = max(1,self.width//len(y))
        bars=[]
        for yy in y:
            bars+=rep*[make_bar(yy,min_y,max_y,self.height,vertical_blocks)[::-1]]
        h=vertical_line
        e=vertical_line+'\n'
        out = ''.join(''.join(a)+'\n' for a in zip(*bars))
        return out




