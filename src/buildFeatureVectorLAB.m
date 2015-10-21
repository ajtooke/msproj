function F = buildFeatureVectorLAB(im)

% Written by A. Tooke

% This function builds feature vector over image "im" over which we
% calculate covariance.

[h, w, c] = size(im);
cform = makecform('srgb2lab');
lab = applycform(im,cform);

% Derivative filters:
d_dx = [-1 0 1; 
        -2 0 2;
        -1 0 1];
d_dy = [-1 -2 -1;
        0  0  0;
        1  2  1];

% grayscale version for intensity derivatives:
imGray = rgb2gray(im);

F = zeros(h, w, 6 + c); %x, y, and RGB (?) dimensions
F(:, :, 1) = repmat((1:w),  [h, 1]); % x pixel locations
F(:, :, 2) = repmat((1:h)', [1, w]); % y pixel locations
F(:, :, 3:5) = lab; %LAB values
dim_dx = filter2(d_dx, imGray);
dim_dy = filter2(d_dy, imGray);
F(:, :, 6) = dim_dx; %d/dx
F(:, :, 7) = dim_dy; %d/dy
F(:, :, 8) = abs(filter2(d_dx, dim_dx)); %d^2/dx^2
F(:, :, 9) = abs(filter2(d_dy, dim_dy)); %d^2/dy^2