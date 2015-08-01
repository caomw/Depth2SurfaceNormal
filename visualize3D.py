from mpl_toolkits.mplot3d import Axes3D
from matplotlib import cm
import matplotlib as mpl
mpl.use('Agg')
from matplotlib.ticker import LinearLocator, FormatStrFormatter
import matplotlib.pyplot as plt
import numpy as np
import scipy.misc
import os

normalsdir = '/home/rgirdhar/Work/Data/008_Hollywood3D/large_unbalanced/frames/train/'
imgslist_fpath = '/home/rgirdhar/Work/Data/008_Hollywood3D/large_unbalanced/lists/train.txt'
outdir = '/home/rgirdhar/Work/Data/008_Hollywood3D/large_unbalanced/normals/train_vis/'

def main():
  with open(imgslist_fpath) as f:
    imgslist = f.read().splitlines()

  fig = plt.figure()
  for im in imgslist:
    for fnum in range(1, 20):
      fig.clear()

      try:
        Z = scipy.misc.imread(os.path.join(normalsdir, im + '_depth', 'image-%03d.png' % fnum), flatten=True)
      except IOError:
        # this image doesn't exist, continue
        continue

      outfpath = os.path.join(outdir, im + '_depth/', str(fnum) + '_vis.png')
      if not lock(outfpath):
        continue

      Z = scipy.misc.imresize(Z, 0.3)

      ax = fig.gca(projection='3d')
      X = np.arange(0, np.shape(Z)[1], 1)
      Y = np.arange(0, np.shape(Z)[0], 1)
      X, Y = np.meshgrid(X, Y)
      surf = ax.plot_surface(X, Y, Z, rstride=1, cstride=1, cmap=cm.jet,
              linewidth=0, antialiased=False)

      ax.zaxis.set_major_locator(LinearLocator(10))
      ax.zaxis.set_major_formatter(FormatStrFormatter('%.02f'))

      fig.colorbar(surf, shrink=0.5, aspect=5)
      
      try:
        os.makedirs(os.path.dirname(outfpath))
      except:
        pass
      plt.savefig(outfpath, bbox_inches='tight')
      unlock(outfpath)

def lock(fpath):
  lock_fpath = fpath + '.lock'
  if os.path.exists(fpath):
    return False
  try:
    os.makedirs(lock_fpath) # will error if exists
    return True
  except:
    return False

def unlock(fpath):
  lock_fpath = fpath + '.lock'
  try:
    os.rmdir(lock_fpath)
    return True
  except:
    print 'Unable to remove', lock_fpath
    return False

if __name__ == '__main__':
  main()
