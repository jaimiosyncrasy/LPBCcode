OPFILE 1.11 PHASOR
Solver<Euler<F64>,Direct<F64,AdmittanceMatrix<F64>>> {
	name=IEEE13_ltc_liz_solver
	powerSystem=Distribution
}
PowerSystem {
	name=Distribution
	frequency=60
	base=40
	network {
		items {
			611_c
			632_a
			632_b
			632_c
			633_a
			633_b
			633_c
			634_a
			634_b
			634_c
			645_b
			645_c
			646_b
			646_c
			650_a
			650_b
			650_c
			651_a
			651_b
			651_c
			652_a
			671_a
			671_b
			671_c
			675_a
			675_b
			675_c
			680_a
			680_b
			680_c
			684_a
			684_c
			692_a
			692_b
			692_c
			G1_a
			G1_b
			G1_c
			TR1_633_634
			TR1_650_651
			LN_632_671
			LN_671_680
			LN_651_632
			LN_632_633
			LN_692_675
			LN_645_646
			LN_632_645
			LN_684_611
			LN_684_652
			LN_671_684
			LD_634
			LD_671
			LD_675
			LD_632
			LD_645
			LD_646
			LD_652
			LD_692
			LD_611
			cap675
			cap611
			SW_671_692_a
			SW_671_692_b
			SW_671_692_c
		}
	}
}
Bus {
	name=611_c
	type=PQ
	voltage {
		base=1000
		magnitude=2121.9
		angle=115
	}
}
Bus {
	name=632_a
	type=PQ
	voltage {
		base=1000
		magnitude=2320
		angle=-2.6
	}
}
Bus {
	name=632_b
	type=PQ
	voltage {
		base=1000
		magnitude=2355.1
		angle=-121.7
	}
}
Bus {
	name=632_c
	type=PQ
	voltage {
		base=1000
		magnitude=2264.4
		angle=117.3
	}
}
Bus {
	name=633_a
	type=PQ
	voltage {
		base=1000
		magnitude=2312.4
		angle=-2.6
	}
}
Bus {
	name=633_b
	type=PQ
	voltage {
		base=1000
		magnitude=2350.2
		angle=-121.8
	}
}
Bus {
	name=633_c
	type=PQ
	voltage {
		base=1000
		magnitude=2257.5
		angle=117.3
	}
}
Bus {
	name=634_a
	type=PQ
	voltage {
		base=1000
		magnitude=259.76
		angle=-3.4
	}
}
Bus {
	name=634_b
	type=PQ
	voltage {
		base=1000
		magnitude=265.76
		angle=-122.3
	}
}
Bus {
	name=634_c
	type=PQ
	voltage {
		base=1000
		magnitude=254.83
		angle=116.8
	}
}
Bus {
	name=645_b
	type=PQ
	voltage {
		base=1000
		magnitude=2320.6
		angle=-121.9
	}
}
Bus {
	name=645_c
	type=PQ
	voltage {
		base=1000
		magnitude=2272.8
		angle=117.2
	}
}
Bus {
	name=646_b
	type=PQ
	voltage {
		base=1000
		magnitude=2309.6
		angle=-122
	}
}
Bus {
	name=646_c
	type=PQ
	voltage {
		base=1000
		magnitude=2275.6
		angle=117.2
	}
}
Bus {
	name=650_a
	type=SLACK
	voltage {
		base=1000
		magnitude=2401.7
		angle=0
	}
}
Bus {
	name=650_b
	type=SLACK
	voltage {
		base=1000
		magnitude=2401.8
		angle=-120
	}
}
Bus {
	name=650_c
	type=SLACK
	voltage {
		base=1000
		magnitude=2401.7
		angle=120
	}
}
Bus {
	name=651_a
	type=PQ
	voltage {
		base=1000
		magnitude=2401.6
		angle=0
	}
}
Bus {
	name=651_b
	type=PQ
	voltage {
		base=1000
		magnitude=2401.7
		angle=-120
	}
}
Bus {
	name=651_c
	type=PQ
	voltage {
		base=1000
		magnitude=2401.6
		angle=120
	}
}
Bus {
	name=652_a
	type=PQ
	voltage {
		base=1000
		magnitude=2248.9
		angle=-5.9
	}
}
Bus {
	name=671_a
	type=PQ
	voltage {
		base=1000
		magnitude=2266
		angle=-5.9
	}
}
Bus {
	name=671_b
	type=PQ
	voltage {
		base=1000
		magnitude=2389.5
		angle=-122
	}
}
Bus {
	name=671_c
	type=PQ
	voltage {
		base=1000
		magnitude=2132.1
		angle=115.2
	}
}
Bus {
	name=675_a
	type=PQ
	voltage {
		base=1000
		magnitude=2249.2
		angle=-6.2
	}
}
Bus {
	name=675_b
	type=PQ
	voltage {
		base=1000
		magnitude=2395.4
		angle=-122.1
	}
}
Bus {
	name=675_c
	type=PQ
	voltage {
		base=1000
		magnitude=2126
		angle=115.3
	}
}
Bus {
	name=680_a
	type=PQ
	voltage {
		base=1000
		magnitude=2266
		angle=-5.9
	}
}
Bus {
	name=680_b
	type=PQ
	voltage {
		base=1000
		magnitude=2389.5
		angle=-122
	}
}
Bus {
	name=680_c
	type=PQ
	voltage {
		base=1000
		magnitude=2132.1
		angle=115.2
	}
}
Bus {
	name=684_a
	type=PQ
	voltage {
		base=1000
		magnitude=2261.7
		angle=-6
	}
}
Bus {
	name=684_c
	type=PQ
	voltage {
		base=1000
		magnitude=2126.9
		angle=115.1
	}
}
Bus {
	name=692_a
	type=PQ
	voltage {
		base=1000
		magnitude=2266
		angle=-5.9
	}
}
Bus {
	name=692_b
	type=PQ
	voltage {
		base=1000
		magnitude=2389.5
		angle=-122
	}
}
Bus {
	name=692_c
	type=PQ
	voltage {
		base=1000
		magnitude=2132.1
		angle=115.2
	}
}
VoltageSource {
	bus=650_a
	name=G1_a
	magnitude=2401.8
	angle=0
	impedance {
		re=0
		im=0
	}
}
VoltageSource {
	bus=650_b
	name=G1_b
	magnitude=2401.8
	angle=-120
	impedance {
		re=0
		im=0
	}
}
VoltageSource {
	bus=650_c
	name=G1_c
	magnitude=2401.8
	angle=120
	impedance {
		re=0
		im=0
	}
}
ThreePhaseTransformer {
	name=TR1_633_634
	windings {
		ThreePhaseTransformerWinding {
			bus_a=633_a
			bus_b=633_b
			bus_c=633_c
			kVll=4.16
			kVA_base=500
			r_pu=0.0055
			conn=wye
		}
		ThreePhaseTransformerWinding {
			bus_a=634_a
			bus_b=634_b
			bus_c=634_c
			kVll=0.48
			kVA_base=500
			r_pu=0.0055
			conn=wye
		}
	}
	xhl_pu=0.02
	tap_a=0
	tap_b=0
	tap_c=0
	min_tap=-16
	max_tap=16
	min_range_percent=10
	max_range_percent=10
}
ThreePhaseTransformer {
	name=TR1_650_651
	windings {
		ThreePhaseTransformerWinding {
			bus_a=650_a
			bus_b=650_b
			bus_c=650_c
			kVll=4.16
			kVA_base=5000
			r_pu=4.98e-06
			conn=wye
		}
		ThreePhaseTransformerWinding {
			bus_a=651_a
			bus_b=651_b
			bus_c=651_c
			kVll=4.16
			kVA_base=5000
			r_pu=4.98e-06
			conn=wye
		}
	}
	xhl_pu=0.0001
	tap_a=0
	tap_b=0
	tap_c=0
	min_tap=-16
	max_tap=16
	min_range_percent=10
	max_range_percent=10
}
ThreePhasePiLine_ {
	name=LN_632_671
	mode=full
	length=0.37878788
	buses {
		632_a
		632_b
		632_c
		671_a
		671_b
		671_c
	}
	resistances=0.3465 0.156 0.158 0.156 0.3375 0.1535 0.158 0.1535 0.3414
	reactances=1.0179 0.5017 0.4236 0.5017 1.0478 0.3849 0.4236 0.3849 1.0348
	charges=0 0 0 0 0 0 0 0 0
}
ThreePhasePiLine_ {
	name=LN_671_680
	mode=full
	length=0.189394
	buses {
		671_a
		671_b
		671_c
		680_a
		680_b
		680_c
	}
	resistances=0.3465 0.156 0.158 0.156 0.3375 0.1535 0.158 0.1535 0.3414
	reactances=1.0179 0.5017 0.4236 0.5017 1.0478 0.3849 0.4236 0.3849 1.0348
	charges=0 0 0 0 0 0 0 0 0
}
ThreePhasePiLine_ {
	name=LN_651_632
	mode=full
	length=0.378788
	buses {
		651_a
		651_b
		651_c
		632_a
		632_b
		632_c
	}
	resistances=0.3465 0.156 0.158 0.156 0.3375 0.1535 0.158 0.1535 0.3414
	reactances=1.0179 0.5017 0.4236 0.5017 1.0478 0.3849 0.4236 0.3849 1.0348
	charges=0 0 0 0 0 0 0 0 0
}
ThreePhasePiLine_ {
	name=LN_632_633
	mode=full
	length=0.094697
	buses {
		632_a
		632_b
		632_c
		633_a
		633_b
		633_c
	}
	resistances=0.7526 0.158 0.156 0.158 0.7475 0.1535 0.156 0.1535 0.7436
	reactances=1.1814 0.4236 0.5017 0.4236 1.1983 0.3849 0.5017 0.3849 1.2112
	charges=0 0 0 0 0 0 0 0 0
}
ThreePhasePiLine_ {
	name=LN_692_675
	mode=full
	length=0.094697
	buses {
		692_a
		692_b
		692_c
		675_a
		675_b
		675_c
	}
	resistances=0.7982 0.3192 0.2849 0.3192 0.7891 0.3192 0.2849 0.3192 0.7982
	reactances=0.4463 0.0328 -0.0143 0.0328 0.4041 0.0328 -0.0143 0.0328 0.4463
	charges=96.8867 0 0 0 96.8867 0 0 0 96.8867
}
TwoPhasePiLine {
	name=LN_645_646
	mode=full
	length=0.0568182
	buses {
		645_b
		645_c
		646_b
		646_c
	}
	resistances=1.3238 0.2066 0.2066 1.3294
	reactances=1.3569 0.4591 0.4591 1.3471
	charges=0 0 0 0
}
TwoPhasePiLine {
	name=LN_632_645
	mode=full
	length=0.094697
	buses {
		632_b
		632_c
		645_b
		645_c
	}
	resistances=1.3238 0.2066 0.2066 1.3294
	reactances=1.3569 0.4591 0.4591 1.3471
	charges=0 0 0 0
}
SinglePhasePiLine {
	name=LN_684_611
	mode=full
	length=0.0568182
	buses {
		684_c
		611_c
	}
	resistances=1.3292
	reactances=1.3475
	charges=0
}
SinglePhasePiLine {
	name=LN_684_652
	mode=full
	length=0.1515152
	buses {
		684_a
		652_a
	}
	resistances=1.3425
	reactances=0.5124
	charges=88.9699
}
TwoPhasePiLine {
	name=LN_671_684
	mode=full
	length=0.0568182
	buses {
		671_a
		671_c
		684_a
		684_c
	}
	resistances=1.3238 0.2066 0.2066 1.3294
	reactances=1.3569 0.4591 0.4591 1.3471
	charges=0 0 0 0
}
ThreePhaseZipLoad {
	name=LD_634
	buses {
		634_a
		634_b
		634_c
	}
	power_re=160 120 120
	power_im=110 90 90
	mode=wye
	vll=0.48
	range=0.2
	z_coef=0
	i_coef=0
	p_coef=1
	status=1
	use_initial_voltage=1
}
ThreePhaseZipLoad {
	name=LD_671
	buses {
		671_a
		671_b
		671_c
	}
	power_re=385 385 385
	power_im=220 220 220
	mode=wye
	vll=4.16
	range=0.2
	z_coef=0
	i_coef=0
	p_coef=1
	status=1
	use_initial_voltage=1
}
ThreePhaseZipLoad {
	name=LD_675
	buses {
		675_a
		675_b
		675_c
	}
	power_re=485 68 290
	power_im=190 60 212
	mode=wye
	vll=4.16
	range=0.2
	z_coef=0
	i_coef=0
	p_coef=1
	status=1
	use_initial_voltage=1
}
ThreePhaseZipLoad {
	name=LD_632
	buses {
		632_a
		632_b
		632_c
	}
	power_re=17 66 117
	power_im=10 38 68
	mode=wye
	vll=4.16
	range=0.2
	z_coef=0
	i_coef=0
	p_coef=1
	status=1
	use_initial_voltage=1
}
SinglePhaseZipLoad {
	name=LD_645
	buses {
		645_b
	}
	power_re=170
	power_im=125
	mode=wye
	vll=4.16
	range=0.2
	z_coef=0
	i_coef=0
	p_coef=1
	status=1
	use_initial_voltage=1
}
SinglePhaseZipLoad {
	name=LD_646
	buses {
		646_b
	}
	power_re=230
	power_im=132
	mode=wye
	vll=4.16
	range=0.2
	z_coef=1
	i_coef=0
	p_coef=0
	status=1
	use_initial_voltage=0
}
SinglePhaseZipLoad {
	name=LD_652
	buses {
		652_a
	}
	power_re=128
	power_im=86
	mode=wye
	vll=4.16
	range=0.2
	z_coef=1
	i_coef=0
	p_coef=0
	status=1
	use_initial_voltage=0
}
SinglePhaseZipLoad {
	name=LD_692
	buses {
		692_c
	}
	power_re=170
	power_im=151
	mode=wye
	vll=4.16
	range=0.2
	z_coef=0
	i_coef=1
	p_coef=0
	status=1
	use_initial_voltage=0
}
SinglePhaseZipLoad {
	name=LD_611
	buses {
		611_c
	}
	power_re=170
	power_im=80
	mode=wye
	vll=4.16
	range=0.2
	z_coef=0
	i_coef=1
	p_coef=0
	status=1
	use_initial_voltage=0
}
ThreePhaseShunt {
	name=cap675
	buses {
		675_a
		675_b
		675_c
	}
	power_re=0 0 0
	power_im=-200 -200 -200
	status=1 1 1
	vll=4.16003962961893
}
SinglePhaseShunt {
	name=cap611
	buses {
		611_c
	}
	power_re=0
	power_im=-100
	status=1
	vll=4.16003962961893
}
Switch {
	name=SW_671_692_a
	bus0=671_a
	bus1=692_a
	status=1
}
Switch {
	name=SW_671_692_b
	bus0=671_b
	bus1=692_b
	status=1
}
Switch {
	name=SW_671_692_c
	bus0=671_c
	bus1=692_c
	status=1
}
