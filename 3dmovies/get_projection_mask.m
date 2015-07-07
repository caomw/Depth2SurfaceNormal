% Gets a mask for the projected images that is most conservative with
% respect to the regions that maintain the kinect depth signal following
% projection.
%
% Returns: 
%   mask - HxW binary image where the projection falls.
%   sz - the size of the valid region.
function [mask sz] = get_projection_mask()
  mask = false(640, 480);
  mask(45:631, 41:441) = 1;
  
  sz = [587 401];
end
