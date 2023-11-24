//David Zhang
//Spring 2023
(
var serverButton, initializeButton, trainButton,
saveDataButton, loadDataButton, printDataButton, clearDataButton,
saveNNButton, loadNNButton, clearNNButton,
trainAudioCaption, trainAudioText,
instNameCaption, instNameText, addPointButton,
testAudioCaption, testAudioText, predictButton;
Window.closeAll;

~win = Window("Classification", Rect(width:502, height:206));
~win.alwaysOnTop = true;

serverButton = Button()
.states_([["Boot Server", Color.black]])
.action_({
	arg but;
	s.boot;
});

initializeButton = Button()
.states_([["Initialize", Color.black]])
.action_({
	arg but;
	// Define functions
	~nmfccs = 13;
	~mfccbuf = Buffer.alloc(s,13);
	~timbredata = FluidDataSet(s);
	~labels = FluidLabelSet(s);
	~counter = 0;
	~realtime_analysis = {
		arg buf;
		OSCdef(\thresh,{
			arg msg;
			var thresh = -40;
			//msg[3].postln;
			~threshPassed = (msg[3] >= thresh);
		},"/thresh");
		{
			var sig = PlayBuf.ar(1,buf,BufRateScale.ir(buf),doneAction:2);
			var mfccs = FluidMFCC.kr(sig,~nmfccs,startCoeff:1,maxNumCoeffs:~nmfccs);
			var loudness = FluidLoudness.kr(sig)[0];
			var trig = Impulse.kr(20);
			SendReply.kr(trig,"/thresh", loudness);
			FluidKrToBuf.kr(mfccs,~mfccbuf);
			sig.dup;
		}.play;
	};
	~add_point = {
		arg label;
		var id = "example-%".format(~counter);
		//~threshPassed.postln;
		if (~threshPassed == true)
		{
			~timbredata.addPoint(id,~mfccbuf);
			~labels.addLabel(id,label);
			~counter = ~counter + 1;
			"Point added: ".post; ~counter.postln;
		}
		{"Signal not loud enough".postln}
	};
	// Create a classifier
	~nn = FluidMLPClassifier(s,hiddenLayers:[5],activation:1,maxIter:1000,learnRate:0.1,momentum:0.9,batchSize:5,validation:0);
	"Initialize".postln;
});

trainButton = Button()
.states_([["Train NN", Color.black]])
.action_({
	arg but;
	// run this fitting function for as long as the error is not acceptable
	~iter = 10;
	"Epochs: ".post; ~iter.postln;
	"Start Training".postln;
	for(1, ~iter)
	{
		arg i;
		~nn.fit(~timbredata,~labels,{
			arg loss;
			"Current Loss: ".post; loss.postln;
		});
	};
});

saveDataButton = Button()
.states_([["Save Data", Color.black]])
.action_({
	arg but;
	~timbredata.write(Document.current.dir +/+ "timbredata.json");
	~labels.write(Document.current.dir +/+ "labels.json");
	"Save Data".postln;
});

loadDataButton = Button()
.states_([["Load Data", Color.black]])
.action_({
	arg but;
	~timbredata.read(Document.current.dir +/+ "timbredata.json");
	~labels.read(Document.current.dir +/+ "labels.json");
	"Load Data".postln;
});

printDataButton = Button()
.states_([["Print Data", Color.black]])
.action_({
	arg but;
	~timbredata.print;
	~labels.print;
});

clearDataButton = Button()
.states_([["Clear Data", Color.black]])
.action_({
	arg but;
	~timbredata.clear;
	~labels.clear;
	~counter = 0;
	"Clear Data".postln;
});

saveNNButton = Button()
.states_([["Save NN", Color.black]])
.action_({
	arg but;
	~nn.write(Document.current.dir +/+ "nn.json");
	"Save NN".postln;
});

loadNNButton = Button()
.states_([["Load NN", Color.black]])
.action_({
	arg but;
	~nn.read(Document.current.dir +/+ "nn.json");
	"Load NN".postln;
});

clearNNButton = Button()
.states_([["Clear NN", Color.black]])
.action_({
	arg but;
	~nn.clear;
	"Clear NN".postln;
});

trainAudioCaption = StaticText()
.string = "Enter the audio filename for training";

trainAudioText = TextField()
.action_({
	~trainAudio = Buffer.read(s, Document.current.dir +/+ trainAudioText.string)
})
.align_(\center);

instNameCaption = StaticText()
.string = "Enter the name of the instrument";

instNameText = TextField()
.action_({~instName = instNameText.string})
.align_(\center);

addPointButton = Button()
.states_([["Add Point"], ["Add Point", Color.black, Color.green]])
.action_({
	arg but;
	if(but.value == 1){
		~realtime_analysis.(~trainAudio);
		~addPointRoutine = Routine({loop
			{
				~add_point.(~instName);
				0.2.wait
			}
	}).play;}
	{~addPointRoutine.stop; s.freeAll;}
});

testAudioCaption = StaticText()
.string = "Enter the audio filename for testing";

testAudioText = TextField()
.action_({
	~testAudio = Buffer.read(s, Document.current.dir +/+ testAudioText.string)
})
.align_(\center);

predictButton = Button()
.states_([["Prediction Test"], ["Prediction Test", Color.black, Color.green]])
.action_({ arg but;
	if(but.value == 1){
		~realtime_analysis.(~testAudio);
		~predictRoutine = Routine({loop
			{
				if (~threshPassed == true)
				{
					~nn.predictPoint(~mfccbuf,{
						arg label;
						label.postln;
					});
				} //else:
				{"Nothing".postln};
				0.1.wait
			}
	}).play;}
	{~predictRoutine.stop; s.freeAll;}
});

~win.layout = HLayout(
	VLayout(serverButton, initializeButton, trainButton),
	VLayout(saveDataButton, loadDataButton, printDataButton, clearDataButton),
	VLayout(saveNNButton, loadNNButton, clearNNButton),
	VLayout(trainAudioCaption, trainAudioText,
		instNameCaption, instNameText, addPointButton,
		testAudioCaption, testAudioText, predictButton)
);
~win.front;
)
