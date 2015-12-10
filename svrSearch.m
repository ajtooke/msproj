% function svrSearch(numIterations)

numIterations = 4;
numBins = 6;
cellSize = 20;
blockSize = 2;
blockOverlap = 0;
useSignedOrientation = false;
imgSize = [240, 320];
augmentDataShift = false;
augmentDataFlip = false;
iter = 1;
numTraining = 3/4;

outstruct = calcHogFeatures_allImgs(cellSize, blockSize, blockOverlap, ...
    numBins, useSignedOrientation, imgSize, augmentDataShift, augmentDataFlip, []);
[label, fvec, imgLabel] = readFvecData(outstruct);

uniqueImgs = unique(imgLabel);
numImgs = length(uniqueImgs);
result = struct();

param.s = 3;
param.Cset = 2.^(-13:10);
param.t = 2;
param.gset = 2.^(-10:0);
param.e = 0.01;

absErr = zeros(length(param.Cset), length(param.gset));

% for ii = 1:length(param.gset)
for ii = 1:length(param.Cset)
    param.C = param.Cset(ii);
    
    for jj = 1:length(param.gset)
        param.g = param.gset(jj);
        
        param.libsvm = ['-s ', num2str(param.s), ' -t ', num2str(param.t), ...
            ' -c ', num2str(param.C), ' -g ', num2str(param.g), ...
            ' -p ', num2str(param.e)];
        
        randseed(1);
        
        fprintf('Calculating abs error for C = %f, g = %f', param.C, param.g);
        
        while iter <= numIterations
            
            trainImgs = randperm(numImgs, ceil(numTraining * numImgs));
            testImgs = setdiff(1:numImgs, trainImgs);
            
            trainIdx = ismember(imgLabel, trainImgs);
            testIdx = ismember(imgLabel, testImgs);
            
            model = svmtrain(label(trainIdx), fvec(trainIdx, :), param.libsvm);
            
            if isnan(model.rho)
                continue;
            end
            
            testLabel = label(testIdx);
            pred_label = svmpredict(testLabel, fvec(testIdx, :), model);
            
            nanIdx = isnan(pred_label);
            
            absErr(ii, jj) = absErr(ii, jj) + mean(abs(testLabel(~nanIdx) - pred_label(~nanIdx)));
            iter = iter + 1;
        end
        
        iter = 1;
        
    end
end

absErr = absErr / numIterations;