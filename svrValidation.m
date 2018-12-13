function result = svrValidation(numIterations, imgSize, ...
    augmentDataShift, augmentDataFlip, augmentDataRotate)

% This function provides a pathway into all core functionality of this
% work. It calculates vectors for all images located in the testImgs
% directory which are in the expected folder format, keeps track of data
% augmentation, sets up libsvm and the 4-fold split, and outputs data so
% that makePlots can be used to compare runs.
%
% Inputs:
%   numIterations: this should probably always be 1, it was included
%       before I figured out how to properly 4-fold split data and just runs
%       with whole chain multiple times with multiple random testing/training
%       sets. Now with it as 1, all images are rated.
%   imgSize: common resize vector of all input images. Set to [240, 320]
%       when not using shift augmentation or [255, 335] when using shift
%       augmentation. Should work with other properly chosen sizes as well.
%   augmentDataShift: true/false; turn on/off data shift augmentation.
%   augmentDataFlip: true/false; turn on/off data horizontal flip
%       augmentation.
%   augmentDataRotate: true/false; turn on/off data rotation augmentation.
%
% Outputs:
%   result: crazy struct format that makePlots needs to make the 4x3
%       subplot result presentation.

% Set random seed for repeatability.
rng(1);

% Set up HOG parameters here.
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

% Determines indexing for cross validation. For 5-fold split, use [0, 0.2,
% 0.4, 0.6, 0.8, 1] etc.
crossValid = [0, 0.25, 0.5, 0.75, 1];
useThreeGroups = false;

% Calculate all HOG features ...
outstruct = calcHogFeatures_allImgs(cellSize, blockSize, blockOverlap, ...
    numBins, useSignedOrientation, imgSize, augmentDataShift, augmentDataFlip, augmentDataRotate, []);

% ... and read them in to a useful format.
if useThreeGroups
    [label, fvec, imgLabel] = readFvecData_threeLabels(outstruct);
else
    [label, fvec, imgLabel, imgName] = readFvecData(outstruct);
end

uniqueImgs = unique(imgLabel);
numImgs = length(uniqueImgs);
result = struct();

% Set libsvm parameters here.
param.s = 3;
param.C = 2^2; % this is best without augmentation
param.t = 2;
param.g = 2^(-5); %this is best without augmentation
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
    
    % Go through whole cross validation routine so that every image is
    % tested once.
    for ii = 1:(length(crossValid)-1)
        testImgs = permSet(permIdxs(ii):permIdxs(ii+1)-1);
        trainImgs = setdiff(1:numImgs, testImgs);
        
        trainIdx = ismember(imgLabel, trainImgs);
        testIdx = ismember(imgLabel, testImgs);
        
        % Call libsvm train
        model = svmtrain(label(trainIdx), fvec(trainIdx, :), param.libsvm);
        
        % This should never happen anymore, leave it just in case
        if isnan(model.rho)
            error('Something went wrong, probably a data vector contains a NaN. Fix!');
        end
        
        % call libsvm predict.
        [pred_label, mse, ~] = svmpredict(label(testIdx), fvec(testIdx, :), model);
        
        % Populate results.
        result(resultIdx).pred_label = pred_label;
        result(resultIdx).true_label = label(testIdx);
        result(resultIdx).img_num = imgLabel(testIdx);
        result(resultIdx).imgName = imgName;
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