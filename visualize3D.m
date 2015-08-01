function visualize3D()
normalsdir = '/home/rgirdhar/Work/Data/008_Hollywood3D/large_unbalanced/frames/train/';
imgslist_fpath = '/home/rgirdhar/Work/Data/008_Hollywood3D/large_unbalanced/lists/train.txt';
outdir = '/home/rgirdhar/Work/Data/008_Hollywood3D/large_unbalanced/normals/train_vis/';

f = fopen(imgslist_fpath);
imgslist = textscan(f, '%s');
imgslist = imgslist{1};
fclose(f);

count = 0;
f = figure('Visible', 'off');
for im = imgslist(:)'
  for fnum = 1 : 20
    count = count + 1;

    thisinpath = fullfile(normalsdir, [im{:} '_depth'], sprintf('image-%03d.png', fnum));
    I = imread(thisinpath);
    mesh(double(I));
    view([-70 44]);
    outfpath = fullfile(outdir, [im{:} '_depth'], [num2str(fnum) '_vis']);
    [thisoutdir, ~, ~] = fileparts(outfpath);
    unix(['mkdir -p ' thisoutdir]);
    %print(outfpath, '-dpng');
    res = zbuffer_cdata(f);
    imwrite(res, [outfpath '.png']);
  end
end
close(f);

function cdata = zbuffer_cdata(hfig)
% Get CDATA from hardcopy using zbuffer
% Need to have PaperPositionMode be auto 
orig_mode = get(hfig, 'PaperPositionMode');
set(hfig, 'PaperPositionMode', 'auto');
cdata = hardcopy(hfig, '-Dzbuffer', '-r0');
% Restore figure to original state
set(hfig, 'PaperPositionMode', orig_mode); % end

