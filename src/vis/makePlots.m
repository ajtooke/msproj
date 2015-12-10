function makePlots(r, idxs, aggregatePlot)

for ii = 1:length(idxs)
    figure();
    scatter(1:length(r(idxs(ii)).pred_label), abs(r(idxs(ii)).true_label - r(idxs(ii)).pred_label));
    ylim([0 9]);
    hold on;
    scatter(1:length(r(idxs(ii)).pred_label), r(idxs(ii)).true_label, 'rx');
    legend('Absolute CIR regression error', 'Actual CIR label');
    xlabel('Image number');
    
    figure;
    subplot(1, 2, 1);
    scatter(1:length(r(idxs(ii)).pred_label), r(idxs(ii)).true_label, 'rx');
    xlabel('Image number');
    ylabel('Actual CIR value');
    ylim([0 9]);
    subplot(1, 2, 2);
    scatter(1:length(r(idxs(ii)).pred_label), r(idxs(ii)).pred_label, 'bo');
    xlabel('Image number');
    ylabel('Predicted CIR value');
    ylim([0 9]);
end

if aggregatePlot
    
    aggImgNum = [r.img_num];
    numTotalTests = numel(aggImgNum);
    aggImgNum = reshape(aggImgNum, [numTotalTests, 1]);
    
    [imgs, a] = unique(aggImgNum);
    score = zeros(length(imgs), 1);
    
    aggPredLabel = [r.pred_label];
    aggTrueLabel = [r.true_label];
    aggPredLabel = reshape(aggPredLabel, [numTotalTests, 1]);
    aggTrueLabel = reshape(aggTrueLabel, [numTotalTests, 1]);
    
    true_label = aggTrueLabel(a);
    
    for ii = 1:length(imgs)
        score(ii) = mean(aggPredLabel(aggImgNum == imgs(ii)));
    end
    
    figure();
    scatter(1:length(imgs), abs(true_label - score));
    ylim([0 9]);
    hold on;
    scatter(1:length(imgs), true_label, 'rx');
    legend('Absolute CIR regression error', 'Actual CIR label');
    xlabel('Image number');
    
    figure;
    subplot(1, 2, 1);
    scatter(1:length(imgs), true_label, 'rx');
    xlabel('Image number');
    ylabel('Actual CIR value');
    ylim([0 9]);
    subplot(1, 2, 2);
    scatter(1:length(imgs), score, 'bo');
    xlabel('Image number');
    ylabel('Predicted CIR value');
    ylim([0 9]);
end