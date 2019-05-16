(
s.waitForBoot{
	SynthDef(\feedbackSin, {
		|
		gate=1, freq=200, modRatio=0.875, feedbackModAm=1.5, sinModAm=1, feedbackSinAm=0.8,
		atk=10, rel=5, panPos=0, whiteNoiseModAm=0.5, lfoModAm=0.05, delayTime=0.05,
		hpfCutoff=80, hpfRez=0.7, chopAmpModAm=0.0, chopAmpModRate=12, demandRate=5, out=0
		|
		var freqMod, local, modulatedFreq, sig, env, trigger;

		trigger = Impulse.kr(demandRate);
		
		env = EnvGen.kr(Env.asr(atk, 1, rel), gate, doneAction:2);
		local = DelayC.ar(
			LocalIn.ar(2), 0.2, delayTime);
		local = BHiPass.ar(local, hpfCutoff, hpfRez);
		freqMod = LFNoise1.ar(0.5 * (local + 1)).range(1-lfoModAm,1+lfoModAm);
		freq = freq.lag(2);
		modulatedFreq = freq * freqMod; 
		sig = SinOsc.ar(modulatedFreq, Mix([
			local * feedbackModAm,
			SinOsc.ar(freq * modRatio.lag(5), local * feedbackSinAm.lag(2)) * sinModAm.lag(2),
			BBandPass.ar(WhiteNoise.ar(1!2), (freq * 12).clip(20,18000), 0.1, whiteNoiseModAm)
		]));
		sig = sig * Pulse.kr(Demand.kr(trigger, 0, Dwhite(2,18)), 0.8).range(1 - chopAmpModAm, 1);
		sig = sig * env;
		LocalOut.ar(sig);
		sig = Balance2.ar(sig[0], sig[1], panPos, 0.4);
		Out.ar(out,sig)
	}).add;

	SynthDef(\limiter, {|in=0|
		var sig = In.ar(in, 2);

		sig = Limiter.ar(sig, 0.8);

		Out.ar(0,sig)
	}).add;

	~masterBus = Bus.audio(s,2);
	~limiter = Synth(\limiter, [\in, ~masterBus]);

	p = Pbind(
		\instrument, \feedbackSin,
		\dur, Pwhite(3.0,10.0),
		\freq, Phprand(400,1200).trace(prefix: "freq: ")
		* Pseq((1,0.9..0.2),inf)
		* Pwrand([
			1,
			[1,Prand([2,3/2,7/4])]
		],[2,1].normalizeSum,inf),
		\demandRate, Pwhite(0.7,1.4),
		\chopAmpModAm, Phprand(0.6,1.0),
		\legato, Pseq((0.7,0.8..2.0),inf),
		\panPos, Pwhite(-1.0,1.0),
		\modRatio, Prand([1,9/8,11/10],inf),
		\atk, Pkey(\dur) * Pwhite(0.2,0.5),
		\rel, Pwhite(4.0,7.0),
		\delayTime, Pwhite(0.01,0.14),
		\hpfCutoff, Pexprand(80,200),
		\hpfRez, Pwhite(0.4,1.0),
		\feedbackModAm, Pwhite(0.9,2.0),
		\out, ~masterBus
	).play
}
)