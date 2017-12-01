% Function to plot time-point DPC cell count data
function [Non_Avg_Tau,Avg_Tau,Unique_Drug,Unique_Co_Drug] = DPC_Plotting(Exp_Name,ExpressionStr,CellLine,Date,Non_Avg_Data_Input,Format_Data_Input,Excel_Path)
reshape_Expression = (reshape(ExpressionStr,[1 size(ExpressionStr,1)]));
%% Extracts Time Points
TP_Headers = Format_Data_Input.Properties.VariableNames(2:end)';
MatchExpression = 'TP_(\d+)_Hr';
Tokens = regexp(TP_Headers,MatchExpression,'tokens');
Time_Points = cell(size(Tokens,1),1);
for tok = 1:size(Tokens,1)
    Time_Points(tok,1) = Tokens{tok,1}{1,1};
end
%%

% [uniTreat ,~] = listdlg('PromptString','Select which Treatments you wish to analyze.','SelectionMode','multiple','ListString',Format_Data_Input.Treatment,'ListSize',[250 250]);
uniTreat = 1:size(Format_Data_Input.Treatment,1);
Non_Avg_Data_uniTreat = 1:size(Non_Avg_Data_Input.Treatment,1);
% dlgTitle    = 'User Question'; dlgQuestion = 'Do you wish to visualize via plots?'; choice = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'Yes');
choice = 'Yes';
%% Extracts Unique Drugs
Treats = Format_Data_Input.Treatment;
RegEx = '(\w+\s[+]\s\d+\s\w+\s\w+|\w+\s[+]\s\d+.\d+\s\w+\s\w+|\w+\s[+]\s\w+)\s[+]\s(\d+\s\w+/\w+\s\w+|\w+\s\w+)|(\d+\s\w+\s\w+|\d+.\d+\s\w+\s\w+|\w+)\s[+]\s(\d+\s\w+/\w+\s\w+|\w+\s\w+)';
Tokens2 = regexp(Treats,RegEx,'tokens');
temp_Drug = cell(size(Tokens2,1),1);
temp_Co_Drug = cell(size(Tokens2,1),1);
for tok2 = 1:size(Tokens2,1)
    Format_Data_Input.Drug1(tok2,1) = cellstr(Tokens2{tok2,1}{1,1}{1,1});
    temp_Drug(tok2,1) = cellstr(Tokens2{tok2,1}{1,1}{1,1});
    Format_Data_Input.Drug2(tok2,1) = cellstr(Tokens2{tok2,1}{1,1}{1,2});
    temp_Co_Drug(tok2,1) = cellstr(Tokens2{tok2,1}{1,1}{1,2});
end
Format_Data_Input = [Format_Data_Input.Treatment Format_Data_Input.Drug1 Format_Data_Input.Drug2 Format_Data_Input(:,2:size(Format_Data_Input,2)-2)];
Format_Data_Input.Properties.VariableNames{1} = 'Treatment';
Format_Data_Input.Properties.VariableNames{2} = 'Drug1';
Format_Data_Input.Properties.VariableNames{3} = 'Drug2';
Unique_Drug = unique(temp_Drug, 'stable');
Unique_Co_Drug = unique(temp_Co_Drug,'stable');
%%

