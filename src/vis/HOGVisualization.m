function HOGVisualization(img)

cellSize = 20;
blockSize = 2;
blockOverlap = 0;
numBins = 4;
useSignedOrientation = false;
imgSize = [240, 320];

if ischar(img)
    img = imread(img);
end

if size(img, 3) > 1
    img = rgb2gray(img);
end
imgResize = imresize(img, imgSize + 2);

[grad, ang] = calculateGradient(imgResize);

tempVec = buildFeatureVectorSVR(grad, ang, ...
    cellSize, blockSize, blockOverlap, numBins, useSignedOrientation);
fVec = reshape(tempVec, [numel(tempVec), 1]);

% very complicated loop and indexing to extract feature vector into a form
% that the rest of the HOG code expects.
for ii = 1:8
    for jj = 1:6
        for kk = 1:2
            for ll = 1:2
                f(2*(ii-1)+kk, 2*(jj-1)+ll, :) = fVec((ii-1)*96 + (jj-1)*16 + (kk-1)*8 + (ll-1)*4 + 1 : ...
                    (ii-1)*96 + (jj-1)*16 + (kk-1)*8 + (ll)*4);
            end
        end
    end
end
f = permute(f, [2, 1, 3]);

hogvis = uint8(getHOGVisualization(f, cellSize));

img = imresize(img, imgSize);
% img(hogvis ~= 0) = hogvis(hogvis ~= 0);

figure;
subplot(1, 2, 1);
imshow(img);

subplot(1, 2, 2);
imshow(hogvis);

return;