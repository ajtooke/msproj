im = im2double(imread('J:\Documents\MATLAB\project\msproj\test2\CIRs Bedroom\CIR9\BR_0031_I.jpg'));

im = imresize(im, [240, 320]);
feat = features(im, 20);
ihog = invertHOG(feat);

figure;
clf;

subplot(131);
imagesc(im); axis image; axis off;
title('Original Image', 'FontSize', 20);

subplot(132);
showHOG(feat); axis off;
title('HOG Features', 'FontSize', 20);

subplot(133);
imagesc(ihog); axis image; axis off;
title('HOG Inverse', 'FontSize', 20);
