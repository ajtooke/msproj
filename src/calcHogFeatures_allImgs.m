function outstruct = calcHogFeatures_allImgs(cellSize, blockSize, blockOverlap, numBins, useSignedOrientation, ...
    imgSize, augmentDataShift, augmentDataFlip, fname)

% Calculate feature vectors with specified HoG options and return struct
% format. Also save as .mat file if a filename is given.

subd = {'test2\CIRs Bedroom', 'test2\CIRs Kitchen', 'test2\CIRs Living Room'};
CIRs = 1:9;
outstruct = struct();

if ~nargin
    cellSize = 20;
    blockSize = 2;
    blockOverlap = 0;
    numBins = 6;
    useSignedOrientation = false;
    imgSize = [255, 335];
    augmentDataShift = true;
    augmentDataFlip = false;
end

% populate struct with all images feature vectors.

for cir = CIRs
    
    imgCount = 1;
    
    for types = 1:length(subd)
        currentDir = [subd{types}, '\', 'CIR', num2str(cir)];
        
        d = dir(currentDir);
        d = {d.name};
        d = d(3:end);
        
        for kk = 1:length(d)
            if ~strcmpi((d{kk}), 'thumbs.db')
                imgFile = [currentDir, '\', d{kk}];
                
                fvec = calcHogFeatures_singleImg(imgFile, ...
                    cellSize, blockSize, blockOverlap, numBins, useSignedOrientation, ...
                    imgSize, augmentDataShift, augmentDataFlip);
                
                % Temporarily augment high CIR images!!!!
                %
                %
                
                count = 1;
                tempFvec = [];
%                 if any(cir == [7, 8])
%                     num2copy = 2;
%                 elseif cir == 9
%                     num2copy = 3;
%                 else
                    num2copy = 1;
%                 end
                
                while count <= num2copy
                    outstruct.(['CIR', num2str(cir)]).(['im', num2str(imgCount)]).fvec = ...
                        [tempFvec, fvec];
                    outstruct.(['CIR', num2str(cir)]).(['im', num2str(imgCount)]).name = imgFile;
                    count = count + 1;
                    tempFvec = outstruct.(['CIR', num2str(cir)]).(['im', num2str(imgCount)]).fvec;
                end
                
                imgCount = imgCount + 1;
                %
                %
                % / Temporarily augment high CIR images!!!!
            end
        end
    end
end

if exist('fname', 'var') && ~isempty(fname)
    save(['results\', fname], 'outstruct')
end