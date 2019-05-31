:
: RetinalInput.mod
:
: This mechanism describes the retinal input spike-train.
: (Depends on RandomGenerator.mod, see "setpointer" in Geometry.hoc)
:
: Thalamocortical convergence studies
: Sebastien Behuret, UNIC/CNRS Paris, 2009
:

NEURON
{
	POINT_PROCESS RetinalInput

	RANGE Frequency, Phase, Noise, Gamma, InterCorrelation
	RANGE Spike, Spike10
	RANGE LastISI, LastSpike, SpikeCount
	RANGE SpikeTime
	POINTER ExpRand1, ExpRand2, ExpRand3
}

PARAMETER
{
	Frequency = 5 (/s)
	Phase = 0 (ms)
	Noise = 0
	Gamma = 0
	InterCorrelation = 0
}

ASSIGNED
{
	Spike
	Spike10

	LastISI (ms)
	LastSpike (ms)
	SpikeCount

	SpikeTime

	ExpRand1
	ExpRand2
	ExpRand3
}

INITIAL
{
	Spike = 0
	Spike10 = 0

	LastISI = 0
	LastSpike = 0
	SpikeCount = 0

	CalculateSpikeTime()
	SpikeTime = SpikeTime + Phase
}

BREAKPOINT
{
	SOLVE TriggerSpike
}

PROCEDURE CalculateSpikeTime()
{
	LOCAL i

	UNITSOFF
		if (Noise != 1) : Will use an exponential distribution if Noise <> 1
		{
			if (scop_random() <= InterCorrelation)
			{
				SpikeTime = t + 1e3 * (1 - Noise + Noise * ExpRand1) / Frequency
			}
			else
			{
				SpikeTime = t + 1e3 * (1 - Noise + Noise * exprand(1)) / Frequency
			}
		}
		else : InterCorrelation will not work if Gamma > 3
		{
			SpikeTime = t

			if (Gamma == 3 && scop_random() <= InterCorrelation)
			{
				SpikeTime = SpikeTime + (1e3 / (Frequency * Gamma)) * (ExpRand1 + ExpRand2 + ExpRand3)
			}
			else
			{
				FROM i = 1 TO Gamma
				{
					SpikeTime = SpikeTime + 1e3 * exprand(1) / (Frequency * Gamma)			
				}
			}
		}
	UNITSON
}

PROCEDURE TriggerSpike()
{
	if (t >= SpikeTime)
	{
		Spike = 1
		Spike10 = 10

		LastISI = t - LastSpike
		LastSpike = t
		SpikeCount = SpikeCount + 1

		CalculateSpikeTime()
	}
	else
	{
		Spike = 0
		Spike10 = 0
	}
}