clear
[Excel_File,Excel_Path,Filer_Index] = uigetfile('*.xlsx','Select the Excel Data File'); %Prompts user for the excel file that contains their data.
warning off
data = readtable([char(Excel_Path) char(Excel_File)]); %Reads excel file and stores information as a table variable.

Total_uniExp = unique(data.Exp_Name,'stable'); %Stores unique experiments, preserving the order.
[uniExp,uniExp_Ok] = listdlg('PromptString','Select which experiments you wish to analyze.','SelectionMode','multiple','ListString',Total_uniExp,'ListSize',[150 150]); %Prompts user what plots they want
% uniExp = num2cell(uniExp);
% Storage_Path = uigetdir(Excel_Path,'Select the Folder you wish to store the output files in'); %Prompts user for where they wish to store their output files.
Tau_Total = table();
Known_Field_Names = '';
DataStructFile = java.io.File([pwd '\DataStructure.mat']);
if DataStructFile.exists() == 1 %Matlab equivalent to exist
    load([pwd '\DataStructure.mat'])
    Known_Field_Names = fieldnames(DataStructure);
    dlgTitle    = 'User Question'; dlgQuestion = 'Do you want to use and build on the previously used Data?'; choice = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'Yes');
    if string(choice) == string('No')
        dlgTitle    = 'User Question'; dlgQuestion = 'Do you want to delete the old Data and start anew?'; choice2 = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'Yes');
        if string(choice2) == string('Yes')
            DataStructFile.delete %Deletes DataStructure.mat file
            
        end
        
    end
    
end

