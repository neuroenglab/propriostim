function [subjects, electrodes] = scrape_stored_data()

subjects = {dir('data\Nerve\*_noElectrode').name};
subjects = cellfun(@(n) n(1:end-12), subjects, 'UniformOutput', false);
electrodes = cell(1, numel(subjects));

for iSubject = 1:numel(subjects)
    subj = subjects{iSubject};
    electrodes{iSubject} = {dir(['data\Fibers\' subj '_*']).name};
    electrodes{iSubject} = cellfun(@(n) n(numel(subj)+2:end), electrodes{iSubject}, 'UniformOutput', false);
end

end
