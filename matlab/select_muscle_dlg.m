function muscle = select_muscle_dlg()

med = 'Medial gastrocnemius';
lat = 'Lateral gastrocnemius';
answer = questdlg('Select muscle', 'Muscle selection', med, lat, med);
if strcmp(answer, med)
    muscle = 1;
else
    muscle = 2;
end

end

