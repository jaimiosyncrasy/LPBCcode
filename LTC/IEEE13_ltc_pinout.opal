OPFILE 1.11 PHASOR
Pinout {
	name=IEEE13_ltc_pinout
	incoming {
		item {
			pins {
				item {
					path=network/TR1_633_634/tap_a
				}
				item {
					path=network/TR1_633_634/tap_b
				}
				item {
					path=network/TR1_633_634/tap_c
				}
			}
		}
		item {
			pins {
				item {
					path=network/LD_634/P1
				}
				item {
					path=network/LD_634/P2
				}
				item {
					path=network/LD_634/P3
				}
			}
		}
		item {
			pins {
				item {
					path=network/LD_634/Q1
				}
				item {
					path=network/LD_634/Q2
				}
				item {
					path=network/LD_634/Q3
				}
			}
		}
	}
	outgoing {
		item {
			pins {
				item {
					path=network/634_a/Vmag
				}
				item {
					path=network/634_b/Vmag
				}
				item {
					path=network/634_c/Vmag
				}
			}
		}
		item {
			pins {
				item {
					path=network/TR1_633_634/tap_a
				}
				item {
					path=network/TR1_633_634/tap_b
				}
				item {
					path=network/TR1_633_634/tap_c
				}
			}
		}
	}
}
