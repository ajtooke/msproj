function Y = makeHeatmap(X, m)

% this function makes a heatmap over blocks of an input image X, where m is
% block size.

if ~exist('m', 'var')
    m = 20;
end

% start with sending input image to buildFeatureVectorLAB and grabbing
% directional derivatives.

F = buildFeatureVectorLAB(X);

d_m = calcFirstOrderIntegralImage(sqrt(F(:, :, 6).^2 + F(:, :, 7).^2));

Y = zeros(size(X(:, :, 1)) - m + 1);

for ii = 1:(size(X, 1) - m + 1)
    for jj = 1:(size(X, 2) - m + 1)
        
        Y(ii, jj) = d_m(ii + m - 1, jj + m - 1) -  ...
            d_m(ii + m - 1, jj) - ...
            d_m(ii, jj + m - 1) + ...
            d_m(ii, jj);
        
    end
end

Y = Y / max(max(Y));

return;