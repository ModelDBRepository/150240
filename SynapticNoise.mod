:
: SynapticNoise.mod
:
: This mechanism implements the synaptic bombardment model and
: generates both excitatory and inhibitory components of the synaptic noise.
: (Depends on RandomGenerator.mod, see "setpointer" in Geometry.hoc)
:
: Thalamocortical convergence studies
: Sebastien Behuret, UNIC/CNRS Paris, 2009
:

NEURON {
	POINT_PROCESS SynapticNoise
	RANGE Enabled
	RANGE GeRev, GeMean, GeSigma, GeTau, Ge, GeDelta, GeExponential, GeAmplitude, GiRev, GiMean, GiSigma, GiTau, Gi, GiDelta, GiExponential, GiAmplitude
	RANGE GeGiCorrelation, GeGiPhase, InterCorrelation
	POINTER V
	ELECTRODE_CURRENT I
	POINTER InterGeNormRand, InterGiNormRand, InterGeGiNormRand
}

DEFINE HISTORY_LENGTH 256

UNITS
{
	(mV) = (millivolt)
	(nS) = (nanosiemens)
}

PARAMETER
{
	mydt = 0.1 (ms)

	Enabled = 1

	GeRev = 0 (mV)
	GeMean = 12 (nS)
	GeSigma = 3.0 (nS)
	GeTau = 2.7 (ms)
	GiRev = -75 (mV)
	GiMean = 57 (nS)
	GiSigma = 6.6 (nS)
	GiTau = 10.5 (ms)
	
	GeGiCorrelation = 0
	GeGiPhase = 0
	InterCorrelation = 0
}

ASSIGNED
{
	Ge (nS)
	GeDelta (nS)
	GeExponential
	GeAmplitude (nS)
	Gi (nS)
	GiDelta (nS)
	GiExponential
	GiAmplitude (nS)

	V (mV)
	I (nA)

	InterGeNormRand
	InterGiNormRand
	InterGeGiNormRand

	GeGiNormRandHistoryA[HISTORY_LENGTH]
	GeGiNormRandHistoryB[HISTORY_LENGTH]
}

INITIAL
{
	LOCAL i

	Ge = 0
	Gi = 0

	I = 0

	FROM i = 0 TO HISTORY_LENGTH - 1
	{
		GeGiNormRandHistoryA[i] = 0
		GeGiNormRandHistoryB[i] = 0
	}

	UpdateParameters()
}

PROCEDURE UpdateParameters()
{
	GeDelta = 0
	GiDelta = 0

	if(GeTau != 0)
	{
		GeExponential = exp(- dt / GeTau)
		GeAmplitude = GeSigma * sqrt((1 - exp(- 2 * dt / GeTau)))
	}

	if(GiTau != 0)
	{
		GiExponential = exp(- dt / GiTau)
		GiAmplitude = GiSigma * sqrt((1 - exp(- 2 * dt / GiTau)))
	}
}

PROCEDURE ShiftGeGiNormRandHistoryA(GeGiNormRand)
{
	LOCAL HistoryLength
	
	HistoryLength = HISTORY_LENGTH

	VERBATIM

		unsigned int i;

		for (i = (unsigned int)_lHistoryLength - 1; i >= 1; i--)
		{
			GeGiNormRandHistoryA[i] = GeGiNormRandHistoryA[i - 1];
		}

		GeGiNormRandHistoryA[0] = _lGeGiNormRand;

	ENDVERBATIM
}

PROCEDURE ShiftGeGiNormRandHistoryB(GeGiNormRand)
{
	LOCAL HistoryLength
	
	HistoryLength = HISTORY_LENGTH

	VERBATIM

		unsigned int i;

		for (i = (unsigned int)_lHistoryLength - 1; i >= 1; i--)
		{
			GeGiNormRandHistoryB[i] = GeGiNormRandHistoryB[i - 1];
		}

		GeGiNormRandHistoryB[0] = _lGeGiNormRand;

	ENDVERBATIM
}

BREAKPOINT
{
	LOCAL GeNormRand, GiNormRand, GeGiNormRand, GePhase, GiPhase

	GeNormRand = sqrt(1 - InterCorrelation) * normrand(0, 1) + sqrt(InterCorrelation) * InterGeNormRand
	GiNormRand = sqrt(1 - InterCorrelation) * normrand(0, 1) + sqrt(InterCorrelation) * InterGiNormRand
	ShiftGeGiNormRandHistoryA(sqrt(1 - InterCorrelation) * normrand(0, 1) + sqrt(InterCorrelation) * InterGeGiNormRand)

	if (GeGiPhase == 0)
	{
		GePhase = 0
		GiPhase = 0
	}
	else if (GeGiPhase > 0)
	{
		GePhase = 0
		GiPhase = floor(GeGiPhase / mydt)
	}
	else
	{
		GePhase = floor(- GeGiPhase / mydt)
		GiPhase = 0
	}

	if (Enabled == 1)
	{
		SOLVE OUProcess

		if (GeTau == 0)
		{
		   GeDelta = GeSigma * (sqrt(1 - GeGiCorrelation) * GeNormRand + sqrt(GeGiCorrelation) * GeGiNormRandHistoryA[GePhase])
		}

		if (GiTau == 0)
		{
	   	GiDelta = GiSigma * (sqrt(1 - GeGiCorrelation) * GiNormRand + sqrt(GeGiCorrelation) * GeGiNormRandHistoryA[GiPhase])
		}

		Ge = GeMean + GeDelta
		Gi = GiMean + GiDelta

		if( Ge < 0)
		{
			Ge = 0
		}

		if (Gi < 0)
		{
			Gi = 0
		}

		UNITSOFF
			I = (Ge * (GeRev - V) + Gi * (GiRev - V)) * 1e-3
		UNITSON
	}
	else
	{
		Ge = 0 
		Gi = 0

		I = 0
	}
}

PROCEDURE OUProcess()
{
	LOCAL GeNormRand, GiNormRand, GeGiNormRand, GePhase, GiPhase

	GeNormRand = sqrt(1 - InterCorrelation) * normrand(0, 1) + sqrt(InterCorrelation) * InterGeNormRand
	GiNormRand = sqrt(1 - InterCorrelation) * normrand(0, 1) + sqrt(InterCorrelation) * InterGiNormRand
	ShiftGeGiNormRandHistoryB(sqrt(1 - InterCorrelation) * normrand(0, 1) + sqrt(InterCorrelation) * InterGeGiNormRand)

	if (GeGiPhase == 0)
	{
		GePhase = 0
		GiPhase = 0
	}
	else if (GeGiPhase > 0)
	{
		GePhase = 0
		GiPhase = floor(GeGiPhase / mydt)
	}
	else
	{
		GePhase = floor(- GeGiPhase / mydt)
		GiPhase = 0
	}

   if (GeTau != 0)
   {
		GeDelta = GeExponential * GeDelta + GeAmplitude * (sqrt(1 - GeGiCorrelation) * GeNormRand + sqrt(GeGiCorrelation) * GeGiNormRandHistoryB[GePhase])
   }

   if (GiTau != 0)
   {
		GiDelta = GiExponential * GiDelta + GiAmplitude * (sqrt(1 - GeGiCorrelation) * GiNormRand + sqrt(GeGiCorrelation) * GeGiNormRandHistoryB[GiPhase])
   }
}