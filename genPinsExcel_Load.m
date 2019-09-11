function genPinsExcel_mLoad(dataFilename)
clc
%{
--------------------------------------------
OPAL

generate excel file for Pins tab for ePHASORsim multiphase loads

Please transpose the data filel into your actual model Pins file
Note: This only generates the Pins tab

%}


[~,Data] = xlsread(dataFilename, 'Multiphase Load', 'A:D');

count = 0;

for row = 2:length(Data)
   
    for col = 1:3
        tail_P = {'/P1','/P2','/P3'};
        tail_Q = {'/Q1','/Q2','/Q3'};
        sc = strcmp (Data{row,col},'');
        if sc ~= 1
           count = count + 1;
           LoadPin(count,1)= strcat(Data(row,4),tail_P{col});
           LoadPin(count,2)= strcat(Data(row,4),tail_Q{col});
        end
    end  
end


 nRows = floor(length(LoadPin)/253);
 if nRows < 1
  excelRange = sprintf('A1:A%d',length(LoadPin));
  xlswrite('LoadPins_gen.xls',LoadPin(:,1),1, excelRange);
  xlswrite('LoadPins_gen.xls',LoadPin(:,2),2, excelRange);  
 else
    for i = 1:nRows
        excelRange = sprintf('%c1:%c253',64+i,64+i);
        xlswrite('LoadPins_gen.xls',LoadPin((i-1)*253+1:253*i,1),1, excelRange);
        xlswrite('LoadPins_gen.xls',LoadPin((i-1)*253+1:253*i,2),2, excelRange);
    end
    if length(LoadPin)>i*253
        excelRange = sprintf('%c1:%c%d',65+i,65+i,length(LoadPin)-i*253);
        xlswrite('LoadPins_gen.xls',LoadPin(i*253+1:length(LoadPin),1),1, excelRange);
        xlswrite('LoadPins_gen.xls',LoadPin(i*253+1:length(LoadPin),2),2, excelRange); 
    end
 end

changeSheetName(1, 'LoadPins_gen.xls','Pins_P');
changeSheetName(2, 'LoadPins_gen.xls','Pins_Q');

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