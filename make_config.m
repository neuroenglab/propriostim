function make_config()

if isfile('config.mat')
    load('config.mat', 'nrnHome', 'deltaQnC', 'maxQnC');
else
    nrnHome = getenv('NEURONHOME');
    if ~isfolder(nrnHome)
        nrnHome = 'C:\nrn';
    end
    deltaQnC = 0.1;
    maxQnC = 120;
end

prompt = {'Enter NEURON path:', 'Enter solution precision [nC]:', 'Enter maximum charge [nC]:'};
definput = {nrnHome, num2str(deltaQnC), num2str(maxQnC)};
answer = inputdlg(prompt, 'Configuration', 1, definput);
if isempty(answer)
    return;
end

nrnHome = answer{1};
deltaQnC = str2double(answer{2});
maxQnC = str2double(answer{3});

save('config.mat', 'nrnHome', 'deltaQnC', 'maxQnC');

end