Framer.Extras.Hints.disable()
# Set-up FlowComponent
pwidth = 1280
pheight = 720


SpeechRecognition = window.SpeechRecognition or window.webkitSpeechRecognition
# Create a new recognizer
recognizer = new SpeechRecognition
# Start producing results before the person has finished speaking
recognizer.interimResults = true
# Set the language of the recognizer

#
#recognizer.continuous = true
recognizer.interimResults = false

recognizing = false
recognizer.onstart = (event) ->
	recognizing = true
	vcircle.animate
		borderColor: "#50E3C2"
		#scale: 1
		options:
			time: 0.3

recognizer.onend = (event) ->
	recognizing = false
	vcircle.animate
		borderColor: ccolor
		#scale: 0.7
		options:
			time: 0.3
	Utils.delay 1, ->
		vcircle.animate
			borderColor: "white"
			#scale: 0.7
			options:
				time: 0.3

startListen = () ->
	if !recognizing
		recognizer.abort()
		recognizer.start()
		listenSound.play()

# Speech Synthesis
synth = window.speechSynthesis

videow = 640
videoh = 360
videofactor = 4

tourVideo = new VideoLayer
	video: "videos/htwberlin.mov"
	y: 0
	width: pwidth
	height: pheight

lookVideo = new VideoLayer
	video: "videos/stoplook.m4v"
	y: 0
	width: pwidth
	height: pheight
lookVideo.visible = false

whereto = null
rstop = null
rstart = null
rnach = null
toVocab = null
toUni = null
toK = null
toSE = null
toOffice = null
noComp = null
rcancel = null
rbegin = null
rsorry = null
rsorrycont = null
ccolor = null

htwframe = false
beginning = true

#default
sprache = "en"
#sprache = "de"
setSprache = (s) ->
	sprache = s
	if s == "en"
		recognizer.lang = 'en-US'
		synth.lang = 'en-US'
		toVocab = ['to', 'towards', 'till', 'into', 'in']
		rstop = /\b(?:stop|stopp|cancel|break|stay|pause)\b/i
		rstart = /\b(?:go|drive|ride|continue|start|resume|keep)\b/i
		rnach = /\b(?:to|towards|till|into|in)\b/i
		whereto = 'Welcome! Where would you like to go today?'
		toUni = 'Ok, starting the ride towards the Communication design building!'
		toK = /\b(?:Communication|Design|building|Campus|Wilhelminenhof)\b/i
		toSE = /\b(?:sehen|ernten|office|offices|bureau|and)\b/i
		toOffice = 'Ok, lets go to the sehen und Ernten Offices!'
		noComp = "I'm sorry, I didn't quite get that!"
		rcancel = "The car has stopped!"
		rbegin = "OK, let's get started!"
		rsorry = "I'm afraid we don't have a tour that includes"
		rsorrycont = 'Please choose from the communication design building or the sehen and ernten offices'
	else if s == "de"
		recognizer.lang = 'de-DE'
		synth.lang = 'de-DE'
		toVocab = ['nach', 'zum', 'zu', 'bis', 'in']
		rstop = /\b(?:stop|stopp|halte|heute|abbruch|halt|bremsen|brems|bleib|anhalten|pause)\b/i
		rstart = /\b(?:phallus|Balos|go|weiterfahren|fahr|weiter|start|los|losfahren)\b/i
		rnach = /\b(?:nach|zum|zu|bis|in)\b/i
		whereto = 'Hallo Janosch, Wilkommen zur A.R. Stadt rundfahrt. Wir befinden uns momentan in Berlin Oberschöneweide! Wohin würdest du gerne Fahren?'
		nach = /\b(?:nach|zum|zu|bis|in)\b/i
		toUni = 'Ok, es kann Losgehen zum H.T.W. Kommunikationsdesign Gebäude! die Fahrt wird circa 5 Minuten dauern.'
		toK = /\b(?:Kommunikationsdesign|Gebäude|Campus|Wilhelminenhof|Kommunikation|design)\b/i
		toSE = /\b(?:sehen|ernten|Büro)\b/i
		toOffice = 'Ok, es kann Losgehen zum sehen und Ernten Büro! die Fahrt wird circa 5 Minuten dauern.'
		noComp = 'das hab ich leider nicht verstanden'
		rcancel = "Die Fahrt wurde abgebrochen!"
		rbegin = "OK, weiter wie geplant!"
		rsorry = 'Leider haben wir für'
		rsorrycont = 'keine Tour im Angebot. Bitte wählen Sie aus Kommunikationsdesign oder dem sehen und ernten Büro'

setSprache(sprache)


checkIndex = (vocab, trans) ->
	transcriptArray = sta(trans)
	destination = ""
	for xx, i in transcriptArray
		for xx, j in vocab
			if transcriptArray[i] == vocab[j]
				ind = i
		if i > ind
			destination += transcriptArray[i]
	return destination
#for 'stopp', index in stopVocab
#console.log 'stopp', index
#print stopVocab.indexOf('stoppp')

#Utils.delay 0.4, ->
	
