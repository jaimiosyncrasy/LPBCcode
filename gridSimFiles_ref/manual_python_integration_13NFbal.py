# This python script will read TV load/gen data from loadData_671_ab.csv, 
# and directly write this TV load/gen data into the grid model PythonAPI_IEEE13NodeFeeder


# we can use as many .xls load/gen data files as we want. In this demo we have two data files
import csv
from opal.ephasorsim import Network,Test
time_ab = []
LD_634P1 = []
LD_634P2 = []
LD_634P3 = []
LD_671P1 = []
LD_671P2 =[]
LD_671P3 =[]
LD_675P1 =[]
LD_675P2 =[]
LD_675P3 =[]
LD_632P1 =[]
LD_632P2 =[]
LD_632P3 =[]
LD_645P1 =[]
LD_645P2 =[]
LD_645P3 =[]
LD_646P1 =[]
LD_646P2 =[]
LD_646P3 =[]
LD_652P1 =[]
LD_652P2 =[]
LD_652P3 =[]
LD_692P1 =[]
LD_692P2 =[]
LD_692P3 =[]
LD_611P1 =[]
LD_611P2 =[]
LD_611P3 =[]
LD_634Q1 =[]
LD_634Q2 =[]
LD_634Q3 =[]
LD_671Q1 =[]
LD_671Q2 =[]
LD_671Q3 =[]
LD_675Q1 =[]
LD_675Q2 =[]
LD_675Q3 =[]
LD_632Q1 =[]
LD_632Q2 =[]
LD_632Q3 =[]
LD_645Q1 =[]
LD_645Q2 =[]
LD_645Q3 =[]
LD_646Q1 =[]
LD_646Q2 =[]
LD_646Q3 =[]
LD_652Q1 =[]
LD_652Q2 =[]
LD_652Q3 =[]
LD_692Q1 =[]
LD_692Q2 =[]
LD_692Q3 =[]
LD_611Q1 =[]
LD_611Q2 =[]
LD_611Q3 =[]



# Read CSV file (LoadData_XX.csv)
# For phases//--> with same time stamp
with open('016_GB_IEEE13_balance_all_ver2_time_sigBuilder_secondwise_norm03.csv') as csvFile_671_ab:
	csvLoadData_671_ab = csv.reader(csvFile_671_ab)
	csvLoadData_671_ab.next()
	for col in csvLoadData_671_ab:
			time_ab.append(col[0])
			LD_634P1.append(col[1])
			LD_634P2.append(col[2])
			LD_634P3.append(col[3])
			LD_671P1.append(col[4])
			LD_671P2.append(col[5])
			LD_671P3.append(col[6])
			LD_675P1.append(col[7])
			LD_675P2.append(col[8])
			LD_675P3.append(col[9])
			LD_632P1.append(col[10])
			LD_632P2.append(col[11])
			LD_632P3.append(col[12])
			LD_645P1.append(col[13])
			LD_645P2.append(col[14])
			LD_645P3.append(col[15])
			LD_646P1.append(col[16])
			LD_646P2.append(col[17])
			LD_646P3.append(col[18])
			LD_652P1.append(col[19])
			LD_652P2.append(col[20])
			LD_652P3.append(col[21])
			LD_692P1.append(col[22])
			LD_692P2.append(col[23])
			LD_692P3.append(col[24])
			LD_611P1.append(col[25])
			LD_611P2.append(col[26])
			LD_611P3.append(col[27])
			LD_634Q1.append(col[28])
			LD_634Q2.append(col[29])
			LD_634Q3.append(col[30])
			LD_671Q1.append(col[31])
			LD_671Q2.append(col[32])
			LD_671Q3.append(col[33])
			LD_675Q1.append(col[34])
			LD_675Q2.append(col[35])
			LD_675Q3.append(col[36])
			LD_632Q1.append(col[37])
			LD_632Q2.append(col[38])
			LD_632Q3.append(col[39])
			LD_645Q1.append(col[40])
			LD_645Q2.append(col[41])
			LD_645Q3.append(col[42])
			LD_646Q1.append(col[43])
			LD_646Q2.append(col[44])
			LD_646Q3.append(col[45])
			LD_652Q1.append(col[46])
			LD_652Q2.append(col[47])
			LD_652Q3.append(col[48])
			LD_692Q1.append(col[49])
			LD_692Q2.append(col[50])
			LD_692Q3.append(col[51])
			LD_611Q1.append(col[52])
			LD_611Q2.append(col[53])
			LD_611Q3.append(col[54])


