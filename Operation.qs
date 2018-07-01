namespace Quantum.ShorQsharp
{
    open Microsoft.Quantum.Primitive;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Extensions.Math;

	operation SamplePeriod (radix: Int, modulus: Int ) : (Int)
    {
        body
        {
			AssertBoolEqual(IsCoprime(radix,modulus), true, "Radix and modulus must be coprime.");

			mutable measuredPeriod = 0;
			let registersize = 2*BitSize(modulus)+1;

			using ( targetState = Qubit[BitSize(modulus)] )
			{
				using ( controlRegister = Qubit[registersize] )
				{
					IntegerIncrementLE( 1 , LittleEndian(targetState) );
					QuantumPhaseEstimation( DiscreteOracle(PowerOracle(radix,modulus,_,_)) , LittleEndian(targetState) , BigEndian(controlRegister) );
					set measuredPeriod = MeasureIntegerBE( BigEndian(controlRegister) );
					ResetAll(targetState);
				}
			}

		    let cleanedPeriod = AbsI(Snd( ContinuedFractionConvergent( Fraction(measuredPeriod, 2^(registersize)) , modulus ) )) ;			
			
			return  ExpMod ( radix, cleanedPeriod/2 , modulus );
		}
    }

	operation PowerOracle (radix: Int, modulus: Int, power: Int, target: Qubit[]) : ()
	{
		body
		{
			ModularMultiplyByConstantLE( ExpMod(radix,power,modulus), modulus, LittleEndian(target));
		}
		adjoint auto
		controlled auto
		adjoint controlled auto
	}
}