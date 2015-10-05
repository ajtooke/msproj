% This function plots an input image in grayscale with a given feature
% criteria "heatmap" overlaid in color by intensity.

function plotHeatmap(X, m)

if ~exist('m', 'var')
    m = 20;
end

% start with sending input image to buildFeatureVectorLAB and grabbing
% directional derivatives.

F = buildFeatureVectorLAB(X);

d_m = calcFirstOrderIntegralImage(sqrt(F(:, :, 6).^2 + F(:, :, 7).^2));
dots = zeros(floor(size(X(:, :, 1)) / m));

for ii = 1:size(dots, 1)
    for jj = 1:size(dots, 2)
        
        dots(ii, jj) = d_m(m*ii, m*jj) -  ...
            d_m(m*ii, m*(jj-1) + 1) - ...
            d_m(m*(ii-1) + 1, m*jj) + ...
            d_m(m*(ii-1) + 1, m*(jj-1) + 1);
        
    end
end

figure;
imshow(repmat(F(:, :, 3)/255, [1, 1, 3])); % Gray scale image
colormap(jet);
hold on;

[x, y] = meshgrid(m/2:m:floor(size(X(:, :, 1), 2) / m)*m, m/2:m:floor(size(X(:, :, 1), 1) / m)*m);
x = reshape(x, 1, numel(x));
y = reshape(y, 1, numel(y));
dots = reshape(dots, 1, numel(dots));

scatter(x, y, 20, dots/max(max(dots)), 's', 'filled');
colorbar;

return;