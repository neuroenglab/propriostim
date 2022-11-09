function build_neuron_dll(nrnModel)
pathToModFiles = ['neuron-demo\neuron\' nrnModel];
pathToDLL = fullfile(pathToModFiles, 'nrnmech.dll');
if ~isfile(pathToDLL)
    pathToNrnivmodl = '%NEURONHOME%\bin\nrnivmodl.bat';
    [status, cmdout] = system(sprintf('cd %s & %s', pathToModFiles, pathToNrnivmodl));
    if status == 0
        fprintf('%s\n', cmdout);
    else
        error('%s', cmdout);
    end
end
% No output in case the DLL was already built
end

