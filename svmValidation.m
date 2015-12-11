function result = svmValidation(numIterations, imgSize, augmentDataShift, augmentDataFlip, augmentDataRotate)

randseed(1);

numBins = 4;
cellSize = 20;
blockSize = 2;
blockOverlap = 0;
useSignedOrientation = false;
if nargin == 1
    imgSize = [];
    augmentDataShift = true;
    augmentDataFlip = true;
    augmentDataRotate = false;
end
iter = 1;
resultIdx = 1;
crossValid = [0, 0.25, 0.5, 0.75, 1];
useThreeGroups = false;

outstruct = calcHogFeatures_allImgs(cellSize, blockSize, blockOverlap, ...
    numBins, useSignedOrientation, imgSize, augmentDataShift, augmentDataFlip, augmentDataRotate, []);
if useThreeGroups
    [label, fvec, imgLabel] = readFvecData_threeLabels(outstruct);
else
    [label, fvec, imgLabel] = readFvecData(outstruct);
end

uniqueImgs = unique(imgLabel);
numImgs = length(uniqueImgs);
result = struct();

param.s = 3;
param.C = 2^2; % this is best without augmentation
% param.C = 1; % with augmentation
param.t = 2;
param.g = 2^(-5); %this is best without augmentation
% param.g = 2^(-4); %with augmentation
param.m = 2000;
param.e = 0.01;

param.libsvm = ['-s ', num2str(param.s), ' -t ', num2str(param.t), ...
    ' -c ', num2str(param.C), ' -g ', num2str(param.g), ...
    ' -p ', num2str(param.e), ' -m ', num2str(param.m)];

% pick out training and testing sets at random in a specified ratio, run
% SVM algorithm.

permIdxs = round(crossValid * numImgs);
permIdxs(end) = permIdxs(end) + 1;
permIdxs(1) = 1;

while iter <= numIterations
    permSet = randperm(numImgs);
    
    for ii = 1:(length(crossValid)-1)
        testImgs = permSet(permIdxs(ii):permIdxs(ii+1)-1);
        trainImgs = setdiff(1:numImgs, testImgs);
        
        trainIdx = ismember(imgLabel, trainImgs);
        testIdx = ismember(imgLabel, testImgs);
        
        model = svmtrain(label(trainIdx), fvec(trainIdx, :), param.libsvm);
        
        if isnan(model.rho)
            continue;
        end
        
        [pred_label, mse, ~] = svmpredict(label(testIdx), fvec(testIdx, :), model);
        
        result(resultIdx).pred_label = pred_label;
        result(resultIdx).true_label = label(testIdx);
        result(resultIdx).img_num = imgLabel(testIdx);
        result(resultIdx).total_imgs = numImgs;
        result(resultIdx).mse = mse;
        result(resultIdx).model = model;
        result(resultIdx).param = param;
        result(resultIdx).numBins = numBins;
        result(resultIdx).cellSize = cellSize;
        result(resultIdx).blockSize = blockSize;
        result(resultIdx).blockOverlap = blockOverlap;
        result(resultIdx).useSignedOrientation = useSignedOrientation;
        resultIdx = resultIdx + 1;
    end
    
    iter = iter + 1;
end