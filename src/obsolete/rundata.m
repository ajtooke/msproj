% runs all data and saves .png files.

testdirs = {'test\CIRS Bedroom', 'test\CIRs Kitchen', 'test\CIRs Living Room'};
outputdir = 'results';
useAngle = true;

for cir = 1:9
    
    imgCount = 0;
    
    for types = 1:3
        currentDir = [testdirs{types}, '\', 'CIR', num2str(cir)];
        
        d = dir(currentDir);
        d = {d.name};
        d = d(3:end);
        
        for ii = 1:length(d)
%             try
            if ~strcmpi((d{ii}), 'thumbs.db')
                imgCount = imgCount + 1;
                imgFile = [currentDir, '\', d{ii}];
                currentImg = imread(imgFile);
                [Y, tempMu, tempSig, angStruct] = process(currentImg, 20, 'resize');
                
                mu{cir}(imgCount) = tempMu;
                sig{cir}(imgCount) = tempSig;
                
                outputDir = [outputdir, '\CIR', num2str(cir), '\'];
                if ~exist(outputDir, 'dir')
                    mkdir(outputDir);
                end
                
                [~, img] = fileparts(imgFile);
                imwrite(Y, [outputDir, img, '.png'], 'png');
                
                if useAngle
                    figure;
                    for jj = 1:10
                        subplot(1, 10, jj);
                        scatter(1:length(angStruct(jj).angle), angStruct(jj).angle);
                    end
                    fig = gcf;
                    fig.PaperPosition = [0.25 0.25 14 5];
                    saveas(fig, [outputDir, img, '_angle.png'], 'png');
                    close(fig);
                end
%             catch
                % probably isn't an image file
%             end
            end
        end
    end
end