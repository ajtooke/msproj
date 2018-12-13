function makePlots(r)


aggImgNum = vertcat(r.img_num);

[imgs, a] = unique(aggImgNum);
score = zeros(length(imgs), 1);
spread = score;

aggPredLabel = vertcat(r.pred_label);
aggTrueLabel = vertcat(r.true_label);

true_label = aggTrueLabel(a);
pred_label = aggPredLabel(a);
nanIdx = isnan(aggPredLabel);

% %TEMP
% aggPredLabel = round(aggPredLabel);

for ii = 1:length(imgs)
    idx = aggImgNum == imgs(ii) & ~nanIdx;
    
    absErr{ii} = abs(aggPredLabel(idx) - aggTrueLabel(idx));
    absErrRound{ii} = abs(round(aggPredLabel(idx)) - aggTrueLabel(idx));
    
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

e = cell2mat(absErr(:));
e_round = cell2mat(absErrRound(:));


% scatter(imgs(~nanIdx), abs(true_label(~nanIdx) - score(~nanIdx)));

a = axes;
xlim([0, max(imgs(~nanIdx))]);
ylim([0 maxScore+1]);
set(a, 'YAxisLocation', 'right');
ylabel('MAE of CIR');

b = axes;
scatter(imgs(~nanIdx), cellfun(@mean, absErr));
xlim([0, max(imgs(~nanIdx))]);
ylim([0 maxScore+1]);
hold on;
scatter(imgs, true_label, 'rx');
legend('MAE of CIR', 'True CIR', 'Location', 'northwest');

xlabel('Image number');
ylabel('True CIR')
% title('CIR value vs. error');
print('1', '-depsc2');
close gcf

figure;
scatter(imgs(~nanIdx), score(~nanIdx), 'bo');
xlabel('Image number');
ylabel('Mean of CIR estimates');
xlim([0, max(imgs(~nanIdx))]);
ylim([0 maxScore+1]);
print('2', '-depsc2');
close gcf

figure;
scatter(imgs(~nanIdx), cellfun(@std, absErr), 'bo');
xlabel('Image number');
ylabel('Std. dev. of CIR AE')
xlim([0, max(imgs(~nanIdx))]);
ylim([0 3]);
print('3', '-depsc2');
close gcf

% Actual vs. error plot
figure;
subplot(subPx, 3, 1);

scatter(imgs(~nanIdx), cellfun(@mean, absErr));
xlim([0, max(imgs(~nanIdx))]);
ylim([0 maxScore+1]);
hold on;
scatter(imgs, true_label, 'rx');
legend('MAE of CIR', 'True CIR', 'Location', 'northwest');

xlabel('Image number');
ylabel('CIR')
title('CIR value vs. error');

% Mean plot
subplot(subPx, 3, 2);
scatter(imgs(~nanIdx), score(~nanIdx), 'bo');
xlabel('Image number');
ylabel('Mean of CIR estimates');
xlim([0, max(imgs(~nanIdx))]);
ylim([0 maxScore+1]);
title(sprintf('Mean of CIR estimates, MAE = %.2f', mean(e(:))));

% standard dev. plot
subplot(subPx, 3, 3);
% scatter(imgs(~nanIdx), spread(~nanIdx), 'bo');
scatter(imgs(~nanIdx), cellfun(@std, absErr), 'bo');
xlabel('Image number');
ylabel('Std. dev. of CIR AE')
xlim([0, max(imgs(~nanIdx))]);
ylim([0 3]);
title(sprintf('Std dev of CIR AE, sig = %.2f', std(e(:))));

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
    xlabel('CIR');
    ylabel('Count');
    e2 = absErr(true_label == ii);
    e3 = cell2mat(e2(:));
    title(sprintf('CIR level %d (%d), MAE = %.2f, STD = %.2f', ...
        ii, sum(true_label == ii), mean(e3(:)), std(e3(:))));
    
    idx = true_label == ii;
    CCR = sum(round(pred_label(idx)) == ii) / sum(idx);
    CCR_1 = sum(round(pred_label(idx)) >= (ii-1) & round(pred_label(idx)) <= (ii+1)) / sum(idx);
    CCR_2 = sum(round(pred_label(idx)) >= (ii-2) & round(pred_label(idx)) <= (ii+2)) / sum(idx);
    fprintf('\nCIR %d: CCR: %.2f\t CCR-1: %.2f\t CCR-2: %.2f', ii, CCR, CCR_1, CCR_2);
    
    handles(ii) = gca;
    ylimtemp = get(handles(ii), 'YLim');
    ylims(ii) = ylimtemp(2);
end

CCR = sum(round(pred_label) == true_label) / numel(imgs);
CCR_1 = sum(round(pred_label) >= (true_label - 1) & round(pred_label) <= (true_label + 1)) / numel(imgs);
CCR_2 = sum(round(pred_label) >= (true_label - 2) & round(pred_label) <= (true_label + 2)) / numel(imgs);
fprintf('\nOverall CCR: %.2f\t CCR-1: %.2f\t CCR-2: %.2f\n', CCR, CCR_1, CCR_2);

for ii = 1:maxScore
%     set(handles(ii), 'YLim', [0, max(ylims)]);
set(handles(ii), 'YLim', [0, 80]);
end

for ii = 1:maxScore
    figure;
    histogram(score(true_label == ii), edges);
    xlabel('CIR')
    ylabel('Count');
    e2 = absErr(true_label == ii);
    e = cell2mat(e2(:));
    set(gca, 'YLim', [0, 80]);
    print(['CIR ', num2str(ii)], '-depsc2');
    close gcf
end

for ii = 1:maxScore
    e2 = absErr(true_label == ii);
    e3 = cell2mat(e2(:));
    
    e2_round = absErrRound(true_label == ii);
    e3_round = cell2mat(e2_round(:));
    fprintf('CIR %d:\t MAE: %.2f\t Quant. MAE: %.2f\t STD: %.2f\t Quant. STD: %.2f\n', ...
        ii, mean(e3(:)), mean(e3_round(:)), std(e3(:)), std(e3_round(:)));
end

e3 = cell2mat(absErr(:));
e3_round = cell2mat(absErrRound(:));

fprintf('Overall:\t MAE: %.2f\t Quant. MAE: %.2f\t STD: %.2f\t Quant. STD: %.2f\n', ...
    mean(e3(:)), mean(e3_round(:)), std(e3(:)), std(e3_round(:)));
    

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
    