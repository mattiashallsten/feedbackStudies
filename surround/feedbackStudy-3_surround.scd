s.record(path: "~/Dropbox/Dokument/SuperCollider/feedbackStudies/feedbackStudy-3.wav");
s.stopRecording
(
s.waitForBoot{
	SynthDef(\feedbackSin, {
		|
		gate=1, freq=200, modRatio=0.875, feedbackModAm=1.5, sinModAm=1, feedbackSinAm=0.8,
		atk=10, rel=5, panPos=0, whiteNoiseModAm=0.5, lfoModAm=0.05, delayTime=0.05,
		hpfCutoff=80, hpfRez=0.7, chopAmpModAm=0.0, chopAmpModRate=12, demandRate=5, out=0,
		pitchEnvDest=1, pitchEnvT1=2.0, pitchEnvT2=0.3, amp=0.5
		|
		var freqMod, local, modulatedFreq, sig, env, trigger, pitchEnv;

		trigger = Impulse.kr(demandRate);
		pitchEnv = EnvGen.kr(Env([1,1,pitchEnvDest],[pitchEnvT1,pitchEnvT2]));
		
		env = EnvGen.kr(Env.asr(atk, 1, rel), gate, doneAction:2);
		local = DelayC.ar(
			LocalIn.ar(10), 0.2, delayTime);
		local = BHiPass.ar(local, hpfCutoff, hpfRez);
		freqMod = LFNoise1.ar(0.5!20 * (local + 1)).range(1-lfoModAm,1+lfoModAm);
		freq = freq.lag(2) * pitchEnv;
		modulatedFreq = freq * freqMod; 
		sig = SinOsc.ar(modulatedFreq, Mix([
			local * feedbackModAm,
			SinOsc.ar(freq * modRatio.lag(5), local * feedbackSinAm.lag(2)) * sinModAm.lag(2),
			BBandPass.ar(WhiteNoise.ar(1!10), (freq * 12).clip(20,18000), 0.1, whiteNoiseModAm)
		]));
		sig = sig * Pulse.kr(Demand.kr(trigger, 0, Dwhite(2,18)), 0.8).range(1 - chopAmpModAm, 1);
		sig = sig * env * amp;
		LocalOut.ar(sig);
		Out.ar(out,sig)
	}).add;

	p = Pbind(
		\instrument, \feedbackSin,
		\initPrint, Pfunc{
			"|---------NEW SYNTH----------".postln
		},
		\dur, Pwhite(3.0,10.0),
		\freq, Phprand(Pseq((400,360..60).mirror,inf),1200).trace(prefix: "|freq: ")
		/ Pseq((1,1.5..8),inf).trace(prefix: "|freq div: ")
		* Pwrand([
			1,
			[1,Prand([0.5,2,3/2,7/4])]
		],[2,1].normalizeSum,inf).trace(prefix: "|freq harmony: "),
		\whiteNoiseModAm, Pwhite(0.4,3.0),
		\demandRate, Pwhite(0.7,1.4),
		\chopAmpModAm, Phprand(0.6,1.0),
		\legato, Pseq((0.7,0.8..2.0),inf).trace(prefix: "|legato: "),
		\panPos, Pwhite(-1.0,1.0),
		\modRatio, Prand([1,9/8,11/10,7/4],inf),
		\atk, Pkey(\dur) * Pwhite(0.2,0.5),
		\rel, Pwhite(4.0,Pseq((7.0,7.5..20),inf)),
		\delayTime, Pwhite(0.01,0.14),
		\hpfCutoff, Pexprand(
			Pseq((80,75..20).mirror,inf),
			200
		),
		\hpfRez, Pwhite(0.4,1.0),
		\feedbackModAm, Pwhite(0.9,Pseq((3.0,3.4..6.0).mirror,inf)),
		\out, 0,
		\pitchEnvDest, 1,
		//\pitchEnvDest, Pwrand([1, Prand([4/3,3/2,9/8])],[4,1].normalizeSum, inf).trace(prefix: "pitchEnvDest: "),
		\pitchEnvT1, Pkey(\dur) * 0.2,
		\pitchEnvT2, Pwhite(0.14,0.4),
		\endPrint, Pfunc{
			"|----------------------------".postln
		}
	).play
}
)