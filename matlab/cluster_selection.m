function [x, y] = cluster_selection()

xC = mean(xlim);
yC = mean(ylim);
h = [text(0.05, 1, 'Align for calibration.', 'Units', 'normalized', 'FontWeight', 'bold'), ...
    xline(xC), yline(yC)];
[x0, y0] = ginput(1);  % Calibration
delete(h);
h = text(0.05, 1, 'Select center of Ia and Ib fibers', 'Units', 'normalized', 'FontWeight', 'bold');
drawnow;
[x, y] = ginput(2);
delete(h);
x = x - x0 + xC;
y = y - y0 + yC;

end

