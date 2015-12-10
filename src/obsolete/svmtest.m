% svm test script

readData;

uniqueImgs = unique(imgLabel);
set1 = uniqueImgs(1:2:end);
set2 = uniqueImgs(2:2:end);

l1 = ismember(imgLabel, set1);
l2 = ismember(imgLabel, set2);

model = svmtrain(label(l1), fvec(l1, :), '-s 3');
pred_label = svmpredict(label(l2), fvec(l2, :), model);

% plotting

figure;
scatter(1:sum(l2), abs(label(l2) - pred_label))
hold on;
scatter(1:sum(l2), label(l2), 'rx');
legend('Absolute CIR regression error', 'Actual CIR label');
xlabel('Image number');