% Function to plot time-point DPC cell count data
function [Tau,Unique_Drug,Unique_Co_Drug] = Plotting2(Exp_Name,ExpressionStr,CellLine,Date,Format_Data_Input,Excel_Path)

%% Extracts Time Points
TP_Headers = Format_Data_Input.Properties.VariableNames(2:end)';
MatchExpression = 'TP_(\d+)_Hr';
Tokens = regexp(TP_Headers,MatchExpression,'tokens');
for tok = 1:size(Tokens,1)
    Time_Points(tok,1) = Tokens{tok,1}{1,1};
end
%%

% [uniTreat ,~] = listdlg('PromptString','Select which Treatments you wish to analyze.','SelectionMode','multiple','ListString',Format_Data.Treatment,'ListSize',[250 250]);
uniTreat = 1:size(Format_Data_Input.Treatment,1);
% dlgTitle    = 'User Question'; dlgQuestion = 'Do you wish to visualize via plots?'; choice = questdlg(dlgQuestion,dlgTitle,'Yes','No', 'Yes');
choice = 'Yes'
%% Extracts Unique Drugs
Treats = Format_Data_Input.Treatment;
RegEx = '(\d+\s\w+\s\w+|\d+.\d+\s\w+\s\w+|\w+)\s[+]\s(\d+\s\w+/\w+\s\w+|\w+\s\w+)'
Tokens2 = regexp(Treats,RegEx,'tokens');
for tok2 = 1:size(Tokens2,1)
    temp_Drug(tok2,1) = cellstr(Tokens2{tok2,1}{1,1}{1,1});
    temp_Co_Drug(tok2,1) = cellstr(Tokens2{tok2,1}{1,1}{1,2});
end
Unique_Drug = unique(temp_Drug, 'stable');
Unique_Co_Drug = unique(temp_Co_Drug,'stable');
%%

