function [names, fullpaths] = list_csv(folder)
files = dir(fullfile(folder, '*.csv'));
names = {files.name};
names = cellfun(@(n) n(1:end-4), names, 'UniformOutput', false);
fullpaths = fullfile({files.folder}, {files.name});
end

