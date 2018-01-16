function [DataStructure] = Coulter_Data_Function(Excel_Path,Desired_Exp_Data,DataStructure)
Total_uniExp = unique(Desired_Exp_Data.Exp_Name,'stable');

for unique_experiment = 1:size(Total_uniExp,1)
    
    TempData = Desired_Exp_Data(contains(Desired_Exp_Data.Exp_Name,Total_uniExp(unique_experiment))&contains(Desired_Exp_Data.Experiment_Type,'Coulter'),:); %Stores only relevant data for current loop analysis.
    Date = TempData.Date;
    CoulterData = readtable(char(TempData.PathToDataset));
    uniCellTypes = unique(CoulterData.CellType_Expression_KO_KD,'stable');
    uniTreatments = unique(CoulterData.Treatment,'stable');
    Time_Points = unique(CoulterData.TimePoint,'stable');
    %% Exponential Plots
    if size(uniCellTypes,1) > 5
        subplot_row = 2;
        subplot_col = 5;
    else
        subplot_row = 1;
        subplot_col = size(uniCellTypes,1);
    end
    fig = figure();counter = 0;Non_Avg_CellNum = table();idx=1;
    for uniCell = 1:size(uniCellTypes,1)
        %         Non_Avg_CellNum.Properties.VariableNames = 'CellType';
        counter = counter+1;
        subplot(subplot_row,subplot_col,counter);hold on;count = 1;
        for uniTreat = 1:size(uniTreatments,1)
            Non_Avg_CellNum.CellType(idx,1)=(uniCellTypes(uniCell));
            Non_Avg_CellNum.Treatment(idx,1) = uniTreatments(uniTreat);
            x = unique(CoulterData.TimePoint(contains(CoulterData.CellType_Expression_KO_KD,uniCellTypes(uniCell))...
                &contains(CoulterData.Treatment,uniTreatments(uniTreat))),'stable');
            y = unique(CoulterData.CellNumber(contains(CoulterData.CellType_Expression_KO_KD,uniCellTypes(uniCell))...
                &contains(CoulterData.Treatment,uniTreatments(uniTreat))),'stable');
            for time = 1:size(x,1)
                Non_Avg_CellNum.(['TP_' num2str(x(time)) '_Hrs'])(idx,1) = y(time);
            end
            idx=idx+1;
            [curvefit,gof] = fit(x,y,'exp1');
            plot(x,y,'o');
            set(gca,'ColorOrderIndex',count)
            h2 = plot(curvefit,'--');
            set(get(get(h2,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
            count = count+1;
        end
        title(char(uniCellTypes(uniCell)))
    end
    hdle=findobj(gcf,'type','legend'); %Stores a handle for legend objects
    delete(hdle) %Deletes legend objects to prevent them from popping up
    legend(char(uniTreatments))
    suptitle(['Exponential Growth of ' char(join(uniCellTypes,' and '))])
    [ax1,h1]=suplabel('Cell Number','y');
    set(h1,'FontSize',15)
    [ax2,h2]=suplabel('Time(Hours)');
    set(h2,'FontSize',15)
    hold off;
    fileName = ['Exponential Growth of ' char(join(uniCellTypes,' and ')) ' cells ' char(Date) '.fig'];
    subfolder = 'Coulter Data\Exponetial Cell Number\';
    [Save_Path] = saveFigure(Excel_Path,fileName,subfolder,fig);
    clearvars fileName subfolder
    %%
    
    FieldName = ['Dataset_' cell2mat(Total_uniExp(unique_experiment))];
    DataStructure.('Coulter').(FieldName).('Non_Averaged_CellNumber') = Non_Avg_CellNum;
    
    %% -----------------------------------------Least Square Fit for Non Avg Data ----------------------------------------------------
    Non_Avg_Data_uniTreat = 1:size(Non_Avg_CellNum.Treatment,1);
    x = Time_Points;
    start = 0; last = 2;idx = 0; Non_Avg_Tau = table();
    for i = 1:size(Non_Avg_CellNum,1)
        y = log2(cell2mat(table2cell(Non_Avg_CellNum(i,3:size(Non_Avg_CellNum,2)))'));
        f = fittype('m*x + b');
        for y_set = 1:size(y,2)
            % Compare the effect of excluding the outliers with the effect of giving them lower bisquare weight in a robust fit.
            [fit3,gof3,fitinfo3] = fit(x,y(:,y_set),f,'StartPoint',[1 1],'Robust','on');
            m = coeffvalues(fit3);
            %         Non_Avg_Tau.Exp_Name(i+idx,1) = cellstr(Exp_Name);
            Non_Avg_Tau.CellType(i+idx,1) = cellstr(Non_Avg_CellNum.CellType(i+idx,1));
            Non_Avg_Tau.Treatment(i+idx,1) = (Non_Avg_CellNum.Treatment(Non_Avg_Data_uniTreat(i+idx),1));
            Non_Avg_Tau.Slope(i+idx,1) = num2cell(m(2));
            Non_Avg_Tau.SlopeInverse(i+idx,1) = num2cell(1/m(2));
            Non_Avg_Tau.RSQ(i+idx,1) = num2cell(gof3.rsquare);
            idx = idx+1;
        end
        idx = idx - 1;
        start = start+2;
        last = last+2;
    end
    DataStructure.('Coulter').(FieldName).('Non_Avg_Tau') = Non_Avg_Tau;
    save('DataStructure.mat', 'DataStructure')
    
    row = size(uniCellTypes,1); col = size(uniTreatments,1);
    temp = DataStructure.('Coulter').(FieldName).('Non_Avg_Tau');
    temp = sortrows(temp,{'Treatment'});
    Plate_Values = temp.SlopeInverse;
    num_text = cellstr(string(round(cell2mat(reshape(Plate_Values,[],col)))));
    Plate_Values = cell2mat(Plate_Values);
    Legend = reshape(strcat(temp.CellType, " + ", temp.Treatment),[],col);
    y_label = unique(temp.CellType,'stable');
    x_label = unique(temp.Treatment,'stable');
    % Plate_Values(Plate_Values<0) = NaN;
    % Plate_Values(Plate_Values>(1.7*min(Plate_Values(Plate_Values>0)))) = NaN;
    Plate_Values = num2cell(Plate_Values);
    fig = figure;microplateplot(cell2mat(reshape(Plate_Values,[],col)),'ROWLABELS',y_label,'COLUMNLABELS',x_label,'TEXTLABELS',num_text,'MissingValueColor',[0,0,0],'TextFontSize',8);colorbar
    colormap('cool')
    title([FieldName '_Non Avg Tau Microplate plot of ' char(join(uniCellTypes,' and ')) ' cells.'],'Interpreter', 'none')
    
    fileName = [FieldName '_Non Avg Tau Microplate plot of ' char(join(uniCellTypes,' and ')) ' cells' '.fig'];
    subfolder = 'Coulter Data\Tau Microplate Plots\';
    [Save_Path] = saveFigure(Excel_Path,fileName,subfolder,fig);
    clearvars fileName subfolder
    
    
    clearvars i temp
    %% -------------------------------------------------------------------------------------------------------------------------------
    
end %End of Unique_Experiment
end %End of Function