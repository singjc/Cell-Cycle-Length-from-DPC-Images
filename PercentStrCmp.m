function percentDiff = PercentStrCmp(str1,str2)
revstr1 = reverse(str1);
revstr2 = reverse(str2);
nstr1 = length(revstr1);
nstr2 = length(revstr2);
if nstr1>=nstr2; len = nstr1;revstr1 = pad(revstr2,len);else; len = nstr2;revstr1 = pad(revstr1,len);end %pad appends leading trail
match = zeros(len,1);
for idc = 1:len
    match(idc,1) = revstr1(idc)==revstr2(idc);
end
sumMatched = sum(match);
percentDiff = (sumMatched/len)*100;
end
