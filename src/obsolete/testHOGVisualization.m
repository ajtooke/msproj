function testHOGVisualization(img)

cellSize = 20;
blockSize = 2;
blockOverlap = 0;
numBins = 4;
useSignedOrientation = false;

[grad, ang] = calculateGradient(img);

tempVec = buildFeatureVectorSVR(grad, ang, ...
    cellSize, blockSize, blockOverlap, numBins, useSignedOrientation);
fVec = reshape(tempVec, [numel(tempVec), 1]);

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

figure;
imshow(img);

figure;
visualizeHOG(f);