for count = 1:size(Total_uniExp(uniExp),1)
    
    
    
    Format_Data = table();
    TempData = data(contains(data.PathToDataset,Total_uniExp(uniExp(count))),:); %Stores only relevant data for current loop analysis.
    
    
    %% Import PlateMap
    [~, ~, PlateMap] = xlsread(char(TempData.Plate_Map(1)),char(TempData.Sheet(1)),char(TempData.Range(1))); %Stores platemap variables for current unique experiment.
    PlateMap = string(PlateMap);
    PlateMap(ismissing(PlateMap)) = '';
    %%
    
    %% Import Drugs
    [~, ~, Drugs] = xlsread(char(TempData.Plate_Map(1)),char(TempData.Sheet2(1))); %Stores platemap variables for current unique experiment.
    Drugs = string(Drugs);
    Drugs(ismissing(Drugs)) = '';
    unique_Control = Drugs(contains(Drugs(:,2),'Control'),1);
    unique_Treatments = Drugs(contains(Drugs(:,2),'Treatment'),1);
    %%
    if any(contains(Known_Field_Names, Total_uniExp(uniExp(count)))) ~= 1 || DataStructFile.exists() == 1
        % For loop to loop over data in TempData for curent unique experiment.
        for cw_Time_Point = 1:nnz(contains(TempData.PathToDataset,Total_uniExp(uniExp(count))))
            path = TempData.PathToDataset(cw_Time_Point); File = 'ResultTable.mat'; load ([char(path) '\' File]); %Loading ResultTable data.
            uniWells = unique(ResultTable(:,{'Row','Column'}));
            uniWells.Treatment = reshape(PlateMap.',[60,1]);
            Num = zeros(size(uniWells,1),1);
            %         Table = table();
            % loop over all wells
            for i = 1:size(uniWells,1)
                row = uniWells.Row(i); col=uniWells.Column(i);
                Num(i) = sum(ResultTable.Row==row&ResultTable.Column==col); % Total number of cells per well
                uniWells.CellCount(i) = Num(i);
            end
%             filename = strcat(Storage_Path,'\','NewCellCountData_', char(Total_uniExp(uniExp(count))), '.xlsx');
            Time_Point = TempData.Time_Point(contains(TempData.Exp_Name,char(Total_uniExp(uniExp(count)))));
            uniWells = sortrows(uniWells, 2);
            
            NewData = table();
            NewData.Treatment(1:30,:) = unique(uniWells.Treatment(1:60,:),'stable');
            %         NewData.Treatment(16:30,:) = unique(uniWells.Treatment(31:60,:),'stable');
            
            %-------------------------------------------------------------------------------------------------------------
            
            Format_Data(:,1) = cellstr(unique(uniWells.Treatment(1:60,:),'stable'));
            Format_Data.Properties.VariableNames{1} = 'Treatment';
            for idx = 1:size(Format_Data.Treatment,1)
                MedianCellNum{idx,1} = num2str((median(uniWells.CellCount(uniWells.Treatment(1:60)==NewData.Treatment(idx)))));
            end
            Format_Data(:,cw_Time_Point+1) = cell2table(MedianCellNum(:,1));
            Format_Data.Properties.VariableNames{cw_Time_Point+1} = ['TP_' num2str(Time_Point(cw_Time_Point)) '_Hr'];
            
        end
        
        FieldName = ['Dataset_' cell2mat(Total_uniExp(uniExp(count)))];
        DataStructure.(FieldName).('CellNumber') = Format_Data;
        
        %     exist([pwd '\DataStructure.mat'],'file') %MatLab
        Format_Data;
        save('DataStructure.mat', 'DataStructure')
        Known_Field_Names = fieldnames(DataStructure);
        clearvars uniTreat
    end
    
    [yCalc3,Tau,Unique_Drug] = Plotting2(char(unique(TempData.Exp_Name)),char(unique(TempData.Expression))...
        ,char(unique(TempData.CellLine)),unique(string(TempData.Date)),DataStructure.(FieldName).('CellNumber'));
    
    Prev_Tau_Count = size(Tau_Total,1);
    Tau_Total(Prev_Tau_Count+1:Prev_Tau_Count+size(Tau,1),:) = Tau;
    
    %     writetable(Format_Data,filename,'sheet',1)
    Tau;
    clearvars PlateMap
end

clearvars filename Prev_Tau_Count TempData
% filename = strcat(Storage_Path,'\','Tau_Total', '.xlsx');
% writetable(Tau_Total,filename,'sheet',1)

Output_Data = table();
TempData = table();
uniExpression = unique(Tau_Total.Expression,'stable');

Prev_Tau_Count = 0;
for Expression_Line = 1:size(uniExpression)
    uniTreatments = unique(Tau_Total.Treatment(contains((Tau_Total.Expression),char(uniExpression(Expression_Line)))),'stable');
    string(uniExpression(Expression_Line))
    for Treatment = 1:size(uniTreatments)
        
        medianTau = median(cell2mat(Tau_Total.Slope(strcmp((Tau_Total.Expression),char(uniExpression(Expression_Line)))...
            & strcmp((Tau_Total.Treatment),char(uniTreatments(Treatment))),:)));
        stdTau = std(cell2mat(Tau_Total.Slope(strcmp((Tau_Total.Expression),char(uniExpression(Expression_Line)))...
            & strcmp((Tau_Total.Treatment),char(uniTreatments(Treatment))),:)));
        TempData.Expression(Treatment,1) =  string(uniExpression(Expression_Line));
        TempData.Treatment(Treatment,1) = uniTreatments(Treatment);
        TempData.medianTau(Treatment,1) = medianTau;
        TempData.stdTau(Treatment,1) = stdTau;
    end
    TempData;
    Output_Data(Prev_Tau_Count+1:Prev_Tau_Count+size(TempData,1),:) = TempData;
    Prev_Tau_Count = size(TempData,1) + Prev_Tau_Count;
end

toDelete = cell2mat(Tau_Total.Slope) < 0;
Tau_Total(toDelete,:) = [];
size(Tau_Total)

% for Expression_Line = 1:size(uniExpression)
%     figure(); hold on;
%     x = Tau_Total.Treatment(contains((Tau_Total.Expression),char(uniExpression(Expression_Line))));
%     y = cell2mat(Tau_Total.Slope(strcmp((Tau_Total.Expression),char(uniExpression(Expression_Line)))));
%     boxplot(y,x,'PlotStyle', 'traditional')
%     title(['Growth Rate of ' char(Tau_Total.CellLine(1)) ' ' char(uniExpression(Expression_Line))])
%     ylabel('Tau');
%     set(gca, 'XTickLabelRotation', -45);
%     hold off;
% end

%--------------------------------- Histogram of Tau--------------
% start = 1;
% for Exp = 1:size(Total_uniExp,1)
%     clearvars x y
% %    for start = 1:size(Tau_Total,1):3
%     figure(); hold on;
%     x = categorical(Tau_Total.Treatment(strcmp((Tau_Total.Exp_Name),char(Total_uniExp(Exp)))));
%     x = reordercats(x)
%     y = cell2mat(Tau_Total.SlopeInverse(strcmp((Tau_Total.Exp_Name),char(Total_uniExp(Exp)))));
% %     idx = [1:3 4:6 16:18] %Radicicol
% %     idx = [1:3 5:7 16:18] % SB203580
%       idx = [1:3 8:10 19:21] % BIRB
%     x = x(idx)
%     y = y(idx)
%     histogram('Categories', x, 'BinCounts', y);
%     title(['Growth Rate of ' char(Tau_Total.CellLine(1)) ' ' char(Total_uniExp(Exp))])
%     ylabel('Cell Cycle Length (1/\tau)');
%     set(gca, 'XTickLabelRotation', -45);
% %    end
%     hold off;
% end
%------------------------------------------------------------------

% --------------- Scatter Tau ---------------------------------

% for Expression = 1:size(uniExpression,1)
% for Exp = 1:size(Total_uniExp,1)
%     clearvars x y idx
%     temp_uniTreatments = unique(Tau_Total.Treatment(contains(cell(Tau_Total.Expression),cell(uniExpression(Expression)))),'stable');
%     for experiment = 1:size(uniExp,2)
%         for idx = 1:size(temp_uniTreatments,1)
%             x = categorical(temp_uniTreatments(idx))
%             y = cell2mat(Tau_Total.SlopeInverse(contains(cell(Tau_Total.Expression),cell(uniExpression(Expression)))...
%                 & contains(cell(Tau_Total.Treatment),cell(temp_uniTreatments(idx)))...
%                 & contains(cell(Tau_Total.Exp_Name),cell(Total_uniExp(experiment)))))
%
%             scatter(x,y)
%         end
%     end
% end
% end

for Expression = 1:size(uniExpression,1)
    Temp_Total_uniExp = unique(Tau_Total.Exp_Name((contains(cell(Tau_Total.Exp_Name),cellstr(uniExpression(Expression)),'IgnoreCase',true))));
    for drug = 1:size(unique_Treatments,1)
        figure();hold on;
        count = 0;
        for experiment = 1:size(Temp_Total_uniExp)
            count = count +1;
            x = categorical(Tau_Total.Treatment((contains(cell(Tau_Total.Exp_Name),cellstr(Temp_Total_uniExp(experiment))))...
                &(contains(cell(Tau_Total.Treatment),cellstr(unique_Treatments(drug)))...
                |contains(cell(Tau_Total.Treatment),cellstr(unique_Control(1))))...
                & contains(cell(Tau_Total.Expression),cell(uniExpression(Expression)))));
            y = cell2mat(Tau_Total.SlopeInverse((contains(cell(Tau_Total.Exp_Name),cellstr(Temp_Total_uniExp(experiment))))...
                &(contains(cell(Tau_Total.Treatment),cellstr(unique_Treatments(drug)))...
                |contains(cell(Tau_Total.Treatment),cellstr(unique_Control(1))))...
                & contains(cell(Tau_Total.Expression),cell(uniExpression(Expression)))));
            
            scatter(x,y)
            temp_legend(count,1) = unique((Tau_Total.Exp_Name((contains(cell(Tau_Total.Exp_Name),cellstr(Temp_Total_uniExp(experiment))))...
                &(contains(cell(Tau_Total.Treatment),cellstr(unique_Treatments(drug)))...
                |contains(cell(Tau_Total.Treatment),cellstr(unique_Control(1))))...
                & contains(cell(Tau_Total.Expression),cell(uniExpression(Expression))))), 'stable');
        end
        hold off;
        title(['Cell Cycle Length for ' char((uniExpression(Expression))) ' ' char(unique_Treatments(drug))])
        legend (temp_legend)
        ylabel('Cell Cycle Length (1/\tau)');
        clearvars temp_legend
    end
end
% --------------------------------------------------------------

system('taskkill /F /IM EXCEL.EXE');
% clear

