(
~bufM = Buffer.readChannel(s, Platform.resourceDir +/+ "sounds/SS-drums-forgrain.wav", channels: 0, bufnum:1);
~bufS = Buffer.readChannel(s, Platform.resourceDir +/+ "sounds/Quebec-drums-forgrain.wav", channels: 0, bufnum:2);
~bufD = Buffer.readChannel(s, Platform.resourceDir +/+ "sounds/Str-PH-01.wav", channels: 0, bufnum:3)

)

(

var synth1,synth2, responder;


synth1 =	SynthDef("wekis", {|amp 0.1, gate 1, buf3 3, dur=0.1, pos=0.0, pan=0,weight=0.5|
			var env, gr1, trig;
			env = EnvGen.kr(Env.asr(1.1, 0.9, 3), gate, doneAction:2);
			trig = Dust.ar(250);
	        gr1 = GrainBuf.ar(2, trig, dur, buf3, 1, 50000*pos-SinOsc.ar(weight*8, 0, 0.01),2,0.5*weight-1.0);
	        Out.ar(0, (1-weight)*gr1*(amp)*2*env);
}).play;


synth2 =	SynthDef("wekis", {|amp 0.05, gate 1, buf1 1, buf2 2, dur=0.1, pos=0.0, pan=0,weight=0.5|
			var env, gr1,gr2, del, trig;
			env = EnvGen.kr(Env.asr(1, 0.9, 3), gate, doneAction:2);
			trig = Dust.ar(500);
	       gr1 = GrainBuf.ar(2, trig, dur, buf1, 0.9, 1000*pos+SinOsc.ar(weight*4, 0, 0.01),2,pan);
		   gr2 = GrainBuf.ar(2, trig, dur, buf2, 1.1, 3000*pos-SinOsc.ar(weight*7, 0, 0.01),2,-1*pan);
           Out.ar(0, weight*(gr1+gr2)*0.6*amp*2*env);
}).play;



~receiver.free; //free the old reciever if it already exists
~receiver = NetAddr.new("127.0.0.1", 57120);    // create the NetAddr ... only the language port 57120 actually works
~responder.free; //if there is an old responder ... then free it first
~responder = OSCFunc(
	{ | msg |

		var specs = Array.newClear(5);

		msg.postln;

		specs[0] =  ControlSpec(0, 1.0,\lin);
		specs[1] = ControlSpec(0, 0.2,\lin);
		specs[2] = ControlSpec(0.1, 1.0,\lin);
		specs[3] =  ControlSpec(100, 1000,\exp);
		specs[4] = ControlSpec(-0.8, 0.8,\lin);


		synth1.set(\dur, specs[0].map(msg[1]));
		synth1.set(\amp, specs[1].map(msg[2]));
		synth1.set(\weight, specs[2].map(msg[3]));
		synth1.set(\pos, specs[3].map(msg[4]));
		synth1.set(\pan, specs[4].map(msg[5]));

		synth2.set(\dur, specs[0].map(msg[1]));
		synth2.set(\amp, specs[1].map(msg[2]));
		synth2.set(\weight, specs[2].map(msg[3]));
		synth2.set(\pos, specs[3].map(msg[4]));
		synth2.set(\pan, specs[4].map(msg[5]));


	},
'/wek/outputs');

)