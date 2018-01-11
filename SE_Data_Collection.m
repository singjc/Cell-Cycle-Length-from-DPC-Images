function [DataStructure] = SE_Data_Collection(row,col,keepers,ResultTable,DataStructure,FieldName)

 %% Collect stats
            DataStructure.('SE').(FieldName).Numcells(row,col) = length(keepers);
            DataStructure.('SE').(FieldName).MeanProt(row,col) = mean(ResultTable.CInt(keepers,3));
            DataStructure.('SE').(FieldName).MedProt(row,col) = median(ResultTable.CInt(keepers,3));
            DataStructure.('SE').(FieldName).TotalProt(row,col) = sum(ResultTable.CInt(keepers,3));
            DataStructure.('SE').(FieldName).CVProt(row,col) = std(ResultTable.CInt(keepers,3))/mean(ResultTable.CInt(keepers,3));
            DataStructure.('SE').(FieldName).MeanNucArea(row,col) = mean(ResultTable.NArea(keepers));
            DataStructure.('SE').(FieldName).MedNucArea(row,col) = median(ResultTable.NArea(keepers));
            DataStructure.('SE').(FieldName).CC(row,col,1) = sum(ResultTable.EG1(keepers))/length(keepers);
            DataStructure.('SE').(FieldName).CC(row,col,2) = sum(ResultTable.LG1(keepers))/length(keepers);
            DataStructure.('SE').(FieldName).CC(row,col,3) = sum(ResultTable.G1S(keepers))/length(keepers);
            DataStructure.('SE').(FieldName).CC(row,col,4) = sum(ResultTable.S(keepers))/length(keepers);
            DataStructure.('SE').(FieldName).CC(row,col,5) = sum(ResultTable.G2(keepers))/length(keepers);
            DataStructure.('SE').(FieldName).MeanProtCC(row,col,1) = mean(ResultTable.CInt(ResultTable.Keep & ResultTable.EG1,3));
            DataStructure.('SE').(FieldName).MeanProtCC(row,col,2) = mean(ResultTable.CInt(ResultTable.Keep & ResultTable.LG1,3));
            DataStructure.('SE').(FieldName).MeanProtCC(row,col,3) = mean(ResultTable.CInt(ResultTable.Keep & ResultTable.G1S,3));
            DataStructure.('SE').(FieldName).MeanProtCC(row,col,4) = mean(ResultTable.CInt(ResultTable.Keep & ResultTable.S,3));
            DataStructure.('SE').(FieldName).MeanProtCC(row,col,5) = mean(ResultTable.CInt(ResultTable.Keep & ResultTable.G2,3));
            DataStructure.('SE').(FieldName).StdProtCC(row,col,1) = MAD(ResultTable.CInt(ResultTable.Keep & ResultTable.EG1,3));
            DataStructure.('SE').(FieldName).StdProtCC(row,col,2) = MAD(ResultTable.CInt(ResultTable.Keep & ResultTable.LG1,3));
            DataStructure.('SE').(FieldName).StdProtCC(row,col,3) = MAD(ResultTable.CInt(ResultTable.Keep & ResultTable.G1S,3));
            DataStructure.('SE').(FieldName).StdProtCC(row,col,4) = MAD(ResultTable.CInt(ResultTable.Keep & ResultTable.S,3));
            DataStructure.('SE').(FieldName).StdProtCC(row,col,5) = MAD(ResultTable.CInt(ResultTable.Keep & ResultTable.G2,3));         
            DataStructure.('SE').(FieldName).MedProtCC(row,col,1) = median(ResultTable.CInt(ResultTable.Keep & ResultTable.EG1,3));
            DataStructure.('SE').(FieldName).MedProtCC(row,col,2) = median(ResultTable.CInt(ResultTable.Keep & ResultTable.LG1,3));
            DataStructure.('SE').(FieldName).MedProtCC(row,col,3) = median(ResultTable.CInt(ResultTable.Keep & ResultTable.G1S,3));
            DataStructure.('SE').(FieldName).MedProtCC(row,col,4) = median(ResultTable.CInt(ResultTable.Keep & ResultTable.S,3));
            DataStructure.('SE').(FieldName).MedProtCC(row,col,5) = median(ResultTable.CInt(ResultTable.Keep & ResultTable.G2,3));
            DataStructure.('SE').(FieldName).MeanNucAreaCC(row,col,1) = mean(ResultTable.NArea(ResultTable.Keep & ResultTable.EG1));
            DataStructure.('SE').(FieldName).MeanNucAreaCC(row,col,2) = mean(ResultTable.NArea(ResultTable.Keep & ResultTable.LG1));
            DataStructure.('SE').(FieldName).MeanNucAreaCC(row,col,3) = mean(ResultTable.NArea(ResultTable.Keep & ResultTable.G1S));
            DataStructure.('SE').(FieldName).MeanNucAreaCC(row,col,4) = mean(ResultTable.NArea(ResultTable.Keep & ResultTable.S));
            DataStructure.('SE').(FieldName).MeanNucAreaCC(row,col,5) = mean(ResultTable.NArea(ResultTable.Keep & ResultTable.G2));
            DataStructure.('SE').(FieldName).MedNucAreaCC(row,col,1) = median(ResultTable.NArea(ResultTable.Keep & ResultTable.EG1));
            DataStructure.('SE').(FieldName).MedNucAreaCC(row,col,2) = median(ResultTable.NArea(ResultTable.Keep & ResultTable.LG1));
            DataStructure.('SE').(FieldName).MedNucAreaCC(row,col,3) = median(ResultTable.NArea(ResultTable.Keep & ResultTable.G1S));
            DataStructure.('SE').(FieldName).MedNucAreaCC(row,col,4) = median(ResultTable.NArea(ResultTable.Keep & ResultTable.S));
            DataStructure.('SE').(FieldName).MedNucAreaCC(row,col,5) = median(ResultTable.NArea(ResultTable.Keep & ResultTable.G2));           
            [f1,s1] = ksdensity(ResultTable.CInt(keepers,3),(mean(ResultTable.CInt(keepers,3))-2*std(ResultTable.CInt(keepers,3))):((mean(ResultTable.CInt(keepers,3))+3*std(ResultTable.CInt(keepers,3)))-(mean(ResultTable.CInt(keepers,3))-2*std(ResultTable.CInt(keepers,3))))/100:(mean(ResultTable.CInt(keepers,3))+3*std(ResultTable.CInt(keepers,3))));
            DataStructure.('SE').(FieldName).Paxis{row,col}=s1;
            DataStructure.('SE').(FieldName).Pdensity{row,col}=f1;
            [f2,s2] = ksdensity(ResultTable.NArea(keepers),(mean(ResultTable.NArea(keepers))-2*std(ResultTable.NArea(keepers))):((mean(ResultTable.NArea(keepers))+3*std(ResultTable.NArea(keepers)))-(mean(ResultTable.NArea(keepers))-2*std(ResultTable.NArea(keepers))))/100:(mean(ResultTable.NArea(keepers))+3*std(ResultTable.NArea(keepers))));
            DataStructure.('SE').(FieldName).Naxis{row,col}=s2;
            DataStructure.('SE').(FieldName).Ndensity{row,col}=f2;
%%           
end % End of Function