clear
parpool
tic
warning off

[Excel_File,Excel_Path,Filer_Index] = uigetfile('C:\*.xlsx','Select the Excel Data File'); %Prompts user for the excel file that contains their data.
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
            DataStructure = struct();
            for img_analysis_choice = 1:size(Image_Analysis_Choice,1)
                DataStructure.(char(Image_Analysis_Choice(img_analysis_choice))) = struct();
            end
        end
        FieldName = '';
        DataStructure = struct();
        for img_analysis_choice = 1:size(Image_Analysis_Choice,1)
            DataStructure.(char(Image_Analysis_Choice(img_analysis_choice))) = struct();
        end
    else
        load([pwd '\DataStructure.mat']) %Loads DataStructure.m file to workspace.
        Known_Field_Names = fieldnames(DataStructure);
    end
else
    FieldName = '';
    DataStructure = struct();
    for img_analysis_choice = 1:size(Image_Analysis_Choice,1)
        DataStructure.(char(Image_Analysis_Choice(img_analysis_choice))) = struct();
    end
end
%%

if contains(fieldnames(DataStructure),'Expressions')==0
    DataStructure.('Expressions') = {};
end

if any(contains(Image_Analysis_Choice,string('DPC')))
    [DataStructure] = DPC_Data_Function(Excel_Path,Desired_Exp_Data,DataStructure,Image_Analysis_Choice);
end

if any(contains(Image_Analysis_Choice,string('SE')))
    [DataStructure] = SE_Data_Function(Excel_Path,Desired_Exp_Data,DataStructure);
end

clearvars filename Prev_Tau_Count TempData

% Output_Data = table();
% TempData = table();

%% Obtaining all unique inducible expression
uniExpression = DataStructure.('Expressions');
%%

%% Scatter Plots For Tau
% ------------------------------------------------------ Scatter Tau -------------------------------------------------------------
no = 0;
if no == 1
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
end
% --------------------------------------------------------------------------------------------------------------------------------
%%

%% Cell Cycle Vs. Protein Mass
no = 0;
if no == 1
    CC_Reshape = cell(7,11);
    CC_Reshape(2:7,2:11) = reshape(DataStructure.DPC.Dataset_20171003_P27.Non_Avg_Tau.SlopeInverse,[],10);
    P_Mass_Median = cell(7,11);
    if size(DataStructure.SE.Dataset_20171003_P27.Paxis,2) ~= 11
        DataStructure.SE.Dataset_20171003_P27.Paxis(1,11) = num2cell(0);
    end
    for r = [2:7]
        for c = [2:11]
            if isempty(DataStructure.SE.Dataset_20171003_P27.Paxis{r,c})
                DataStructure.SE.Dataset_20171003_P27.Paxis{r,c} = (0);
            end
            P_Mass_Median(r,c) = num2cell(median(DataStructure.SE.Dataset_20171003_P27.Paxis{r,c}));
        end
    end
    shapes = {'o', 'x', '^', '+'};
    colour = {'k', 'r', 'g', 'c'};
    % l = {'DMSO1 + 1000 ng/mL doxycyclin','DMSO1 + 1000 ng/mL doxycyclin','DMSO1 + No doxycyclin',...
    %     'DMSO1 + No doxycyclin','5 uM SB203580 + 1000 ng/mL doxycyclin','5 uM SB203580 + 1000 ng/mL doxycyclin',...
    %     '5 uM SB203580 + No doxycyclin','5 uM SB203580 + No doxycyclin'};
    %     name = '5 uM SB'; h = 4;l = {'DMSO1 + 1000 ng/mL doxycyclin','DMSO1 + No doxycyclin','5 uM SB203580 + 1000 ng/mL doxycyclin','5 uM SB203580 + No doxycyclin'};
    %     name ='1 uM BIRB';h = 10;l = {'DMSO1 + 1000 ng/mL doxycyclin','DMSO1 + No doxycyclin','1 uM BIRB + 1000 ng/mL doxycyclin','1 uM BIRB + No doxycyclin'};
    name = '0.5 nM Bortezomib';h = 11;l = {'DMSO1 + 1000 ng/mL doxycyclin','DMSO1 + No doxycyclin','0.5 nM Bortezomib + 1000 ng/mL doxycyclin','0.5 nM Bortezomib + No doxycyclin'};
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
%
%%

