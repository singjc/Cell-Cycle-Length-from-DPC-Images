% Load DataStructure.mat
function SE_Plotting(FieldName,Unique_Drug,Unique_Co_Drug,PlateMap,unique_Control,unique_Treatments,Excel_Path,DataStructure)

% ------------------------- Cell Number MicroPltate Plots -----------------------------------------
idcs   = strfind(Excel_Path,'\'); % Gets indices for Excel Path based on every location of a '\'.
Save_Path = [Excel_Path(1:idcs(size(idcs,2)-1)) 'Graphs\SE Data\Cell Number MicroPlate Plot'];
if exist(Save_Path, 'dir')~=7
    disp(string('Making Directory Graphs to store figures in.'))
    mkdir (Save_Path)
end
fig = figure;microplateplot(DataStructure.('SE').(FieldName).Numcells(2:7,2:11));colorbar
title([FieldName ' Cell Number'],'Interpreter', 'none')
Save_Path_Name = [Save_Path '\' FieldName ' Cell Number MicroPlate Plot' '.fig'];
saveas(fig,Save_Path_Name)
% --------------------------------------------------------------------------------------------------



idc_Co_Drug_Hi_Conc = find((contains(PlateMap,Unique_Co_Drug(1,1))&contains(PlateMap,unique_Control)))+1;
idc_Co_Drug_Lo_Conc = find((contains(PlateMap,Unique_Co_Drug(3,1))&contains(PlateMap,unique_Control)))+1;
Drug_w_o_Control = Unique_Drug(contains(Unique_Drug,unique_Treatments))


if size(DataStructure.('SE').(FieldName).Paxis,2) ~= 11
    DataStructure.('SE').(FieldName).Paxis{1,11} = {}
end

% figure;microplateplot(DataStructure.SE.(DataName).MedProt(2:7,2:11))
fig = figure();position = 0;counter = 2;
for iter=1:size(Drug_w_o_Control,1)
    position = position+1;
    subplot(2,(size(Drug_w_o_Control,1)/2),position);hold on;
    
    plot(DataStructure.SE.(FieldName).Paxis{6,2},DataStructure.SE.(FieldName).Pdensity{6,2},'b')
    plot(DataStructure.SE.(FieldName).Paxis{7,2},DataStructure.SE.(FieldName).Pdensity{7,2},'b')
    
    plot(DataStructure.SE.(FieldName).Paxis{2,2},DataStructure.SE.(FieldName).Pdensity{2,2},'r')
    plot(DataStructure.SE.(FieldName).Paxis{3,2},DataStructure.SE.(FieldName).Pdensity{3,2},'r')
    if ~isempty(DataStructure.SE.(FieldName).Paxis{6,iter+counter})
        plot(DataStructure.SE.(FieldName).Paxis{6,iter+counter},DataStructure.SE.(FieldName).Pdensity{6,iter+counter},'k')
        plot(DataStructure.SE.(FieldName).Paxis{7,iter+counter},DataStructure.SE.(FieldName).Pdensity{7,iter+counter},'k')
        
        plot(DataStructure.SE.(FieldName).Paxis{2,iter+counter},DataStructure.SE.(FieldName).Pdensity{2,iter+counter},'g')
        plot(DataStructure.SE.(FieldName).Paxis{3,iter+counter},DataStructure.SE.(FieldName).Pdensity{3,iter+counter},'g')
    end
    title(Drug_w_o_Control(iter),'Interpreter', 'none')
    if (iter+counter) == 6
        counter = counter + 1;
    end
end
set(0,'DefaultTextInterpreter','none')
suptitle([FieldName ' Protein Mass'])
[ax1,h1]=suplabel('Protein Mass');
set(h1,'FontSize',15)
[ax2,h2]=suplabel('Density','y');
set(h2,'FontSize',15)

idcs   = strfind(Excel_Path,'\'); % Gets indices for Excel Path based on every location of a '\'.
Save_Path = [Excel_Path(1:idcs(size(idcs,2)-1)) 'Graphs\SE Data\Protein Mass vs Density Plots'];
if exist(Save_Path, 'dir')~=7
    disp(string('Making Directory Graphs to store figures in.'))
    mkdir (Save_Path)
end
Save_Path_Name = [Save_Path '\' FieldName ' Protein Mass vs Density Plots' '.fig'];
saveas(fig,Save_Path_Name)


end % end of function