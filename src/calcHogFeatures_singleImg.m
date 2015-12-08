function fVec = calcHogFeatures_singleImg(imgFname, ...
    cellSize, blockSize, blockOverlap, numBins, useSignedOrientation, ...
    imgSize, augmentDataShift, augmentDataFlip)

img = imread(imgFname);

if nargin == 1
    cellSize = 20;
    blockSize = 2;
    blockOverlap = 0;
    numBins = 4;
    useSignedOrientation = false;
end

if isempty(imgSize)
    imgSize = [255, 335];
end

% resize image to 15 pixels larger than 320x240 so we can shift it by 5
% pixels.
img = imresize(img, imgSize);

if augmentDataShift
    iter = 1;
    
    loopIdx = 0:double(augmentDataFlip);    
    numBlocks = floor(((imgSize-15)./cellSize - blockSize)./(blockSize - blockOverlap) + 1);
    fVec = zeros(prod([numBlocks, blockSize.^2, numBins]), 16 * length(loopIdx));
    
    for kk = loopIdx
        for ii = 1:4
            for jj = 1:4
                rowIdx = (1:(imgSize(1)-15))+(ii-1)*5;
                colIdx = (1:(imgSize(2)-15))+(jj-1)*5;
                if kk
                    colIdx = fliplr(colIdx);
                end
                tempVec = buildFeatureVectorSVR(img(rowIdx, colIdx, :), ...
                    cellSize, blockSize, blockOverlap, numBins, useSignedOrientation);
                fVec(:, iter) = reshape(tempVec, [numel(tempVec), 1]);
                iter = iter + 1;
            end
        end
    end
elseif ~augmentDataShift && augmentDataFlip
    iter = 1;
    loopIdx = 0:1;
    numBlocks = floor(((imgSize)./cellSize - blockSize)./(blockSize - blockOverlap) + 1);
    fVec = zeros(prod([numBlocks, blockSize.^2, numBins]), 2);
    colIdx = 1:size(img, 2);
    
    for kk = loopIdx
        if kk
            colIdx = fliplr(colIdx);
        end
        tempVec = buildFeatureVectorSVR(img(:, colIdx, :), ...
            cellSize, blockSize, blockOverlap, numBins, useSignedOrientation);
        fVec(:, iter) = reshape(tempVec, [numel(tempVec), 1]);
        iter = iter + 1;
    end
else
    tempVec = buildFeatureVectorSVR(img, ...
        cellSize, blockSize, blockOverlap, numBins, useSignedOrientation);
    fVec = reshape(tempVec, [numel(tempVec), 1]);
end


return;