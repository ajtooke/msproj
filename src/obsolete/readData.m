% convert struct

input = load('results\testing6.mat');
f = fieldnames(input);
input = input.(f{1});
CIRs = fieldnames(input);
label = []; count = 1;
imgCount = 1;
imgLabel = [];

for cir = 1:length(CIRs)
    
    curStruct = input.(CIRs{cir});
    imgs = fieldnames(curStruct);
    
    for ii = 1:length(imgs)
        
        curFvec = curStruct.(imgs{ii}).fvec;
        numVecs = size(curFvec, 2);
        label(count:(count+numVecs-1), 1) = cir;
        imgLabel(count:(count+numVecs-1), 1) = imgCount;
        
        fvec(count:(count+numVecs-1), :) = curFvec';
        
        count = count + numVecs;
        imgCount = imgCount + 1;
    end
end
        
        
        