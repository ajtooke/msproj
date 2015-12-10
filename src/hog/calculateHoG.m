function [grad, uniqueBins, bins] = calculateHoG(mag, ang, numBins, useSignedOrientation)

% This function takes as input a block of equivalently sized magnitude and
% angle matrices and returns a histogram of gradients with vote values
% equivalent to magnitude.

% separate input angles into bins.
bins = floor((ang + pi*(1 + useSignedOrientation)/numBins/2) * numBins/pi) * pi/numBins;
uniqueBins = 0:(1 + useSignedOrientation)*pi/numBins:(1 + useSignedOrientation - 1/numBins)*pi;

grad = zeros(size(uniqueBins));
% loop over the bins for now (vectorize later ...)
for ii = 1:length(grad)
    grad(ii) = sum(mag(bins == uniqueBins(ii)));
end