addpath(genpath('toolbox/'));
addpath(genpath('toolbox2/'));
addpath('utils/');
addpath('normalCompress/');
addpath('depthCompress/');
normalDict = load('normalCompress/vq_dict.mat');
depthDict = load('depthCompress/vq_dict.mat');

% The directory where you extracted the raw dataset.
imgslist = '/home/rgirdhar/Work/Data/006_CornellActivity/CAD-60/processed/lists/Images.txt';
dataDir = '/home/rgirdhar/Work/Data/006_CornellActivity/CAD-60/processed/base/';
targetDir = '/home/rgirdhar/Work/Data/006_CornellActivity/CAD-60/processed/normals/';


Consts;
Params;
[projectionMask, projectionSize] = get_projection_mask();
[yv,xv] = find(projectionMask);
maskYMin = min(yv); maskYMax = max(yv);
maskXMin = min(xv); maskXMax = max(xv);

fin = fopen(imgslist);
filesList = textscan(fin, '%s');
filesList = filesList{1};
fclose(fin);

for i=1:numel(filesList)
    name = filesList{i};
    impath = fullfile(dataDir, name);
    
    outfpath = fullfile(targetDir, [num2str(i) '.mat']);

    if ~lock(outfpath)
        continue;
    end

    dname = strrep(impath, 'RGB_', 'Depth_');
    imgDepthProj = double(imread(dname)); % 16bit 1C depth image

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
    save(outfpath,'N','NMask','-v7.3');

    unlock(outfpath);
end 

