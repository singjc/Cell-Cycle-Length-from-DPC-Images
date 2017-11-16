function [DataStructure] = DPC_Data_Function(Excel_Path,Desired_Exp_Data,DataStructure)
if isempty(uniExp) == 0
    for unique_experiment = 1:size(unique(Desired_Exp_Data.Exp_Name,'stable'),1)
        Non_Averaged_Data = table();
        Format_Data = table();
        TempData = Desired_Exp_Data((contains(Desired_Exp_Data.PathToDataset,Total_uniExp(uniExp(unique_experiment)))|contains(Desired_Exp_Data.Exp_Name,Total_uniExp(uniExp(unique_experiment))))&contains(Desired_Exp_Data.Imaging_Type,Image_Analysis_Choice),:); %Stores only relevant data for current loop analysis.
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
        if any(contains(Known_Field_Names, Total_uniExp(uniExp(unique_experiment)))) ~= 1 || DataStructFile.exists() == 1
            % For loop to loop over data in TempData for curent unique experiment.
            for cw_Time_Point = 1:nnz(contains(TempData.PathToDataset,Total_uniExp(uniExp(unique_experiment))))
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
                
                Time_Point = TempData.Time_Point(contains(TempData.Exp_Name,char(Total_uniExp(uniExp(unique_experiment))))); %Extracts time points used in experiment.
                uniWells = sortrows(uniWells, 2); %Sorts uniWells based on column
                
                Non_Averaged_Data(:,1) = cellstr(uniWells.Treatment(1:60,:));
                Non_Averaged_Data.Properties.VariableNames{1} = 'Treatment';
                Non_Averaged_Data(:,cw_Time_Point+1) = cell2table(num2cell(uniWells.CellCount(:,1)));
                Non_Averaged_Data.Properties.VariableNames{cw_Time_Point+1} = ['TP_' num2str(Time_Point(cw_Time_Point)) '_Hr'];
                
                Format_Data(:,1) = cellstr(unique(uniWells.Treatment(1:60,:),'stable'));
                Format_Data.Properties.VariableNames{1} = 'Treatment';
                MedianCellNum = cell(size(Format_Data,1),1)
                for idx = 1:size(Format_Data.Treatment,1)
                    MedianCellNum{idx,1} = num2str((median(uniWells.CellCount(uniWells.Treatment(1:60)==Format_Data.Treatment(idx)))));
                end
                Format_Data(:,cw_Time_Point+1) = cell2table(MedianCellNum(:,1));
                Format_Data.Properties.VariableNames{cw_Time_Point+1} = ['TP_' num2str(Time_Point(cw_Time_Point)) '_Hr'];
            end
            FieldName = ['Dataset_' cell2mat(Total_uniExp(uniExp(unique_experiment)))];
            DataStructure.('DPC').(FieldName).('Non_Averaged_CellNumber') = Non_Averaged_Data;
            DataStructure.('DPC').(FieldName).('Averaged_CellNumber') = Format_Data;
            clearvars uniTreat
        end
        
        Exp_Name = char(unique(TempData.Exp_Name));
        ExpressionStr = unique(TempData.Expression,'stable');
        ExpressionStr = strtrim(split(ExpressionStr,','));
        CellLine = char(unique(TempData.CellLine));
        Date = unique(string(TempData.Date));
        Non_Avg_Data_Input = DataStructure.('DPC').(FieldName).('Non_Averaged_CellNumber');
        Format_Data_Input = DataStructure.('DPC').(FieldName).('Averaged_CellNumber');
        
        [Non_Avg_Tau,Avg_Tau,Unique_Drug,Unique_Co_Drug] = DPC_Plotting(Exp_Name,ExpressionStr,CellLine,Date,Non_Avg_Data_Input,Format_Data_Input,Excel_Path);
        DataStructure.('DPC').(FieldName).('Non_Avg_Tau') = Non_Avg_Tau;
        DataStructure.('DPC').(FieldName).('Avg_Tau') = Avg_Tau;
        
        save('DataStructure.mat', 'DataStructure')
        clearvars PlateMap
    end
end