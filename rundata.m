% runs all data and saves .png files.

testdirs = {'test\CIRS Bedroom', 'test\CIRs Kitchen', 'test\CIRs Living Room'};
outputdir = 'results';

for types = 1:3
    for cir = 1:9
        currentDir = [testdirs{types}, '\', 'CIR', num2str(cir)];
        
        d = dir(currentDir);
        d = {d.name};
        
        for ii = 1:length(d)
            try
                imgFile = [currentDir, '\', d{ii}];
                currentImg = imread(imgFile);
                plotHeatmap(currentImg);
                
                outputDir = [outputdir, '\CIR', num2str(cir), '\'];
                if ~exist(outputDir, 'dir')
                    mkdir(outputDir);
                end
                
                [~, img] = fileparts(imgFile);
                saveas(gcf, [outputDir, img], 'png');
                close(gcf);
            catch
                % probably isn't an image file
            end
        end
    end
end