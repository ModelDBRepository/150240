:
: SineWaveCurrent.mod
:
: This mechanism generates sine-wave currents.
:
: Thalamocortical convergence studies
: Sebastien Behuret, UNIC/CNRS Paris, 2009
:

NEURON {
	POINT_PROCESS SineWaveCurrent
	RANGE Enabled, Amplitude, Frequency, Phase, Offset
	ELECTRODE_CURRENT I
}

UNITS
{
	(mV) = (millivolt)
	(nA) = (nanoamp)
}

PARAMETER
{
	Enabled = 0
	Amplitude = 0.1 (nA)
	Frequency = 15 (/s) 
	Phase = 0
	Offset = 0 (nA)
}

ASSIGNED
{
	I (nA)
}

INITIAL
{
	I = 0
}

PROCEDURE UpdateParameters()
{
}

BREAKPOINT
{
	SOLVE Injection
}

PROCEDURE Injection()
{
	if (Enabled == 1)
	{
		UNITSOFF

			I = sin((t / 1000.0) * 6.28318531 * Frequency + Phase) * Amplitude + Offset
		
		UNITSON
	}
	else
	{
		I = 0
	}
}