OPFILE 1.11 PHASOR
Pinout {
	name=impedMod_ieee13_dan_pinout
	incoming {
		item {
			pins {
				item {
					path=network/LD_675/Q1
				}
				item {
					path=network/LD_675/Q2
				}
				item {
					path=network/LD_675/Q3
				}
			}
		}
		item {
			pins {
				item {
					path=network/LD_675/P1
				}
				item {
					path=network/LD_675/P2
				}
				item {
					path=network/LD_675/P3
				}
			}
		}
	}
	outgoing {
		item {
			pins {
				item {
					path=network/671_a/Vmag
				}
				item {
					path=network/671_b/Vmag
				}
				item {
					path=network/671_c/Vmag
				}
			}
		}
		item {
			pins {
				item {
					path=network/671_a/Vang
				}
				item {
					path=network/671_b/Vang
				}
				item {
					path=network/671_c/Vang
				}
			}
		}
	}
}
