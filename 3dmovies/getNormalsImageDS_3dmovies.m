addpath(genpath('../toolbox/'));
addpath(genpath('../toolbox2/'));
addpath('../utils/');
addpath('../normalCompress/');
addpath('../depthCompress/');
addpath('Inpaint_nans/');
normalDict = load('../normalCompress/vq_dict.mat');
depthDict = load('../depthCompress/vq_dict.mat');

% The directory where you extracted the raw dataset.
dataDir = '/home/rgirdhar/Work/Projects/005_PoseNContext/3dmovies/temp-data/10_out/';
targetDir = '/home/rgirdhar/Work/Projects/005_PoseNContext/3dmovies/temp-data/10_out_normals/';

Consts;
Params;
[projectionMask, projectionSize] = get_projection_mask();
[yv,xv] = find(projectionMask);
maskYMin = min(yv); maskYMax = max(yv);
maskXMin = min(xv); maskXMax = max(xv);

%for i=200:2000
%for i=1287:1287
for i=[70:100 800:1000]
    name = sprintf('image-%03d_disp.mat', i);
    impath = fullfile(dataDir, name);
    
    outfpath = fullfile(targetDir, [num2str(i) '.mat']);

    if ~lock(outfpath)
        continue;
    end

    dname = fullfile(dataDir, sprintf('image-%03d_disp.mat', i));
    try
      load(dname, 'dep');
    catch
      unlock(outfpath);
      continue;
    end
    %dep(dep < 0) = min(dep(:));
    dep(dep < 0) = NaN;
    %imgDepthProj = max(dep(:)) - dep;
    %dep = inpaint_nans(double(dep));
    imgDepthProj = dep;
    imgDepthProj = imgDepthProj * 5000 / max(imgDepthProj(:));
    imgDepthProj = imresize(imgDepthProj, [size(projectionMask, 1), size(projectionMask, 2)]);

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

    imwrite(N, fullfile(targetDir, [num2str(i) '.jpg']));
    save(outfpath,'N','NMask','-v7.3');

    unlock(outfpath);
end 

