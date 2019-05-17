(
s.waitForBoot{
	SynthDef(\feedbackSin, {
		arg gate=1, freq=200, modRatio=0.875, feedbackModAm=1.5, sinModAm=1, feedbackSinAm=0.8, atk=10, rel=5, panPos=0, whiteNoiseModAm=0.5, lfoModAm=0.05, delayTime=0.05, hpfCutoff=80, chopAmpModAm=0.0, chopAmpModRate=12;
		var freqMod, local, modulatedFreq, sig, env;
		env = EnvGen.kr(Env.asr(atk, 1, rel), gate, doneAction:2);
		local = DelayC.ar(
			LocalIn.ar(2), 0.2, delayTime);
		local = BHiPass.ar(local, hpfCutoff, 0.7);
		freqMod = LFNoise1.ar(0.5 * (local + 1)).range(1-lfoModAm,1+lfoModAm);
		freq = freq.lag(2);
		modulatedFreq = freq * freqMod; 
		sig = SinOsc.ar(modulatedFreq, Mix([
			local * feedbackModAm,
			SinOsc.ar(freq * modRatio.lag(5), local * feedbackSinAm.lag(2)) * sinModAm.lag(2),
			BBandPass.ar(WhiteNoise.ar(1!2), freq * 12, 0.1, whiteNoiseModAm)
		]));
		sig = sig * Pulse.kr(chopAmpModRate, 0.8).range(1 - chopAmpModAm, 1);
		sig = sig * env;
		LocalOut.ar(sig);
		sig = Balance2.ar(sig[0], sig[1], panPos, 0.4);
		Out.ar(0,sig)
	}).add;

	s.sync;

	i = 0;

	~chordIndex = -1;
	~chords = [
		[11/10, 4/3, 5/3, 5/2],
		[1, 7/6, 3/2, 7/4],
		[1, 4/3, 11/8, 9/4],
		[5/4, 11/8, 3/2, 15/8],

	];

	p = Pbind(
		\instrument, \feedbackSin,
		// duration is a sequence running from 0.3 to 4.0, and an added 6 second duration
		\dur, Pseq((0.3,0.4..4.0) ++ 6.0,inf),
		// \changeChord is a function to change the chord everytime the duration is 0.3, i.e.
		// the start of the duration sequence.
		\changeChord, Pfunc{|e|
			if(e[\dur] == 0.3, {
				~chordIndex = ~chordIndex + 1;
				~chordIndex = ~chordIndex % ~chords.size;
			});

			~chordIndex.postln
			("Ratios: " + ~chords[~chordIndex].asString).postln;
		},
		// frequency is determined by the ratios in the current array from the two-dimensional
		// ~chords. if the duration is 6.0, the Pbind generates a rest. this could probably be
		// done easier with the \type keyword, going from \note to \rest.
		\freq, Pfunc{|e|
			var val;

			val = ~chords[~chordIndex].choose;

			if(e[\dur] == 6.0, {
				"rest".postln;
				Rest()
			}, { 100 * val
			});
		},
		// legato is determined by the duration -- making sure that every event lasts 4 seconds.
		\legato, Pfunc{|e|
			4 / e[\dur]},
		\feedbackModAm, Pkey(\dur) * 0.6,
		\whiteNoiseModAm, Pwhite(0.1,0.5),
		\hpfCutoff, Pkey(\freq) * 4,
		\lfoModAm, 0.001,
		\atk, 5,
		\rel, 14,
		\sinModAm, 1.2,
		\modRatio, Pwhite(1.99,2.01),
		\delayTime, 0.01,
		\chopAmpModAm, Pkey(\dur).linlin(0.3,4.0,0.0,1.0),
		\chopAmpModRate, 14

	).play;
}
)