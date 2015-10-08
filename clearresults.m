% clears results folder

base = 'results';

d = dir(base);
d = d(3:end);
c = cd;

for ii = 1:length(d)
    if d(ii).isdir
        rmdir([c, '\', base, '\', d(ii).name], 's');
    end
end