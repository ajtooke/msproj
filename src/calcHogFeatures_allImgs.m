function outstruct = calcHogFeatures_allImgs(cellSize, blockSize, blockOverlap, numBins, useSignedOrientation, ...
    imgSize, augmentDataShift, augmentDataFlip, fname)

% Calculate feature vectors with specified HoG options and return struct
% format. Also save as .mat file if a filename is given.

subd = {'test\CIRs Bedroom', 'test\CIRs Kitchen', 'test\CIRs Living Room'};
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
    
    imgCount = 0;
    
    for types = 1:length(subd)
        currentDir = [subd{types}, '\', 'CIR', num2str(cir)];
        
        d = dir(currentDir);
        d = {d.name};
        d = d(3:end);
        
        for kk = 1:length(d)
            if ~strcmpi((d{types}), 'thumbs.db')
                imgCount = imgCount + 1;
                imgFile = [currentDir, '\', d{types}];
                
                fvec = calcHogFeatures_singleImg(imgFile, ...
                    cellSize, blockSize, blockOverlap, numBins, useSignedOrientation, ...
                    imgSize, augmentDataShift, augmentDataFlip);
                
                outstruct.(['CIR', num2str(cir)]).(['im', num2str(imgCount)]).fvec = fvec;
                outstruct.(['CIR', num2str(cir)]).(['im', num2str(imgCount)]).name = imgFile;
            end
        end
    end
end

if exist('fname', 'var') && ~isempty(fname)
    save(['results\', fname], 'outstruct')
end