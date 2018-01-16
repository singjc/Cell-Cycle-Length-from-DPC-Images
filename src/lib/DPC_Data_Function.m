function [DataStructure] = DPC_Data_Function(Excel_Path,Desired_Exp_Data,DataStructure,Image_Analysis_Choice)
Total_uniExp = unique(Desired_Exp_Data.Exp_Name,'stable');
for unique_experiment = 1:size(Total_uniExp,1)
    Non_Averaged_Data = table();
    Format_Data = table();
    TempData = Desired_Exp_Data(contains(Desired_Exp_Data.Exp_Name,Total_uniExp(unique_experiment))&contains(Desired_Exp_Data.Imaging_Type,'DPC'),:); %Stores only relevant data for current loop analysis.
    
    %% Import PlateMap
    [~, ~, PlateMap] = xlsread(char(TempData.Plate_Map(1)),char(TempData.Sheet(1)),char(TempData.Range(1))); %Stores platemap variables for current unique experiment.
    PlateMap = string(PlateMap);
    PlateMap(ismissing(PlateMap)) = '';
    %%
    
    %% Import Drugs
    [~, ~, Drugs] = xlsread(char(TempData.Plate_Map(1)),char(TempData.Sheet2(1))); %Stores platemap variables for current unique experiment.
    Drugs = string(Drugs);
    Drugs =  Drugs(~ismissing(Drugs)==1);
    Drugs = reshape(Drugs, [(size(Drugs,1)/2) 2]);
    %             Drugs = rmmissing(Drugs)
    unique_Control = Drugs(contains(Drugs(:,2),'Control'),1);
    if isempty(unique_Control)
        unique_Control = 'No Control';
    end
    unique_Treatments = Drugs(contains(Drugs(:,2),'Treatment'),1);
    %%
    Known_Field_Names = fieldnames(DataStructure.(char(Image_Analysis_Choice(contains(Image_Analysis_Choice,'DPC'))))); %Get known field names already in DataStructure.
    %     if any(contains(Known_Field_Names, Desired_Exp_Data.Exp_Name(unique_experiment))) ~= 1 || DataStructFile.exists() == 1
    % For loop to loop over data in TempData for curent unique experiment.
    for cw_Time_Point = 1:nnz(contains(TempData.Exp_Name,Total_uniExp(unique_experiment)))
        path = TempData.PathToDataset(cw_Time_Point); File = 'ResultTable.mat'; load ([char(path) '\' File]); %Loading ResultTable data.
        uniWells = unique(ResultTable(:,{'Row','Column'}));
        uniWells.Treatment = reshape(PlateMap.',[60,1]);
        Num = zeros(size(uniWells,1),1);
        
        % loop over all wells
        for well = 1:size(uniWells,1)
            row = uniWells.Row(well); col=uniWells.Column(well);
            Num(well) = sum(ResultTable.Row==row&ResultTable.Column==col); % Total number of cells per well
            uniWells.CellCount(well) = Num(well); %Append cell number at the particular well to the uniWells variable.
        end
        
        Time_Point = TempData.Time_Point(contains(TempData.Exp_Name,char(Total_uniExp(unique_experiment)))); %Extracts time points used in experiment.
        uniWells = sortrows(uniWells, 2); %Sorts uniWells based on column
        
        Non_Averaged_Data(:,1) = cellstr(uniWells.Treatment(1:60,:));
        Non_Averaged_Data.Properties.VariableNames{1} = 'Treatment';
        Non_Averaged_Data(:,cw_Time_Point+1) = cell2table(num2cell(uniWells.CellCount(:,1)));
        Non_Averaged_Data.Properties.VariableNames{cw_Time_Point+1} = ['TP_' num2str(Time_Point(cw_Time_Point)) '_Hr'];
        
        Format_Data(:,1) = cellstr(unique(uniWells.Treatment(1:60,:),'stable'));
        Format_Data.Properties.VariableNames{1} = 'Treatment';
        MedianCellNum = cell(size(Format_Data,1),1);
        for idx = 1:size(Format_Data.Treatment,1)
            MedianCellNum{idx,1} = num2str((median(uniWells.CellCount(uniWells.Treatment(1:60)==Format_Data.Treatment(idx)))));
        end
        Format_Data(:,cw_Time_Point+1) = cell2table(MedianCellNum(:,1));
        Format_Data.Properties.VariableNames{cw_Time_Point+1} = ['TP_' num2str(Time_Point(cw_Time_Point)) '_Hr'];
    end
    FieldName = ['Dataset_' cell2mat(Total_uniExp(unique_experiment))];
    DataStructure.('DPC').(FieldName).('Non_Averaged_CellNumber') = Non_Averaged_Data;
    DataStructure.('DPC').(FieldName).('Averaged_CellNumber') = Format_Data;
    clearvars uniTreat
    %     end
    
    Exp_Name = char(unique(TempData.Exp_Name));
    ExpressionStr = unique(TempData.Expression,'stable');
    ExpressionStr = strtrim(split(ExpressionStr,','));
    if isempty(DataStructure.('Expressions'))
        DataStructure.('Expressions') = ExpressionStr;
    elseif contains(DataStructure.('Expressions'),ExpressionStr)==0
        DataStructure.('Expressions') = ExpressionStr;
    end    
    CellLine = char(unique(TempData.CellLine));
    Date = unique(string(TempData.Date));
    Non_Avg_Data_Input = DataStructure.('DPC').(FieldName).('Non_Averaged_CellNumber');
    Format_Data_Input = DataStructure.('DPC').(FieldName).('Averaged_CellNumber');
    
    [Non_Avg_Tau,Avg_Tau,Unique_Drug,Unique_Co_Drug] = DPC_Plotting(Exp_Name,ExpressionStr,CellLine,Date,Non_Avg_Data_Input,Format_Data_Input,Excel_Path);
    DataStructure.('DPC').(FieldName).('Non_Avg_Tau') = Non_Avg_Tau;
    DataStructure.('DPC').(FieldName).('Avg_Tau') = Avg_Tau;
    
    save('DataStructure.mat', 'DataStructure')
    
    
    %% MicroPlate Plots
    % --------------------------------------- MicroPlate -----------------------------------------------------------------------------
    idcs   = strfind(Excel_Path,'\'); % Gets indices for Excel Path based on every location of a '\'.
    Save_Path = [Excel_Path(1:idcs(size(idcs,2)-1)) 'Graphs\DPC Data\Tau MicroPlate Plot'];
    if exist(Save_Path, 'dir')~=7
        disp(string('Making Directory Graphs to store figures in.'))
        mkdir (Save_Path)
    end
    
    Plate_Values = DataStructure.('DPC').(FieldName).('Non_Avg_Tau').SlopeInverse;
    num_text = cellstr(string(round(cell2mat(reshape(Plate_Values,[],10)))));
    Plate_Values = cell2mat(Plate_Values);
%     Plate_Values(Plate_Values<0) = NaN;
%     Plate_Values(Plate_Values>(1.7*min(Plate_Values(Plate_Values>0)))) = NaN;
    Plate_Values = num2cell(Plate_Values);
    fig = figure;microplateplot(cell2mat(reshape(Plate_Values,[],10)),'TEXTLABELS',num_text,'MissingValueColor',[0,0,0],'TextFontSize',8);colorbar
    colormap('cool')
    title([FieldName ' Non Avg Tau'],'Interpreter', 'none')
    Save_Path_Name = [Save_Path '\' FieldName ' Non Avg Tau' '.fig'];
    saveas(fig,Save_Path_Name)
    
    PlateMap_uniRow = unique(PlateMap,'rows','stable');
    uni_PlateMap = unique(PlateMap_uniRow,'stable');
    
    if size(reshape(PlateMap_uniRow,[],1),1)/2 == size(uni_PlateMap,1)
        Plate_Col = size(PlateMap_uniRow,2);
    elseif size(DataStructure.('DPC').(FieldName).('Avg_Tau').Treatment,1) == 30
        Plate_Col = 10; 
    elseif size(reshape(PlateMap_uniRow,[],1),1) == size(uni_PlateMap,1)
        Plate_Col = size(PlateMap_uniRow,2);
    else
        Plate_Col = size(DataStructure.('DPC').(FieldName).('Avg_Tau').Treatment,1);
    end
    Plate_Values = DataStructure.('DPC').(FieldName).('Avg_Tau').SlopeInverse;
    num_text = cellstr(string(round(cell2mat(reshape(Plate_Values,[],Plate_Col)))));
    Plate_Values = cell2mat(Plate_Values);
    Plate_Values(Plate_Values<0) = NaN; %Replace all negative values with NaN
    Plate_Values(Plate_Values>(1.7*min(Plate_Values(Plate_Values>0)))) = NaN; %Replace all values that are 1.7 times the min value
    Plate_Values = num2cell(Plate_Values);
    
    fig = figure;microplateplot((cell2mat(reshape(Plate_Values,[],Plate_Col))),'TEXTLABELS',num_text,'MissingValueColor',[0,0,0],'TextFontSize',8);colorbar
    colormap('cool')
    title([FieldName ' Avg Tau'],'Interpreter', 'none')
    Save_Path_Name = [Save_Path '\' FieldName ' Avg Tau' '.fig'];
    saveas(fig,Save_Path_Name)
    
    % --------------------------------------------------------------------------------------------------------------------------------
    clearvars PlateMap TempData
end
end