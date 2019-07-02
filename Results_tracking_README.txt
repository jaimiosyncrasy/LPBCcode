Readme for L-PBC Results Tracking Tool


Purpose:

This Python script is designed to take in simulation voltage magnitudes, 
angles, real and reactive power as inputs and return a .csv and .pdf with relevant metrics and visualisations as outputs. 
The objective is to have one master .csv file called "Test Results" with results from each individual test and the relevant
data.




Intended Audience:

This script is meant to be read by anyone who is involved with L-PBC simulations, or by anyone who wishes 
to analyse the L-PBC results.


Expected input:
Important: Make sure the relevant .mat file and the results tracking jupyter 
notebooks lie in the same directory!

Filename of .mat file with relevant simulation number (eg. "sim1_1.mat"). 

This must be changed manually in the script's first code block. 
For now, the name of the sim test is to be input in the 
"sim_number" variable. However, there is code that has been commented out that can read a given "init.csv" file and 
extract the relevant test number from the CSV file itself.




Expected outputs:


1. PDF of V_mag, V_ang, P, and Q plotted over 
3 separate 5-minute intervals for the given simulation
. Master CSV file called "test_results" with results of various 
parameters for a given simulation. 

These parameters include:
	
- Number of times Voltage magnitude (V_mag) went out of bounds
	
- Largest V_mag deviation from target value
	
- Largest Voltage Angle (V_ang) deviation from target value
	
- Largest and Average V_mag overshoot (OS) value (in %)
	
- Largest and Average V_ang overshoot (OS) value (in %)
	
- Largest and Average V_mag Settling Time
	
- Largest and Average V_ang Settling Time
	
- Largest Real Power (P) value and timestamp
	
- Largest Reactive Power (Q) value and timestamp
	
- Number of transient violations (Settling Time > 10s, overshoot > 3%, undershoot > 6%)





Troubleshooting: 


1. The PDFs for each test take a few seconds to 
form, so wait about 10 seconds after running the script to view your completed PDF. 


2. In some cases, the PDF for a sim test doesn't contain the last graph for reactive power. If this happens, simply run the
relevant code block.


3. There is a realtime function that takes in an index number and outputs a timestamp corresponding to the index number. 
Please change this function with the relevant timeframe you are looking at. Else, feel free to comment it out and remove 
any reference to realtime made in the max_realpower and max_reactivepower functions.





4. IMPORTANT: The simulation length on simulink must be the same length as the simulation you are running. Ex. if the
simulation is 60 min, then the simulink simulation length must be changed to 3600 (seconds). 
5. If the PDF is not populating, try downloading it and opening it through your file explorer (sometimes a windows problem). 

For any questions/concerns, please e-mail jashvora@berkeley.edu (Jash Vora). Have a nice day!

Or, email t.g.roberts@berkeley.edu (I modifed the code after Jash) 