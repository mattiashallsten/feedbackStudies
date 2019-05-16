(
s.waitForBoot{
	
	SynthDef(\feedbackSin, {
		arg gate=1, freq=200, modRatio=0.875, feedbackModAm=1.5, sinModAm=1, feedbackSinAm=0.8, atk=10, rel=5, panPos=0, whiteNoiseModAm=0.5;
		var freqMod, local, modulatedFreq, sig, env;
		env = EnvGen.kr(Env.asr(atk, 1, rel), gate, doneAction:2);
		local = DelayC.ar(
			LocalIn.ar(2), 0.05, 0.05);
		freqMod = LFNoise1.ar(0.5 * (local + 1)).range(0.95,1.05);
		freq = freq.lag(2);
		modulatedFreq = freq * freqMod; 
		sig = SinOsc.ar(modulatedFreq, Mix([
			local * feedbackModAm,
			SinOsc.ar(freq * modRatio.lag(5), local * feedbackSinAm.lag(2)) * sinModAm.lag(2),
			BBandPass.ar(WhiteNoise.ar(1!2), freq * 12, 0.1, whiteNoiseModAm)
		]));
		sig = sig * env;
		LocalOut.ar(sig);
		sig = Balance2.ar(sig[0], sig[1], panPos, 0.4);
		Out.ar(0,sig)
	}).add;

	s.sync;

	i = 0;
	
	p = Pbind(
		\instrument, \feedbackSin,
		\newPost, Pfunc{"|------- N E W  S Y N T H --------->".postln},
		\dur, Pwhite(10,50),
		\freq, Pexprand(80, 300).trace(prefix:"|freq: "),
		\feedbackModAm, Pfunc{
			var bottom = (i + 1) * 0.05;
			var top = (i + 1) * 0.2 + 0.2;

			var val = rrand(bottom, top);

			val = val.clip(0.0,1.8);

			i = i + 1;

			("|index: " ++ i ++"\n|feedbackModAm: " ++ val).postln;
			
			val
		},
		//\feedbackModAm, Pwhite(1.2,1.6).trace(prefix:"feedbackModAm: "),
		\sinModAm, Pwhite(0.8,1.1).trace(prefix:"|sinModAm: "),
		\modRatio, Prand([
			1,
			8/9,
			7/8,
			2/3,
			4/3,
			3/2
		],inf).trace(prefix:"|ratio: "),
		\whiteNoiseModAm, Pbrown(0.2,1.5).trace(prefix: "|whiteNoiseModAm: "),
		\atk, Pkey(\dur) * 0.5,
		\rel, Pwhite(10,30),
		\legato, Pwhite(0.6,2.0).trace(prefix: "|legato: "),
		\panPos, Pwhite(-0.5,0.5),
		\endPost, Pfunc{"|---------------------------------->".postln}
	).play
}
)