%% Section for plotting growth rate for each individual drug
if string(choice) == 'Yes'
    
    % ----------------------------- Plot for Exponetial Growth Curve -------------------------------------------------------------
    if size(Unique_Drug,1) > 5
        subplot_row = 2;
        subplot_col = 5;
    else
        subplot_row = 1;
        subplot_col = size(Unique_Drug,1);
    end
    
    fig = figure(); counter = 0; start = 0; last = 2;
    for treat = 1:size(Unique_Drug,1)
        counter = counter+1;
        subplot(subplot_row,subplot_col,counter);hold on;
        x = str2double(Time_Points);
        y = (cellfun(@str2num,(table2cell(Format_Data_Input(strcmp((Format_Data_Input.Drug1),Unique_Drug(treat)),4:size(Format_Data_Input,2)))')));
        %         char(Unique_Drug(treat))
        count = 1;
        for value = 1:size(y,2)
            temp_y = y(:,value);
            [curvefit,gof] = fit(x,y(:,value),'exp1');
            plot (x,temp_y,'o');
            set(gca,'ColorOrderIndex',count)
            h2 = plot(curvefit, '--');
            hasbehavior(h2,'legend',false)
            legend(h2,'visible','off')
            count = count+1;            
            hdle=findobj(gcf,'type','legend'); %Stores a handle for legend objects
            delete(hdle) %Deletes legend objects to prevent them from popping up
            
            set(gca,'ColorOrderIndex',count)
        end
        hold off;
        title(char(Unique_Drug(treat)))
        start = start+2; last = last+2;

    end
    
    suptitle(['Exponential Cell Number of ' char(CellLine) ' ' char({sprintf('%s;',reshape_Expression{:})}) ' cells ' char(Date)])
    [ax1,h1]=suplabel('Cell Number','y');
    set(h1,'FontSize',15)
    [ax2,h2]=suplabel('Time(Hours)');
    set(h2,'FontSize',15)
    hold off;

    fileName = ['Exponential Cell Number of ' char(CellLine) ' ' char({sprintf('%s;',reshape_Expression{:})}) ' cells ' char(Date) '.fig'];
    subfolder = 'DPC Data\Exponetial Cell Number\';
    [Save_Path] = saveFigure(Excel_Path,fileName,subfolder,fig);
    clearvars fileName subfolder
    
    figHandle = figure();hold on;
    for leg_item = 1:size(Unique_Co_Drug,1)
        plot(leg_item, leg_item)
        legHandle = legend(Unique_Co_Drug,'Interpreter', 'none');
    end
    fileName = [Save_Path 'Legend for Exponential Cell Number of ' char(CellLine) ' ' char({sprintf('%s;',reshape_Expression{:})}) ' cells ' char(Date)];
    fileType = 'png';
    saveLegendToImage(figHandle, legHandle, fileName, fileType)
    
    clearvars fig counter start last treat x y curvefit gof fileName fileType figHandle Save_Path
    % ----------------------------------------------------------------------------------------------------------------------------
    
    % ----------------------------- Plot for log Growth Curve -------------------------------------------------------------
    fig = figure(); counter = 0; start = 0; last = 2;
    for treat = 1:size(Unique_Drug,1)
        counter = counter+1;
        subplot(subplot_row,subplot_col,counter);hold on;
        x = str2double(Time_Points);
        y = log2(cellfun(@str2num,(table2cell(Format_Data_Input(strcmp((Format_Data_Input.Drug1),Unique_Drug(treat)),4:size(Format_Data_Input,2)))')));
        char(Unique_Drug(treat))
        for value = 1:size(y,2)
            %             y(:,value)
            [curvefit,gof] = fit(x,y(:,value),'exp1');
            plot (x,y)
            %             plot(curvefit, '--')
            hdle=findobj(gcf,'type','legend'); %Stores a handle for legend objects
            delete(hdle) %Deletes legend objects to prevent them from popping up
        end
        hold off;
        title(char(Unique_Drug(treat)))
        start = start+2; last = last+2;
%         if treat  == 1
%             legend(Unique_Co_Drug)
%         end
    end
    suptitle(['Log2 Cell Number of ' char(CellLine) ' ' char({sprintf('%s;',reshape_Expression{:})}) ' cells ' char(Date)])
    [ax1,h1]=suplabel('log2 Cell Number','y');
    set(h1,'FontSize',15)
    [ax2,h2]=suplabel('Time(Hours)');
    set(h2,'FontSize',15)
    hold off;
    
    fileName = ['Log2 Cell Number of ' char(CellLine) ' ' char({sprintf('%s;',reshape_Expression{:})}) ' cells ' char(Date) '.fig'];
    subfolder = 'DPC Data\Log2 Cell Number\';
    [Save_Path] = saveFigure(Excel_Path,fileName,subfolder,fig);
    clearvars fileName subfolder
    
    figHandle = figure();hold on;
    for leg_item = 1:size(Unique_Co_Drug,1)
        plot(leg_item, leg_item)
        legHandle = legend(Unique_Co_Drug,'Interpreter', 'none');
    end
    fileName = [Save_Path 'Legend for Log2 Cell Number of ' char(CellLine) ' ' char({sprintf('%s;',reshape_Expression{:})}) ' cells ' char(Date)];
    fileType = 'png';
    saveLegendToImage(figHandle, legHandle, fileName, fileType)
    
    % ----------------------------------------------------------------------------------------------------------------------------
end
clearvars fileName fileType figHandle Save_Path
%%
% %---------------------------------Previous Linear Fit Testing---------------------------------------------------------------
% % clearvars count
% % Tau = table();
% % count = 1;
% % % figure(); hold on;
% % for i = 1:size(uniTreat,2)
% %     x = str2double(Time_Points);
% %     y = log2(cellfun(@str2num,(table2cell(Format_Data_Input(uniTreat(i),2:size(Format_Data_Input,2)))')));
% %     [R,P] = corrcoef(x,y); %Correlation Coefficient will tell you how linear a data set is. 1 is positive correlation, -1 is negative correlation.
% %
% %     %         if P(2) < 0.05
% %     %     %-------- Calculating R Correlation Coefficient--------%
% %     %     a=mean(x); b=mean(y);
% %     %     a1=x-a; b1=y-b; abprod = a1.*b1;
% %     %     asq=a1.^2; bsq = b1.^2;
% %     %     sumprod = sum(abprod);
% %     %     sumasq = sum(asq); sumbsq = sum(bsq);
% %     %     prod = sumasq*sumbsq; denom = sqrt(prod);
% %     %     r = sumprod/denom
% %     %     %-------------------------------------------------------%
% %
% %     %     %-------------------No Intercept-------------------
% %     %     b1 = x\y;
% %     %     yCalc1 = b1*x;
% %     %     Rsq1 = 1 - (sum((y - yCalc1).^2)/sum((y - mean(y)).^2))
% %     %     %--------------------------------------------------
% %
% %     %     %-------------------Intercept--------------------
% %     %     X = [ones(length(x),1) x];
% %     %     b2 = X\y;
% %     %     yCalc2 = (b2(2))*x + (b2(1));
% %     %     Rsq2 = 1 - sum((y - yCalc2).^2)/sum((y - mean(y)).^2)
% %     %     %------------------------------------------------
% %
% % %     % ----------------------Using Polyfit---------------------
% % %     Polyfit_Coeff = polyfit(x,y,1);
% % %     yCalc3 = Polyfit_Coeff(1)*x + Polyfit_Coeff(2);
% % %     Rsq3 = 1 - (sum((y - yCalc3).^2)/sum((y - mean(y)).^2));
% % %     % --------------------------------------------------------
% %     Tau.Exp_Name(i,1) = cellstr(Exp_Name);
% %     Tau.Expression(i,1) = cellstr(ExpressionStr);
% %     Tau.CellLine(i,1) = cellstr(CellLine);
% %     Tau.Treatment(i,1) = table2cell(Format_Data_Input(uniTreat(i),1));
% % %     Tau.Slope(i,1) = num2cell((Polyfit_Coeff(1)));
% % %     Tau.SlopeInverse(i,1) = num2cell(1/(Polyfit_Coeff(1)));
% % %     Tau.R_Calc(i,1) = num2cell(Rsq3);
% % %     Tau.P_Value(i,1) = num2cell(P(2));
% % %     Tau.R_Coeff(i,1) = num2cell(R(2));
% %     %             Tau(all(cellfun(@isempty,Tau{:,:}),2),:) = []; %Deletes empty rows
% %
% %
% %     count = count + 1;
% %     %     Curr_Tau_Count = size(Tau,1);
% % end

% Tau_Total(Prev_Tau_Count+1:Prev_Tau_Count+size(Tau,1),:) = Tau;
% clearvars uniTreat data Format_Data_Input Time_Points
% %-------------------------------------------------------------------------------------------------------------------------------


%% -----------------------------------------Least Square Fit for Non Avg Data ----------------------------------------------------
x = str2double(Time_Points);
start = 0; last = 2;idx = 0; Non_Avg_Tau = table();
for i = 1:size(Non_Avg_Data_Input,1)
    
    y = log2(cell2mat(table2cell(Non_Avg_Data_Input(i,2:size(Non_Avg_Data_Input,2)))'));
    f = fittype('m*x + b');
    
    for y_set = 1:size(y,2)
        % Compare the effect of excluding the outliers with the effect of giving them lower bisquare weight in a robust fit.
        [fit3,gof3,fitinfo3] = fit(x,y(:,y_set),f,'StartPoint',[1 1],'Robust','on');
        m = coeffvalues(fit3);
        
        Non_Avg_Tau.Exp_Name(i+idx,1) = cellstr(Exp_Name);
        if size(ExpressionStr,1) == 1
            
            Non_Avg_Tau.Expression(i+idx,1) = cellstr(ExpressionStr);
            cellstr(ExpressionStr)
        else
            for express = 1:size(ExpressionStr,1)
                if contains(table2cell(Non_Avg_Data_Input(Non_Avg_Data_uniTreat(i+idx),1)),ExpressionStr(express))
                    Non_Avg_Tau.Expression(i+idx,1) = cellstr(ExpressionStr(express));
                    cellstr(ExpressionStr(express))
                    
                    %             else
                    %                 Non_Avg_Tau.Expression(i+idx,1) = cellstr(ExpressionStr(express));
                    %                 cellstr(ExpressionStr(express))
                end
            end
        end
        Non_Avg_Tau.CellLine(i+idx,1) = cellstr(CellLine);
        Non_Avg_Tau.Treatment(i+idx,1) = table2cell(Non_Avg_Data_Input(Non_Avg_Data_uniTreat(i+idx),1));
        Non_Avg_Tau.Slope(i+idx,1) = num2cell(m(2));
        Non_Avg_Tau.SlopeInverse(i+idx,1) = num2cell(1/m(2));
        Non_Avg_Tau.RSQ(i+idx,1) = num2cell(gof3.rsquare);
         
        idx = idx+1;
    end
    idx = idx - 1;
    start = start+2;
    last = last+2;
end

    if size(ExpressionStr,1) > 1
        for express = 1:size(ExpressionStr,1)
            Avg_Control = median(cell2mat((Non_Avg_Tau.SlopeInverse((contains(Non_Avg_Tau.Treatment,'DMSO')|contains(Non_Avg_Tau.Treatment,ExpressionStr(express))) & contains(Non_Avg_Tau.Treatment,'No doxycyclin')))));
            Non_Avg_Tau.Normalized(contains(Non_Avg_Tau.Expression,ExpressionStr(express)),1) = num2cell(cell2mat(Non_Avg_Tau.SlopeInverse(contains(Non_Avg_Tau.Expression,ExpressionStr(express))))/Avg_Control);
        end
    else
        Avg_Control = median(cell2mat((Non_Avg_Tau.SlopeInverse(contains(Non_Avg_Tau.Treatment,'DMSO') & contains(Non_Avg_Tau.Treatment,'No doxycyclin')))));
        Non_Avg_Tau.Normalized = num2cell(cell2mat(Non_Avg_Tau.SlopeInverse)/Avg_Control);
    end
 
clearvars i
%% -------------------------------------------------------------------------------------------------------------------------------

%% -----------------------------------------Least Square Fit for Avg Data --------------------------------------------------------

if size(Unique_Drug,1) > 5
    subplot_row = 2;
    subplot_col = 5;
else
    subplot_row = 1;
    subplot_col = size(Unique_Drug,1);
end
x = str2double(Time_Points);
fig = figure(); hold on; counter = 0;start = 0; last = 2;idx = 0; Avg_Tau = table();
for i = 1:size(Unique_Drug,1)
    
    y = log2(cellfun(@str2num,(table2cell(Format_Data_Input(strcmp(cellstr(Format_Data_Input.Drug1),Unique_Drug(i)),4:size(Format_Data_Input,2)))')));
    f = fittype('m*x + b');
    counter = counter+1;
    subplot(subplot_row,subplot_col,counter);
    
    for y_set = 1:size(y,2)
        % Compare the effect of excluding the outliers with the effect of giving them lower bisquare weight in a robust fit.
        [fit3,gof3,fitinfo3] = fit(x,y(:,y_set),f,'StartPoint',[1 1],'Robust','on');
        hold on;
        h = plot(fit3,'--');
        hasbehavior(h,'legend',false)
        set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
           
        m = coeffvalues(fit3);
        Avg_Tau.Exp_Name(i+idx,1) = cellstr(Exp_Name);
%         for express = 1:size(ExpressionStr,1)
%             if contains(table2cell(Format_Data_Input(uniTreat(i+idx),1)),ExpressionStr(express))
%                 Avg_Tau.Expression(i+idx,1) = cellstr(ExpressionStr(express));
%             end
%         end
        % Made Changes Here
        if size(ExpressionStr,1) == 1
            
            Non_Avg_Tau.Expression(i+idx,1) = cellstr(ExpressionStr);
            cellstr(ExpressionStr)
        else
            for express = 1:size(ExpressionStr,1)
                if contains(table2cell(Non_Avg_Data_Input(Non_Avg_Data_uniTreat(i+idx),1)),ExpressionStr(express))
                    Non_Avg_Tau.Expression(i+idx,1) = cellstr(ExpressionStr(express));
                    cellstr(ExpressionStr(express))
                    
                    %             else
                    %                 Non_Avg_Tau.Expression(i+idx,1) = cellstr(ExpressionStr(express));
                    %                 cellstr(ExpressionStr(express))
                end
            end
        end
        
        Avg_Tau.CellLine(i+idx,1) = cellstr(CellLine);
        Avg_Tau.Treatment(i+idx,1) = table2cell(Format_Data_Input(uniTreat(i+idx),1));
        Avg_Tau.Slope(i+idx,1) = num2cell(m(2));
        Avg_Tau.SlopeInverse(i+idx,1) = num2cell(1/m(2));
        Avg_Tau.RSQ(i+idx,1) = num2cell(gof3.rsquare);     
        idx = idx+1;
%         pause()
    end
    idx = idx - 1;
%     if i == 1
%         legend(Unique_Co_Drug)
%     end
    title(char(Unique_Drug(i)))
    hold off;
    start = start+2;
    last = last+2;
    
    %     figure()
    %     hold on
    %     plot(fit3,x,y,'bx','residuals')
    %     title(table2cell(Format_Data_Input(uniTreat(i),1)))
    
end

suptitle(['Avg Least Squarse Fit ' char(CellLine) ' ' char({sprintf('%s;',reshape_Expression{:})}) ' cells ' char(Date)])
legend(Unique_Co_Drug)
[ax1,h1]=suplabel('Hours');
set(h1,'FontSize',15)
[ax2,h2]=suplabel('Cell Number','y');
set(h2,'FontSize',15)
hold off;

idcs   = strfind(Excel_Path,'\');
Save_Path = [Excel_Path(1:idcs(size(idcs,2)-1)) 'Graphs\DPC Data\Least Squares Fit'];
if exist(Save_Path, 'dir')~=7
    disp(string('Making Directory Graphs to store figures in.'))
    mkdir (Save_Path)
end
Save_Path_Name = [Save_Path '\' 'Avg Least Squares Fit ' char(CellLine) ' ' char({sprintf('%s;',reshape_Expression{:})}) ' cells ' char(Date) '.fig'];
saveas(fig,Save_Path_Name)
% clearvars i
%% -------------------------------------------------------------------------------------------------------------------------------



end
