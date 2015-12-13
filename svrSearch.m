% function svrSearch(numIterations)

numIterations = 4;
numBins = 4;
cellSize = 20;
blockSize = 2;
blockOverlap = 0;
useSignedOrientation = false;
imgSize = [240, 320];
augmentDataShift = false;
augmentDataFlip = false;
augmentDataRotate = true;
crossValid = [0, 0.25, 0.5, 0.75, 1];

outstruct = calcHogFeatures_allImgs(cellSize, blockSize, blockOverlap, ...
    numBins, useSignedOrientation, imgSize, augmentDataShift, augmentDataFlip, augmentDataRotate, []);
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

randseed(1);
permIdxs = round(crossValid * numImgs);
permIdxs(end) = permIdxs(end) + 1;
permIdxs(1) = 1;
permSet = randperm(numImgs);

% for ii = 1:length(param.gset)
for ii = 1:length(param.Cset)
    param.C = param.Cset(ii);
    
    for jj = 1:length(param.gset)
        param.g = param.gset(jj);
        param.libsvm = ['-s ', num2str(param.s), ' -t ', num2str(param.t), ...
            ' -c ', num2str(param.C), ' -g ', num2str(param.g), ...
            ' -p ', num2str(param.e)];
        
        fprintf('Calculating abs error for C = %f, g = %f', param.C, param.g);
        
        for kk = 1:(length(crossValid)-1)
            
            testImgs = permSet(permIdxs(kk):permIdxs(kk+1)-1);
            trainImgs = setdiff(1:numImgs, testImgs);
            
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
        end
                
    end
end

absErr = absErr / numIterations;