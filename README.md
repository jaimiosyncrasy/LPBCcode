# LPBCcode
Start with driver_v2, this is the "main" file. Sim_v2 is simulink raw code
In summary, this code is matlab for initilaization and setup, then calls simulink, then returns to matlab to output results

Outline of code:
initialization: read in init file, TV load/gen data, impedance model
read in phasor targets (currently get full set at start)
If computing controller gains by ZN:
  set kgains
  create actual disturbance
  run controlled sim
If computing controller gains by 'sysID'
  create test disturbance
  run uncontrolled sim
  compute sensitivities from measurements
  compute kgains
  run controlled sim
Output results

When running "controlled sim" or "uncontrolled sim", this refers to launching simulink, which has a controller loop (ephasorsim solver = plant, process measurement block, PI controllers, project actuation block)
