function prepare_plot_cross_section(ax)

hold(ax, 'on');
axis(ax, 'equal');
title(ax, 'Cross-section');
xlabel(ax, 'x [um]');
ylabel(ax, 'y [um]');
colormap(ax, flipud(parula));
c = colorbar(ax);
c.Label.String = 'Charge threshold [nC]';

end
