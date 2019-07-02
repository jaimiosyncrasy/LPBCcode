*** README before inputting a CSV file in the TV Load/Gen Data section of Driver_v2 ***

Your input file must be in a .csv format, with second-wise data.
In order to convert minutewise data to secondwise data, use the "minToSecCsv.m" file.

HOW TO USE THE "minToSecCsv.m" file:

0. If your input file is .xls, convert to .csv first before proceeding. 

1. Make sure you're using the "minToSecCsv.m" file and not any other version.

2. Make sure your input CSV file has no headers in the first row. You can append these later.
   The first column should only contain index numbers corresponding to minutes (1,2...)

3. In line 37 of the "minToSecCsv.m" file (the one with myData = [1:___], change the 
   second number to the corresponding number of seconds you wish to run your simulation for.

4. When you run the .m file, make sure you input start time as "1", not "0".

5. The input end time should be in minutes. 

