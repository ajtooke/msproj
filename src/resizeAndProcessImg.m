function fVec = resizeAndProcessImg(imgFname)

img = imread(imgFname);

% resize image to 15 pixels larger than 320x240 so we can shift it by 5
% pixels.
img = imresize(img, [255, 335]);
fVec = zeros((2*8 + 2*4*16) * 4, 4);

for ii = 1:4
    for jj = 1:4
        tempVec = buildFeatureVectorSVR(img((1:240)+(ii-1)*5, (1:320)+(jj-1)*5));
        fVec(:, ii) = reshape(tempVec, [numel(tempVec), 1]);
    end
end

return;