function result = svmValidation(numIterations)

randseed(1);

numBins = 4;
cellSize = 20;
blockSize = 2;
blockOverlap = 0;
useSignedOrientation = false;
imgSize = [];
augmentDataShift = true;
augmentDataFlip = true;
iter = 1;
numTraining = 3/4;

outstruct = calcHogFeatures_allImgs(cellSize, blockSize, blockOverlap, ...
    numBins, useSignedOrientation, imgSize, augmentDataShift, augmentDataFlip, []);
[label, fvec, imgLabel] = readFvecData(outstruct);

uniqueImgs = unique(imgLabel);
numImgs = length(uniqueImgs);
result = struct();

% pick out training and testing sets at random in a specified ratio, run
% SVM algorithm.

while iter <= numIterations
    trainImgs = randperm(numImgs, ceil(numTraining * numImgs));
    testImgs = setdiff(1:numImgs, trainImgs);
    
    trainIdx = ismember(imgLabel, trainImgs);
    testIdx = ismember(imgLabel, testImgs);
    
    model = svmtrain(label(trainIdx), fvec(trainIdx, :), '-s 3');
    [pred_label, mse, ~] = svmpredict(label(testIdx), fvec(testIdx, :), model);
    
    result(iter).pred_label = pred_label;
    result(iter).true_label = label(testIdx);
    result(iter).img_num = imgLabel(testIdx);
    result(iter).total_imgs = numImgs;
    result(iter).mse = mse;
    result(iter).model = model;
    result(iter).numBins = numBins;
    result(iter).cellSize = cellSize;
    result(iter).blockSize = blockSize;
    result(iter).blockOverlap = blockOverlap;
    result(iter).useSignedOrientation = useSignedOrientation;
    
    iter = iter + 1;
end