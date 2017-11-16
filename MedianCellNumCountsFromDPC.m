clear
parpool
tic
warning off

[Excel_File,Excel_Path,Filer_Index] = uigetfile('*.xlsx','Select the Excel Data File'); %Prompts user for the excel file that contains their data.
data = readtable([char(Excel_Path) char(Excel_File)]); %Reads excel file and stores information as a table variable.
Total_uniExp = unique(data.Exp_Name,'stable'); %Stores unique experiments, preserving the order.
[uniExp,uniExp_Ok] = listdlg('PromptString','Select which experiments you wish to analyze.','SelectionMode','multiple','ListString',Total_uniExp,'ListSize',[300 200],'CancelString','None'); %Prompts user what plots they want
Temp_Selected_Data = data(contains(data.Exp_Name,cellstr(Total_uniExp(uniExp))),:);
Total_uniImaging_Types = unique(Temp_Selected_Data.Imaging_Type,'stable');
[type_of_Img_Experiment,~] = listdlg('PromptString','Do you wish to analyze DPC images or SE images or both?','SelectionMode','multiple','ListString',Total_uniImaging_Types,'ListSize',[300 200],'CancelString','None');
Image_Analysis_Choice = Total_uniImaging_Types(type_of_Img_Experiment);
Desired_Exp = Total_uniExp(uniExp);
Desired_Exp_Data = Temp_Selected_Data(contains(Temp_Selected_Data.Exp_Name,Desired_Exp),:);

% Storage_Path = uigetdir(Excel_Path,'Select the Folder you wish to store the output files in'); %Prompts user for where they wish to store their output files.
% Tau_Total = table();

%% Determine if there is a previously stored DataStructure containing all user Data.
Known_Field_Names = ''; %Create empty storage variable for total known field names in DataStructure.
DataStructFile = java.io.File([pwd '\DataStructure.mat']); %Path name to DataStructure.m file.
if DataStructFile.exists() == 1 %If DataStructure.m file is in the path specified by DataStructFile, then if statement holds true.
    
    dlgTitle    = 'User Question'; dlgQuestion = 'Do you want to use and build on the previously used Data?'; choice = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'Yes'); %Prompts user if they want to continue using the old DataStructure File, or start a new DataStructure File. Default answer is yes.
    if string(choice) == string('No') %If user does not want to use the old DataStructure.
        dlgTitle    = 'User Question'; dlgQuestion = 'Do you want to delete the old Data and start anew?'; choice2 = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'Yes'); %Prompts user if they want to delete the old DataStructure.
        if string(choice2) == string('Yes')
            DataStructFile.delete %Deletes DataStructure.mat file
            FieldName = '';
            DataStructureTest = struct();
            for img_analysis_choice = 1:size(Image_Analysis_Choice,1)
                DataStructureTest.(char(Image_Analysis_Choice(img_analysis_choice))) = struct();
            end
        end
        FieldName = '';
        DataStructureTest = struct();
        for img_analysis_choice = 1:size(Image_Analysis_Choice,1)
            DataStructureTest.(char(Image_Analysis_Choice(img_analysis_choice))) = struct();
        end
    else
        load([pwd '\DataStructure.mat']) %Loads DataStructure.m file to workspace.
    end
else
    FieldName = '';
    DataStructureTest = struct();
    for img_analysis_choice = 1:size(Image_Analysis_Choice,1)
        DataStructureTest.(char(Image_Analysis_Choice(img_analysis_choice))) = struct();
    end
end
%%


if string(Image_Analysis_Choice) == string('SE')
    [DataStructure] = SE_Data_Function(Excel_Path,Desired_Exp_Data,DataStructure);
end

