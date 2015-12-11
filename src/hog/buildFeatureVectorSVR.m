function fvec2 = buildFeatureVectorSVR(grad, ang, cellSize, blockSize, blockOverlap, numBins, useSignedOrientation)

[r, c, ~] = size(grad);

% take mod if using unsigned orientation.
if ~useSignedOrientation
    ang = mod(ang + pi*(1 + useSignedOrientation)/numBins/2, pi) - pi*(1 + useSignedOrientation)/numBins/2;
end

blockJump = blockSize - blockOverlap;
numHorizBlocks = c/(blockJump*cellSize);
numVertBlocks = r/(blockJump*cellSize);

fvec2 = [];

% loop over each block and cell within each block.
for ii = 1:numHorizBlocks
    for jj = 1:numVertBlocks
        
        currentCell = 1;
        % iterate over cells in block
        for kk = 1:(blockSize)
            for ll = 1:(blockSize)
                horizIdxs = ((ii-1)*blockJump*cellSize + (kk-1)*cellSize + 1):((ii-1)*blockJump*cellSize + kk*cellSize);
                vertIdxs = ((jj-1)*blockJump*cellSize + (ll-1)*cellSize + 1):((jj-1)*blockJump*cellSize + ll*cellSize);
                fvec(:, currentCell) = calculateHoG(grad(vertIdxs, horizIdxs), ang(vertIdxs, horizIdxs), numBins, useSignedOrientation)';
                currentCell = currentCell + 1;
            end
        end
        
        % normalize descriptor vector over current block (L2 norm)
        if any(any(fvec))
            fvec = fvec / sqrt(sum(sum(fvec.^2)));
        end
        fvec2 = [fvec2; fvec(:)];
        
    end
end

return;