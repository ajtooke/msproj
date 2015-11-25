function makePlots2(r)


aggImgNum = [r.img_num];
numTotalTests = numel(aggImgNum);
aggImgNum = reshape(aggImgNum, [numTotalTests, 1]);

[imgs, a] = unique(aggImgNum);
score = zeros(length(imgs), 1);
spread = score;

aggPredLabel = [r.pred_label];
aggTrueLabel = [r.true_label];
aggPredLabel = reshape(aggPredLabel, [numTotalTests, 1]);
aggTrueLabel = reshape(aggTrueLabel, [numTotalTests, 1]);

true_label = aggTrueLabel(a);
nanIdx = isnan(aggPredLabel);

for ii = 1:length(imgs)
    idx = aggImgNum == imgs(ii) & ~nanIdx;
    score(ii) = mean(aggPredLabel(idx));
    spread(ii) = std(aggPredLabel(idx));
end

figure();

% Actual vs. error plot
subplot(4, 3, 1);
scatter(1:length(imgs), abs(true_label - score));
ylim([0 9]);
hold on;
scatter(1:length(imgs), true_label, 'rx');
legend('Absolute CIR regression error', 'Actual CIR label');
xlabel('Image number');
ylabel('CIR value')
title('CIR value vs. error');

% Mean plot
subplot(4, 3, 2);
scatter(1:length(imgs), score, 'bo');
xlabel('Image number');
ylabel('Mean predicted CIR value');
ylim([0 9]);
title(sprintf('Mean CIR value, MAE = %.2f', mean(abs(true_label - score))));

% standard dev. plot
subplot(4, 3, 3);
scatter(1:length(imgs), spread, 'bo');
xlabel('Image number');
ylabel('Predicted CIR standard deviation')
ylim([0 3]);
title(sprintf('Std dev of CIR value, sig = %.2f', std(abs(true_label - score))));

for ii = 1:9
    
    subplot(4, 3, 3+ii);
    
    histogram(score(true_label == ii), 10);
    xlabel('Score');
    ylabel('Count');
    title(sprintf('CIR level %d', ii));
end
    