my_network = Network('IEEE13NF_bal') # must be simulink file name, not impedance model
my_test=Test(my_network)
for i in range(0, 20):
	my_test.set('LD_634', 'P1', time_ab[i], LD_634P1[i])
	my_test.set('LD_634', 'P2', time_ab[i], LD_634P2[i])
	my_test.set('LD_634', 'P3', time_ab[i], LD_634P3[i])
	my_test.set('LD_671', 'P1', time_ab[i], LD_671P1[i])
	my_test.set('LD_671', 'P2', time_ab[i], LD_671P2[i])
	my_test.set('LD_671', 'P3', time_ab[i], LD_671P3[i])
	my_test.set('LD_675', 'P1', time_ab[i], LD_675P1[i])
	my_test.set('LD_675', 'P2', time_ab[i], LD_675P2[i])
	my_test.set('LD_675', 'P3', time_ab[i], LD_675P3[i])
	my_test.set('LD_632', 'P1', time_ab[i], LD_632P1[i])
	my_test.set('LD_632', 'P2', time_ab[i], LD_632P2[i])
	my_test.set('LD_632', 'P3', time_ab[i], LD_632P3[i])
	my_test.set('LD_645', 'P1', time_ab[i], LD_645P1[i])
	my_test.set('LD_645', 'P2', time_ab[i], LD_645P2[i])
	my_test.set('LD_645', 'P3', time_ab[i], LD_645P3[i])
	my_test.set('LD_646', 'P1', time_ab[i], LD_646P1[i])
	my_test.set('LD_646', 'P2', time_ab[i], LD_646P2[i])
	my_test.set('LD_646', 'P3', time_ab[i], LD_646P3[i])
	my_test.set('LD_652', 'P1', time_ab[i], LD_652P1[i])
	my_test.set('LD_652', 'P2', time_ab[i], LD_652P2[i])
	my_test.set('LD_652', 'P3', time_ab[i], LD_652P3[i])
	my_test.set('LD_692', 'P1', time_ab[i], LD_692P1[i])
	my_test.set('LD_692', 'P2', time_ab[i], LD_692P2[i])
	my_test.set('LD_692', 'P3', time_ab[i], LD_692P3[i])
	my_test.set('LD_611', 'P1', time_ab[i], LD_611P1[i])
	my_test.set('LD_611', 'P2', time_ab[i], LD_611P2[i])
	my_test.set('LD_611', 'P3', time_ab[i], LD_611P3[i])
	my_test.set('LD_634', 'Q1', time_ab[i], LD_634Q1[i])
	my_test.set('LD_634', 'Q2', time_ab[i], LD_634Q2[i])
	my_test.set('LD_634', 'Q3', time_ab[i], LD_634Q3[i])
	my_test.set('LD_671', 'Q1', time_ab[i], LD_671Q1[i])
	my_test.set('LD_671', 'Q2', time_ab[i], LD_671Q2[i])
	my_test.set('LD_671', 'Q3', time_ab[i], LD_671Q3[i])
	my_test.set('LD_675', 'Q1', time_ab[i], LD_675Q1[i])
	my_test.set('LD_675', 'Q2', time_ab[i], LD_675Q2[i])
	my_test.set('LD_675', 'Q3', time_ab[i], LD_675Q3[i])
	my_test.set('LD_632', 'Q1', time_ab[i], LD_632Q1[i])
	my_test.set('LD_632', 'Q2', time_ab[i], LD_632Q2[i])
	my_test.set('LD_632', 'Q3', time_ab[i], LD_632Q3[i])
	my_test.set('LD_645', 'Q1', time_ab[i], LD_645Q1[i])
	my_test.set('LD_645', 'Q2', time_ab[i], LD_645Q2[i])
	my_test.set('LD_645', 'Q3', time_ab[i], LD_645Q3[i])
	my_test.set('LD_646', 'Q1', time_ab[i], LD_646Q1[i])
	my_test.set('LD_646', 'Q2', time_ab[i], LD_646Q2[i])
	my_test.set('LD_646', 'Q3', time_ab[i], LD_646Q3[i])
	my_test.set('LD_652', 'Q1', time_ab[i], LD_652Q1[i])
	my_test.set('LD_652', 'Q2', time_ab[i], LD_652Q2[i])
	my_test.set('LD_652', 'Q3', time_ab[i], LD_652Q3[i])
	my_test.set('LD_692', 'Q1', time_ab[i], LD_692Q1[i])
	my_test.set('LD_692', 'Q2', time_ab[i], LD_692Q2[i])
	my_test.set('LD_692', 'Q3', time_ab[i], LD_692Q3[i])
	my_test.set('LD_611', 'Q1', time_ab[i], LD_611Q1[i])
	my_test.set('LD_611', 'Q2', time_ab[i], LD_611Q2[i])
	my_test.set('LD_611', 'Q3', time_ab[i], LD_611Q3[i])
	my_test.execute()