if string(Image_Analysis_Choice) == string('DPC')
    [DataStructure] = DPC_Data_Function(Excel_Path,Desired_Exp_Data,DataStructure)
    %     if isempty(uniExp) == 0
    %         for count = 1:size(Total_uniExp(uniExp),1)
    %             Non_Averaged_Data = table();
    %             Format_Data = table();
    %             TempData = data((contains(data.PathToDataset,Total_uniExp(uniExp(count)))|contains(data.Exp_Name,Total_uniExp(uniExp(count))))&contains(data.Imaging_Type,Image_Analysis_Choice),:); %Stores only relevant data for current loop analysis.
    %             %% Import PlateMap
    %             [~, ~, PlateMap] = xlsread(char(TempData.Plate_Map(1)),char(TempData.Sheet(1)),char(TempData.Range(1))); %Stores platemap variables for current unique experiment.
    %             PlateMap = string(PlateMap);
    %             PlateMap(ismissing(PlateMap)) = '';
    %             %%
    %
    %             %% Import Drugs
    %             [~, ~, Drugs] = xlsread(char(TempData.Plate_Map(1)),char(TempData.Sheet2(1))); %Stores platemap variables for current unique experiment.
    %             Drugs = string(Drugs);
    %             Drugs =  Drugs(~ismissing(Drugs)==1);
    %             Drugs = reshape(Drugs, [(size(Drugs,1)/2) 2])
    %             %             Drugs = rmmissing(Drugs)
    %             unique_Control = Drugs(contains(Drugs(:,2),'Control'),1);
    %             if isempty(unique_Control)
    %                 unique_Control = 'No Control';
    %             end
    %             unique_Treatments = Drugs(contains(Drugs(:,2),'Treatment'),1);
    %             %%
    %             Known_Field_Names = fieldnames(DataStructure.(char(Image_Analysis_Choice)));
    %             if any(contains(Known_Field_Names, Total_uniExp(uniExp(count)))) ~= 1 || DataStructFile.exists() == 1
    %                 % For loop to loop over data in TempData for curent unique experiment.
    %                 for cw_Time_Point = 1:nnz(contains(TempData.PathToDataset,Total_uniExp(uniExp(count))))
    %                     path = TempData.PathToDataset(cw_Time_Point); File = 'ResultTable.mat'; load ([char(path) '\' File]); %Loading ResultTable data.
    %                     uniWells = unique(ResultTable(:,{'Row','Column'}));
    %                     uniWells.Treatment = reshape(PlateMap.',[60,1]);
    %                     Num = zeros(size(uniWells,1),1);
    %
    %                     % loop over all wells
    %                     for well = 1:size(uniWells,1)
    %                         row = uniWells.Row(well); col=uniWells.Column(well);
    %                         Num(well) = sum(ResultTable.Row==row&ResultTable.Column==col); % Total number of cells per well
    %                         uniWells.CellCount(well) = Num(well);
    %                     end
    %
    %                     Time_Point = TempData.Time_Point(contains(TempData.Exp_Name,char(Total_uniExp(uniExp(count)))));
    %                     uniWells = sortrows(uniWells, 2);
    %
    %                     Non_Averaged_Data(:,1) = cellstr(uniWells.Treatment(1:60,:));
    %                     Non_Averaged_Data.Properties.VariableNames{1} = 'Treatment';
    %                     Non_Averaged_Data(:,cw_Time_Point+1) = cell2table(num2cell(uniWells.CellCount(:,1)));
    %                     Non_Averaged_Data.Properties.VariableNames{cw_Time_Point+1} = ['TP_' num2str(Time_Point(cw_Time_Point)) '_Hr'];
    %
    %                     Format_Data(:,1) = cellstr(unique(uniWells.Treatment(1:60,:),'stable'));
    %                     Format_Data.Properties.VariableNames{1} = 'Treatment';
    %                     MedianCellNum = cell(size(Format_Data,1),1)
    %                     for idx = 1:size(Format_Data.Treatment,1)
    %                         MedianCellNum{idx,1} = num2str((median(uniWells.CellCount(uniWells.Treatment(1:60)==Format_Data.Treatment(idx)))));
    %                     end
    %                     Format_Data(:,cw_Time_Point+1) = cell2table(MedianCellNum(:,1));
    %                     Format_Data.Properties.VariableNames{cw_Time_Point+1} = ['TP_' num2str(Time_Point(cw_Time_Point)) '_Hr'];
    %                 end
    %                 FieldName = ['Dataset_' cell2mat(Total_uniExp(uniExp(count)))];
    %                 DataStructure.('DPC').(FieldName).('Non_Averaged_CellNumber') = Non_Averaged_Data;
    %                 DataStructure.('DPC').(FieldName).('Averaged_CellNumber') = Format_Data;
    %                 clearvars uniTreat
    %             end
    %
    %             Exp_Name = char(unique(TempData.Exp_Name));
    %             ExpressionStr = unique(TempData.Expression,'stable');
    %             ExpressionStr = strtrim(split(ExpressionStr,','));
    %             CellLine = char(unique(TempData.CellLine));
    %             Date = unique(string(TempData.Date));
    %             Non_Avg_Data_Input = DataStructure.('DPC').(FieldName).('Non_Averaged_CellNumber');
    %             Format_Data_Input = DataStructure.('DPC').(FieldName).('Averaged_CellNumber');
    %
    %             [Non_Avg_Tau,Avg_Tau,Unique_Drug,Unique_Co_Drug] = Plotting2(Exp_Name,ExpressionStr,CellLine,Date,Non_Avg_Data_Input,Format_Data_Input,Excel_Path);
    %             DataStructure.('DPC').(FieldName).('Non_Avg_Tau') = Non_Avg_Tau;
    %             DataStructure.('DPC').(FieldName).('Avg_Tau') = Avg_Tau;
    %
    %             save('DataStructure.mat', 'DataStructure')
    %             clearvars PlateMap
    %         end
    %     end
end
clearvars filename Prev_Tau_Count TempData

Output_Data = table();
TempData = table();


%% Obtaining all unique inducible expression
uniExpression = {};
for Field_Name = 1:size(Known_Field_Names,1)
    Inducible_Expression = unique(DataStructure.('DPC').(char(Known_Field_Names(Field_Name))).('Avg_Tau').Expression,'stable');
    if ~(ismember(Inducible_Expression,uniExpression))
        uniExpression {end+1,1} = char(Inducible_Expression);
    end
end
%%

%% OLD Grouping all Tau Data -------------------------------
% Prev_Tau_Count = 0;
% for Expression_Line = 1:size(uniExpression)

%     uniTreatments = unique(Tau_Total.Treatment(contains((Tau_Total.Expression),char(uniExpression(Expression_Line)))),'stable');
%     string(uniExpression(Expression_Line))
%     for Treatment = 1:size(uniTreatments)
%
%         medianTau = median(cell2mat(Tau_Total.Slope(strcmp((Tau_Total.Expression),char(uniExpression(Expression_Line)))...
%             & strcmp((Tau_Total.Treatment),char(uniTreatments(Treatment))),:)));
%         stdTau = std(cell2mat(Tau_Total.Slope(strcmp((Tau_Total.Expression),char(uniExpression(Expression_Line)))...
%             & strcmp((Tau_Total.Treatment),char(uniTreatments(Treatment))),:)));
%         TempData.Expression(Treatment,1) =  string(uniExpression(Expression_Line));
%         TempData.Treatment(Treatment,1) = uniTreatments(Treatment);
%         TempData.medianTau(Treatment,1) = medianTau;
%         TempData.stdTau(Treatment,1) = stdTau;
%     end
%     TempData;
%     Output_Data(Prev_Tau_Count+1:Prev_Tau_Count+size(TempData,1),:) = TempData;
%     Prev_Tau_Count = size(TempData,1) + Prev_Tau_Count;
% end
%
% toDelete = cell2mat(Tau_Total.Slope) < 0;
% Tau_Total(toDelete,:) = [];
% size(Tau_Total)
%%--------------------------------------------------------------

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

%% Scatter Plots For Tau
% ------------------------------------------------------ Scatter Tau -------------------------------------------------------------

for Expression = 1:size(uniExpression,1)
    
    Temp_Field_Names = Known_Field_Names((contains(Known_Field_Names,uniExpression(Expression),'IgnoreCase',true)));
    headers = {'Exp_Name' 'Expression' 'CellLine' 'Treatment' 'Slope' 'SlopeInverse' 'RSQ'};
    empty_data = cell(1,7);
    Tau_Total = cell2table(empty_data);
    Tau_Total.Properties.VariableNames = headers;
    start = 0;
    
    for Field_Name = 1:size(Temp_Field_Names,1)
        
        Temp_Data_Table = table();
        Temp_Data_Table = DataStructure.('DPC').(char(Temp_Field_Names(Field_Name))).('Avg_Tau');
        
        %         Tau_Total= cell2table(~,'VariableNames',Temp_Data_Table.Properties.VariableNames)
        %         if ~(ismember(Temp_Data_Table,Tau_Total))
        Tau_Total(start+1:start+size(Temp_Data_Table,1),:)  = Temp_Data_Table;
        %         end
        start = start+size(Temp_Data_Table,1);
    end
    
    Temp_Total_uniExp = unique(Tau_Total.Exp_Name((contains(cell(Tau_Total.Exp_Name),cellstr(uniExpression(Expression)),'IgnoreCase',true))));
    for drug = 1:size(unique_Treatments,1)
        fig = figure();hold on;
        count = 0;
        for experiment = 1:size(Temp_Total_uniExp)
            count = count +1;
            x = categorical(Tau_Total.Treatment((contains(cell(Tau_Total.Exp_Name),cellstr(Temp_Total_uniExp(experiment))))...
                &(contains(cell(Tau_Total.Treatment),cellstr(unique_Treatments(drug)))...
                |contains(cell(Tau_Total.Treatment),cellstr(unique_Control(1))))...
                & contains(cell(Tau_Total.Expression),cell(uniExpression(Expression)))));
            if isempty(x); continue; end
            x = reordercats(x,Tau_Total.Treatment((contains(cell(Tau_Total.Exp_Name),cellstr(Temp_Total_uniExp(experiment))))...
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
        legend (temp_legend,'Interpreter', 'none')
        ylabel('Cell Cycle (1/\tau) (cell/hour)');
        clearvars temp_legend
        % Saves Image
        idcs   = strfind(Excel_Path,'\');
        Save_Path = [Excel_Path(1:idcs(size(idcs,2)-1)) 'Graphs\DPC Data\Scatter Plots of Cell Cycle Length'];
        if exist(Save_Path, 'dir')~=7
            disp(string('Making Directory Graphs to store figures in.'))
            mkdir (Save_Path)
        end
        Save_Path_Name = [Save_Path '\' 'Cell Cycle Length for ' char((uniExpression(Expression))) ' ' char(unique_Treatments(drug)) '.fig'];
        saveas(fig,Save_Path_Name)
        %
        
    end
end
% --------------------------------------------------------------------------------------------------------------------------------
%%

%% MicroPlate Plots
% --------------------------------------- MicroPlate -----------------------------------------------------------------------------
idcs   = strfind(Excel_Path,'\'); % Gets indices for Excel Path based on every location of a '\'.
Save_Path = [Excel_Path(1:idcs(size(idcs,2)-1)) 'Graphs\DPC Data\Tau MicroPlate Plot'];
if exist(Save_Path, 'dir')~=7
    disp(string('Making Directory Graphs to store figures in.'))
    mkdir (Save_Path)
end
for field = 1:size(Known_Field_Names,1)
    current_field_name = char(Known_Field_Names(field));
    num_text = cellstr(string(round(cell2mat(reshape(DataStructure.('DPC').(current_field_name).('Non_Avg_Tau').SlopeInverse,[],10)))))
    fig = figure;microplateplot(cell2mat(reshape(DataStructure.('DPC').(current_field_name).('Non_Avg_Tau').SlopeInverse,[],10)),'TEXTLABELS',num_text,'TextFontSize',8);colorbar
    title([current_field_name ' Non Avg Tau'],'Interpreter', 'none')
    Save_Path_Name = [Save_Path '\' current_field_name ' Non Avg Tau' '.fig'];
    saveas(fig,Save_Path_Name)
    if size(DataStructure.('DPC').(FieldName).('Avg_Tau').Treatment,1) == 30
        Plate_Col = 10
    else
        Plate_Col = 3
    end
    num_text = cellstr(string(round(cell2mat(reshape(DataStructure.('DPC').(current_field_name).('Avg_Tau').SlopeInverse,[],Plate_Col)))))
    fig = figure;microplateplot(cell2mat(reshape(DataStructure.('DPC').(current_field_name).('Avg_Tau').SlopeInverse,[],Plate_Col)),'TEXTLABELS',num_text,'TextFontSize',8);colorbar
    title([current_field_name ' Avg Tau'],'Interpreter', 'none')
    Save_Path_Name = [Save_Path '\' current_field_name ' Avg Tau' '.fig'];
    saveas(fig,Save_Path_Name)
end
% --------------------------------------------------------------------------------------------------------------------------------
%%

% Cell Cycle Vs. Protein Mass
no = 0
if no == 1
    CC_Reshape = cell(7,11)
    CC_Reshape(2:7,2:11) = reshape(DataStructure.DPC.Dataset_20171003_P27.Non_Avg_Tau.SlopeInverse,[],10)
    P_Mass_Median = cell(7,11)
    if size(DataStructure.SE.Dataset_20171003_P27.Paxis,2) ~= 11
        DataStructure.SE.Dataset_20171003_P27.Paxis(1,11) = num2cell(0)
    end
    for r = [2:7]
        for c = [2:11]
            if isempty(DataStructure.SE.Dataset_20171003_P27.Paxis{r,c})
                DataStructure.SE.Dataset_20171003_P27.Paxis{r,c} = (0)
            end
            P_Mass_Median(r,c) = num2cell(median(DataStructure.SE.Dataset_20171003_P27.Paxis{r,c}))
        end
    end
    shapes = {'o', 'x', '^', '+'};
    colour = {'k', 'r', 'g', 'c'};
    % l = {'DMSO1 + 1000 ng/mL doxycyclin','DMSO1 + 1000 ng/mL doxycyclin','DMSO1 + No doxycyclin',...
    %     'DMSO1 + No doxycyclin','5 uM SB203580 + 1000 ng/mL doxycyclin','5 uM SB203580 + 1000 ng/mL doxycyclin',...
    %     '5 uM SB203580 + No doxycyclin','5 uM SB203580 + No doxycyclin'};
    %     name = '5 uM SB'; h = 4;l = {'DMSO1 + 1000 ng/mL doxycyclin','DMSO1 + No doxycyclin','5 uM SB203580 + 1000 ng/mL doxycyclin','5 uM SB203580 + No doxycyclin'}
    %     name ='1 uM BIRB';h = 10;l = {'DMSO1 + 1000 ng/mL doxycyclin','DMSO1 + No doxycyclin','1 uM BIRB + 1000 ng/mL doxycyclin','1 uM BIRB + No doxycyclin'}
    name = '0.5 nM Bortezomib';h = 11;l = {'DMSO1 + 1000 ng/mL doxycyclin','DMSO1 + No doxycyclin','0.5 nM Bortezomib + 1000 ng/mL doxycyclin','0.5 nM Bortezomib + No doxycyclin'}
    figure(); hold on; s = 1; col = 1;count =1;
    for c = [2,h]
        for r = [2,6]
            if c==2 && r ==6
                s = s+1;col=col+1;
            end
            if c==h&&r==2
                s=s+1;col=col+1;
            end
            if c==h&&r==6
                s=s+1;col=col+1;
            end
            x = CC_Reshape{r,c}; y = P_Mass_Median{r,c};
            x2 = CC_Reshape{r+1,c};y2 = P_Mass_Median{r+1,c};
            scp1 = scatter(x,y,50,char(shapes(s)),char(colour(col)));
            scp2 =  scatter(x2,y2,50,char(shapes(s)),char(colour(col)));
            %         set(get(get(scp2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
            hasbehavior(scp2,'legend',false)
            count =count+1;
        end
    end
    title(['RPE1 p27 Drug: ' name '_Dataset_20171003']); ylabel('Protein Mass');xlabel('Cell Cycle Length (Hours)');legend(l)
    
end
system('taskkill /F /IM EXCEL.EXE');
delete(gcp('nocreate')) %Shuts down parrallel pool
toc
% clear