:
: RandomGenerator.mod
:
: Generates various random numbers which are used by other mechanisms.
: (See "setpointer" in Geometry.hoc)
:
: Thalamocortical convergence studies
: Sebastien Behuret, UNIC/CNRS Paris, 2009
:

NEURON
{ 
	POINT_PROCESS RandomGenerator

	RANGE Seed
	RANGE NormRand1, NormRand2, NormRand3, UniRand1, UniRand2, UniRand3, ExpRand1, ExpRand2, ExpRand3
}

PARAMETER
{
	Seed = 0
}

ASSIGNED
{
	NormRand1
	NormRand2
	NormRand3
	UniRand1
	UniRand2
	UniRand3
	ExpRand1
	ExpRand2
	ExpRand3
}

INITIAL
{
	ResetSeed()
	GenerateRandomNumbers()
}

BREAKPOINT
{
	SOLVE GenerateRandomNumbers
}

PROCEDURE ResetSeed()
{
	set_seed(Seed)
}

PROCEDURE GenerateRandomNumbers()
{
	LOCAL i

	NormRand1 = normrand(0, 1)
	NormRand2 = normrand(0, 1)
	NormRand3 = normrand(0, 1)
	UniRand1 = scop_random()
	UniRand2 = scop_random()
	UniRand3 = scop_random()
	ExpRand1 = exprand(1)
	ExpRand2 = exprand(1)
	ExpRand3 = exprand(1)
}
