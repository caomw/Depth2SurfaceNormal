addpath(genpath('../toolbox/'));
addpath(genpath('../toolbox2/'));
addpath('../utils/');
addpath('../normalCompress/');
addpath('../depthCompress/');
addpath('Inpaint_nans/');
normalDict = load('../normalCompress/vq_dict.mat');
depthDict = load('../depthCompress/vq_dict.mat');

% The directory where you extracted the raw dataset.
dataDir = '/home/rgirdhar/Work/Data/008_Hollywood3D/large_unbalanced/frames/train/';
targetDir = '/home/rgirdhar/Work/Data/008_Hollywood3D/large_unbalanced/normals/train/';
fpath = '/home/rgirdhar/Work/Data/008_Hollywood3D/large_unbalanced/lists/train.txt';

f = fopen(fpath);
lst = textscan(f, '%s');
fclose(f);
lst = lst{1};

Consts;
Params;
[projectionMask, projectionSize] = get_projection_mask();
[yv,xv] = find(projectionMask);
maskYMin = min(yv); maskYMax = max(yv);
maskXMin = min(xv); maskXMax = max(xv);

for id = lst(:)'
  for fnum = 1 : 20
    dname = fullfile(dataDir, sprintf('%s_depth/image-%03d.png', id{:}, fnum));
    if ~exist(dname, 'file')
      break;
    end
    outfpath = fullfile(targetDir, [id{:} '_depth/'], [num2str(fnum) '_norm.png']);
    % mkdir the parent dirs
    [outd, ~, ~] = fileparts(outfpath);
    unix(['mkdir -p ' outd]);

    if ~lock(outfpath)
      continue;
    end

    try
      dep = double(rgb2gray(imread(dname)));
    catch
      unlock(outfpath);
      continue;
    end
    %dep(dep < 0) = min(dep(:));
    dep(dep < 0) = NaN;
    %imgDepthProj = max(dep(:)) - dep;
    %dep = inpaint_nans(double(dep));
    imgDepthProj = dep;
    imgDepthProj = imresize(imgDepthProj, [size(projectionMask, 1), size(projectionMask, 2)]);
    imgDepthProj = imgDepthProj * 5000 / max(imgDepthProj(:));

    points3d = rgb_plane2rgb_world(imgDepthProj);
    points3d = points3d(projectionMask,:);

    X = points3d(:,1);
    Y = points3d(:,3);
    Z = points3d(:,2);

    tt = tic;
    [imgPlanes, imgNormals, normalConf,NCompute] = compute_local_planes(X, Z, Y, params);
    fprintf('Computing normals took %fs\n',toc(tt));

    NMask = sum(NCompute.^2,3).^0.5 > 0.5;
    N = NCompute;

    imwrite(N, outfpath);
%    save(outfpath,'N','NMask','-v7.3');

    unlock(outfpath);
  end
end 

