function model = view_run(model)
addpath('matlab');

if nargin == 0
    [file, path] = uigetfile('data/runs/*.mat');
    load([path file], 'model');
end

figure;
tiledlayout(2, 1);
nexttile;
prepare_plot_cross_section(gca());
plot_cross_section(model, gca());
nexttile;
prepare_plot_recruitment(gca());
plot_recruitment(model, gca());

end