%% Section for plotting growth rate for each individual drug
if string(choice) == 'Yes'
  
    %     --------------------------------------------- OLD ------------------
    %     [Trend_Line,~] = listdlg('PromptString','Select which Treatments you wish to have a trendline for.','SelectionMode','multiple','ListString',Format_Data.Treatment(uniTreat),'ListSize',[300 250]); %Prompts user what plots they want
    %     Colour_Range = {'[.5 .5 .5]' '[1 .4 .4]' '[.2 .4 1]' '[.3 .8 .3]' '[.6 .3 .4]' '[.9 .8 .9]' '[0 0 0]' '[0 0 1]' '[0 1 0]' '[1 0 0]' '[1 0 1]' '[1 1 0]' '[.3 .7 .5]' '[.5 0.6 1]' '[.7 .2 .9]' '[1 .2 .7]' '[.2 .9 1]' '[.1 1 .9]'}';
    %     count = 1;
    %     figure(); hold on;
    %     for i = 1:size(uniTreat,2)
    %         x = str2double(Time_Points);
    %         y = log(cellfun(@str2num,(table2cell(Format_Data(uniTreat(i),2:size(Format_Data,2)))')));
    % %         Current_Colour = rand(1,3);
    % %         plot(x,y,'o','MarkerFaceColor',char(Colour_Range(count)));
    %         plot(x,y,'o');
    %         logi = contains(table2cell(Format_Data(uniTreat,1)),table2cell(Format_Data(uniTreat(Trend_Line),1)));
    %         if (logi(count)) == 1
    %             [curvefit,gof] = fit(x,y,'exp1');
    %             t = plot(curvefit,'--');
    % %             t.Color = char(Colour_Range(count));
    %             set(get(get(t,'Annotation'),'LegendInformation'),'IconDisplayStyle','off');
    %             legend_list(i,1) = cellstr([char(table2cell(Format_Data(uniTreat(i),1))) ': (R^{2}: ' num2str(gof.rsquare) ')']);
    %         else
    %             legend_list(i,1) = table2cell(Format_Data(uniTreat(i),1))  ;
    %         end
    %         count = count + 1;
    %     end
    %     legend(legend_list);
    %     xlabel('Time (Hours)')
    %     ylabel('Cell Number')
    %     title(string(['Proliferation Rate of ' Expression ' ' CellLine ' Cells']))
    %     hold off;
    % ------------------------------------------------------------------------
    
    % ----------------------------- Plot for Exponetial Growth Curve -------------------------------------------------------------
    fig = figure(); counter = 0; start = 0; last = 2;
    for treat = 1:size(Unique_Drug,1)
        counter = counter+1;
        subplot(2,5,counter);hold on;
        x = str2double(Time_Points);
        y = (cellfun(@str2num,(table2cell(Format_Data_Input(treat+start:treat+last,2:size(Format_Data_Input,2)))')));
        char(Unique_Drug(treat))
        count = 1;
        for value = 1:size(y,2)
            temp_y = y(:,value)
            [curvefit,gof] = fit(x,y(:,value),'exp1');
             h =  plot (x,temp_y,'o')
%               set(gca, 'ColorOrder', circshift(get(gca, 'ColorOrder'), numel(h)))
              set(gca,'ColorOrderIndex',count)
              h = plot(curvefit, '--')
              set(get(get(h,'Annotation'),'LegendInformation'),'IconDisplayStyle','off'); 
              count = count+1
              set(gca,'ColorOrderIndex',count)
        end
        hold off;
        title(char(Unique_Drug(treat)))
        start = start+2; last = last+2; 
        
        legend(Unique_Co_Drug)
    end
    suptitle(['Exponential Cell Number of ' char(CellLine) ' ' char(ExpressionStr) ' cells ' char(Date)])
    hold off;
    
    idcs   = strfind(Excel_Path,'\');
    Save_Path = [Excel_Path(1:idcs(size(idcs,2)-1)) 'Graphs\Exponetial Cell Number'];
    if exist(Save_Path, 'dir')~=7
        disp("Making Directory Graphs to store figures in.")
        mkdir (Save_Path)
    end
    Save_Path_Name = [Save_Path '\' 'Exponential Cell Number of ' char(CellLine) ' ' char(ExpressionStr) ' cells ' char(Date) '.fig'];
    saveas(fig,Save_Path_Name)
    clearvars fig counter start last treat x y curvefit gof
    % ----------------------------------------------------------------------------------------------------------------------------
    
    % ----------------------------- Plot for Exponetial Growth Curve -------------------------------------------------------------
    fig = figure(); counter = 0; start = 0; last = 2;
    for treat = 1:size(Unique_Drug,1)
        counter = counter+1;
        subplot(2,5,counter);hold on;
        x = str2double(Time_Points);
        y = log2(cellfun(@str2num,(table2cell(Format_Data_Input(treat+start:treat+last,2:size(Format_Data_Input,2)))')));
        char(Unique_Drug(treat))
        for value = 1:size(y,2)
            y(:,value)
            [curvefit,gof] = fit(x,y(:,value),'exp1');
            plot (x,y)
            %             plot(curvefit, '--')
        end
        hold off;
        title(char(Unique_Drug(treat)))
        start = start+2; last = last+2; 
        legend(Unique_Co_Drug)
   
    end
    suptitle(['Log2 Cell Number of ' char(CellLine) ' ' char(ExpressionStr) ' cells ' char(Date)])
    hold off;
    idcs   = strfind(Excel_Path,'\');
    Save_Path = [Excel_Path(1:idcs(size(idcs,2)-1)) 'Graphs\Log2 Cell Number'];
    if exist(Save_Path, 'dir')~=7
        disp("Making Directory Graphs to store figures in.")
        mkdir (Save_Path)
    end
    Save_Path_Name = [Save_Path '\' 'Log2 Cell Number of ' char(CellLine) ' ' char(ExpressionStr) ' cells ' char(Date) '.fig'];
    saveas(fig,Save_Path_Name)
    % ----------------------------------------------------------------------------------------------------------------------------    
end
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
%% -----------------------------------------Least Square Fit----------------------------------------------------------------------
x = str2double(Time_Points);
fig = figure(); hold on; counter = 0;start = 0; last = 2;idx = 0; Tau = table();
for i = 1:size(Unique_Drug,1)
    
    y = log2(cellfun(@str2num,(table2cell(Format_Data_Input(uniTreat(i+start:i+last),2:size(Format_Data_Input,2)))')));
    f = fittype('m*x + b');  
    counter = counter+1;
    subplot(2,5,counter);

    for y_set = 1:size(y,2)
        % Compare the effect of excluding the outliers with the effect of giving them lower bisquare weight in a robust fit.
        [fit3,gof3,fitinfo3] = fit(x,y(:,y_set),f,'StartPoint',[1 1],'Robust','on');
        hold on;
        plot(fit3,'--')
        m = coeffvalues(fit3);
        Tau.Exp_Name(i+idx,1) = cellstr(Exp_Name);
        Tau.Expression(i+idx,1) = cellstr(ExpressionStr);
        Tau.CellLine(i+idx,1) = cellstr(CellLine);
        Tau.Treatment(i+idx,1) = table2cell(Format_Data_Input(uniTreat(i+idx),1));
        Tau.Slope(i+idx,1) = num2cell(m(2));
        Tau.SlopeInverse(i+idx,1) = num2cell(1/m(2));
        Tau.RSQ(i+idx,1) = num2cell(gof3.rsquare);
        i+idx
        idx = idx+1;
        
    end
    idx = idx - 1;
    legend(Unique_Co_Drug)
    title(char(Unique_Drug(i)))
    hold off; 
    start = start+2; 
    last = last+2;

    %     figure()
    %     hold on
    %     plot(fit3,x,y,'bx','residuals')
    %     title(table2cell(Format_Data_Input(uniTreat(i),1)))
  
end

suptitle(['Linear Square Fit ' char(CellLine) ' ' char(ExpressionStr) ' cells ' char(Date)])
hold off;

 idcs   = strfind(Excel_Path,'\');
 Save_Path = [Excel_Path(1:idcs(size(idcs,2)-1)) 'Graphs\Least Squares Fit'];
 if exist(Save_Path, 'dir')~=7
     disp("Making Directory Graphs to store figures in.")
     mkdir (Save_Path)
 end
 Save_Path_Name = [Save_Path '\' 'Linear Square Fit ' char(CellLine) ' ' char(ExpressionStr) ' cells ' char(Date) '.fig'];
 saveas(fig,Save_Path_Name)
%% -------------------------------------------------------------------------------------------------------------------------------
end
