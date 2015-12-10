function makeImgHistogram

% this function creates histogram of image labels vs. count.

subd = {'test2\CIRs Bedroom', 'test2\CIRs Kitchen', 'test2\CIRs Living Room'};
CIRs = 1:9;
imgCount = zeros(1, length(CIRs));

for cir = CIRs
    
    for types = 1:length(subd)
        currentDir = [subd{types}, '\', 'CIR', num2str(cir)];
        
        d = dir(currentDir);
        d = {d.name};
        d = d(3:end);
        
        for kk = 1:length(d)
            if ~strcmpi((d{kk}), 'thumbs.db')
                imgFile = [currentDir, '\', d{kk}];
                
                try
                    % imfinfo errors out if file isn't in a format
                    % it recognizes, so put the call in a try-catch.
                    info = imfinfo(imgFile); %#ok<NASGU>
                    imgCount(cir) = imgCount(cir) + 1;
                catch
                    fprintf('Unable to read file: %s', imgFile);
                end
            end
            
        end
        
    end
end

figure;
bar(CIRs, imgCount);