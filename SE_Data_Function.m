function [DataStructure] = SE_Data_Function(Excel_Path,Desired_Exp_Data,DataStructure)

for unique_experiment = 1:size(unique(Desired_Exp_Data.Exp_Name,'stable'),1)
    %% Import PlateMap
    [~, ~, PlateMap] = xlsread(char(Desired_Exp_Data.Plate_Map(1)),char(Desired_Exp_Data.Sheet(1)),char(Desired_Exp_Data.Range(1))); %Stores platemap variables for current unique experiment.
    PlateMap = string(PlateMap);
    PlateMap(ismissing(PlateMap)) = '';
    %%
    
    %% Import Drugs
    [~, ~, Drugs] = xlsread(char(Desired_Exp_Data.Plate_Map(1)),char(Desired_Exp_Data.Sheet2(1))); %Stores platemap variables for current unique experiment.
    Drugs = string(Drugs);
    Drugs(ismissing(Drugs)) = '';
    unique_Control = Drugs(contains(Drugs(:,2),'Control'),1);
    unique_Treatments = Drugs(contains(Drugs(:,2),'Treatment'),1);
    %%
    
    %% Extracts Unique Drugs from PlateMap
    PlateMap_uniDrugs = unique(PlateMap,'stable');
    temp_Drug = cell(size(PlateMap_uniDrugs,1)*size(PlateMap_uniDrugs,2),1)
    temp_Co_Drug = cell(size(PlateMap_uniDrugs,1)*size(PlateMap_uniDrugs,2),1)
    RegEx = '(\d+\s\w+\s\w+|\d+.\d+\s\w+\s\w+|\w+)\s[+]\s(\d+\s\w+/\w+\s\w+|\w+\s\w+)';
    Tokens2 = regexp(PlateMap_uniDrugs,RegEx,'tokens');
    for tok2 = 1:size(Tokens2,1)
        temp_Drug(tok2,1) = cellstr(Tokens2{tok2,1}{1,1}{1,1});
        temp_Co_Drug(tok2,1) = cellstr(Tokens2{tok2,1}{1,1}{1,2});
    end
    Unique_Drug = unique(temp_Drug, 'stable');
    Unique_Co_Drug = unique(temp_Co_Drug,'stable');
    %%
    
    Temp_Data = Desired_Exp_Data(contains(Desired_Exp_Data.Exp_Name,Desired_Exp_Data.Exp_Name(unique_experiment)),:);
    
    FieldName = ['Dataset_' cell2mat(Desired_Exp_Data.Exp_Name(unique_experiment))];
    for cw_Time_Point = 1:nnz(contains(Desired_Exp_Data.PathToDataset,Desired_Exp_Data.Exp_Name(unique_experiment)))
        
        path = Temp_Data.PathToDataset(cw_Time_Point); File = 'ResultTable.mat'; load ([char(path) '\' File]); %Loading ResultTable data.
        
        chDNA=1; chGEM = 2; chSE=3;
        uniWells = unique(ResultTable(:,{'Row','Column'}));

        ResultTable.lGem = mylog(ResultTable.NInt(:,chGEM));
        ResultTable.EG1=zeros(size(ResultTable.lGem));ResultTable.LG1=zeros(size(ResultTable.lGem));ResultTable.G1S=zeros(size(ResultTable.lGem));
        ResultTable.S=zeros(size(ResultTable.lGem));ResultTable.G2=zeros(size(ResultTable.lGem));
        ResultTable.Reject=zeros(size(ResultTable.lGem));
        ResultTable.numinfield=zeros(size(ResultTable.lGem));
    
        for kk = 1:size(uniWells,1)
            row = uniWells.Row(kk); col=uniWells.Column(kk);
            
            FCells = find(ResultTable.Row == row & ResultTable.Column == col); %All cells in well
            if length(FCells)<50
                continue
            end
            DNA = ResultTable.NInt(FCells,chDNA);
            lGem = ResultTable.lGem(FCells);
            [idxEG1,idxLG1,idxG1S,idxS,idxG2] = FindStages_VarGem(DNA,lGem,FieldName,'NOimage');
        
            ResultTable.EG1(FCells(idxEG1))=1;
            ResultTable.LG1(FCells(idxLG1))=1;
            ResultTable.G1S(FCells(idxG1S))=1;
            ResultTable.S(FCells(idxS))=1;
            ResultTable.G2(FCells(idxG2))=1;
            ResultTable.Reject(FCells(~(idxEG1|idxLG1|idxG1S|idxS|idxG2)))=1; %Discard cells that have abnormal DNA/geminin levels- probably dead or segmentation errors. We are also discarding mitotics here.
            keepers=FCells(ResultTable.Reject(FCells)==0);
            ResultTable.Keep=false(size(ResultTable.lGem)); ResultTable.Keep(keepers)=true;  
%             figure(1000);hold on;plot(DNA(logical(ResultTable.Reject(FCells))),lGem(logical(ResultTable.Reject(FCells))),'ko')
% %             figure(1);hold on;plot(DNA(ResultTable.Solidity(FCells)<0.9),lGem(ResultTable.Solidity(FCells)<0.9),'bo')
%             title(['R ' num2str(row) ', C ' num2str(col) ' Keep ' num2str(length(keepers)) ' of ' num2str(length(DNA))])

            [DataStructure] = SE_Data_Collection(row,col,keepers,ResultTable,DataStructure,FieldName);

        end
        if size(DataStructure.('SE').(FieldName).Numcells,2) ~= 11
            DataStructure.('SE').(FieldName).Numcells(1,11) = double(0)
        end
        save('DataStructure.mat', 'DataStructure')
        
        SE_Plotting(FieldName,Unique_Drug,Unique_Co_Drug,PlateMap,unique_Control,unique_Treatments,Excel_Path,DataStructure)
        
    end % cw_Time_Point end
%     clearvars FieldName Cells
    
end % unique_experiment end
end % Function end