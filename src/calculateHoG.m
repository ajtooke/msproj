function grad = calculateHoG(block)

d_dx = [-1 0 1; 
        -1 0 1;
        -1 0 1];
d_dy = [-1 -1 -1;
        0  0  0;
        1  1  1];
    
dim_dx = filter2(d_dx, block);
dim_dy = filter2(d_dy, block);

% Calculate magnitude

% calculate angle and round to histogram
ang = atan2(dim_dy, dim_dx);
ang = mod(ang + pi/8, pi);

