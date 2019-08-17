function genPinsExcel_mbus(dataFilename)

[~,Data] = xlsread(dataFilename, 'Bus', 'A:A');

[m,n] = size(Data);
K = zeros(m,n-1);
count = 0;

for row = 2:length(Data)
        
        tail_Vang = {'/Vang','/Vang','/Vang'};
        tail_Vmag = {'/Vmag','/Vmag','/Vmag'};
        
        count = count + 1;
       BusPin_Vang(count)= strcat(Data(row),tail_Vang{1});
       BusPin_Vmag(count)= strcat(Data(row),tail_Vmag{1});
       
end
BusPin = [BusPin_Vang BusPin_Vmag];
excelRange = sprintf('A1:B%d',length(BusPin));

xlswrite('BusPins_gen.xls',BusPin(:),excelRange)

end        
        
        