: constant current for initialization to a specific membrane potential

NEURON {
	SUFFIX constant
	NONSPECIFIC_CURRENT i
	RANGE i, ic
}

UNITS {
	(mA) = (milliamp)
}

PARAMETER {
	ic = 0 (mA/cm2)
}

ASSIGNED {
	i (mA/cm2)
}

INITIAL {
	i = ic
}

BREAKPOINT {
	i = ic
}