listenSound = new Audio("sounds/Notification4.m4a")
listenedSound = new Audio("sounds/Notification3.m4a")
noCompSound = new Audio("sounds/Error1.m4a")


Events.wrap(window).addEventListener "keydown", (event) ->
	#print event.keyCode
	if event.keyCode is 32 #Space bar
		sprich(whereto, true)
		ldown(welcometext)
		tintit.start()
	if event.keyCode is 76 #L Key
		startListen()
		
	#recognizer.stop()
	#recognizer.start()




recognizer.onresult = (event) ->
	ccolor = "#7ED321"
	result = event.results[event.resultIndex]
	transcript = result[0].transcript
	#print transcript
	tr.text = transcript
	start = rstart.test(transcript)
	stop = rstop.test(transcript)
	nach = rnach.test(transcript)
	info = /\b(?:info|informationen|anhören|hören|zusätzliche|lies|vor|vorlesen)\b/i.test(transcript)
	bild = /\b(?:bild|bilder|groß|größer|anzeigen|zeig)\b/i.test(transcript)
	look = /\b(?:anschauen|aussteigen|raus|hier|schauen)\b/i.test(transcript)
	rbild = /\b(?:klein|kleiner)\b/i.test(transcript)
	validDestK = toK.test(transcript)
	validDestSE = toSE.test(transcript)
	de = /\b(?:deutsch|german)\b/i.test(transcript)
	en = /\b(?:english|Englisch)\b/i.test(transcript)
	nachInvalidDest = nach && !validDestK && !validDestSE
	listenedSound.play()
	grade = switch
		when validDestK then sprich(toUni, false); tourVideo.player.play(); lup(welcometext); untintit.start()
		when de then setSprache("de"); sprich("OK, die sprache wurde auf deutsch gewechselt", false)
		when en then setSprache("en"); sprich("OK, the language has been set to english", false)
		when validDestSE then sprich(toOffice, false)
		when nachInvalidDest && beginning then sprich((rsorry + checkIndex(toVocab,transcript) + rsorrycont), true)
		#transcript.replace /nach/, "Wir kommen in 5 Minuten an bei "
		when stop then sprich(rcancel, false); car.animateStop(); tourVideo.player.pause()
		when start then sprich(rbegin, false); caranimation.start(); tourVideo.player.play()
		when htwframe && info then sprich("Vor etwas mehr als hundert Jahren war Oberschöneweide eines der Gründungszentren der Berliner Industrie.", false)
		when htwframe && bild then karte.visible = true; karteanimation.start(); karte.bringToFront(); spruch("Dieses Bild ist eine Karte von Oberschöneweide aus dem Jahr 1935",false)
		when htwframe && rbild then rkarteanimation.start()
		when htwframe && look then spruch("Ok, die Fahrt wurde pausiert. Du kannst jetzt aussteigen und dir das Gebäude genauer anschauen.", false); lookVideo.visible = true; lookVideo.player.play()
		else noCompSound.play(); sprich(noComp, false); ccolor = "#D0021B" #true?
	return

#Hier an der Rathenaustraße stiegen täglich Tausende von Arbeitern aus den Straßenbahnenin die Fabrikanlagen entlang der WilhelminenhofstraßeHeute steigen allerdings hauptsächliche Studenten aus den Trams oder dem Schienenersatzverkehr. Die HTW die Hochschule für Technik und Wirtschaft, hat hier 2009 den Campus Wilhelminenhof eröffnet. Der Campus befindet sich auf einem der bedeutendsten Industrieareale Berlins, dem ehemaligen Kabelwerk Oberspree. Das Gelände wurde ursprünglich von der AEG aufgebaut und genutzt, zu Zeiten der DDR werden die Gebäude Teil der wichtigen Kombinate VEB KWO. Ab der Wende wird hier jedoch nicht mehr produziert und Oberschöneweide verliert an Bedeutung.

synthActive = new Layer
	width: 20
	height: 20
	x: 0
	y: 0
	backgroundColor: "red"
	borderRadius: 25
	opacity: 0

car = new Layer
	backgroundColor: "none"
	color: "#000"
	y: 10
	x: 500
	html: "🚗 "
	opacity: 0

karte.visible = false
karte.bringToFront()
karte.x = 195
karte.y = 340
karte.originX = 0
karte.originY = 0
karteanimation = new Animation karte,
	x: 400
	y: 90
	scale: 6
	opacity: 1
	#height: 360
	options:
		curve: "ease"
		time: 0.6

rkarteanimation = new Animation karte,
	x: 195
	y: 340
	scale: 1
	opacity: 0
	#height: 360
	options:
		curve: "ease"
		time: 0.6

caranimation = new Animation car,
	x: 0
	options:
		curve: "linear"
		time: 10

#helpers
sprich = (spruch, listen) ->
	utterThis = new SpeechSynthesisUtterance(spruch)
	voices = synth.getVoices()
	if sprache == "de"
		utterThis.voice = voices[47]
	else if sprache == "en"
		utterThis.voice = voices[48]
	console.log("utterance", utterThis)
	synth.speak(utterThis)
	utterThis.onend = (event) ->
		#print 'stopped'
		if listen
			startListen()
	return



