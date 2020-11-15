import numpy as np
_lower_block = '▄'
_reset_color = "\u001b[0m"
_jet = [ 21,  27,  33,  39,  45,  51,  50,  49,  48,  47,  46,
         82, 118, 154, 190, 226, 220, 214, 208, 202, 196]
_viridis = [ 53, 54, 55, 61, 67, 74, 80, 79, 78, 77, 113, 149, 185,226]

def setfg(fg):
    return "\u001b[38;5;" + str(fg) + "m"

def setbg(bg):
    return "\u001b[48;5;" + str(bg) + "m"

def ansi_cmap(x,y,z,invalid_color=None,cmap=None):
    assert x.size == z.shape[1] or x.size==z.shape[1]+1
    assert y.size == z.shape[0] or y.size==z.shape[0]+1

    if cmap is None:
        cmap = _viridis.copy()
    else:
        cmap = cmap.copy()

    zmin = z[z>0].min()
    ci = (z - zmin)/(z.max()-zmin)*(len(cmap))
    ci = ci.astype(int)
    ci = np.clip(ci,0,len(cmap)-1)
    ci[z==0] =len(cmap)
    cmap+=[15]

    x0l='{:0.3g}'.format(x[0])
    x1l='{:0.3g}'.format(x[-1])
    y0l='{:0.3g}'.format(y[0])
    y1l='{:0.3g}'.format(y[-1])
    margin = max(len(y0l),len(y1l))
    s=''
    for yi in range(0,z.shape[0],2)[::-1]:
        if yi==0:
            s+='{:>{}}'.format(y0l,margin)
        elif yi>=z.shape[0]-2:
            s+='{:>{}}'.format(y1l,margin)
        else:
            s+=margin*' '
        if yi+1>=z.shape[0]:
            for xi in range(z.shape[1]):
                s+= setfg(cmap[ci[yi,xi]]) + _lower_block
        else:
            for xi in range(z.shape[1]):
                s+= setfg(cmap[ci[yi,xi]]) +setbg(cmap[ci[yi+1,xi]])+_lower_block
        s+=_reset_color+'\n'

    s+=margin*' '+x0l+(z.shape[1]-len(x0l)-len(x1l))*' '+x1l
    return s


if __name__=='__main__':
    x= np.linspace(0, 4,60)
    y= np.linspace(0,10,50)


    xx,yy=np.meshgrid(x,y)
    z=30*xx*np.exp(-xx)-yy
    print(ansi_cmap(x,y,z))

    import pylab as plt
    plt.pcolormesh(xx,yy,z,shading='auto',cmap=None)
    plt.colorbar()
    plt.show()





