% This function is used to save figures.
function [Save_Path] = saveFigure(Excel_Path,filename,subfolder,fig)
idcs   = strfind(Excel_Path,'\'); %Get indices of Excel_Path string, based on every word between a '\'
Save_Path = [Excel_Path(1:idcs(size(idcs,2)-1)) 'Graphs\' subfolder];
if exist(Save_Path, 'dir')~=7
    disp(string('Making Directory Graphs to store figures in.'))
    mkdir (Save_Path)
end
Save_Path_Name = [Save_Path filename];
saveas(fig,Save_Path_Name)
end