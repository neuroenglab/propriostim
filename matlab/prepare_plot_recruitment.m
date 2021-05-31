function prepare_plot_recruitment(ax)

xlabel(ax, 'Injected Charge [nC]');
ylabel(ax, 'Relative recruitment [%]');
ylim(ax, [0 100]);
title(ax, 'Recruitment');

end

