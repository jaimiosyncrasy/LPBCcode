function genPinsExcel_mBus(dataFilename)
clc
%{
--------------------------------------------
OPAL

generate excel file for Pins tab for ePHASORsim multiphase loads

Please transpose the data filel into your actual model Pins file
Note: This only generates the Pins tab

%}


[~,Data] = xlsread(dataFilename, 'Bus', 'A:A');

count = 0;

for row = 2:length(Data)
           count = count + 1;
           BusPin(count,1)= strcat(Data(row,1),'/Vmag');
           BusPin(count,2)= strcat(Data(row,1),'/Vang');
end


 nRows = floor(length(BusPin)/253);
 if nRows < 1
  excelRange = sprintf('A1:A%d',length(BusPin));
  xlswrite('BusPins_gen.xls',BusPin(:,1),1, excelRange);
  xlswrite('BusPins_gen.xls',BusPin(:,2),2, excelRange);  
 else
    for i = 1:nRows
        excelRange = sprintf('%c1:%c253',64+i,64+i);
        xlswrite('BusPins_gen.xls',BusPin((i-1)*253+1:253*i,1),1, excelRange);
        xlswrite('BusPins_gen.xls',BusPin((i-1)*253+1:253*i,2),2, excelRange);
    end
    if length(BusPin)>i*253
        excelRange = sprintf('%c1:%c%d',65+i,65+i,length(BusPin)-i*253);
        xlswrite('BusPins_gen.xls',BusPin(i*253+1:length(BusPin),1),1, excelRange);
        xlswrite('BusPins_gen.xls',BusPin(i*253+1:length(BusPin),2),2, excelRange); 
    end
 end

changeSheetName(1, 'BusPins_gen.xls','Vmag');
changeSheetName(2, 'BusPins_gen.xls','Vang');

clear all
end

function changeSheetName(tab,excel_file,sheetName)
    e = actxserver('Excel.Application'); %open Activex server
    fileLocation = sprintf('%s\\%s',pwd,excel_file);
    ewb = e.Workbooks.Open(fileLocation); %open File
    ewb.Worksheets.Item(tab).Name = sheetName; % rename
    ewb.Save % save
    ewb.Close(false)
    e.Quit
end