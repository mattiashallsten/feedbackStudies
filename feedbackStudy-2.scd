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

	SynthDef(\reed, {
		arg buf = 0, rate = 1, length=1;
		var sig, env;

		env = EnvGen.kr(Env([0,1,1,0],[0.2, length - 0.5, 0.3]), doneAction:2);
		sig = PlayBuf.ar(2, buf, rate * BufRateScale.kr(buf));
		sig = sig * env;

		Out.ar(0,sig)
	}).add;

	~bufferFolder = PathName("/Users/mattiashallsten/Music/Ljud/Toner für Bläserquintett");
	~buffers = [];
	
	~bufferFolder.entries.do{|path, i|
		~buffers.add(Buffer.read(s, path.fullPath))
	};

	s.sync;

	i = 0;

	~chordIndex = -1;
	~chords = [
		[11/10, 4/3, 5/3, 5/2],
		[1, 7/6, 3/2, 7/4],
		[1, 4/3, 11/8, 9/4],
		[5/4, 11/8, 3/2, 15/8],

	].scramble;

	p = Pbind(
		\instrument, \feedbackSin,
		\dur, Pseq((0.3,0.4..4.0) ++ 6.0,inf),
		\changeChord, Pfunc{|e|
			if(e[\dur] == 0.3, {
				
				~chordIndex = ~chordIndex + 1;
				~chordIndex = ~chordIndex % ~chords.size;
				
				
			});

			~chordIndex.postln
		},
		\freq, Pfunc{|e|
			var val;

			val = ~chords[~chordIndex].choose;

			if(e[\dur] == 6.0, {
				"rest".postln;
				Rest()
			}, { 100 * val
			});
		},
		\legato, Pfunc{|e|
			4 / e[\dur]},
		\feedbackModAm, Pkey(\dur) * 0.6,
		//\feedbackModAm, Pwrand([0.2, Pwhite(0.9,1.6,1)],[4,1].normalizeSum, inf).trace(prefix:"feedbackModAm: "),
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

	Pbind(
		\instrument, \reed,
		\buf, Pseq(~buffers,inf),
		\rate, Pfunc{
			var val = ~chords[~chordIndex].choose * [1,0.5].choose;

			// "reed!".postln;
			
			1.445 * val / 2;
		},
		\dur, Pwhite(5.0,8.0),
		\length, Pfunc{|e|
			var val = e[\buf].numFrames;

			val = val / 44100;
			val = val * e[\rate];

			val
		}
	)
}
)