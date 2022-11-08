function subfolders = list_subfolders(folder)
subfolders = {dir(folder).name};
subfolders = subfolders(~ismember(subfolders ,{'.','..'}));
end