# String to array of words:
sta = (str) ->
  str.toLowerCase().trim().split ' '

# On animation end restart the animation 
caranimation.on Events.AnimationEnd, ->
	#caranimation.restart()


tourVideo.player.volume = 0
lookVideo.player.volume = 0

car.onClick ->
	#tourVideo.player.fastSeek(5)
	tourVideo.player.currentTime = 4
	#video.player.fastSeek(video.player.currentTime + 5)
	#tourVideo.player.play()

Events.wrap(tourVideo.player).on "pause", ->
	checkend(tourVideo.player.currentTime,18)

checkend = (time,end) ->
	if time > end
		htwbg.opacity = 1
		htwframe = true
		beginning = false
		htwi.opacity = 1
		ldown(htwinfo)
		tintit.start()
		htwi.bringToFront()
		sprich("Wir haben das Ziel erreicht. Möchten sie mehr darüber erfahren?",true)

htwbg = new Layer
	image: "images/htwbg.png"
	x: 0
	y: 0
	width: pwidth
	height: pheight
	opacity: 0

htwi = new Layer
	image: "images/htwi.png"
	x: 0
	y: 0
	width: pwidth
	height: pheight
	opacity: 0

tint = new Layer
	image: "images/tint.png"
	x: 0
	y: 0
	width: pwidth
	height: pheight
	opacity: 0

tint.states =
	tinted:
		opacity: 1
	untinted:
		opacity: 0.2
	animationOptions:
		curve: "ease"
		time: 0.3
 
tintit = new Animation tint,
	tint.states.tinted

untintit = new Animation tint,
	tint.states.untinted

cockpitHeight = 385
cockpit = new Layer
	image: "images/car_asset.png"
	x: 0
	y: pheight-cockpitHeight
	width: pwidth
	height: cockpitHeight

gridp = 90

welcometext.bringToFront()
welcometext.x = gridp
welcometext.y = -welcometext.height

htwinfo.bringToFront()
htwinfo.x = gridp
htwinfo.y = -htwinfo.height

ldown = (layer) ->
	layer.animate
		y: gridp
		options:
			ease: "ease"
			time: 0.5
			curve: Spring(damping: 0.5)

lup = (layer) ->
	layer.animate
		y: -layer.height
		options:
			time: 0.4

tr = new TextLayer
	text: "transcript"
	color: 'white'
	fontSize: 20
tr.x = gridp
tr.y = pheight-gridp


# Handling Voice

inputVolume = undefined
UPDATE_FREQUENCY = 0.15

# you might want to change that for different environments
MAX_VOLUME = 10

# get the volume value
getVolume = (input) ->
	sum = 0.0
	for i in [0...input.length]
		sum += input[i] * input[i]
	volume = Math.sqrt(sum / input.length) * 100
	return volume.toFixed(2)

# handle success in case we were able to get access to the mic
handleSuccess = (stream) ->
	audioCtx = new AudioContext
	source = audioCtx.createMediaStreamSource(stream)
	scriptNode = audioCtx.createScriptProcessor(2048, 1, 1);
	
	source.connect(scriptNode)
	scriptNode.connect(audioCtx.destination)
	
	scriptNode.onaudioprocess = (event) ->
		input = event.inputBuffer.getChannelData(0)
		inputVolume = getVolume(input)
	
	return

# print error in case of error
handleFailure = (error) ->
	#print(error)
	return

# set the constraints
constraints = 
	audio: true
	video: false

# check whether or not the browser supports Web Audio API
# if yes, try to get access to the mic
if navigator.mediaDevices
	console.log('getUserMedia supported')
	navigator.mediaDevices.getUserMedia(constraints).then(handleSuccess).catch(handleFailure)
else 
	console.log('getUserMedia is not supported')

# making layer from the startListening function located below respond to voice
respondToVoice = (layer) ->
	
	currentScale = Utils.modulate(inputVolume, [0, MAX_VOLUME], [layer.states.inactive.scale, layer.states.active.scale], true)
	currentBorderWidth = Utils.modulate(inputVolume, [0, MAX_VOLUME], [layer.states.inactive.borderWidth, layer.states.active.borderWidth], true)
	
	layerAnimation = new Animation layer,
		scale: currentScale
		borderWidth: currentBorderWidth
		options: 
			curve: Spring(damping: 0.91)
			time: 0.30
			
	layerAnimation.start()
	layerAnimation.onAnimationEnd ->
		layerAnimation.start()

startListening = () ->
	Utils.interval UPDATE_FREQUENCY, ->
		respondToVoice(vcircle)
		
startListening()

# Layer Setup

vcircle = new Layer
	width: 70
	height: 70
	x: 150 #(pwidth/2)-48
	y: 400 #pheight-130
	borderRadius: 200
	borderWidth: 8
	scale: 0.7
	borderColor: "white"
	backgroundColor: ""
	opacity: 1.0

vcircle.states =
	inactive:
		scale: 1
		borderWidth: 12
	active:
		scale: 1.75
		borderWidth: 2

vcircle.stateSwitch("inactive")
