function make_config()

if isfile('config.mat')
    load('config.mat', 'nrnHome', 'deltaQnC', 'qMaxnC', 'nbNod', 'stimStart', 'stimDur');
else
    nrnHome = getenv('NEURONHOME');
    if ~isfolder(nrnHome)
        nrnHome = 'C:\nrn';
    end
    deltaQnC = 0.1;
    qMaxnC = 120;
    nbNod = 21;
    stimStart = 0.2;
    stimDur = 0.05;
end

prompt = {'NEURON path', ...
          'Solution precision [nC]', ...
          'Maximum charge [nC]', ...
          'Number of nodes of Ranvier per fiber', ...
          'Time to first current pulse [ms]', ...
          'Stimulus duration [ms]'};
definput = {nrnHome, num2str(deltaQnC), num2str(qMaxnC), num2str(nbNod), num2str(stimStart), num2str(stimDur)};
answer = inputdlg(prompt, 'Configuration', 1, definput);
if isempty(answer)
    return;
end

nrnHome = answer{1};
deltaQnC = str2double(answer{2});
qMaxnC = str2double(answer{3});
nbNod = str2double(answer{4});
stimStart = str2double(answer{5});
stimDur = str2double(answer{6});

save('config.mat', 'nrnHome', 'deltaQnC', 'qMaxnC', 'nbNod', 'stimStart', 'stimDur');

end