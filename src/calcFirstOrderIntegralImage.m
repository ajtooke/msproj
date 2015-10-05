function I_prime = calcFirstOrderIntegralImage(I)

% Written by A. Tooke

% Calculate first rows and columns as simple cumulative sums .. the rest
% will be looped through and based on these
% [X, Y, d] = size(I);
% I_prime = zeros(X, Y, d);
% I_prime(1, :, :) = cumsum(I(1, :, :));
% I_prime(:, 1, :) = cumsum(I(:, 1, :));

% I_prime_test = I_prime;

% loop through rest of pixels .. 3 additions for each pixel
% for x = 2:X
%     for y = 2:Y
%         I_prime(x, y, :) = ...
%             I(x, y, :) + I_prime(x-1, y, :) + I_prime(x, y-1, :) - I_prime(x-1, y-1, :);
%     end
% end

I_prime = cumsum(cumsum(I,2));

return;