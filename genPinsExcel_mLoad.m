function genPinsExcel_mLoad(dataFilename)

%{
--------------------------------------------
OPAL

generate excel file for Pins tab for ePHASORsim multiphase loads

Please transpose the data filel into your actual model Pins file
Note: This only generates the Pins tab

%}


[~,Data] = xlsread(dataFilename, 'Multiphase Load', 'A:D');

[m,n] = size(Data);
K = zeros(m,n-1);
count = 0;

for row = 2:length(Data)
   
    for col = 1:3
        tail_P = {'/P1','/P2','/P3'};
        tail_Q = {'/Q1','/Q2','/Q3'};
        sc = strcmp (Data{row,col},'');
        if sc ~= 1
           count = count + 1;
           LoadPin_P(count)= strcat(Data(row,4),tail_P{col});
           LoadPin_Q(count)= strcat(Data(row,4),tail_Q{col});
        end
    end  
end
LoadPin = [LoadPin_P LoadPin_Q];
excelRange = sprintf('A1:B%d',length(LoadPin));

xlswrite('LoadPins_gen.xls',LoadPin(:),excelRange)

end