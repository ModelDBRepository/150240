:
: ConductancePattern.mod
:
: Generates conductance patterns mimicking AMPA and GABAA postsynaptic potentials.
:
: Thalamocortical convergence studies
: Sebastien Behuret, UNIC/CNRS Paris, 2009
:

NEURON
{
	POINT_PROCESS ConductancePattern
	RANGE BaseDelay, DelayExpMean, DelayExpNoise, DelayGaussMean, DelayGaussStd, DelayGaussNoise, Weight, Tau, ERev, Threshold, DeadTime, ExpireTime
	POINTER V, Trigger
	RANGE G
	ELECTRODE_CURRENT I
}

DEFINE MAX_INPUTS 1024

UNITS
{
	(nA) = (nanoampere)
	(mV) = (millivolt)
	(nS) = (nanosiemens)
}

PARAMETER
{
	mydt = 0.1 (ms)

	BaseDelay = 0 (ms)
	DelayExpMean = 0 (ms)
	DelayExpNoise = 0
	DelayGaussMean = 0 (ms)
	DelayGaussStd = 1 (ms)
	DelayGaussNoise = 0
	Weight = 10 (nS)
	Tau = 1 (ms)
	ERev = 0 (mV)
	Threshold = 0
	DeadTime = 1 (ms)
	ExpireTime = 10 (ms)
}

ASSIGNED
{
	V (mV)
	Trigger

	G (nS)
	I (nA)

	LastTime (ms)
	InputTimes[MAX_INPUTS] (ms)
	InputAmplitudes[MAX_INPUTS]
}

INITIAL
{
	LOCAL i

	G = 0
	I = 0

	LastTime = - (DeadTime + mydt)

	UpdateParameters()
}

BREAKPOINT
{
	SOLVE ProcessInputs
}

PROCEDURE UpdateParameters()
{
	FROM i = 0 TO MAX_INPUTS - 1
	{
		InputTimes[i] = ExpireTime
		InputAmplitudes[i] = 0
	}
}

PROCEDURE DetectInput()
{
	LOCAL Amplitude, i, j

	Amplitude = 0

	if (t - LastTime > DeadTime)
	{
		if (Trigger > Threshold)
		{
			Amplitude = 1
			LastTime = t
		}
	}

	if (Amplitude > 0)
	{
		i = 0
		j = 0

		while (i < MAX_INPUTS && j == 0)
		{
			if (InputTimes[i] >= ExpireTime)
			{
				InputTimes[i] = - (BaseDelay + DelayExpMean * (1 - DelayExpNoise + DelayExpNoise * exprand(1)))

				if (DelayGaussNoise == 1)
				{
					InputTimes[i] = InputTimes[i] - normrand(DelayGaussMean, DelayGaussStd)
				}

				InputAmplitudes[i] = Amplitude

				j = 1
			}
			else
			{
				i = i + 1
			}
		}

		if (j == 0)
		{
			printf("Detected input couldn't be added!\n")
		}
	}
}

FUNCTION TraverseInputs() (nS)
{
	LOCAL i, j

	TraverseInputs = 0

	FROM i = 0 TO MAX_INPUTS - 1
	{
		if (InputTimes[i] < ExpireTime)
		{
			if (InputTimes[i] >= 0)
			{
				TraverseInputs = TraverseInputs + Weight * InputAmplitudes[i] * (InputTimes[i] / Tau) * exp(- (InputTimes[i] - Tau) / Tau)
			}

			InputTimes[i] = InputTimes[i] + mydt
		}
	}
}

PROCEDURE ProcessInputs()
{
	DetectInput()
	G = TraverseInputs()

	UNITSOFF
		I = G * (ERev - V) * 1e-3
	UNITSON
}