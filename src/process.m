% This function plots an input image in grayscale with a given feature
% criteria "heatmap" overlaid in color by intensity.

function [Y, mu, sig] = process(X, m, useScaling)

if exist('useScaling', 'var') && strcmp(useScaling, 'noResize')
    % find 1D scaling factor based on smaller dimension and m = 20 for
    % 480 pixel small dimension (i.e., 640 x 480)
    S = size(X(:, :, 1));
    scalingFactor = min(S) / 480;
    m = round(m * scalingFactor);
elseif exist('useScaling', 'var') && strcmp(useScaling, 'resize')
    % resize image to 640 x 480 or 480x640
    S = size(X(:, :, 1));
    scalingFactor = min(S) / 480;
    X = imresize(X, 1/scalingFactor);
    scalingFactor = 1;
else
    scalingFactor = 1;
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

Y = repmat(F(:, :, 3)/255, [1, 1, 3]); % Gray scale image

% number of pixels to use for displaying color dot.
pixels = round(-2*sqrt(scalingFactor)):round(2*sqrt(scalingFactor));
[x, y] = meshgrid(round(m/2):m:floor(size(X(:, :, 1), 2) / m)*m, round(m/2):m:floor(size(X(:, :, 1), 1) / m)*m);
x = reshape(x, 1, numel(x));
y = reshape(y, 1, numel(y));
dots = reshape(dots, 1, numel(dots));

% Calculate mean and standard deviation before rescaling.
mu = mean(dots) / scalingFactor^2;
sig = std(dots) / scalingFactor^4;

dots = dots / max(dots);
dots(dots <= 0) = eps;

cmap = colormap('jet');

for ii = 1:length(pixels)
    for jj = 1:length(pixels)
        for kk = 1:3
            idx = sub2ind(size(Y), y+pixels(ii), x+pixels(jj), kk*ones(size(x)));
            Y(idx) = cmap(ceil(dots*64), kk);
        end
    end
end

return;