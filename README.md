# LPBCcode
This code designs a set of PI controllers to take in a measured voltage phasor and phasor target reference and produce real and reactive power commands. These commands are sent to actuator devices, followed by the ephasorsim solver updating the power flows at each timestep.

To review this code, start with "driver_v2". This is the "main" file. "Sim_v2" is Simulink source code so is better viewed by downloading and running simulink.

Outline of code:
1) initialization: read in init file, TV load/gen data, impedance model
2) read in phasor targets (currently get full set at start)
3) If computing controller gains by ZN:
  -set kgains
  -create actual disturbance
  -run controlled sim in simulink
If computing controller gains by new method "way 3"
  -create test disturbance
  -run uncontrolled sim in simulink
  -compute sensitivities from measurements
  -compute kgains
  -run controlled sim in simulink
4) Output results
----------------------
When running "controlled sim" or "uncontrolled sim", this refers to launching simulink, which has a controller loop (ephasorsim solver = plant, process measurement block, PI controllers, project actuation block)