%% Graphing Variation between experiments and treatments
DPC_Known_Field_Names = fieldnames(DataStructure.('DPC'));
for Expression = 1:size(uniExpression,1)
    
    Temp_Field_Names = DPC_Known_Field_Names((contains(DPC_Known_Field_Names,uniExpression(Expression),'IgnoreCase',true)));
    headers = {'Exp_Name' 'Expression' 'CellLine' 'Treatment' 'Slope' 'SlopeInverse' 'RSQ' 'Normalized'};
    empty_data = cell(1,8);
    Tau_Total = cell2table(empty_data);
    Tau_Total.Properties.VariableNames = headers;
    
    for Field_Name = 1:size(Temp_Field_Names,1)
        Temp_Data_Table = table();
        Temp_Data_Table = DataStructure.('DPC').(char(Temp_Field_Names(Field_Name))).('Non_Avg_Tau');
        Tau_Total  = [Tau_Total;Temp_Data_Table];
    end
    Tau_Total(1,:) = [];
    Tau_Total(cell2mat(Tau_Total.SlopeInverse)<0,:) = [];
    percntiles = prctile(cell2mat(Tau_Total.SlopeInverse),[5 80]); %5th and 95th percentile
    outlierIndex = cell2mat(Tau_Total.SlopeInverse) < percntiles(1) | cell2mat(Tau_Total.SlopeInverse) > percntiles(2);
    Tau_Total(outlierIndex,:) = [];
    
    Unique_Experiments = unique(Tau_Total.Exp_Name,'stable');
    
    for idx = 1:size(Unique_Experiments,1)
        fig = figure(); hold on;
        x = categorical(Tau_Total.Treatment(contains(Tau_Total.Exp_Name,Unique_Experiments(idx))));
        x = reordercats(x,unique(Tau_Total.Treatment(contains(Tau_Total.Exp_Name,Unique_Experiments(idx))),'stable'));
        y = cell2mat(Tau_Total.Normalized(contains(Tau_Total.Exp_Name,Unique_Experiments(idx))));
        
        for x_Set = 1:size(x,1)
            scatter(x(x_Set),y(x_Set))
            % Resets Color
            ax = gca; ax.ColorOrderIndex = 1;
        end
        grid on
        y_med = zeros(size(Tau_Total.Exp_Name(contains(Tau_Total.Exp_Name,Unique_Experiments(idx))),1),1);
        y_med(:,1) = median(cell2mat(Tau_Total.Normalized(contains(Tau_Total.Treatment,'DMSO')|contains(Tau_Total.Treatment,uniExpression(Expression)) ...
            & contains(Tau_Total.Treatment,'No doxycyclin')& contains(Tau_Total.Exp_Name,Unique_Experiments(idx)))));
        line(x,double(y_med),'Color','red','LineStyle','--')
        title(Unique_Experiments(idx),'Interpreter', 'none')
        hold off;
        subfolder = 'Individual_Experiment_Variation Data\';
        filename = ['Normalized Cell Cycle Experiment Variation for ' char(uniExpression(Expression)) ' RPE1, Experiment_ ' char(Unique_Experiments(idx))];
        saveFigure(Excel_Path,filename,subfolder,fig)
    end
    
    clearvars x y
    
    Unique_Treatments = unique(Tau_Total.Treatment,'stable');
    Control = Unique_Treatments(contains(Unique_Treatments,'DMSO'));
    Unique_Treatments(contains(Unique_Treatments,'DMSO')) = [];
    
    RegEx = '\d+\s[mun]M\s(\w*)\s[+]\s\d+\s[mun]g/mL\s\w*|\d+\s[mun]M\s(\w*)\s[+]\sNo\s\w*|\d+.\d+\s[mun]M\s(\w*)\s[+]\s\d+\s[mun]g/mL\s\w*';
    [Tokens,Match] = regexp(Unique_Treatments,RegEx,'tokens','match');
    
    uni_Drugs = cell(size(Tokens,1),1);
    for tok2 = 1:size(Tokens,1)
        uni_Drugs(tok2,1) = cellstr(Tokens{tok2,1}{1,1});
    end
    uni_Drugs = unique(uni_Drugs,'stable');
    
    for drug = 1:size(uni_Drugs,1)
        fig = figure(); hold on; coloridx = 1;
        for experiment = 1:size(Unique_Experiments,1)
            x = categorical(Tau_Total.Treatment(contains(Tau_Total.Treatment,uni_Drugs(drug))&contains(Tau_Total.Exp_Name,Unique_Experiments(experiment))|contains(Tau_Total.Treatment,'DMSO')...
                &contains(Tau_Total.Exp_Name,Unique_Experiments(experiment))));
            x = reordercats(x,unique(Tau_Total.Treatment(contains(Tau_Total.Treatment,uni_Drugs(drug))&contains(Tau_Total.Exp_Name,Unique_Experiments(experiment))|contains(Tau_Total.Treatment,'DMSO')...
                &contains(Tau_Total.Exp_Name,Unique_Experiments(experiment))),'stable'));
            y = cell2mat(Tau_Total.Normalized(contains(Tau_Total.Treatment,uni_Drugs(drug))&contains(Tau_Total.Exp_Name,Unique_Experiments(experiment))|contains(Tau_Total.Treatment,'DMSO')...
                &contains(Tau_Total.Exp_Name,Unique_Experiments(experiment))));
            
            for kk = 1:size(x,1)
                ax = gca; ax.ColorOrderIndex = coloridx; %Sets current color to plot
                x_set = categorical(x(kk));
                y_set = (y(kk));
                if contains(string(x_set),'1000 ng/mL doxycyclin')
                    sp_size = 100
                elseif contains(string(x_set),'100 ng/mL doxycyclin')
                    sp_size = 50
                elseif contains(string(x_set),'No doxycyclin')
                    sp_size = 25
                end
                sph = scatter(x_set,y_set)
                
            end % end of for loop
            coloridx=coloridx+1; %increase colour id count to change the colour for the next unique experiment
        end
        %         lh = legend(Unique_Experiments(experiment))
        grid on;title(['Normalized Cell Cycle Experiment Variation for ' char(uniExpression(Expression)) ' RPE1, Drug_ ' char(uni_Drugs(drug))]);
        hold off;
        
        subfolder = 'Grouped_Experiment_Variation Data\';
        filename = ['Normalized Cell Cycle Experiment Variation for ' char(uniExpression(Expression)) ' RPE1, Drug_ ' char(uni_Drugs(drug))]
        saveFigure(Excel_Path,filename,subfolder,fig)
        
        figHandle = figure();hold on;
        for experiment = 1:size(Unique_Experiments,1)
            
            plot(experiment, experiment)
            legHandle = legend(Unique_Experiments,'Interpreter', 'none')
        end
        idcs   = strfind(Excel_Path,'\');
        Save_Path = [Excel_Path(1:idcs(size(idcs,2)-1)) 'Graphs\Variation Data\'];
        if exist(Save_Path, 'dir')~=7
            disp(string('Making Directory Graphs to store figures in.'))
            mkdir (Save_Path)
        end
        fileName = [Save_Path 'Legend for ' char(uniExpression(Expression)) ', Drug_ ' char(uni_Drugs(drug))];
        fileType = 'png';
        saveLegendToImage(figHandle, legHandle, fileName, fileType)
    end
    
    clearvars x y
end
%%

%%
system('taskkill /F /IM EXCEL.EXE');
delete(gcp('nocreate')) %Shuts down parrallel pool
toc
