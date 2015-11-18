% svm test script

% HoG settings to test.
% numBins = 4:9;
% cellSize = [10, 20];
% blockSize = 2:3;
% blockOverlap = 0;
% useSignedOrientation = [false, true];
% iter = 1;

numBins = 4;
cellSize = [20];
blockSize = 2;
blockOverlap = 0;
useSignedOrientation = false;
imgSize = [240, 320];
augmentData = false;
iter = 1;


resultStruct3 = struct;

for b = 1:length(numBins)
    for c = 1:length(cellSize)
        for bs = 1:length(blockSize)
            for bo = 1:length(blockOverlap)
                for ss = 1:length(useSignedOrientation)
                    if ~mod(320, cellSize(c)*blockSize(bs)) && ~mod(240, cellSize(c)*blockSize(bs))
                        outstruct = calcHogFeatures_allImgs(cellSize(c), blockSize(bs), blockOverlap(bo), ...
                            numBins(b), useSignedOrientation(ss), imgSize, augmentData, []);
                        [label, fvec, imgLabel] = readFvecData(outstruct);
                        
                        uniqueImgs = unique(imgLabel);
                        set1 = uniqueImgs(1:2:end);
                        set2 = uniqueImgs(2:2:end);
                        
                        l1 = ismember(imgLabel, set1);
                        l2 = ismember(imgLabel, set2);
                        
                        model = svmtrain(label(l1), fvec(l1, :), '-s 3');
                        [pred_label, mse, ~] = svmpredict(label(l2), fvec(l2, :), model);
                        
                        % plotting
                        
                        figure;
                        scatter(1:sum(l2), abs(label(l2) - pred_label))
                        hold on;
                        scatter(1:sum(l2), label(l2), 'rx');
                        legend('Absolute CIR regression error', 'Actual CIR label');
                        xlabel('Image number');
                        title(['Iteration number ', num2str(iter)]);
                        
                        resultStruct3(iter).pred_label = pred_label;
                        resultStruct3(iter).true_label = label(l2);
                        resultStruct3(iter).mse = mse;
                        resultStruct3(iter).model = model;
                        resultStruct3(iter).numBins = numBins(b);
                        resultStruct3(iter).cellSize = cellSize(c);
                        resultStruct3(iter).blockSize = blockSize(bs);
                        resultStruct3(iter).blockOverlap = blockOverlap(bo);
                        resultStruct3(iter).useSignedOrientation = useSignedOrientation(ss);
                        
                        iter = iter + 1;
                    end
                end
            end
        end
    end
end