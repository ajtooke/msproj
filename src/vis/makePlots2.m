function makePlots2(r)


aggImgNum = vertcat(r.img_num);

[imgs, a] = unique(aggImgNum);
score = zeros(length(imgs), 1);
spread = score;

aggPredLabel = vertcat(r.pred_label);
aggTrueLabel = vertcat(r.true_label);

true_label = aggTrueLabel(a);
nanIdx = isnan(aggPredLabel);

for ii = 1:length(imgs)
    idx = aggImgNum == imgs(ii) & ~nanIdx;
    score(ii) = mean(aggPredLabel(idx));
    spread(ii) = std(aggPredLabel(idx));
end

nanIdx = isnan(score);

figure();

maxScore = floor(max(aggTrueLabel) / 3) * 3;
if maxScore <= 3
    subPx = 2;
else
    subPx = 4;
end

% Actual vs. error plot
subplot(subPx, 3, 1);
scatter(imgs(~nanIdx), abs(true_label(~nanIdx) - score(~nanIdx)));
ylim([0 maxScore]);
hold on;
scatter(imgs, true_label, 'rx');
legend('Absolute CIR regression error', 'Actual CIR label');
xlabel('Image number');
ylabel('CIR value')
title('CIR value vs. error');

% Mean plot
subplot(subPx, 3, 2);
scatter(imgs(~nanIdx), score(~nanIdx), 'bo');
xlabel('Image number');
ylabel('Mean predicted CIR value');
ylim([0 maxScore]);
title(sprintf('Mean CIR value, MAE = %.2f', mean(abs(true_label(~nanIdx) - score(~nanIdx)))));

% standard dev. plot
subplot(subPx, 3, 3);
scatter(imgs(~nanIdx), spread(~nanIdx), 'bo');
xlabel('Image number');
ylabel('Predicted CIR standard deviation')
ylim([0 3]);
title(sprintf('Std dev of CIR value, sig = %.2f', std(abs(true_label(~nanIdx) - score(~nanIdx)))));

edges = 0.5:9.5;
ylims = zeros(1, maxScore);
handles = zeros(1, maxScore);
v = version();
for ii = 1:maxScore
    
    subplot(subPx, 3, 3+ii);
    
    % version checking using the two I have access to. Adjust accordingly
    if strcmp(v, '7.13.0.564 (R2011b)')
        n = histc(score(true_label == ii), edges);
        n(end-1) = n(end-1) + n(end);
        bar(edges(1:end-1) + 0.5, n(1:end-1));
    else
        histogram(score(true_label == ii), edges);
    end
    xlabel('Score');
    ylabel('Count');
    title(sprintf('CIR level %d', ii));
    
    handles(ii) = gca;
    ylimtemp = get(handles(ii), 'YLim');
    ylims(ii) = ylimtemp(2);
end

for ii = 1:maxScore
    set(handles(ii), 'YLim', [0, max(ylims)]);
end

% get super title stuff right.
if r(1).useSignedOrientation
    signed = 'signed';
else
    signed = 'unsigned';
end

titlestring = sprintf('%d runs with: %d %s bins; cell size = %d; SVM C = %0.3f; SVM gamma = %0.3f; %d total images rated', ...
    length(r), r(1).numBins, signed, r(1).cellSize, r(1).param.C, r(1).param.g, length(imgs));
suptitle(titlestring);

return;
    