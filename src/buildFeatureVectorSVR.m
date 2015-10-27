function vec = buildFeatureVectorSVR(img)

% this function builds HoG feature vectors for 320x240 images, with block
% sizes in the top third 40x40 and block sizes in the bottom 2/3 20x20

for ii = 1:2
    for jj = 1:8
        