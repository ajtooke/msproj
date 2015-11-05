function vec = buildFeatureVectorSVR(img)

% this function builds HoG feature vectors for 320x240 images, with block
% sizes in the top third 40x40 and block sizes in the bottom 2/3 20x20

if size(img, 3) > 1
    img = rgb2gray(img);
end

% First, grab magnitudes and angles of gradient vectors in image.
[mag, ang] = calculateGradient(img);

vec = zeros(2*8 + 2*4*16, 4);
vecIdx = 1;
% Now loop through and calculate the 40x40 blocks.
for ii = 1:2
    for jj = 1:8
        vertIdxs = (ii-1)*40+1:ii*40;
        horizIdxs = (jj-1)*40+1:jj*40;
        vec(vecIdx, :) = calculateHoG(mag(vertIdxs, horizIdxs), ang(vertIdxs, horizIdxs));
        vecIdx = vecIdx + 1;
    end
end

% Loop through 20x20 blocks
for ii = 5:12
    for jj = 1:16
        vertIdxs = (ii-1)*20+1:ii*20;
        horizIdxs = (jj-1)*20+1:jj*20;
        vec(vecIdx, :) = calculateHoG(mag(vertIdxs, horizIdxs), ang(vertIdxs, horizIdxs));
        vecIdx = vecIdx + 1;
    end
end

return