(
~numSines = 2;
s.waitForBoot{
	SynthDef(\feedbackSinPerc, {
		|
		gate=1, freq=200, modRatio=0.875, feedbackModAm=1.5, sinModAm=1, feedbackSinAm=0.8,
		atk=10, rel=5, susTime=1, panPos=0, whiteNoiseModAm=0.5, lfoModAm=0.05, delayTime=0.05,
		hpfCutoff=80, hpfRez=0.7, chopAmpModAm=0.0, chopAmpModRate=12, demandRate=5, out=0,
		pitchEnvDest=1, pitchEnvT1=2.0, pitchEnvT2=0.3
		|
		var freqMod, local, modulatedFreq, sig, env, trigger, pitchEnv;

		trigger = Impulse.kr(demandRate);
		pitchEnv = EnvGen.kr(Env([1,1,pitchEnvDest],[pitchEnvT1,pitchEnvT2]));
		
		env = EnvGen.kr(Env([0,1,1,0],[atk,susTime,rel]), doneAction:2);
		local = DelayC.ar(
			LocalIn.ar(2), 0.2, delayTime);
		local = BHiPass.ar(local, hpfCutoff, hpfRez);
		freqMod = LFNoise1.ar(0.5!~numSines * (local + 1)).range(1-lfoModAm,1+lfoModAm);
		freq = freq.lag(2) * pitchEnv;
		modulatedFreq = freq * freqMod; 
		sig = SinOsc.ar(modulatedFreq, Mix([
			local * feedbackModAm,
			SinOsc.ar(freq * modRatio.lag(5), local * feedbackSinAm.lag(2)) * sinModAm.lag(2),
			BBandPass.ar(WhiteNoise.ar(1!~numSines), (freq * 12).clip(20,18000), 0.1, whiteNoiseModAm)
		]));
		sig = Splay.ar(sig);
		sig = sig * Pulse.kr(Demand.kr(trigger, 0, Dwhite(2,18)), 0.8).range(1 - chopAmpModAm, 1);
		sig = sig * env;
		LocalOut.ar(sig);
		sig = Balance2.ar(sig[0], sig[1], panPos, 0.4);
		Out.ar(out,sig)
	}).add;

	~chords = [
		[1,9/4,3/2],
		[1,4/3,5/3],
		[1,4/3,7/4],
		[5/6,5/4,3/2],
		[9/8, 5/4, 7/4, 7/3]
	];

	~chordIndex = rrand(0, ~chords.size - 1);
	~lfoModAm = 0;
	~modRatio = 1;
	~feedbackModAm = 0.3;

	s.sync;

	r = Routine{
		loop {
			var time = rrand(0.2, 5.0);
			Synth(\feedbackSinPerc,[
				\freq, 200 * ~chords[~chordIndex].choose * ((1..3) ++ 0.5).choose,
				\lfoModAm, ~lfoModAm * rrand(0.0,1.0),
				\modRatio, ~modRatio,
				\atk, rrand(0.2,3.0),
				\susTime, time * rrand(0.5,2.0);
				\rel, rrand(0.2,2.0),
				\feedbackModAm, ~feedbackModAm,
				\sinModAm, 1.5,
				\panPos, rrand(-1.0,1.0),
				\whiteNoiseModAm, rrand(0.5,2.0)
			]);
			wait(time);
		}
	}.play;

	~changes = Routine{
		loop {
			var time = rrand(10,30);
			~chordIndex = rrand(0, ~chords.size - 1);
			~lfoModAm = rrand(0.0,0.05);
			~modRatio = [1,4/3,3/2,0.5].choose;
			~feedbackModAm = rrand(0.2,0.9);

			"|-----N E W  S E T T I N G S------".postln;
			("|modRatio:\t\t" + ~modRatio).postln;
			("|lfoModAm:\t\t" + ~lfoModAm).postln;
			("|chordIndex:\t" + ~chordIndex).postln;
			("|feedbackModAm:\t" + ~feedbackModAm).postln;

			wait(time)
		}
	};

	Routine {
		wait(20);
		~changes.play
	}.play;	
}
)