function [mag, ang] = calculateGradient(img)

% This function takes an image as an input and returns a matrix of gradient
% magnitudes and gradient angles of the same size.

d_dx = [-1 0 1; 
        -1 0 1;
        -1 0 1];
d_dy = [-1 -1 -1;
        0  0  0;
        1  1  1];
    
dim_dx = filter2(d_dx, img, 'valid');
dim_dy = filter2(d_dy, img, 'valid');

% Calculate magnitude

% calculate angle
ang = atan2(dim_dy, dim_dx);

% calculate final magnitude.
mag = sqrt(dim_dx.^2 + dim_dy.^2);

return;