
Option Explicit

'*****************************************************************************************************
' CREDITS
' Art for playfeild and plastics all created by Joe Picasso
' Help with 3d guns by remdwaas
' Gun fire switch and animations by Devious 626
' Table Light shaping by Pedro Peres
' 3d Bulldozer cropped and aided by Andrei Maraklov
' Table rebuilt by Aubrel for VPX (thanks to Destruk, TAB, Rascal and Bigus for the previous builds) 
' Initial table created by Bigus, fuzzel, jimmyfingers, jpsalas, toxie & unclewilly (in alphabetical order)
' JLouLou For Recreating both ramps in blender and creating their texture packs. 
' JPsalas For helping me fix left set of ramps
' Flipper primitives by zany
' Ball shadow by ninuzzu
' Ball control by rothbauerw
' DOF by arngrim
' nFozzy Physics, Fleep Sounds, Ramp Rolling SFX, Plastics and Flipper Swaps added by Scampa123
' Plus a lot of input from the whole community (sorry if we forgot you :/)
'*****************************************************************************************************

On Error Resume Next
ExecuteGlobal GetTextFile("controller.vbs")
If Err Then MsgBox "You need the controller.vbs in order to run this table, available in the vp10 package"
On Error Goto 0

' Aubrel 2021 March/June
'- LightsMod option (allows to add some not acurate lightings) and some randomness to the kickers added
'- GI Solenoid (Tilt) fixed (not 26 but 31 and the result is not excatly the same)
'- Some code cleanups (and ManualBallControl removed)
'- LUTs selection and "LightslevelUpdate" added
'- vpm lights mapping and "lit" primitives domes replaced by "JP's VP10 Fading Lamps&Flashers" and "iaakki's FadeDisableLighting"
'- BigFatso moves code was wrong and killed the game rules. It should be working now.
'- ContactLens primitive and code added (fake lights removed).
'- Bumper light fixed (L30)

 
' Thalamus 2019 March
' Made ready for improved directional sounds, but, there is very few samples in the table.



'********************
' Options
'********************

Const Mute_Sound_For_PuPPack = 1 ' 1=mute sound when using the PuPPack, 0=Normal Rom Sounds

'----- General Sound Options -----
Const VolumeDial = 0.8			'Overall Mechanical sound effect volume. Recommended values should be no greater than 1.
Const BallRollVolume = 0.5		'Level of ball rolling volume. Value between 0 and 1
Const RampRollVolume = 0.5 			'Level of ramp rolling volume. Value between 0 and 1

'Game Specific Sound Volume
Const VolMotor   = 0.5   ' BigFatso motor volume

'Visual Options
Const PG_Plastics = 1	'set to 1 for rated-PG plastics, set to 0 for rated-X plastics
Const BarbWire_Flippers = 1 'set to 1 for custom Barb Wire flippers, set to 0 for Gottlieb flippers

Const LightsMod  = 1     'set to 1 to switch off GI also with RelayA (not accurate), 2 will also add slingshots lightings (phantasy); 0 is default (accurate)
Dim Luts,LutPos
Luts = array("ColorGradeLUT256x16_1to1","ColorGradeLUT256x16_ModDeSat","ColorGradeLUT256x16_ConSat","ColorGradeLUT256x16_ExtraConSat","ColorGradeLUT256x16_ConSatMD","ColorGradeLUT256x16_ConSatD")
LutPos = 2         		 'set the nr of the LUT you want to use (0=first in the list above, 1=second, etc; 4 and 5 are "Medium Dark" and "Dark" LUTs); 2 is the default
Const VisualLock = 0     'set to 1 if you don't want to change the visual settings using Magna-Save buttons; 0 is the default (live changes enabled)

'Table Options
Const Gunfight = 1		 'Set to 1 to enable gunfight sounds and images, set to 0 to Disable

'*************************************

Const BallSize = 50					'Ball size must be 50
Const BallMass = 1					'Ball mass must be 1
Const tnob = 5						'Total number of balls
Dim tablewidth: tablewidth = Table1.width
Dim tableheight: tableheight = Table1.height
Dim BIPL : BIPL = False				'Ball in plunger lane

LoadVPM "01120100","gts3.vbs",3.10

Dim VarRol,VarCL
If Table1.ShowDT = true then 
	VarRol=0 
	VarCL=-5
Else 
	VarRol=1
	Ramp15.Visible=0
	Ramp16.Visible=0
	Ramp17.Visible=0
	VarCL=5
End If

ContactLensP.TransY = ContactLensP.TransY + VarCL

If LutPos = 4 Then LightsLevelUpdate 1, 1    'set lights for "Medium Dark" LUT
If LutPos = 5 Then LightsLevelUpdate 2, 2    'set lights for "Dark" LUT
Table1.ColorGradeImage = Luts(LutPos)


Const UseSolenoids=2,UseLamps=0,UseSync=1,UseGI=0,SCoin="coin",cGameName="barbwire"
Const SSolenoidOn="SolOn",SSolenoidOff="SolOff"

'Const swStartButton=4

'SolCallback(1) = "vpmSolSound SoundFX(""fx_bumper"",DOFContactors),"
'SolCallback(2) = "vpmSolSound SoundFX(""Left_Slingshot"",DOFContactors),"
'SolCallback(3) = "vpmSolSound SoundFX(""Right_Slingshot"",DOFContactors),"
SolCallback(6) = "bsLK.SolOut"
SolCallback(7) = "bsRK.SolOut"
SolCallback(8) = "FireAutoPlunge"
'SolCallback(9) = 'Pull BallGate Diverter
SolCallback(10) = "vpmSolDiverter BallGate,True," 'Hold Ballgate Diverter
SolCallback(11) = "LensUnit1"
SolCallback(12) = "LensUnit2"
SolCallback(13) = "LensUnit3"
SolCallback(14) = "SetLamp 113,"
SolCallback(15) = "SetLamp 114,"
SolCallback(16) = "MoveFatso"     'Big Fatso Motor
SolCallback(17) = "SetLamp 116,"  'Bottom Left Dome Flasher
SolCallback(18) = "SetLamp 117,"  'Captive Ball Flasher
SolCallback(19) = "SetLamp 118,"  'Top Left Upkicker Flasher
SolCallback(20) = "SetF19"        'Top Left Dome Flasher
SolCallback(21) = "SetLamp 120,"  'Left Ramp Flasher
SolCallback(22) = "SetLamp 121,"  'Big Fatso Flasher
SolCallback(23) = "SetLamp 122,"  'Right Ramp Flasher
SolCallback(24) = "SetF23"        'Top Right Dome Flasher
SolCallback(25) = "SetF24"        'Bottom Right Dome Flasher
SolCallback(26) = "RelayA"        'Lightbox Relay (A)
'SolCallback(27)= 'Ticket/Coin Meter
SolCallback(28) = "bsTrough.SolOut"
SolCallback(29) = "bsTrough.SolIn"
SolCallback(30) = "SolKnocker"
SolCallback(31) = "TiltGI"        'Playfield GI (TiltGI)
SolCallback(32) = "vpmNudge.SolGameOn"
SolCallback(sLRFlipper) = "SolRFlipper"
SolCallback(sLLFlipper) = "SolLFlipper"

Sub FireAutoPlunge(Enabled)
	vpmSolAutoPlunger PlungerAuto,1,Enabled
	If Enabled Then
		SoundPlungerPull()
	End If
End Sub


'*******************************************
'  Flippers
'*******************************************
Const ReflipAngle = 20

Sub SolLFlipper(Enabled)
  If Enabled Then
	LF.Fire:LF2.fire  'leftflipper.rotatetoend

	If Leftflipper.currentangle < Leftflipper.endangle + ReflipAngle Then 
			RandomSoundReflipUpLeft LeftFlipper
	Else 
			SoundFlipperUpAttackLeft LeftFlipper
			RandomSoundFlipperUpLeft LeftFlipper
	End If                
  Else
	LeftFlipper.RotateToStart:LeftFlipperUp.RotateToStart
	If LeftFlipper.currentangle < LeftFlipper.startAngle - 5 Then
			RandomSoundFlipperDownLeft LeftFlipper
	End If
	FlipperLeftHitParm = FlipperUpSoundLevel
  End If
End Sub

Sub SolRFlipper(Enabled)
  If Enabled Then
	RF.Fire 'rightflipper.rotatetoend


	If Rightflipper.currentangle > Rightflipper.endangle - ReflipAngle Then
			RandomSoundReflipUpRight RightFlipper
	Else 
			SoundFlipperUpAttackRight RightFlipper
			RandomSoundFlipperUpRight RightFlipper
	End If
  Else
	RightFlipper.RotateToStart
	If RightFlipper.currentangle > RightFlipper.startAngle + 5 Then
			RandomSoundFlipperDownRight RightFlipper
	End If        
	FlipperRightHitParm = FlipperUpSoundLevel
  End If
End Sub

'*******************************************
'  Other Solenoids
'*******************************************

' Knocker (this sub mimics how you would handle kicker in ROM based tables)
' For this to work, you must create a primite on the table named KnockerPosition
' SolCallback(XX) = "SolKnocker"  'In ROM based tables, change the solenoid number XX to the correct number for your table.
Sub SolKnocker(Enabled)
	If enabled Then
		KnockerSolenoid 'Add knocker position object
	End If
End Sub


Dim bsTrough,bsLK,bsRK,UnitLens1,UnitLens2,UnitLens3

Sub LensUnit1(Enabled)
	UnitLens1=Enabled
End Sub

Sub LensUnit2(Enabled)
	UnitLens2=Enabled
End Sub

Sub LensUnit3(Enabled)
	UnitLens3=Enabled
End Sub

Sub SetF19(Enabled)
	SetLamp 119, Enabled
	F19C.Visible=Enabled
End Sub

Sub SetF23(Enabled)
	SetLamp 123, Enabled
	F23C.Visible=Enabled
End Sub

Sub SetF24(Enabled)
	SetLamp 124, Enabled
	F24C.Visible=Enabled
End Sub

'LightBox Relay A
Sub RelayA(Enabled)
	If LightsMod>0 Then pfgilights Enabled
End Sub

'Playfield GI
Sub TiltGI(Enabled) 'Sol 31 (Tilt)
	pfgilights Enabled
End Sub

Sub pfgilights(Enabled)
	PlaySound "fx_relay"
	dim xx
	For each xx in GI:xx.State = Not Enabled: Next
	If Enabled Then
		LightsLevelUpdate 1, 0
	Else
		LightsLevelUpdate -1, 0
	End If
End Sub

Sub Table1_Init
	vpmInit Me
 	On Error Resume Next
 	With Controller
		.GameName=cGameName
		If Err Then MsgBox"Can't start Game"&cGameName&vbNewLine&Err.Description:Exit Sub
		.SplashInfoLine="Barb Wire - Gottlieb 1996"
		.HandleKeyboard=0
		.ShowTitle=0
		.ShowDMDOnly=1
		.HandleMechanics=0
		.ShowFrame=0
		.Games(cGameName).Settings.Value("rol") = 0
		if Mute_Sound_For_PuPPack = 1 then .Games(cGameName).Settings.Value("sound") = 0
		.Run GetPlayerHwnd
		If Err Then MsgBox Err.Description
	End With
	On Error Goto 0
	PinMAMETimer.Interval=PinMAMEInterval
	PinMAMETimer.Enabled=1
	vpmNudge.TiltSwitch=151
	vpmNudge.Sensitivity=6
	vpmNudge.TiltObj=Array(Bumper1,Leftslingshot,Rightslingshot)

'	vpmMapLights AllLights

	Set bsTrough=New cvpmBallStack
		bsTrough.InitSw 16,0,0,26,0,0,0,0
		bsTrough.InitKick BallRelease,120,2
		bsTrough.InitEntrySnd "SolOn","SolOn"
		bsTrough.Balls=3

 	Set bsLK=New cvpmBallStack
		bsLK.InitSw 0,50,0,0,0,0,0,0
		bsLK.InitKick LUK,152,6
		'bsLK.InitExitSnd 
		RandomSoundBallRelease LUK 
		bsLK.KickForceVar = 2
		bsLK.KickAngleVar = 2

	Set bsRK=New cvpmBallStack
		bsRK.InitSw 0,25,0,0,0,0,0,0
		bsRK.InitKick RUK,235,12
		'bsRK.InitExitSnd 
		RandomSoundBallRelease RUK
		bsRK.KickForceVar = 2
		bsRK.KickAngleVar = 2

	vpmCreateEvents AllSwitches
	Drain.CreateBall
	Drain.Kick 150,2
 	Kicker2.CreateBall
	Kicker2.Kick 180,1

	SwapPlastics
	SwapFlippers
End Sub

'*********************************
'KeyDown 
'*********************************
Sub Table1_KeyDown(ByVal KeyCode)
	If keycode=StartGamekey then Controller.switch(4)=1:soundStartButton() 'Start (Button 1)
	If KeyCode=KeyFront Then Controller.Switch(1)=1 'Buy-In (Button 2)
	If KeyCode=LeftFlipperKey Then Controller.Switch(42)=1:FlipperActivate LeftFlipper, LFPress:FlipperActivate LeftFlipperUp, LFPress2
	If KeyCode=RightFlipperkey Then Controller.Switch(43)=1:FlipperActivate RightFlipper, RFPress
	If keycode = LeftTiltKey Then Nudge 90, 5:SoundNudgeLeft()
	If keycode = RightTiltKey Then Nudge 270, 5:SoundNudgeRight()
	If keycode = CenterTiltKey Then Nudge 0, 3:SoundNudgeCenter()
	If KeyCode=LeftMagnaSave Then  Controller.switch(5)=1 'Tournament (Left MagnaSave Button)
	If VisualLock = 0 Then
		If KeyCode = RightMagnaSave Then
			If LutPos = 5 Then LutPos = 0:LightsLevelUpdate -2,-2 Else LutPos = LutPos +1   'Max LUTs number is set to 5; so back to 0 and Lights level reseted for standard LUTs.
			If LutPos > 3 Then LightsLevelUpdate 1,1                                        'LUTs 4 and 5 are "Medium Dark" and "Dark LUTs" so Lights Level should be updated
			Table1.ColorGradeImage = Luts(LutPos)
		End If
	End If
	If keycode = keyInsertCoin1 or keycode = keyInsertCoin2 or keycode = keyInsertCoin3 or keycode = keyInsertCoin4 Then
		Select Case Int(rnd*3)
			Case 0: PlaySound ("Coin_In_1"), 0, CoinSoundLevel, 0, 0.25
			Case 1: PlaySound ("Coin_In_2"), 0, CoinSoundLevel, 0, 0.25
			Case 2: PlaySound ("Coin_In_3"), 0, CoinSoundLevel, 0, 0.25
		End Select
	End If
	If KeyCode=PlungerKey Then Plunger.PullBack:SoundPlungerPull()
	If vpmKeyDown(KeyCode) Then Exit Sub
End Sub

'*********************************
'KeyUp 
'*********************************


Sub Table1_KeyUp(ByVal KeyCode)
	If keycode=StartGamekey then Controller.switch(4)=0
	If KeyCode=KeyFront Then Controller.Switch(1)=0
	If KeyCode=LeftFlipperKey Then Controller.Switch(42)=0:FlipperDeActivate LeftFlipper, LFPress:FlipperDeActivate LeftFlipperUp, LFPress2
	If KeyCode=RightFlipperkey Then	Controller.Switch(43)=0:FlipperDeActivate RightFlipper, RFPress
	If KeyCode=LeftMagnaSave Then Controller.switch(5)=0
	If KeyCode = PlungerKey Then
		Plunger.Fire
		If BIPL = 1 Then
			SoundPlungerReleaseBall()			'Plunger release sound when there is a ball in shooter lane
		Else
			SoundPlungerReleaseNoBall()			'Plunger release sound when there is no ball in shooter lane
		End If
	End If
	If vpmKeyUp(KeyCode) Then Exit Sub
End Sub

Sub Bumper1_Hit:vpmTimer.PulseSw 10:RandomSoundBumperTop Bumper1:End Sub
Sub BallRelease_UnHit : RandomSoundBallRelease BallRelease: End Sub
Sub Drain_Hit:bsTrough.Addball Me:RandomSoundDrain Drain:End Sub
Sub KickerRampDrop_Hit:SoundSaucerLock:End Sub
Sub KickerRampDrop_UnHit:SoundSaucerKick 1,KickerRampDrop:End Sub
Sub Kicker2_Hit : SoundSaucerLock:End Sub
Sub Kicker2_UnHit : SoundSaucerKick 1,Kicker2 :End Sub
Sub RUK_Hit:bsRK.AddBall Me:SoundSaucerLock:End Sub
Sub RUK_UnHit:SoundSaucerKick 1, RUK:End Sub
Sub LUK_Hit:bsLK.AddBall Me:SoundSaucerLock:End Sub
Sub LUK_UnHit:SoundSaucerKick 1, LUK:End Sub
Sub Kicker4_Hit:Me.DestroyBall:vpmTimer.PulseSwitch(60),600,"ToRightUpkicker":End Sub
Sub ToRightUpkicker(swNo):bsRK.AddBall 0:End Sub
Sub Kicker3_Hit:Me.DestroyBall:vpmTimer.PulseSwitch(70),200,"ToLeftVuk":SoundSaucerLock:End Sub
Sub Kicker3_UnHit:SoundSaucerKick 1, Kicker3:End Sub


'*******************************************
'  Ramp Triggers
'*******************************************
Sub ramptrigger01_hit()
	WireRampOn True 'Play Plastic Ramp Sound
End Sub

Sub ramptrigger02_hit()
	WireRampOn True 'Play Plastic Ramp Sound
End Sub

Sub ramptrigger03_hit()
	WireRampOn True 'Play Plastic Ramp Sound
End Sub

Sub ramptrigger03_unhit()
	WireRampOn False 'Play Wire Ramp Sound
End Sub

Sub ramptrigger04_hit()
	WireRampOff ' Exiting Wire Ramp Stop Playing Sound
End Sub

Sub ramptrigger04_unhit()
	PlaySoundAt "WireRamp_Stop", ramptrigger04
End Sub

Sub ramptrigger05_hit()
	WireRampOn True 'Play Plastic Ramp Sound
End Sub

Sub ramptrigger06_hit()
	WireRampOn True 'Play Plastic Ramp Sound
End Sub

Sub ramptrigger06_unhit()
	WireRampOn False 'Play Wire Ramp Sound
End Sub
Sub ramptrigger07_hit()
	WireRampOff ' Exiting Wire Ramp Stop Playing Sound
End Sub

Sub ramptrigger07_unhit()
	PlaySoundAt "WireRamp_Stop", ramptrigger07
End Sub

Sub ramptrigger08_hit()
	WireRampOff ' Exiting Wire Ramp Stop Playing Sound
End Sub

Sub ramptrigger08_unhit()
	PlaySoundAt "WireRamp_Stop", ramptrigger08
End Sub



Sub ToLeftVuk(swNo):bsLK.AddBall 0:End Sub

Sub ContactLensT_Timer  'I'm not sure it really works that way but it gives the same result as the real pinball :)
	If UnitLens2 Then
		If ContactLensP.TransY > (-55 +VarCL) Then ContactLensP.TransY=ContactLensP.TransY-5
		If ContactLensP.TransY < (-55 +VarCL) Then ContactLensP.TransY=ContactLensP.TransY+5
	Else
		If UnitLens1 And ContactLensP.TransY < (0 +VarCL) Then ContactLensP.TransY=ContactLensP.TransY+5
		If UnitLens3 And ContactLensP.TransY > (-140 +VarCL) Then ContactLensP.TransY=ContactLensP.TransY-5
	End If
End Sub

Dim FatsoDir
FatsoDir=1

Sub MoveFatso(Enabled)
	If Enabled Then
		FatsoTimer.Enabled=1
	Else
		FatsoTimer.Enabled=0
	End If
End Sub

Sub FatsoTimer_Timer
    PlaySoundAtVol SoundFX("motor", DOFContactors), FatsoPrim, VolMotor
	If FatsoPrim.TransY >= 0 Then Controller.Switch(27)=1:Controller.Switch(17)=0:FatsoDir=-2
	If FatsoPrim.TransY <= -66 Then Controller.Switch(27)=0:Controller.Switch(17)=1:FatsoDir=2
	FatsoPrim.TransY=FatsoPrim.TransY+FatsoDir
	If FatsoPrim.TransY <= -40 Then BigFatso.IsDropped=1 Else BigFatso.IsDropped=0
End Sub

Sub BigFatso_Hit:vpmTimer.PulseSw 70:End Sub


 Sub s13_Hit:vpmTimer.PulseSw 13:End Sub
 Sub s14_Hit:vpmTimer.PulseSw 14:End Sub
 Sub s15_Hit:Controller.Switch(15) = 1:End Sub
 Sub s15_UnHit:Controller.Switch(15) = 0:End Sub
 Sub s40_Hit:vpmTimer.PulseSw 40:End Sub
 Sub s41_Hit:vpmTimer.PulseSw 41:End Sub
 Sub s52_Hit:vpmTimer.PulseSw 52:End Sub
 Sub s53_Hit:vpmTimer.PulseSw 53:End Sub
 Sub s54_Hit:vpmTimer.PulseSw 54:End Sub
 Sub s55_Hit:vpmTimer.PulseSw 55:End Sub
 Sub s56_Hit:vpmTimer.PulseSw 56:End Sub
 Sub s57_Hit:vpmTimer.PulseSw 57:End Sub
 Sub s62_Hit:vpmTimer.PulseSw 62:End Sub
 Sub s63_Hit:vpmTimer.PulseSw 63:End Sub
 Sub s64_Hit:vpmTimer.PulseSw 64:End Sub
 Sub s65_Hit:vpmTimer.PulseSw 65:End Sub
 Sub s66_Hit:vpmTimer.PulseSw 66:End Sub
 Sub s67_Hit:vpmTimer.PulseSw 67:End Sub
 
Sub flippers_Timer()
	GottliebFlipperLeft.objRotZ = LeftFlipper.CurrentAngle-90
	GottliebFlipperLeftUp.objRotZ = LeftFlipperUp.CurrentAngle-90
	GottliebFlipperRight.objRotZ = RightFlipper.CurrentAngle-90
    'ninuzzu's	FLIPPER SHADOWS
	FlipperLSh.RotZ = LeftFlipper.currentangle
	FlipperLShUp.RotZ = LeftFlipperUp.currentangle
	FlipperRSh.RotZ = RightFlipper.currentangle
End Sub


'LightsLevelUpdate by Aubrel
Dim obj
Sub LightsLevelUpdate(OffsetL, OffsetGI)
  For each obj in PFLights
    obj.Intensity = obj.Intensity * 1.3^(OffsetL)
  Next
  For each obj in FlasherLights
    obj.Intensity = obj.Intensity * 1.15^(OffsetL)
  Next
  For each obj in OtherLights
    obj.Intensity = obj.Intensity * 1.15^(OffsetL)
  Next
  For each obj in AllFlashers
    obj.Opacity = obj.Opacity * 1.2^(OffsetL)
  Next
  For each obj in GI
    obj.Intensity = obj.Intensity * 1.25^(OffsetGI)
  Next
End Sub


'**********Sling Shot Animations
' Rstep and Lstep  are the variables that increment the animation
'****************
Dim RStep, Lstep

Sub RightSlingShot_SlingShot:vpmTimer.PulseSw 12:RandomSoundSlingshotRight Sling1
    RSling.Visible = 0
    RSling1.Visible = 1
    sling1.rotx = 20
    RStep = 0
    RightSlingShot.TimerEnabled = 1
	If LightsMod>1  Then GI001.State = 0
	LastSwitchHit = "Eagle"
	StartImage
End Sub

Sub RightSlingShot_Timer
    Select Case RStep
        Case 3:RSLing1.Visible = 0:RSLing2.Visible = 1:sling1.rotx = 10
        Case 4:RSLing2.Visible = 0:RSLing.Visible = 1:sling1.rotx = 0:RightSlingShot.TimerEnabled = 0
			If LightsMod>1  Then GI001.State = 1
    End Select
    RStep = RStep + 1
	ImageTimerStop.Enabled = 1
End Sub

Sub LeftSlingShot_SlingShot:vpmTimer.PulseSw 11:RandomSoundSlingshotLeft Sling2
    LSling.Visible = 0
    LSling1.Visible = 1
    sling2.rotx = 20
    LStep = 0
    LeftSlingShot.TimerEnabled = 1
	If LightsMod>1  Then GI002.State = 0
	LastSwitchHit = "MP5"
	StartImage
End Sub

Sub LeftSlingShot_Timer
    Select Case LStep
        Case 3:LSLing1.Visible = 0:LSLing2.Visible = 1:sling2.rotx = 10
        Case 4:LSLing2.Visible = 0:LSLing.Visible = 1:sling2.rotx = 0:LeftSlingShot.TimerEnabled = 0
			If LightsMod>1  Then GI002.State = 1
    End Select
    LStep = LStep + 1
	ImageTimerStop.Enabled = 1
End Sub


'***************************************************
'       JP's VP10 Fading Lamps & Flashers
'       Based on PD's Fading Light System
' SetLamp 0 is Off
' SetLamp 1 is On
' fading for non opacity objects is 4 steps
'***************************************************

Dim LampState(200), FadingLevel(200)
Dim FlashSpeedUp(200), FlashSpeedDown(200), FlashMin(200), FlashMax(200), FlashLevel(200)

InitLamps()             ' turn off the lights and flashers and reset them to the default parameters
LampTimer.Interval = 5 'lamp fading speed
LampTimer.Enabled = True

' Lamp & Flasher Timers

Sub LampTimer_Timer()
    Dim chgLamp, num, chg, ii
    chgLamp = Controller.ChangedLamps
    If Not IsEmpty(chgLamp) Then
        For ii = 0 To UBound(chgLamp)
            LampState(chgLamp(ii, 0) ) = chgLamp(ii, 1)       'keep the real state in an array
            FadingLevel(chgLamp(ii, 0) ) = chgLamp(ii, 1) + 4 'actual fading step

	   'Special Handling
	   'If chgLamp(ii,0) = 0 Then RelQ chgLamp(ii,1) 'Game Overr Q Relay
        Next
    End If
    UpdateLamps
End Sub


Sub UpdateLamps()
    NFadeL 0, L0
'   NFadeL 1, L1
'   NFadeL 2, L2
'   NFadeL 3, L3
'   NFadeL 4, L4
    NFadeL 5, L5
    NFadeL 6, L6
    NFadeL 7, L7
'   NFadeL 10, L10
    NFadeL 11, L11
    NFadeL 12, L12
    NFadeL 13, L13
    NFadeL 14, L14
    NFadeL 15, L15
    NFadeL 16, L16
    NFadeL 17, L17
'   NFadeL 20, L20
    NFadeL 21, L21
    NFadeL 22, L22
    NFadeL 23, L23
    NFadeL 24, L24
    NFadeL 25, L25
    NFadeL 26, L26
    NfadeL 27, L27
    NfadeL 30, L30
'   NfadeL 31, L31
    NfadeL 32, L32
    NfadeL 33, L33
    NfadeL 34, L34
    NFadeL 35, L35
    NFadeL 36, L36
    NFadeL 37, L37
'   NFadeL 40, L40
'   NFadeL 41, L41
    NFadeL 42, L42
    NFadeL 43, L43
    NFadeL 44, L44
    NfadeL 45, L45
    NfadeL 46, L46
    NfadeL 47, L47
    NFadeL 50, L50
    NFadeL 51, L51
    NFadeL 52, L52
    NFadeL 53, L53
    NFadeL 54, L54
    NFadeL 55, L55
    NFadeL 56, L56
    NFadeL 57, L57
    NFadeL 60, L60
    NFadeL 61, L61
    NFadeL 62, L62
    NFadeL 63, L63
    NFadeL 64, L64
    NFadeL 65, L65
    NFadeL 66, L66
    NFadeL 67, L67
    NFadeL 70, L70
    NFadeL 71, L71
    NFadeL 72, L72
    NFadeL 73, L73
    NFadeL 74, L74
    NFadeL 75, L75
    NFadeL 76, L76
    NFadeL 77, L77

    NFadeL  113, F13
    NFadeL  114, F14
    NFadeLm 116, F16
    NFadeLm 116, F16b
    Flash   116, F16C
    NFadeLm 117, F17
    NFadeLm 117, F17b
    NFadeL  117, L57
    NFadeLm 118, F18
    NFadeL  118, F18b
    NFadeLm 119, F19
    FadeDisableLighting 119, PrimF19, 60
    NFadeL  120, F20
    NFadeLm 121, F21
    NFadeL  121, F21b
    NFadeL  122, F22
    NFadeLm 123, F23
    NFadeLm 123, L30a
    NFadeLm 123, F23b
    FadeDisableLighting 123, PrimF23, 60
    NFadeLm 124, F24
    FadeDisableLighting 124, PrimF24, 60
End Sub

' div lamp subs
Sub InitLamps()
    Dim x
    For x = 0 to 200
        LampState(x) = 0        ' current light state, independent of the fading level. 0 is off and 1 is on
        FadingLevel(x) = 4      ' used to track the fading state
        FlashSpeedUp(x) = 0.4   ' faster speed when turning on the flasher
        FlashSpeedDown(x) = 0.2 ' slower speed when turning off the flasher
        FlashMax(x) = 1         ' the maximum value when on, usually 1
        FlashMin(x) = 0         ' the minimum value when off, usually 0
        FlashLevel(x) = 0       ' the intensity of the flashers, usually from 0 to 1
    Next
End Sub

Sub AllLampsOff
    Dim x
    For x = 0 to 200
        SetLamp x, 0
    Next
End Sub

Sub SetLamp(nr, value)
    If value <> LampState(nr) Then
        LampState(nr) = abs(value)
        FadingLevel(nr) = abs(value) + 4
    End If
End Sub

' Lights: used for VP10 standard lights, the fading is handled by VP itself
Sub NFadeL(nr, object)
    Select Case FadingLevel(nr)
        Case 4:object.state = 0:FadingLevel(nr) = 0
        Case 5:object.state = 1:FadingLevel(nr) = 1
    End Select
End Sub

Sub NFadeLm(nr, object) ' used for multiple lights
    Select Case FadingLevel(nr)
        Case 4:object.state = 0
        Case 5:object.state = 1
    End Select
End Sub

'Lights, Ramps & Primitives used as 4 step fading lights
'a,b,c,d are the images used from on to off
Sub FadeObj(nr, object, a, b, c, d)
    Select Case FadingLevel(nr)
        Case 4:object.image = b:FadingLevel(nr) = 6                   'fading to off...
        Case 5:object.image = a:FadingLevel(nr) = 1                   'ON
        Case 6, 7, 8:FadingLevel(nr) = FadingLevel(nr) + 1             'wait
        Case 9:object.image = c:FadingLevel(nr) = FadingLevel(nr) + 1 'fading...
        Case 10, 11, 12:FadingLevel(nr) = FadingLevel(nr) + 1         'wait
        Case 13:object.image = d:FadingLevel(nr) = 0                  'Off
    End Select
End Sub

Sub FadeObjm(nr, object, a, b, c, d)
    Select Case FadingLevel(nr)
        Case 4:object.image = b
        Case 5:object.image = a
        Case 9:object.image = c
        Case 13:object.image = d
    End Select
End Sub

Sub NFadeObj(nr, object, a, b)
    Select Case FadingLevel(nr)
        Case 4:object.image = b:FadingLevel(nr) = 0 'off
        Case 5:object.image = a:FadingLevel(nr) = 1 'on
    End Select
End Sub

Sub NFadeObjm(nr, object, a, b)
    Select Case FadingLevel(nr)
        Case 4:object.image = b
        Case 5:object.image = a
    End Select
End Sub


'FadeDisableLighting by iaakki
Sub FadeDisableLighting(nr, a, alvl)
  'debug.print a.uservalue
  Select Case FadingLevel(nr)
    Case 4
      a.UserValue = a.UserValue - (a.UserValue * 0.5)^3 - 0.03
      If a.UserValue < 0 Then 
        a.UserValue = 0
        FadingLevel(nr) = 0
      end If
      a.BlendDisableLighting = alvl * a.UserValue 'brightness
    Case 5
      a.UserValue = (a.UserValue + 0.1) * 1.1
      If a.UserValue > 1 Then 
        a.UserValue = 1
        FadingLevel(nr) = 1
      end If
      a.BlendDisableLighting = alvl * a.UserValue 'brightness
  End Select
End Sub

' Flasher objects
Sub Flash(nr, object)
    Select Case FadingLevel(nr)
        Case 4 'off
            FlashLevel(nr) = FlashLevel(nr) - FlashSpeedDown(nr)
            If FlashLevel(nr) < FlashMin(nr) Then
                FlashLevel(nr) = FlashMin(nr)
                FadingLevel(nr) = 0 'completely off
            End if
            Object.IntensityScale = FlashLevel(nr)
        Case 5 ' on
            FlashLevel(nr) = FlashLevel(nr) + FlashSpeedUp(nr)
            If FlashLevel(nr) > FlashMax(nr) Then
                FlashLevel(nr) = FlashMax(nr)
                FadingLevel(nr) = 1 'completely on
            End if
            Object.IntensityScale = FlashLevel(nr)
    End Select
End Sub

Sub Flashm(nr, object) 'multiple flashers, it just sets the flashlevel
    Object.IntensityScale = FlashLevel(nr)
End Sub


'*****************************************
'	ninuzzu's	BALL SHADOW
'*****************************************
Dim BallShadow
BallShadow = Array (BallShadow1,BallShadow2,BallShadow3,BallShadow4,BallShadow5)

Sub BallShadowUpdate_timer()
    Dim BOT, b
    BOT = GetBalls
    ' hide shadow of deleted balls
    If UBound(BOT)<(tnob-1) Then
        For b = (UBound(BOT) + 1) to (tnob-1)
            BallShadow(b).visible = 0
        Next
    End If
    ' exit the Sub if no balls on the table
    If UBound(BOT) = -1 Then Exit Sub
    ' render the shadow for each ball
    For b = 0 to UBound(BOT)
        If BOT(b).X < Table1.Width/2 Then
            BallShadow(b).X = ((BOT(b).X) - (Ballsize/6) + ((BOT(b).X - (Table1.Width/2))/7)) + 6
        Else
            BallShadow(b).X = ((BOT(b).X) + (Ballsize/6) + ((BOT(b).X - (Table1.Width/2))/7)) - 6
        End If
        ballShadow(b).Y = BOT(b).Y + 12
        If BOT(b).Z > 20 Then
            BallShadow(b).visible = 1
        Else
            BallShadow(b).visible = 0
        End If
    Next
End Sub


Sub LeftFlipper_Collide(parm)
    CheckLiveCatch Activeball, LeftFlipper, LFCount, parm
    LeftFlipperCollide parm   
End Sub


Sub LeftFlipperUp_Collide(parm)
    CheckLiveCatch Activeball, LeftFlipperUp, LFCount2, parm
    LeftFlipperCollide parm   
End Sub

Sub RightFlipper_Collide(parm)
    CheckLiveCatch Activeball, RightFlipper, RFCount, parm
    RightFlipperCollide parm  
End Sub



'*****************************************
'	Devious626	GUN FLASHER IMAGES
'*****************************************

Dim IMGPos, IMGPos2, IMGPos3, LastSwitchHit, Eagle_Images, M60_Images, MP5_Images
Eagle_Images = Array("Eagle_1", "Eagle_2", "Eagle_3", "Eagle_4", "Eagle_5", "Eagle_6", "Eagle_Blank") 'Eagle
M60_Images = Array("M60_1", "M60_2", "M60_3", "M60_4", "M60_5", "M60_6", "M60_7", "M60_8", "M60_9", "M60_10", "M60_11", "M60_12", "M60_13", "M60_14", "M60_15", "M60_16", "M60_17", "M60_18", "M60_19", "M60_20", "M60_blank") 'M60
MP5_Images = Array("Mp5_1", "Mp5_2", "Mp5_3", "Mp5_4", "Mp5_5", "Mp5_6", "Mp5_7", "Mp5_8", "Mp5_Blank") 'MP5

Sub TriggerM60_Hit:LastSwitchHit = "M60":StartImage:BIPL=1:End Sub
Sub TriggerM60_UnHit:BIPL=0:End Sub

Sub StartImage

	if (Gunfight = 0) then Exit Sub

    IMGPos = 0
	IMGPos2 = 0
	IMGPos3 = 0
		If (LastSwitchHit= "Eagle") then FlasherEagle.visible = True:ImageTimer.Enabled = 1:End If
		If (LastSwitchHit= "M60") then FlasherM60.visible = True:ImageTimer.Enabled = 1:End If
		If (LastSwitchHit= "MP5") then FlasherMP5.visible = True:ImageTimer.Enabled = 1:End If

End Sub

Sub ImageTimer_Timer

	if (Gunfight = 0) then Exit Sub
    'debug.print IMGpos
		If (LastSwitchHit= "Eagle") Then FlasherEagle.ImageA = Eagle_Images(IMGPos):IMGPos = (IMGPos + 1) MOD 7:PlaySound "Eagle_fx":End If	'Eagle
		If (LastSwitchHit= "M60") Then FlasherM60.ImageA = M60_Images(IMGPos2):IMGPos2 = (IMGPos2 + 1) MOD 21:PlaySound "m60_fx":ImageTimerStop.Enabled = 1:End If 'M60
		If (LastSwitchHit= "MP5") Then FlasherMP5.ImageA = MP5_Images(IMGPos3):IMGPos3 = (IMGPos3 + 1) MOD 9:PlaySound "mp5_fx":End If 'MP5
End Sub

Sub ImageTimerStop_Timer

	if (Gunfight = 0) then Exit Sub
    IMGPos = 0
	IMGPos2 = 0
	IMGPos3 = 0
		If (LastSwitchHit= "Eagle") then FlasherEagle.visible = False:StopSound "Eagle_fx":ImageTimer.Enabled = 0:ImageTimerStop.Enabled = 0:End If
		If (LastSwitchHit= "M60") then FlasherM60.visible = False:StopSound "m60_fx":ImageTimer.Enabled = 0:ImageTimerStop.Enabled = 0:End If
		If (LastSwitchHit= "MP5") then FlasherMP5.visible = False:StopSound "mp5_fx":ImageTimer.Enabled = 0:ImageTimerStop.Enabled = 0:End If
End Sub



'******************************************************
'****  FLIPPER CORRECTIONS by nFozzy
'******************************************************
dim LF : Set LF = New FlipperPolarity
dim LF2 : Set LF2 = New FlipperPolarity
dim RF : Set RF = New FlipperPolarity

InitPolarity

Sub InitPolarity()
        dim x, a : a = Array(LF, RF, LF2)
        for each x in a
                x.AddPoint "Ycoef", 0, RightFlipper.Y-65, 1        'disabled
                x.AddPoint "Ycoef", 1, RightFlipper.Y-11, 1
                x.enabled = True
                x.TimeDelay = 60
        Next

        AddPt "Polarity", 0, 0, 0
        AddPt "Polarity", 1, 0.05, -5.5
        AddPt "Polarity", 2, 0.4, -5.5
        AddPt "Polarity", 3, 0.6, -5.0
        AddPt "Polarity", 4, 0.65, -4.5
        AddPt "Polarity", 5, 0.7, -4.0
        AddPt "Polarity", 6, 0.75, -3.5
        AddPt "Polarity", 7, 0.8, -3.0
        AddPt "Polarity", 8, 0.85, -2.5
        AddPt "Polarity", 9, 0.9,-2.0
        AddPt "Polarity", 10, 0.95, -1.5
        AddPt "Polarity", 11, 1, -1.0
        AddPt "Polarity", 12, 1.05, -0.5
        AddPt "Polarity", 13, 1.1, 0
        AddPt "Polarity", 14, 1.3, 0

        addpt "Velocity", 0, 0,         1
        addpt "Velocity", 1, 0.16, 1.06
        addpt "Velocity", 2, 0.41,         1.05
        addpt "Velocity", 3, 0.53,         1'0.982
        addpt "Velocity", 4, 0.702, 0.968
        addpt "Velocity", 5, 0.95,  0.968
        addpt "Velocity", 6, 1.03,         0.945

        LF.Object = LeftFlipper        
        LF.EndPoint = EndPointLp
		LF2.Object = LeftFlipperUp        
        LF2.EndPoint = EndPointLp2
        RF.Object = RightFlipper
        RF.EndPoint = EndPointRp
End Sub

Sub TriggerLF_Hit() : LF.Addball activeball : End Sub
Sub TriggerLF_UnHit() : LF.PolarityCorrect activeball : End Sub
Sub TriggerLF2_Hit() : LF2.Addball activeball : End Sub
Sub TriggerLF2_UnHit() : LF2.PolarityCorrect activeball : End Sub
Sub TriggerRF_Hit() : RF.Addball activeball : End Sub
Sub TriggerRF_UnHit() : RF.PolarityCorrect activeball : End Sub

'******************************************************
'           FLIPPER CORRECTION FUNCTIONS
'******************************************************

Sub AddPt(aStr, idx, aX, aY)        'debugger wrapper for adjusting flipper script in-game
        dim a : a = Array(LF,LF2,RF)
        dim x : for each x in a
                x.addpoint aStr, idx, aX, aY
        Next
End Sub

Class FlipperPolarity
	Public DebugOn, Enabled
	Private FlipAt        'Timer variable (IE 'flip at 723,530ms...)
	Public TimeDelay        'delay before trigger turns off and polarity is disabled TODO set time!
	private Flipper, FlipperStart,FlipperEnd, FlipperEndY, LR, PartialFlipCoef
	Private Balls(20), balldata(20)
        
	dim PolarityIn, PolarityOut
	dim VelocityIn, VelocityOut
	dim YcoefIn, YcoefOut
	Public Sub Class_Initialize 
		redim PolarityIn(0) : redim PolarityOut(0) : redim VelocityIn(0) : redim VelocityOut(0) : redim YcoefIn(0) : redim YcoefOut(0)
		Enabled = True : TimeDelay = 50 : LR = 1:  dim x : for x = 0 to uBound(balls) : balls(x) = Empty : set Balldata(x) = new SpoofBall : next 
	End Sub
        
	Public Property let Object(aInput) : Set Flipper = aInput : StartPoint = Flipper.x : End Property
	Public Property Let StartPoint(aInput) : if IsObject(aInput) then FlipperStart = aInput.x else FlipperStart = aInput : end if : End Property
	Public Property Get StartPoint : StartPoint = FlipperStart : End Property
	Public Property Let EndPoint(aInput) : FlipperEnd = aInput.x: FlipperEndY = aInput.y: End Property
	Public Property Get EndPoint : EndPoint = FlipperEnd : End Property        
	Public Property Get EndPointY: EndPointY = FlipperEndY : End Property
        
	Public Sub AddPoint(aChooseArray, aIDX, aX, aY) 'Index #, X position, (in) y Position (out) 
		Select Case aChooseArray
			case "Polarity" : ShuffleArrays PolarityIn, PolarityOut, 1 : PolarityIn(aIDX) = aX : PolarityOut(aIDX) = aY : ShuffleArrays PolarityIn, PolarityOut, 0
			Case "Velocity" : ShuffleArrays VelocityIn, VelocityOut, 1 :VelocityIn(aIDX) = aX : VelocityOut(aIDX) = aY : ShuffleArrays VelocityIn, VelocityOut, 0
			Case "Ycoef" : ShuffleArrays YcoefIn, YcoefOut, 1 :YcoefIn(aIDX) = aX : YcoefOut(aIDX) = aY : ShuffleArrays YcoefIn, YcoefOut, 0
		End Select
		if gametime > 100 then Report aChooseArray
	End Sub 

	Public Sub Report(aChooseArray)         'debug, reports all coords in tbPL.text
		if not DebugOn then exit sub
		dim a1, a2 : Select Case aChooseArray
			case "Polarity" : a1 = PolarityIn : a2 = PolarityOut
			Case "Velocity" : a1 = VelocityIn : a2 = VelocityOut
			Case "Ycoef" : a1 = YcoefIn : a2 = YcoefOut 
			case else :tbpl.text = "wrong string" : exit sub
		End Select
		dim str, x : for x = 0 to uBound(a1) : str = str & aChooseArray & " x: " & round(a1(x),4) & ", " & round(a2(x),4) & vbnewline : next
		tbpl.text = str
	End Sub
        
	Public Sub AddBall(aBall) : dim x : for x = 0 to uBound(balls) : if IsEmpty(balls(x)) then set balls(x) = aBall : exit sub :end if : Next  : End Sub

	Private Sub RemoveBall(aBall)
		dim x : for x = 0 to uBound(balls)
		if TypeName(balls(x) ) = "IBall" then 
			if aBall.ID = Balls(x).ID Then
				balls(x) = Empty
				Balldata(x).Reset
			End If
		End If
		Next
	End Sub
        
	Public Sub Fire() 
		Flipper.RotateToEnd
		processballs
	End Sub

	Public Property Get Pos 'returns % position a ball. For debug stuff.
		dim x : for x = 0 to uBound(balls)
			if not IsEmpty(balls(x) ) then
				pos = pSlope(Balls(x).x, FlipperStart, 0, FlipperEnd, 1)
			End If
		Next                
	End Property

	Public Sub ProcessBalls() 'save data of balls in flipper range
		FlipAt = GameTime
		dim x : for x = 0 to uBound(balls)
			if not IsEmpty(balls(x) ) then
				balldata(x).Data = balls(x)
			End If
		Next
		PartialFlipCoef = ((Flipper.StartAngle - Flipper.CurrentAngle) / (Flipper.StartAngle - Flipper.EndAngle))
		PartialFlipCoef = abs(PartialFlipCoef-1)
	End Sub
	Private Function FlipperOn() : if gameTime < FlipAt+TimeDelay then FlipperOn = True : End If : End Function        'Timer shutoff for polaritycorrect
        
	Public Sub PolarityCorrect(aBall)
		if FlipperOn() then 
			dim tmp, BallPos, x, IDX, Ycoef : Ycoef = 1

			'y safety Exit
			if aBall.VelY > -8 then 'ball going down
				RemoveBall aBall
				exit Sub
			end if

			'Find balldata. BallPos = % on Flipper
			for x = 0 to uBound(Balls)
				if aBall.id = BallData(x).id AND not isempty(BallData(x).id) then 
					idx = x
					BallPos = PSlope(BallData(x).x, FlipperStart, 0, FlipperEnd, 1)
					if ballpos > 0.65 then  Ycoef = LinearEnvelope(BallData(x).Y, YcoefIn, YcoefOut)                                'find safety coefficient 'ycoef' data
				end if
			Next

			If BallPos = 0 Then 'no ball data meaning the ball is entering and exiting pretty close to the same position, use current values.
				BallPos = PSlope(aBall.x, FlipperStart, 0, FlipperEnd, 1)
				if ballpos > 0.65 then  Ycoef = LinearEnvelope(aBall.Y, YcoefIn, YcoefOut)                                                'find safety coefficient 'ycoef' data
 			End If

			'Velocity correction
			if not IsEmpty(VelocityIn(0) ) then
				Dim VelCoef
				VelCoef = LinearEnvelope(BallPos, VelocityIn, VelocityOut)

				if partialflipcoef < 1 then VelCoef = PSlope(partialflipcoef, 0, 1, 1, VelCoef)

				if Enabled then aBall.Velx = aBall.Velx*VelCoef
				if Enabled then aBall.Vely = aBall.Vely*VelCoef
			End If

                        'Polarity Correction (optional now)
			if not IsEmpty(PolarityIn(0) ) then
				If StartPoint > EndPoint then LR = -1        'Reverse polarity if left flipper
				dim AddX : AddX = LinearEnvelope(BallPos, PolarityIn, PolarityOut) * LR
        
				if Enabled then aBall.VelX = aBall.VelX + 1 * (AddX*ycoef*PartialFlipcoef)
			End If
		End If
		RemoveBall aBall
	End Sub
End Class

'******************************************************
'                FLIPPER POLARITY AND RUBBER DAMPENER
'                        SUPPORTING FUNCTIONS 
'******************************************************

' Used for flipper correction and rubber dampeners
Sub ShuffleArray(ByRef aArray, byVal offset) 'shuffle 1d array
	dim x, aCount : aCount = 0
	redim a(uBound(aArray) )
	for x = 0 to uBound(aArray)        'Shuffle objects in a temp array
		if not IsEmpty(aArray(x) ) Then
			if IsObject(aArray(x)) then 
				Set a(aCount) = aArray(x)
			Else
				a(aCount) = aArray(x)
			End If
			aCount = aCount + 1
		End If
	Next
	if offset < 0 then offset = 0
	redim aArray(aCount-1+offset)        'Resize original array
	for x = 0 to aCount-1                'set objects back into original array
		if IsObject(a(x)) then 
			Set aArray(x) = a(x)
		Else
			aArray(x) = a(x)
		End If
	Next
End Sub

' Used for flipper correction and rubber dampeners
Sub ShuffleArrays(aArray1, aArray2, offset)
	ShuffleArray aArray1, offset
	ShuffleArray aArray2, offset
End Sub

' Used for flipper correction, rubber dampeners, and drop targets
Function BallSpeed(ball) 'Calculates the ball speed
    BallSpeed = SQR(ball.VelX^2 + ball.VelY^2 + ball.VelZ^2)
End Function

' Used for flipper correction and rubber dampeners
Function PSlope(Input, X1, Y1, X2, Y2)        'Set up line via two points, no clamping. Input X, output Y
	dim x, y, b, m : x = input : m = (Y2 - Y1) / (X2 - X1) : b = Y2 - m*X2
	Y = M*x+b
	PSlope = Y
End Function

' Used for flipper correction
Class spoofball 
	Public X, Y, Z, VelX, VelY, VelZ, ID, Mass, Radius 
	Public Property Let Data(aBall)
		With aBall
			x = .x : y = .y : z = .z : velx = .velx : vely = .vely : velz = .velz
			id = .ID : mass = .mass : radius = .radius
		end with
	End Property
	Public Sub Reset()
		x = Empty : y = Empty : z = Empty  : velx = Empty : vely = Empty : velz = Empty 
		id = Empty : mass = Empty : radius = Empty
	End Sub
End Class

' Used for flipper correction and rubber dampeners
Function LinearEnvelope(xInput, xKeyFrame, yLvl)
	dim y 'Y output
	dim L 'Line
	dim ii : for ii = 1 to uBound(xKeyFrame)        'find active line
		if xInput <= xKeyFrame(ii) then L = ii : exit for : end if
	Next
	if xInput > xKeyFrame(uBound(xKeyFrame) ) then L = uBound(xKeyFrame)        'catch line overrun
	Y = pSlope(xInput, xKeyFrame(L-1), yLvl(L-1), xKeyFrame(L), yLvl(L) )

	if xInput <= xKeyFrame(lBound(xKeyFrame) ) then Y = yLvl(lBound(xKeyFrame) )         'Clamp lower
	if xInput >= xKeyFrame(uBound(xKeyFrame) ) then Y = yLvl(uBound(xKeyFrame) )        'Clamp upper

	LinearEnvelope = Y
End Function

'******************************************************
'                        FLIPPER TRICKS
'******************************************************

RightFlipper.timerinterval=1
Rightflipper.timerenabled=True

sub RightFlipper_timer()
	FlipperTricks LeftFlipper, LFPress, LFCount, LFEndAngle, LFState
	FlipperTricks LeftFlipperUp, LFPress2, LFCount2, LFEndAngle2, LFState
	FlipperTricks RightFlipper, RFPress, RFCount, RFEndAngle, RFState
	FlipperNudge RightFlipper, RFEndAngle, RFEOSNudge, LeftFlipper, LFEndAngle
	FlipperNudge LeftFlipper, LFEndAngle, LFEOSNudge,  RightFlipper, RFEndAngle
	FlipperNudge LeftFlipperUp, LFEndAngle2, LFEOSNudge2,  RightFlipper, RFEndAngle
end sub

Dim LFEOSNudge,LFEOSNudge2,RFEOSNudge

Sub FlipperNudge(Flipper1, Endangle1, EOSNudge1, Flipper2, EndAngle2)
	Dim b, BOT
	BOT = GetBalls

	If Flipper1.currentangle = Endangle1 and EOSNudge1 <> 1 Then
		EOSNudge1 = 1
	'	debug.print Flipper1.currentangle &" = "& Endangle1 &"--"& Flipper2.currentangle &" = "& EndAngle2
		If Flipper2.currentangle = EndAngle2 Then 
			For b = 0 to Ubound(BOT)
				If FlipperTrigger(BOT(b).x, BOT(b).y, Flipper1) Then
					'Debug.Print "ball in flip1. exit"
					exit Sub
				end If
			Next
			For b = 0 to Ubound(BOT)
				If FlipperTrigger(BOT(b).x, BOT(b).y, Flipper2) Then
					BOT(b).velx = BOT(b).velx / 1.3
					BOT(b).vely = BOT(b).vely - 0.5
				end If
			Next
		End If
	Else 
		If Abs(Flipper1.currentangle) > Abs(EndAngle1) + 30 then EOSNudge1 = 0
	End If
End Sub

'*****************
' Maths
'*****************
Dim PI: PI = 4*Atn(1)

Function dSin(degrees)
	dsin = sin(degrees * Pi/180)
End Function

Function dCos(degrees)
	dcos = cos(degrees * Pi/180)
End Function

Function Atn2(dy, dx)
	If dx > 0 Then
		Atn2 = Atn(dy / dx)
	ElseIf dx < 0 Then
		If dy = 0 Then 
			Atn2 = pi
		Else
			Atn2 = Sgn(dy) * (pi - Atn(Abs(dy / dx)))
		end if
	ElseIf dx = 0 Then
		if dy = 0 Then
			Atn2 = 0
		else
			Atn2 = Sgn(dy) * pi / 2
		end if
	End If
End Function

'*************************************************
' Check ball distance from Flipper for Rem
'*************************************************

Function Distance(ax,ay,bx,by)
	Distance = SQR((ax - bx)^2 + (ay - by)^2)
End Function

Function DistancePL(px,py,ax,ay,bx,by) ' Distance between a point and a line where point is px,py
	DistancePL = ABS((by - ay)*px - (bx - ax) * py + bx*ay - by*ax)/Distance(ax,ay,bx,by)
End Function

Function Radians(Degrees)
	Radians = Degrees * PI /180
End Function

Function AnglePP(ax,ay,bx,by)
	AnglePP = Atn2((by - ay),(bx - ax))*180/PI
End Function

Function DistanceFromFlipper(ballx, bally, Flipper)
	DistanceFromFlipper = DistancePL(ballx, bally, Flipper.x, Flipper.y, Cos(Radians(Flipper.currentangle+90))+Flipper.x, Sin(Radians(Flipper.currentangle+90))+Flipper.y)
End Function

Function FlipperTrigger(ballx, bally, Flipper)
	Dim DiffAngle
	DiffAngle  = ABS(Flipper.currentangle - AnglePP(Flipper.x, Flipper.y, ballx, bally) - 90)
	If DiffAngle > 180 Then DiffAngle = DiffAngle - 360

	If DistanceFromFlipper(ballx,bally,Flipper) < 48 and DiffAngle <= 90 and Distance(ballx,bally,Flipper.x,Flipper.y) < Flipper.Length Then
		FlipperTrigger = True
	Else
		FlipperTrigger = False
	End If        
End Function


'*************************************************
' End - Check ball distance from Flipper for Rem
'*************************************************

dim LFPress,LFPress2, RFPress, LFCount,LFCount2, RFCount
dim LFState,LFState2, RFState
dim EOST, EOSA,Frampup, FElasticity,FReturn
dim RFEndAngle, LFEndAngle, LFEndAngle2

Const FlipperCoilRampupMode = 0   	'0 = fast, 1 = medium, 2 = slow (tap passes should work)

LFState = 1
RFState = 1
EOST = leftflipper.eostorque
EOSA = leftflipper.eostorqueangle
Frampup = LeftFlipper.rampup
FElasticity = LeftFlipper.elasticity
FReturn = LeftFlipper.return
Const EOSTnew = 0.8 
Const EOSAnew = 1
Const EOSRampup = 0
Dim SOSRampup
Select Case FlipperCoilRampupMode 
	Case 0:
		SOSRampup = 2.5
	Case 1:
		SOSRampup = 6
	Case 2:
		SOSRampup = 8.5
End Select

Const LiveCatch = 16
Const LiveElasticity = 0.45
Const SOSEM = 0.815
Const EOSReturn = 0.025

LFEndAngle = Leftflipper.endangle
LFEndAngle2 = LeftFlipperUp.endangle
RFEndAngle = RightFlipper.endangle

Sub FlipperActivate(Flipper, FlipperPress)
	FlipperPress = 1
	Flipper.Elasticity = FElasticity

	Flipper.eostorque = EOST         
	Flipper.eostorqueangle = EOSA         
End Sub

Sub FlipperDeactivate(Flipper, FlipperPress)
	FlipperPress = 0
	Flipper.eostorqueangle = EOSA
	Flipper.eostorque = EOST*EOSReturn/FReturn

        
	If Abs(Flipper.currentangle) <= Abs(Flipper.endangle) + 0.1 Then
		Dim b, BOT
		BOT = GetBalls
                        
		For b = 0 to UBound(BOT)
			If Distance(BOT(b).x, BOT(b).y, Flipper.x, Flipper.y) < 55 Then 'check for cradle
				If BOT(b).vely >= -0.4 Then BOT(b).vely = -0.4
			End If
		Next
	End If
End Sub

Sub FlipperTricks (Flipper, FlipperPress, FCount, FEndAngle, FState) 
	Dim Dir
	Dir = Flipper.startangle/Abs(Flipper.startangle)        '-1 for Right Flipper

	If Abs(Flipper.currentangle) > Abs(Flipper.startangle) - 0.05 Then
		If FState <> 1 Then
			Flipper.rampup = SOSRampup 
			Flipper.endangle = FEndAngle - 3*Dir
			Flipper.Elasticity = FElasticity * SOSEM
			FCount = 0 
			FState = 1
		End If
	ElseIf Abs(Flipper.currentangle) <= Abs(Flipper.endangle) and FlipperPress = 1 then
		if FCount = 0 Then FCount = GameTime

		If FState <> 2 Then
			Flipper.eostorqueangle = EOSAnew
			Flipper.eostorque = EOSTnew
			Flipper.rampup = EOSRampup                        
			Flipper.endangle = FEndAngle
			FState = 2
		End If
	Elseif Abs(Flipper.currentangle) > Abs(Flipper.endangle) + 0.01 and FlipperPress = 1 Then 
		If FState <> 3 Then
			Flipper.eostorque = EOST        
			Flipper.eostorqueangle = EOSA
			Flipper.rampup = Frampup
			Flipper.Elasticity = FElasticity
			FState = 3
		End If

	End If
End Sub

Const LiveDistanceMin = 30  'minimum distance in vp units from flipper base live catch dampening will occur
Const LiveDistanceMax = 114  'maximum distance in vp units from flipper base live catch dampening will occur (tip protection)

Sub CheckLiveCatch(ball, Flipper, FCount, parm) 'Experimental new live catch
	Dim Dir
	Dir = Flipper.startangle/Abs(Flipper.startangle)    '-1 for Right Flipper
	Dim LiveCatchBounce                                                                                                                        'If live catch is not perfect, it won't freeze ball totally
	Dim CatchTime : CatchTime = GameTime - FCount

	if CatchTime <= LiveCatch and parm > 6 and ABS(Flipper.x - ball.x) > LiveDistanceMin and ABS(Flipper.x - ball.x) < LiveDistanceMax Then
		if CatchTime <= LiveCatch*0.5 Then                                                'Perfect catch only when catch time happens in the beginning of the window
			LiveCatchBounce = 0
		else
			LiveCatchBounce = Abs((LiveCatch/2) - CatchTime)        'Partial catch when catch happens a bit late
		end If

		If LiveCatchBounce = 0 and ball.velx * Dir > 0 Then ball.velx = 0
		ball.vely = LiveCatchBounce * (32 / LiveCatch) ' Multiplier for inaccuracy bounce
		ball.angmomx= 0
		ball.angmomy= 0
		ball.angmomz= 0
	Else
        If Abs(Flipper.currentangle) <= Abs(Flipper.endangle) + 1 Then FlippersD.Dampenf Activeball, parm
	End If
End Sub

'******************************************************
'****  END FLIPPER CORRECTIONS
'******************************************************


'****************************************************************************
'PHYSICS DAMPENERS
'****************************************************************************

'These are data mined bounce curves, 
'dialed in with the in-game elasticity as much as possible to prevent angle / spin issues.
'Requires tracking ballspeed to calculate COR


Sub dPosts_Hit(idx) 
	RubbersD.dampen Activeball
	TargetBouncer Activeball, 1
End Sub

Sub dSleeves_Hit(idx) 
	SleevesD.Dampen Activeball
	TargetBouncer Activeball, 0.7
End Sub


dim RubbersD : Set RubbersD = new Dampener        'frubber
RubbersD.name = "Rubbers"
RubbersD.debugOn = False        'shows info in textbox "TBPout"
RubbersD.Print = False        'debug, reports in debugger (in vel, out cor)
'cor bounce curve (linear)
'for best results, try to match in-game velocity as closely as possible to the desired curve
'RubbersD.addpoint 0, 0, 0.935        'point# (keep sequential), ballspeed, CoR (elasticity)
RubbersD.addpoint 0, 0, 1.1        'point# (keep sequential), ballspeed, CoR (elasticity)
RubbersD.addpoint 1, 3.77, 0.97
RubbersD.addpoint 2, 5.76, 0.967        'dont take this as gospel. if you can data mine rubber elasticitiy, please help!
RubbersD.addpoint 3, 15.84, 0.874
RubbersD.addpoint 4, 56, 0.64        'there's clamping so interpolate up to 56 at least

dim SleevesD : Set SleevesD = new Dampener        'this is just rubber but cut down to 85%...
SleevesD.name = "Sleeves"
SleevesD.debugOn = False        'shows info in textbox "TBPout"
SleevesD.Print = False        'debug, reports in debugger (in vel, out cor)
SleevesD.CopyCoef RubbersD, 0.85

'######################### Add new FlippersD Profile
'#########################    Adjust these values to increase or lessen the elasticity

dim FlippersD : Set FlippersD = new Dampener
FlippersD.name = "Flippers"
FlippersD.debugOn = False
FlippersD.Print = False	
FlippersD.addpoint 0, 0, 1.1	
FlippersD.addpoint 1, 3.77, 0.99
FlippersD.addpoint 2, 6, 0.99

Class Dampener
	Public Print, debugOn 'tbpOut.text
	public name, Threshold         'Minimum threshold. Useful for Flippers, which don't have a hit threshold.
	Public ModIn, ModOut
	Private Sub Class_Initialize : redim ModIn(0) : redim Modout(0): End Sub 

	Public Sub AddPoint(aIdx, aX, aY) 
		ShuffleArrays ModIn, ModOut, 1 : ModIn(aIDX) = aX : ModOut(aIDX) = aY : ShuffleArrays ModIn, ModOut, 0
		if gametime > 100 then Report
	End Sub

	public sub Dampen(aBall)
		if threshold then if BallSpeed(aBall) < threshold then exit sub end if end if
		dim RealCOR, DesiredCOR, str, coef
		DesiredCor = LinearEnvelope(cor.ballvel(aBall.id), ModIn, ModOut )
		RealCOR = BallSpeed(aBall) / (cor.ballvel(aBall.id)+0.0000001)
		coef = desiredcor / realcor 
		if debugOn then str = name & " in vel:" & round(cor.ballvel(aBall.id),2 ) & vbnewline & "desired cor: " & round(desiredcor,4) & vbnewline & _
		"actual cor: " & round(realCOR,4) & vbnewline & "ballspeed coef: " & round(coef, 3) & vbnewline 
		if Print then debug.print Round(cor.ballvel(aBall.id),2) & ", " & round(desiredcor,3)
                
		aBall.velx = aBall.velx * coef : aBall.vely = aBall.vely * coef
		if debugOn then TBPout.text = str
	End Sub

	public sub Dampenf(aBall, parm) 'Rubberizer is handle here
		dim RealCOR, DesiredCOR, str, coef
		DesiredCor = LinearEnvelope(cor.ballvel(aBall.id), ModIn, ModOut )
		RealCOR = BallSpeed(aBall) / (cor.ballvel(aBall.id)+0.0001)
		coef = desiredcor / realcor 
		If abs(aball.velx) < 2 and aball.vely < 0 and aball.vely > -3.75 then 
			aBall.velx = aBall.velx * coef : aBall.vely = aBall.vely * coef
		End If
	End Sub

	Public Sub CopyCoef(aObj, aCoef) 'alternative addpoints, copy with coef
		dim x : for x = 0 to uBound(aObj.ModIn)
			addpoint x, aObj.ModIn(x), aObj.ModOut(x)*aCoef
		Next
	End Sub


	Public Sub Report()         'debug, reports all coords in tbPL.text
		if not debugOn then exit sub
		dim a1, a2 : a1 = ModIn : a2 = ModOut
		dim str, x : for x = 0 to uBound(a1) : str = str & x & ": " & round(a1(x),4) & ", " & round(a2(x),4) & vbnewline : next
		TBPout.text = str
	End Sub
        
End Class

'******************************************************
' VPW TargetBouncer for targets and posts by Iaakki, Wrd1972, Apophis
'******************************************************

Const TargetBouncerEnabled = 1 		'0 = normal standup targets, 1 = bouncy targets, 2 = orig TargetBouncer
Const TargetBouncerFactor = 0.7 	'Level of bounces. Recommmended value of 0.7 when TargetBouncerEnabled=1, and 1.1 when TargetBouncerEnabled=2

sub TargetBouncer(aBall,defvalue)
    dim zMultiplier, vel, vratio
    if TargetBouncerEnabled = 1 and aball.z < 30 then
        'debug.print "velx: " & aball.velx & " vely: " & aball.vely & " velz: " & aball.velz
        vel = BallSpeed(aBall)
        if aBall.velx = 0 then vratio = 1 else vratio = aBall.vely/aBall.velx
        Select Case Int(Rnd * 6) + 1
            Case 1: zMultiplier = 0.2*defvalue
			Case 2: zMultiplier = 0.25*defvalue
            Case 3: zMultiplier = 0.3*defvalue
			Case 4: zMultiplier = 0.4*defvalue
            Case 5: zMultiplier = 0.45*defvalue
            Case 6: zMultiplier = 0.5*defvalue
        End Select
        aBall.velz = abs(vel * zMultiplier * TargetBouncerFactor)
        aBall.velx = sgn(aBall.velx) * sqr(abs((vel^2 - aBall.velz^2)/(1+vratio^2)))
        aBall.vely = aBall.velx * vratio
        'debug.print "---> velx: " & aball.velx & " vely: " & aball.vely & " velz: " & aball.velz
        'debug.print "conservation check: " & BallSpeed(aBall)/vel
    elseif TargetBouncerEnabled = 2 and aball.z < 30 then
		'debug.print "velz: " & activeball.velz
		Select Case Int(Rnd * 4) + 1
			Case 1: zMultiplier = defvalue+1.1
			Case 2: zMultiplier = defvalue+1.05
			Case 3: zMultiplier = defvalue+0.7
			Case 4: zMultiplier = defvalue+0.3
		End Select
		aBall.velz = aBall.velz * zMultiplier * TargetBouncerFactor
		'debug.print "----> velz: " & activeball.velz
		'debug.print "conservation check: " & BallSpeed(aBall)/vel
	end if
end sub

Sub TargetBounce_Hit
	TargetBouncer activeball, 1
End Sub




'******************************************************
'		TRACK ALL BALL VELOCITIES
' 		FOR RUBBER DAMPENER AND DROP TARGETS
'******************************************************

dim cor : set cor = New CoRTracker

Class CoRTracker
	public ballvel, ballvelx, ballvely

	Private Sub Class_Initialize : redim ballvel(0) : redim ballvelx(0): redim ballvely(0) : End Sub 

	Public Sub Update()	'tracks in-ball-velocity
		dim str, b, AllBalls, highestID : allBalls = getballs

		for each b in allballs
			if b.id >= HighestID then highestID = b.id
		Next

		if uBound(ballvel) < highestID then redim ballvel(highestID)	'set bounds
		if uBound(ballvelx) < highestID then redim ballvelx(highestID)	'set bounds
		if uBound(ballvely) < highestID then redim ballvely(highestID)	'set bounds

		for each b in allballs
			ballvel(b.id) = BallSpeed(b)
			ballvelx(b.id) = b.velx
			ballvely(b.id) = b.vely
		Next
	End Sub
End Class

Sub RDampen_Timer()
	Cor.Update 						'update ball tracking (this sometimes goes in the RDampen_Timer sub)
	RollingUpdate					'update rolling sounds
End Sub



'******************************************************
'****  END PHYSICS DAMPENERS
'******************************************************



'////////////////////////////  MECHANICAL SOUNDS  ///////////////////////////
'//  This part in the script is an entire block that is dedicated to the physics sound system.
'//  Various scripts and sounds that may be pretty generic and could suit other WPC systems, but the most are tailored specifically for this table.


'///////////////////////////////  SOUNDS PARAMETERS  //////////////////////////////
Dim GlobalSoundLevel, CoinSoundLevel, PlungerReleaseSoundLevel, PlungerPullSoundLevel, NudgeLeftSoundLevel
Dim NudgeRightSoundLevel, NudgeCenterSoundLevel, StartButtonSoundLevel, RollingSoundFactor


CoinSoundLevel = 1                                                                                                                'volume level; range [0, 1]
NudgeLeftSoundLevel = 1                                                                                                        'volume level; range [0, 1]
NudgeRightSoundLevel = 1                                                                                                'volume level; range [0, 1]
NudgeCenterSoundLevel = 1                                                                                                'volume level; range [0, 1]
StartButtonSoundLevel = 0.1                                                                                                'volume level; range [0, 1]
PlungerReleaseSoundLevel = 0.8 '1 wjr                                                                                        'volume level; range [0, 1]
PlungerPullSoundLevel = 1                                                                                                'volume level; range [0, 1]
RollingSoundFactor = 1.1/5                


'///////////////////////-----Solenoids, Kickers and Flash Relays-----///////////////////////
Dim FlipperUpAttackMinimumSoundLevel, FlipperUpAttackMaximumSoundLevel, FlipperUpAttackLeftSoundLevel, FlipperUpAttackRightSoundLevel
Dim FlipperUpSoundLevel, FlipperDownSoundLevel, FlipperLeftHitParm, FlipperRightHitParm
Dim SlingshotSoundLevel, BumperSoundFactor, KnockerSoundLevel


FlipperUpAttackMinimumSoundLevel = 0.010                                                           'volume level; range [0, 1]
FlipperUpAttackMaximumSoundLevel = 0.635                                                                'volume level; range [0, 1]
FlipperUpSoundLevel = 1.0                                                                        'volume level; range [0, 1]
FlipperDownSoundLevel = 0.45                                                                      'volume level; range [0, 1]
FlipperLeftHitParm = FlipperUpSoundLevel                                                                'sound helper; not configurable
FlipperRightHitParm = FlipperUpSoundLevel                                                                'sound helper; not configurable
SlingshotSoundLevel = 0.95                                                                                                'volume level; range [0, 1]
BumperSoundFactor = 4.25                                                                                                'volume multiplier; must not be zero
KnockerSoundLevel = 1                                                                                                         'volume level; range [0, 1]


'///////////////////////-----Ball Drops, Bumps and Collisions-----///////////////////////
Dim RubberStrongSoundFactor, RubberWeakSoundFactor, RubberFlipperSoundFactor,BallWithBallCollisionSoundFactor
Dim BallBouncePlayfieldSoftFactor, BallBouncePlayfieldHardFactor, PlasticRampDropToPlayfieldSoundLevel, WireRampDropToPlayfieldSoundLevel, DelayedBallDropOnPlayfieldSoundLevel
Dim WallImpactSoundFactor, MetalImpactSoundFactor, SubwaySoundLevel, SubwayEntrySoundLevel, ScoopEntrySoundLevel
Dim SaucerLockSoundLevel, SaucerKickSoundLevel


BallWithBallCollisionSoundFactor = 3.2                                                                        'volume multiplier; must not be zero
RubberStrongSoundFactor = 0.055/5                                                                                        'volume multiplier; must not be zero
RubberWeakSoundFactor = 0.075/5                                                                                        'volume multiplier; must not be zero
RubberFlipperSoundFactor = 0.075/5                                                                                'volume multiplier; must not be zero
BallBouncePlayfieldSoftFactor = 0.025                                                                        'volume multiplier; must not be zero
BallBouncePlayfieldHardFactor = 0.025                                                                        'volume multiplier; must not be zero
DelayedBallDropOnPlayfieldSoundLevel = 0.8                                                                        'volume level; range [0, 1]
WallImpactSoundFactor = 0.075                                                                                        'volume multiplier; must not be zero
MetalImpactSoundFactor = 0.075/3
SaucerLockSoundLevel = 0.8
SaucerKickSoundLevel = 0.8


'///////////////////////-----Gates, Spinners, Rollovers and Targets-----///////////////////////


Dim GateSoundLevel, TargetSoundFactor, SpinnerSoundLevel, RolloverSoundLevel, DTSoundLevel

GateSoundLevel = 0.5/5													'volume level; range [0, 1]
TargetSoundFactor = 0.0025 * 10											'volume multiplier; must not be zero
DTSoundLevel = 0.25														'volume multiplier; must not be zero
RolloverSoundLevel = 0.25                              					'volume level; range [0, 1]
SpinnerSoundLevel = 0.5                              					'volume level; range [0, 1]

'///////////////////////-----Ball Release, Guides and Drain-----///////////////////////
Dim DrainSoundLevel, BallReleaseSoundLevel, BottomArchBallGuideSoundFactor, FlipperBallGuideSoundFactor 


DrainSoundLevel = 0.8                                                                                                                'volume level; range [0, 1]
BallReleaseSoundLevel = 1                                                                                                'volume level; range [0, 1]
BottomArchBallGuideSoundFactor = 0.2                                                                        'volume multiplier; must not be zero
FlipperBallGuideSoundFactor = 0.015                                                                                'volume multiplier; must not be zero


'///////////////////////-----Loops and Lanes-----///////////////////////
Dim ArchSoundFactor
ArchSoundFactor = 0.025/5                                                                                                        'volume multiplier; must not be zero




'/////////////////////////////  SOUND PLAYBACK FUNCTIONS  ////////////////////////////
'/////////////////////////////  POSITIONAL SOUND PLAYBACK METHODS  ////////////////////////////
' Positional sound playback methods will play a sound, depending on the X,Y position of the table element or depending on ActiveBall object position
' These are similar subroutines that are less complicated to use (e.g. simply use standard parameters for the PlaySound call)
' For surround setup - positional sound playback functions will fade between front and rear surround channels and pan between left and right channels
' For stereo setup - positional sound playback functions will only pan between left and right channels
' For mono setup - positional sound playback functions will not pan between left and right channels and will not fade between front and rear channels


' PlaySound full syntax - PlaySound(string, int loopcount, float volume, float pan, float randompitch, int pitch, bool useexisting, bool restart, float front_rear_fade)
' Note - These functions will not work (currently) for walls/slingshots as these do not feature a simple, single X,Y position
Sub PlaySoundAtLevelStatic(playsoundparams, aVol, tableobj)
    PlaySound playsoundparams, 0, aVol * VolumeDial, AudioPan(tableobj), 0, 0, 0, 0, AudioFade(tableobj)
End Sub


Sub PlaySoundAtLevelExistingStatic(playsoundparams, aVol, tableobj)
    PlaySound playsoundparams, 0, aVol * VolumeDial, AudioPan(tableobj), 0, 0, 1, 0, AudioFade(tableobj)
End Sub


Sub PlaySoundAtLevelStaticLoop(playsoundparams, aVol, tableobj)
    PlaySound playsoundparams, -1, aVol * VolumeDial, AudioPan(tableobj), 0, 0, 0, 0, AudioFade(tableobj)
End Sub


Sub PlaySoundAtLevelStaticRandomPitch(playsoundparams, aVol, randomPitch, tableobj)
    PlaySound playsoundparams, 0, aVol * VolumeDial, AudioPan(tableobj), randomPitch, 0, 0, 0, AudioFade(tableobj)
End Sub


Sub PlaySoundAtLevelActiveBall(playsoundparams, aVol)
        PlaySound playsoundparams, 0, aVol * VolumeDial, AudioPan(ActiveBall), 0, 0, 0, 0, AudioFade(ActiveBall)
End Sub


Sub PlaySoundAtLevelExistingActiveBall(playsoundparams, aVol)
        PlaySound playsoundparams, 0, aVol * VolumeDial, AudioPan(ActiveBall), 0, 0, 1, 0, AudioFade(ActiveBall)
End Sub


Sub PlaySoundAtLeveTimerActiveBall(playsoundparams, aVol, ballvariable)
        PlaySound playsoundparams, 0, aVol * VolumeDial, AudioPan(ballvariable), 0, 0, 0, 0, AudioFade(ballvariable)
End Sub


Sub PlaySoundAtLevelTimerExistingActiveBall(playsoundparams, aVol, ballvariable)
        PlaySound playsoundparams, 0, aVol * VolumeDial, AudioPan(ballvariable), 0, 0, 1, 0, AudioFade(ballvariable)
End Sub


Sub PlaySoundAtLevelRoll(playsoundparams, aVol, pitch)
    PlaySound playsoundparams, -1, aVol * VolumeDial, AudioPan(tableobj), randomPitch, 0, 0, 0, AudioFade(tableobj)
End Sub


' Previous Positional Sound Subs


Sub PlaySoundAt(soundname, tableobj)
    PlaySound soundname, 1, 1 * VolumeDial, AudioPan(tableobj), 0,0,0, 1, AudioFade(tableobj)
End Sub


Sub PlaySoundAtVol(soundname, tableobj, aVol)
    PlaySound soundname, 1, aVol * VolumeDial, AudioPan(tableobj), 0,0,0, 1, AudioFade(tableobj)
End Sub


Sub PlaySoundAtBall(soundname)
    PlaySoundAt soundname, ActiveBall
End Sub


Sub PlaySoundAtBallVol (Soundname, aVol)
        Playsound soundname, 1,aVol * VolumeDial, AudioPan(ActiveBall), 0,0,0, 1, AudioFade(ActiveBall)
End Sub


Sub PlaySoundAtBallVolM (Soundname, aVol)
        Playsound soundname, 1,aVol * VolumeDial, AudioPan(ActiveBall), 0,0,0, 0, AudioFade(ActiveBall)
End Sub


Sub PlaySoundAtVolLoops(sound, tableobj, Vol, Loops)
        PlaySound sound, Loops, Vol * VolumeDial, AudioPan(tableobj), 0,0,0, 1, AudioFade(tableobj)
End Sub



'******************************************************
'**** RAMP ROLLING SFX
'******************************************************

'Ball tracking ramp SFX 1.0
'   Reqirements:
'          * Import A Sound File for each ball on the table for plastic ramps.  Call It RampLoop<Ball_Number> ex: RampLoop1, RampLoop2, ...
'          * Import a Sound File for each ball on the table for wire ramps. Call it WireLoop<Ball_Number> ex: WireLoop1, WireLoop2, ...
'          * Create a Timer called RampRoll, that is enabled, with a interval of 100
'          * Set RampBAlls and RampType variable to Total Number of Balls
'	Usage:
'          * Setup hit events and call WireRampOn True or WireRampOn False (True = Plastic ramp, False = Wire Ramp)
'          * To stop tracking ball
'                 * call WireRampOff
'                 * Otherwise, the ball will auto remove if it's below 30 vp units
'

dim RampMinLoops : RampMinLoops = 4

' RampBalls
'      Setup:        Set the array length of x in RampBalls(x,2) Total Number of Balls on table + 1:  if tnob = 5, then RammBalls(6,2)
'      Description:  
dim RampBalls(6,2)
'x,0 = ball x,1 = ID,	2 = Protection against ending early (minimum amount of updates)
'0,0 is boolean on/off, 0,1 unused for now
RampBalls(0,0) = False

' RampType
'     Setup: Set this array to the number Total number of balls that can be tracked at one time + 1.  5 ball multiball then set value to 6
'     Description: Array type indexed on BallId and a values used to deterimine what type of ramp the ball is on: False = Wire Ramp, True = Plastic Ramp
dim RampType(6)	

Sub WireRampOn(input)  : Waddball ActiveBall, input : RampRollUpdate: End Sub
Sub WireRampOff() : WRemoveBall ActiveBall.ID	: End Sub


' WaddBall (Active Ball, Boolean)
'     Description: This subroutine is called from WireRampOn to Add Balls to the RampBalls Array
Sub Waddball(input, RampInput)	'Add ball
	' This will loop through the RampBalls array checking each element of the array x, position 1
	' To see if the the ball was already added to the array.
	' If the ball is found then exit the subroutine
	dim x : for x = 1 to uBound(RampBalls)	'Check, don't add balls twice
		if RampBalls(x, 1) = input.id then 
			if Not IsEmpty(RampBalls(x,1) ) then Exit Sub	'Frustating issue with BallId 0. Empty variable = 0
		End If
	Next

	' This will itterate through the RampBalls Array.
	' The first time it comes to a element in the array where the Ball Id (Slot 1) is empty.  It will add the current ball to the array
	' The RampBalls assigns the ActiveBall to element x,0 and ball id of ActiveBall to 0,1
	' The RampType(BallId) is set to RampInput
	' RampBalls in 0,0 is set to True, this will enable the timer and the timer is also turned on
	For x = 1 to uBound(RampBalls)
		if IsEmpty(RampBalls(x, 1)) then 
			Set RampBalls(x, 0) = input
			RampBalls(x, 1)	= input.ID
			RampType(x) = RampInput
			RampBalls(x, 2)	= 0
			'exit For
			RampBalls(0,0) = True
			RampRoll.Enabled = 1	 'Turn on timer
			'RampRoll.Interval = RampRoll.Interval 'reset timer
			exit Sub
		End If
		if x = uBound(RampBalls) then 	'debug
			Debug.print "WireRampOn error, ball queue is full: " & vbnewline & _
			RampBalls(0, 0) & vbnewline & _
			Typename(RampBalls(1, 0)) & " ID:" & RampBalls(1, 1) & "type:" & RampType(1) & vbnewline & _
			Typename(RampBalls(2, 0)) & " ID:" & RampBalls(2, 1) & "type:" & RampType(2) & vbnewline & _
			Typename(RampBalls(3, 0)) & " ID:" & RampBalls(3, 1) & "type:" & RampType(3) & vbnewline & _
			Typename(RampBalls(4, 0)) & " ID:" & RampBalls(4, 1) & "type:" & RampType(4) & vbnewline & _
			Typename(RampBalls(5, 0)) & " ID:" & RampBalls(5, 1) & "type:" & RampType(5) & vbnewline & _
			" "
		End If
	next
End Sub

' WRemoveBall (BallId)
'    Description: This subroutine is called from the RampRollUpdate subroutine 
'                 and is used to remove and stop the ball rolling sounds
Sub WRemoveBall(ID)		'Remove ball
	'Debug.Print "In WRemoveBall() + Remove ball from loop array"
	dim ballcount : ballcount = 0
	dim x : for x = 1 to Ubound(RampBalls)
		if ID = RampBalls(x, 1) then 'remove ball
			Set RampBalls(x, 0) = Nothing
			RampBalls(x, 1) = Empty
			RampType(x) = Empty
			StopSound("RampLoop" & x)
			StopSound("wireloop" & x)
		end If
		'if RampBalls(x,1) = Not IsEmpty(Rampballs(x,1) then ballcount = ballcount + 1
		if not IsEmpty(Rampballs(x,1)) then ballcount = ballcount + 1
	next
	if BallCount = 0 then RampBalls(0,0) = False	'if no balls in queue, disable timer update
End Sub

Sub RampRoll_Timer():RampRollUpdate:End Sub

Sub RampRollUpdate()		'Timer update
	dim x : for x = 1 to uBound(RampBalls)
		if Not IsEmpty(RampBalls(x,1) ) then 
			if BallVel(RampBalls(x,0) ) > 1 then ' if ball is moving, play rolling sound
				If RampType(x) then 
					PlaySound("RampLoop" & x), -1, VolPlayfieldRoll(RampBalls(x,0)) * RampRollVolume * VolumeDial, AudioPan(RampBalls(x,0)), 0, BallPitchV(RampBalls(x,0)), 1, 0, AudioFade(RampBalls(x,0))				
					StopSound("wireloop" & x)
				Else
					StopSound("RampLoop" & x)
					PlaySound("wireloop" & x), -1, VolPlayfieldRoll(RampBalls(x,0)) * RampRollVolume * VolumeDial, AudioPan(RampBalls(x,0)), 0, BallPitch(RampBalls(x,0)), 1, 0, AudioFade(RampBalls(x,0))
				End If
				RampBalls(x, 2)	= RampBalls(x, 2) + 1
			Else
				StopSound("RampLoop" & x)
				StopSound("wireloop" & x)
			end if
			if RampBalls(x,0).Z < 30 and RampBalls(x, 2) > RampMinLoops then	'if ball is on the PF, remove  it
				StopSound("RampLoop" & x)
				StopSound("wireloop" & x)
				Wremoveball RampBalls(x,1)
			End If
		Else
			StopSound("RampLoop" & x)
			StopSound("wireloop" & x)
		end if
	next
	if not RampBalls(0,0) then RampRoll.enabled = 0

End Sub

' This can be used to debug the Ramp Roll time.  You need to enable the tbWR timer on the TextBox
Sub tbWR_Timer()	'debug textbox
	me.text =	"on? " & RampBalls(0, 0) & " timer: " & RampRoll.Enabled & vbnewline & _
	"1 " & Typename(RampBalls(1, 0)) & " ID:" & RampBalls(1, 1) & " type:" & RampType(1) & " Loops:" & RampBalls(1, 2) & vbnewline & _
	"2 " & Typename(RampBalls(2, 0)) & " ID:" & RampBalls(2, 1) & " type:" & RampType(2) & " Loops:" & RampBalls(2, 2) & vbnewline & _
	"3 " & Typename(RampBalls(3, 0)) & " ID:" & RampBalls(3, 1) & " type:" & RampType(3) & " Loops:" & RampBalls(3, 2) & vbnewline & _
	"4 " & Typename(RampBalls(4, 0)) & " ID:" & RampBalls(4, 1) & " type:" & RampType(4) & " Loops:" & RampBalls(4, 2) & vbnewline & _
	"5 " & Typename(RampBalls(5, 0)) & " ID:" & RampBalls(5, 1) & " type:" & RampType(5) & " Loops:" & RampBalls(5, 2) & vbnewline & _
	"6 " & Typename(RampBalls(6, 0)) & " ID:" & RampBalls(6, 1) & " type:" & RampType(6) & " Loops:" & RampBalls(6, 2) & vbnewline & _
	" "
End Sub


Function BallPitch(ball) ' Calculates the pitch of the sound based on the ball speed
    BallPitch = pSlope(BallVel(ball), 1, -1000, 60, 10000)
End Function

Function BallPitchV(ball) ' Calculates the pitch of the sound based on the ball speed Variation
	BallPitchV = pSlope(BallVel(ball), 1, -4000, 60, 7000)
End Function



'******************************************************
'**** END RAMP ROLLING SFX
'******************************************************


' *********************************************************************
'                     Fleep  Supporting Ball & Sound Functions
' *********************************************************************

Function AudioFade(tableobj) ' Fades between front and back of the table (for surround systems or 2x2 speakers, etc), depending on the Y position on the table. "table1" is the name of the table
  Dim tmp
    tmp = tableobj.y * 2 / tableheight-1

	if tmp > 7000 Then
		tmp = 7000
	elseif tmp < -7000 Then
		tmp = -7000
	end if

    If tmp > 0 Then
		AudioFade = Csng(tmp ^10)
    Else
        AudioFade = Csng(-((- tmp) ^10) )
    End If
End Function

Function AudioPan(tableobj) ' Calculates the pan for a tableobj based on the X position on the table. "table1" is the name of the table
    Dim tmp
    tmp = tableobj.x * 2 / tablewidth-1

	if tmp > 7000 Then
		tmp = 7000
	elseif tmp < -7000 Then
		tmp = -7000
	end if

    If tmp > 0 Then
        AudioPan = Csng(tmp ^10)
    Else
        AudioPan = Csng(-((- tmp) ^10) )
    End If
End Function

Function Vol(ball) ' Calculates the volume of the sound based on the ball speed
        Vol = Csng(BallVel(ball) ^2)
End Function


Function Volz(ball) ' Calculates the volume of the sound based on the ball speed
        Volz = Csng((ball.velz) ^2)
End Function


Function Pitch(ball) ' Calculates the pitch of the sound based on the ball speed
    Pitch = BallVel(ball) * 20
End Function


Function BallVel(ball) 'Calculates the ball speed
    BallVel = INT(SQR((ball.VelX ^2) + (ball.VelY ^2) ) )
End Function


Function VolPlayfieldRoll(ball) ' Calculates the roll volume of the sound based on the ball speed
        VolPlayfieldRoll = RollingSoundFactor * 0.0005 * Csng(BallVel(ball) ^3)
End Function


Function PitchPlayfieldRoll(ball) ' Calculates the roll pitch of the sound based on the ball speed
    PitchPlayfieldRoll = BallVel(ball) ^2 * 15
End Function


Function RndInt(min, max)
    RndInt = Int(Rnd() * (max-min + 1) + min)' Sets a random number integer between min and max
End Function


Function RndNum(min, max)
    RndNum = Rnd() * (max-min) + min' Sets a random number between min and max
End Function


'/////////////////////////////  GENERAL SOUND SUBROUTINES  ////////////////////////////
Sub SoundStartButton()
        PlaySound ("Start_Button"), 0, StartButtonSoundLevel, 0, 0.25
End Sub


Sub SoundNudgeLeft()
        PlaySound ("Nudge_" & Int(Rnd*2)+1), 0, NudgeLeftSoundLevel * VolumeDial, -0.1, 0.25
End Sub


Sub SoundNudgeRight()
        PlaySound ("Nudge_" & Int(Rnd*2)+1), 0, NudgeRightSoundLevel * VolumeDial, 0.1, 0.25
End Sub


Sub SoundNudgeCenter()
        PlaySound ("Nudge_" & Int(Rnd*2)+1), 0, NudgeCenterSoundLevel * VolumeDial, 0, 0.25
End Sub




Sub SoundPlungerPull()
        PlaySoundAtLevelStatic ("Plunger_Pull_1"), PlungerPullSoundLevel, Plunger
End Sub


Sub SoundPlungerReleaseBall()
        PlaySoundAtLevelStatic ("Plunger_Release_Ball"), PlungerReleaseSoundLevel, Plunger        
End Sub


Sub SoundPlungerReleaseNoBall()
        PlaySoundAtLevelStatic ("Plunger_Release_No_Ball"), PlungerReleaseSoundLevel, Plunger
End Sub




'/////////////////////////////  KNOCKER SOLENOID  ////////////////////////////
Sub KnockerSolenoid()
        PlaySoundAtLevelStatic SoundFX("Knocker_1",DOFKnocker), KnockerSoundLevel, KnockerPosition
End Sub


'/////////////////////////////  DRAIN SOUNDS  ////////////////////////////
Sub RandomSoundDrain(drainswitch)
        PlaySoundAtLevelStatic ("Drain_" & Int(Rnd*11)+1), DrainSoundLevel, drainswitch
End Sub


'/////////////////////////////  TROUGH BALL RELEASE SOLENOID SOUNDS  ////////////////////////////


Sub RandomSoundBallRelease(drainswitch)
        PlaySoundAtLevelStatic SoundFX("BallRelease" & Int(Rnd*7)+1,DOFContactors), BallReleaseSoundLevel, drainswitch
End Sub


'/////////////////////////////  SLINGSHOT SOLENOID SOUNDS  ////////////////////////////
Sub RandomSoundSlingshotLeft(sling)
        PlaySoundAtLevelStatic SoundFX("Sling_L" & Int(Rnd*10)+1,DOFContactors), SlingshotSoundLevel, Sling
End Sub


Sub RandomSoundSlingshotRight(sling)
        PlaySoundAtLevelStatic SoundFX("Sling_R" & Int(Rnd*8)+1,DOFContactors), SlingshotSoundLevel, Sling
End Sub


'/////////////////////////////  BUMPER SOLENOID SOUNDS  ////////////////////////////
Sub RandomSoundBumperTop(Bump)
        PlaySoundAtLevelStatic SoundFX("Bumpers_Top_" & Int(Rnd*5)+1,DOFContactors), Vol(ActiveBall) * BumperSoundFactor, Bump
End Sub


Sub RandomSoundBumperMiddle(Bump)
        PlaySoundAtLevelStatic SoundFX("Bumpers_Middle_" & Int(Rnd*5)+1,DOFContactors), Vol(ActiveBall) * BumperSoundFactor, Bump
End Sub


Sub RandomSoundBumperBottom(Bump)
        PlaySoundAtLevelStatic SoundFX("Bumpers_Bottom_" & Int(Rnd*5)+1,DOFContactors), Vol(ActiveBall) * BumperSoundFactor, Bump
End Sub


'/////////////////////////////  FLIPPER BATS SOUND SUBROUTINES  ////////////////////////////
'/////////////////////////////  FLIPPER BATS SOLENOID ATTACK SOUND  ////////////////////////////
Sub SoundFlipperUpAttackLeft(flipper)
        FlipperUpAttackLeftSoundLevel = RndNum(FlipperUpAttackMinimumSoundLevel, FlipperUpAttackMaximumSoundLevel)
        PlaySoundAtLevelStatic ("Flipper_Attack-L01"), FlipperUpAttackLeftSoundLevel, flipper
End Sub


Sub SoundFlipperUpAttackRight(flipper)
        FlipperUpAttackRightSoundLevel = RndNum(FlipperUpAttackMinimumSoundLevel, FlipperUpAttackMaximumSoundLevel)
                PlaySoundAtLevelStatic ("Flipper_Attack-R01"), FlipperUpAttackLeftSoundLevel, flipper
End Sub


'/////////////////////////////  FLIPPER BATS SOLENOID CORE SOUND  ////////////////////////////
Sub RandomSoundFlipperUpLeft(flipper)
        PlaySoundAtLevelStatic SoundFX("Flipper_L0" & Int(Rnd*9)+1,DOFFlippers), FlipperLeftHitParm, Flipper
End Sub


Sub RandomSoundFlipperUpRight(flipper)
        PlaySoundAtLevelStatic SoundFX("Flipper_R0" & Int(Rnd*9)+1,DOFFlippers), FlipperRightHitParm, Flipper
End Sub


Sub RandomSoundReflipUpLeft(flipper)
        PlaySoundAtLevelStatic SoundFX("Flipper_ReFlip_L0" & Int(Rnd*3)+1,DOFFlippers), (RndNum(0.8, 1))*FlipperUpSoundLevel, Flipper
End Sub


Sub RandomSoundReflipUpRight(flipper)
        PlaySoundAtLevelStatic SoundFX("Flipper_ReFlip_R0" & Int(Rnd*3)+1,DOFFlippers), (RndNum(0.8, 1))*FlipperUpSoundLevel, Flipper
End Sub


Sub RandomSoundFlipperDownLeft(flipper)
        PlaySoundAtLevelStatic SoundFX("Flipper_Left_Down_" & Int(Rnd*7)+1,DOFFlippers), FlipperDownSoundLevel, Flipper
End Sub


Sub RandomSoundFlipperDownRight(flipper)
        PlaySoundAtLevelStatic SoundFX("Flipper_Right_Down_" & Int(Rnd*8)+1,DOFFlippers), FlipperDownSoundLevel, Flipper
End Sub


'/////////////////////////////  FLIPPER BATS BALL COLLIDE SOUND  ////////////////////////////


Sub LeftFlipperCollide(parm)
        FlipperLeftHitParm = parm/10
        If FlipperLeftHitParm > 1 Then
                FlipperLeftHitParm = 1
        End If
        FlipperLeftHitParm = FlipperUpSoundLevel * FlipperLeftHitParm
        RandomSoundRubberFlipper(parm)
End Sub


Sub RightFlipperCollide(parm)
        FlipperRightHitParm = parm/10
        If FlipperRightHitParm > 1 Then
                FlipperRightHitParm = 1
        End If
        FlipperRightHitParm = FlipperUpSoundLevel * FlipperRightHitParm
         RandomSoundRubberFlipper(parm)
End Sub


Sub RandomSoundRubberFlipper(parm)
        PlaySoundAtLevelActiveBall ("Flipper_Rubber_" & Int(Rnd*7)+1), parm  * RubberFlipperSoundFactor
End Sub


'/////////////////////////////  ROLLOVER SOUNDS  ////////////////////////////
Sub RandomSoundRollover()
        PlaySoundAtLevelActiveBall ("Rollover_" & Int(Rnd*4)+1), RolloverSoundLevel
End Sub


Sub Rollovers_Hit(idx)
        RandomSoundRollover
End Sub


'/////////////////////////////  VARIOUS PLAYFIELD SOUND SUBROUTINES  ////////////////////////////
'/////////////////////////////  RUBBERS AND POSTS  ////////////////////////////
'/////////////////////////////  RUBBERS - EVENTS  ////////////////////////////
Sub Rubbers_Hit(idx)
         dim finalspeed
          finalspeed=SQR(activeball.velx * activeball.velx + activeball.vely * activeball.vely)
         If finalspeed > 5 then                
                 RandomSoundRubberStrong 1
        End if
        If finalspeed <= 5 then
                 RandomSoundRubberWeak()
         End If        
End Sub


'/////////////////////////////  RUBBERS AND POSTS - STRONG IMPACTS  ////////////////////////////
Sub RandomSoundRubberStrong(voladj)
        Select Case Int(Rnd*10)+1
                Case 1 : PlaySoundAtLevelActiveBall ("Rubber_Strong_1"), Vol(ActiveBall) * RubberStrongSoundFactor*voladj
                Case 2 : PlaySoundAtLevelActiveBall ("Rubber_Strong_2"), Vol(ActiveBall) * RubberStrongSoundFactor*voladj
                Case 3 : PlaySoundAtLevelActiveBall ("Rubber_Strong_3"), Vol(ActiveBall) * RubberStrongSoundFactor*voladj
                Case 4 : PlaySoundAtLevelActiveBall ("Rubber_Strong_4"), Vol(ActiveBall) * RubberStrongSoundFactor*voladj
                Case 5 : PlaySoundAtLevelActiveBall ("Rubber_Strong_5"), Vol(ActiveBall) * RubberStrongSoundFactor*voladj
                Case 6 : PlaySoundAtLevelActiveBall ("Rubber_Strong_6"), Vol(ActiveBall) * RubberStrongSoundFactor*voladj
                Case 7 : PlaySoundAtLevelActiveBall ("Rubber_Strong_7"), Vol(ActiveBall) * RubberStrongSoundFactor*voladj
                Case 8 : PlaySoundAtLevelActiveBall ("Rubber_Strong_8"), Vol(ActiveBall) * RubberStrongSoundFactor*voladj
                Case 9 : PlaySoundAtLevelActiveBall ("Rubber_Strong_9"), Vol(ActiveBall) * RubberStrongSoundFactor*voladj
                Case 10 : PlaySoundAtLevelActiveBall ("Rubber_1_Hard"), Vol(ActiveBall) * RubberStrongSoundFactor * 0.6*voladj
        End Select
End Sub


'/////////////////////////////  RUBBERS AND POSTS - WEAK IMPACTS  ////////////////////////////
Sub RandomSoundRubberWeak()
        PlaySoundAtLevelActiveBall ("Rubber_" & Int(Rnd*9)+1), Vol(ActiveBall) * RubberWeakSoundFactor
End Sub


'/////////////////////////////  WALL IMPACTS  ////////////////////////////
Sub Walls_Hit(idx)
	RandomSoundWall()      
End Sub


Sub RandomSoundWall()
         dim finalspeed
          finalspeed=SQR(activeball.velx * activeball.velx + activeball.vely * activeball.vely)
         If finalspeed > 16 then 
                Select Case Int(Rnd*5)+1
                        Case 1 : PlaySoundAtLevelExistingActiveBall ("Wall_Hit_1"), Vol(ActiveBall) * WallImpactSoundFactor
                        Case 2 : PlaySoundAtLevelExistingActiveBall ("Wall_Hit_2"), Vol(ActiveBall) * WallImpactSoundFactor
                        Case 3 : PlaySoundAtLevelExistingActiveBall ("Wall_Hit_5"), Vol(ActiveBall) * WallImpactSoundFactor
                        Case 4 : PlaySoundAtLevelExistingActiveBall ("Wall_Hit_7"), Vol(ActiveBall) * WallImpactSoundFactor
                        Case 5 : PlaySoundAtLevelExistingActiveBall ("Wall_Hit_9"), Vol(ActiveBall) * WallImpactSoundFactor
                End Select
        End if
        If finalspeed >= 6 AND finalspeed <= 16 then
                Select Case Int(Rnd*4)+1
                        Case 1 : PlaySoundAtLevelExistingActiveBall ("Wall_Hit_3"), Vol(ActiveBall) * WallImpactSoundFactor
                        Case 2 : PlaySoundAtLevelExistingActiveBall ("Wall_Hit_4"), Vol(ActiveBall) * WallImpactSoundFactor
                        Case 3 : PlaySoundAtLevelExistingActiveBall ("Wall_Hit_6"), Vol(ActiveBall) * WallImpactSoundFactor
                        Case 4 : PlaySoundAtLevelExistingActiveBall ("Wall_Hit_8"), Vol(ActiveBall) * WallImpactSoundFactor
                End Select
         End If
        If finalspeed < 6 Then
                Select Case Int(Rnd*3)+1
                        Case 1 : PlaySoundAtLevelExistingActiveBall ("Wall_Hit_4"), Vol(ActiveBall) * WallImpactSoundFactor
                        Case 2 : PlaySoundAtLevelExistingActiveBall ("Wall_Hit_6"), Vol(ActiveBall) * WallImpactSoundFactor
                        Case 3 : PlaySoundAtLevelExistingActiveBall ("Wall_Hit_8"), Vol(ActiveBall) * WallImpactSoundFactor
                End Select
        End if
End Sub


'/////////////////////////////  METAL TOUCH SOUNDS  ////////////////////////////
Sub RandomSoundMetal()
        PlaySoundAtLevelActiveBall ("Metal_Touch_" & Int(Rnd*13)+1), Vol(ActiveBall) * MetalImpactSoundFactor
End Sub


'/////////////////////////////  METAL - EVENTS  ////////////////////////////


Sub Metals_Hit (idx)
        RandomSoundMetal
End Sub


Sub ShooterDiverter_collide(idx)
        RandomSoundMetal
End Sub


'/////////////////////////////  BOTTOM ARCH BALL GUIDE  ////////////////////////////
'/////////////////////////////  BOTTOM ARCH BALL GUIDE - SOFT BOUNCES  ////////////////////////////
Sub RandomSoundBottomArchBallGuide()
         dim finalspeed
          finalspeed=SQR(activeball.velx * activeball.velx + activeball.vely * activeball.vely)
         If finalspeed > 16 then 
                PlaySoundAtLevelActiveBall ("Apron_Bounce_"& Int(Rnd*2)+1), Vol(ActiveBall) * BottomArchBallGuideSoundFactor
        End if
        If finalspeed >= 6 AND finalspeed <= 16 then
                 Select Case Int(Rnd*2)+1
                        Case 1 : PlaySoundAtLevelActiveBall ("Apron_Bounce_1"), Vol(ActiveBall) * BottomArchBallGuideSoundFactor
                        Case 2 : PlaySoundAtLevelActiveBall ("Apron_Bounce_Soft_1"), Vol(ActiveBall) * BottomArchBallGuideSoundFactor
                End Select
         End If
        If finalspeed < 6 Then
                 Select Case Int(Rnd*2)+1
                        Case 1 : PlaySoundAtLevelActiveBall ("Apron_Bounce_Soft_1"), Vol(ActiveBall) * BottomArchBallGuideSoundFactor
                        Case 2 : PlaySoundAtLevelActiveBall ("Apron_Medium_3"), Vol(ActiveBall) * BottomArchBallGuideSoundFactor
                End Select
        End if
End Sub


'/////////////////////////////  BOTTOM ARCH BALL GUIDE - HARD HITS  ////////////////////////////
Sub RandomSoundBottomArchBallGuideHardHit()
        PlaySoundAtLevelActiveBall ("Apron_Hard_Hit_" & Int(Rnd*3)+1), BottomArchBallGuideSoundFactor * 0.25
End Sub


Sub Apron_Hit (idx)
        If Abs(cor.ballvelx(activeball.id) < 4) and cor.ballvely(activeball.id) > 7 then
                RandomSoundBottomArchBallGuideHardHit()
        Else
                RandomSoundBottomArchBallGuide
        End If
End Sub


'/////////////////////////////  FLIPPER BALL GUIDE  ////////////////////////////
Sub RandomSoundFlipperBallGuide()
         dim finalspeed
          finalspeed=SQR(activeball.velx * activeball.velx + activeball.vely * activeball.vely)
         If finalspeed > 16 then 
                 Select Case Int(Rnd*2)+1
                        Case 1 : PlaySoundAtLevelActiveBall ("Apron_Hard_1"),  Vol(ActiveBall) * FlipperBallGuideSoundFactor
                        Case 2 : PlaySoundAtLevelActiveBall ("Apron_Hard_2"),  Vol(ActiveBall) * 0.8 * FlipperBallGuideSoundFactor
                End Select
        End if
        If finalspeed >= 6 AND finalspeed <= 16 then
                PlaySoundAtLevelActiveBall ("Apron_Medium_" & Int(Rnd*3)+1),  Vol(ActiveBall) * FlipperBallGuideSoundFactor
         End If
        If finalspeed < 6 Then
                PlaySoundAtLevelActiveBall ("Apron_Soft_" & Int(Rnd*7)+1),  Vol(ActiveBall) * FlipperBallGuideSoundFactor
        End If
End Sub


'/////////////////////////////  TARGET HIT SOUNDS  ////////////////////////////
Sub RandomSoundTargetHitStrong()
        PlaySoundAtLevelActiveBall SoundFX("Target_Hit_" & Int(Rnd*4)+5,DOFTargets), Vol(ActiveBall) * 0.45 * TargetSoundFactor
End Sub


Sub RandomSoundTargetHitWeak()                
        PlaySoundAtLevelActiveBall SoundFX("Target_Hit_" & Int(Rnd*4)+1,DOFTargets), Vol(ActiveBall) * TargetSoundFactor
End Sub


Sub PlayTargetSound()
         dim finalspeed
          finalspeed=SQR(activeball.velx * activeball.velx + activeball.vely * activeball.vely)
         If finalspeed > 10 then
                 RandomSoundTargetHitStrong()
                RandomSoundBallBouncePlayfieldSoft Activeball
        Else 
                 RandomSoundTargetHitWeak()
         End If        
End Sub


Sub Targets_Hit (idx)
        PlayTargetSound        
End Sub


'/////////////////////////////  BALL BOUNCE SOUNDS  ////////////////////////////
Sub RandomSoundBallBouncePlayfieldSoft(aBall)
        Select Case Int(Rnd*9)+1
                Case 1 : PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Soft_1"), volz(aBall) * BallBouncePlayfieldSoftFactor, aBall
                Case 2 : PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Soft_2"), volz(aBall) * BallBouncePlayfieldSoftFactor * 0.5, aBall
                Case 3 : PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Soft_3"), volz(aBall) * BallBouncePlayfieldSoftFactor * 0.8, aBall
                Case 4 : PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Soft_4"), volz(aBall) * BallBouncePlayfieldSoftFactor * 0.5, aBall
                Case 5 : PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Soft_5"), volz(aBall) * BallBouncePlayfieldSoftFactor, aBall
                Case 6 : PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Hard_1"), volz(aBall) * BallBouncePlayfieldSoftFactor * 0.2, aBall
                Case 7 : PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Hard_2"), volz(aBall) * BallBouncePlayfieldSoftFactor * 0.2, aBall
                Case 8 : PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Hard_5"), volz(aBall) * BallBouncePlayfieldSoftFactor * 0.2, aBall
                Case 9 : PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Hard_7"), volz(aBall) * BallBouncePlayfieldSoftFactor * 0.3, aBall
        End Select
End Sub


Sub RandomSoundBallBouncePlayfieldHard(aBall)
        PlaySoundAtLevelStatic ("Ball_Bounce_Playfield_Hard_" & Int(Rnd*7)+1), volz(aBall) * BallBouncePlayfieldHardFactor, aBall
End Sub


'/////////////////////////////  DELAYED DROP - TO PLAYFIELD - SOUND  ////////////////////////////
Sub RandomSoundDelayedBallDropOnPlayfield(aBall)
        Select Case Int(Rnd*5)+1
                Case 1 : PlaySoundAtLevelStatic ("Ball_Drop_Playfield_1_Delayed"), DelayedBallDropOnPlayfieldSoundLevel, aBall
                Case 2 : PlaySoundAtLevelStatic ("Ball_Drop_Playfield_2_Delayed"), DelayedBallDropOnPlayfieldSoundLevel, aBall
                Case 3 : PlaySoundAtLevelStatic ("Ball_Drop_Playfield_3_Delayed"), DelayedBallDropOnPlayfieldSoundLevel, aBall
                Case 4 : PlaySoundAtLevelStatic ("Ball_Drop_Playfield_4_Delayed"), DelayedBallDropOnPlayfieldSoundLevel, aBall
                Case 5 : PlaySoundAtLevelStatic ("Ball_Drop_Playfield_5_Delayed"), DelayedBallDropOnPlayfieldSoundLevel, aBall
        End Select
End Sub


'/////////////////////////////  BALL GATES AND BRACKET GATES SOUNDS  ////////////////////////////


Sub SoundPlayfieldGate()                        
        PlaySoundAtLevelStatic ("Gate_FastTrigger_" & Int(Rnd*2)+1), GateSoundLevel, Activeball
End Sub


Sub SoundHeavyGate()
        PlaySoundAtLevelStatic ("Gate_2"), GateSoundLevel, Activeball
End Sub


Sub Gates_hit(idx)
        SoundHeavyGate
End Sub


Sub GatesWire_hit(idx)        
        SoundPlayfieldGate        
End Sub        


'/////////////////////////////  LEFT LANE ENTRANCE - SOUNDS  ////////////////////////////


Sub RandomSoundLeftArch()
        PlaySoundAtLevelActiveBall ("Arch_L" & Int(Rnd*4)+1), Vol(ActiveBall) * ArchSoundFactor
End Sub


Sub RandomSoundRightArch()
        PlaySoundAtLevelActiveBall ("Arch_R" & Int(Rnd*4)+1), Vol(ActiveBall) * ArchSoundFactor
End Sub




Sub Arch1_hit()
        If Activeball.velx > 1 Then SoundPlayfieldGate
        StopSound "Arch_L1"
        StopSound "Arch_L2"
        StopSound "Arch_L3"
        StopSound "Arch_L4"
End Sub


Sub Arch1_unhit()
        If activeball.velx < -8 Then
                RandomSoundRightArch
        End If
End Sub


Sub Arch2_hit()
        If Activeball.velx < 1 Then SoundPlayfieldGate
        StopSound "Arch_R1"
        StopSound "Arch_R2"
        StopSound "Arch_R3"
        StopSound "Arch_R4"
End Sub


Sub Arch2_unhit()
        If activeball.velx > 10 Then
                RandomSoundLeftArch
        End If
End Sub


'/////////////////////////////  SAUCERS (KICKER HOLES)  ////////////////////////////


Sub SoundSaucerLock()
        PlaySoundAtLevelStatic ("Saucer_Enter_" & Int(Rnd*2)+1), SaucerLockSoundLevel, Activeball
End Sub


Sub SoundSaucerKick(scenario, saucer)
        Select Case scenario
                Case 0: PlaySoundAtLevelStatic SoundFX("Saucer_Empty", DOFContactors), SaucerKickSoundLevel, saucer
                Case 1: PlaySoundAtLevelStatic SoundFX("Saucer_Kick", DOFContactors), SaucerKickSoundLevel, saucer
        End Select
End Sub


'/////////////////////////////  BALL COLLISION SOUND  ////////////////////////////
Sub OnBallBallCollision(ball1, ball2, velocity)
        Dim snd
        Select Case Int(Rnd*7)+1
                Case 1 : snd = "Ball_Collide_1"
                Case 2 : snd = "Ball_Collide_2"
                Case 3 : snd = "Ball_Collide_3"
                Case 4 : snd = "Ball_Collide_4"
                Case 5 : snd = "Ball_Collide_5"
                Case 6 : snd = "Ball_Collide_6"
                Case 7 : snd = "Ball_Collide_7"
        End Select


        PlaySound (snd), 0, Csng(velocity) ^2 / 200 * BallWithBallCollisionSoundFactor * VolumeDial, AudioPan(ball1), 0, Pitch(ball1), 0, 0, AudioFade(ball1)
End Sub



'///////////////////////////  DROP TARGET HIT SOUNDS  ///////////////////////////

Sub RandomSoundDropTargetReset(obj)
	PlaySoundAtLevelStatic SoundFX("Drop_Target_Reset_" & Int(Rnd*6)+1,DOFContactors), 1, obj
End Sub

Sub SoundDropTargetDrop(obj)
	PlaySoundAtLevelStatic ("Drop_Target_Down_" & Int(Rnd*6)+1), 200, obj
End Sub

'/////////////////////////////  GI AND FLASHER RELAYS  ////////////////////////////

Const RelayFlashSoundLevel = 0.315									'volume level; range [0, 1];
Const RelayGISoundLevel = 1.05									'volume level; range [0, 1];

Sub Sound_GI_Relay(toggle, obj)
	Select Case toggle
		Case 1
			PlaySoundAtLevelStatic ("Relay_GI_On"), 0.025*RelayGISoundLevel, obj
		Case 0
			PlaySoundAtLevelStatic ("Relay_GI_Off"), 0.025*RelayGISoundLevel, obj
	End Select
End Sub

Sub Sound_Flash_Relay(toggle, obj)
	Select Case toggle
		Case 1
			PlaySoundAtLevelStatic ("Relay_Flash_On"), 0.025*RelayFlashSoundLevel, obj			
		Case 0
			PlaySoundAtLevelStatic ("Relay_Flash_Off"), 0.025*RelayFlashSoundLevel, obj		
	End Select
End Sub



'/////////////////////////////////////////////////////////////////
'                                        End Mechanical Sounds
'/////////////////////////////////////////////////////////////////


'******************************************************
'****  BALL ROLLING AND DROP SOUNDS
'******************************************************

ReDim rolling(tnob)
InitRolling

Dim DropCount
ReDim DropCount(tnob)

Sub InitRolling
	Dim i
	For i = 0 to tnob
		rolling(i) = False
	Next
End Sub

Sub RollingUpdate()
	Dim BOT, b
	BOT = GetBalls

	' stop the sound of deleted balls
	For b = UBound(BOT) + 1 to tnob
		'If AmbientBallShadowOn = 0 Then BallShadowA(b).visible = 0
		rolling(b) = False
		StopSound("BallRoll_" & b)
	Next

	' exit the sub if no balls on the table
	If UBound(BOT) = -1 Then Exit Sub

	' play the rolling sound for each ball

	For b = 0 to UBound(BOT)
		If BallVel(BOT(b)) > 1 AND BOT(b).z < 30 Then
			rolling(b) = True
			PlaySound ("BallRoll_" & b), -1, VolPlayfieldRoll(BOT(b)) * BallRollVolume * VolumeDial, AudioPan(BOT(b)), 0, PitchPlayfieldRoll(BOT(b)), 1, 0, AudioFade(BOT(b))

		Else
			If rolling(b) = True Then
				StopSound("BallRoll_" & b)
				rolling(b) = False
			End If
		End If

		' Ball Drop Sounds
		If BOT(b).VelZ < -1 and BOT(b).z < 55 and BOT(b).z > 27 Then 'height adjust for ball drop sounds
			If DropCount(b) >= 5 Then
				DropCount(b) = 0
				If BOT(b).velz > -7 Then
					RandomSoundBallBouncePlayfieldSoft BOT(b)
				Else
					RandomSoundBallBouncePlayfieldHard BOT(b)
				End If				
			End If
		End If
		If DropCount(b) < 5 Then
			DropCount(b) = DropCount(b) + 1
		End If

		' "Static" Ball Shadows
'		If AmbientBallShadowOn = 0 Then
'			If BOT(b).Z > 30 Then
'				BallShadowA(b).height=BOT(b).z - BallSize/4		'This is technically 1/4 of the ball "above" the ramp, but it keeps it from clipping
'			Else
'				BallShadowA(b).height=BOT(b).z - BallSize/2 + 5
'			End If
'			BallShadowA(b).Y = BOT(b).Y + Ballsize/5 + fovY
'			BallShadowA(b).X = BOT(b).X
'			BallShadowA(b).visible = 1
'		End If
	Next
End Sub
Sub table1_Exit():Controller.Games(cGameName).Settings.Value("sound") = 1:Controller.Stop : End Sub


'******************************************************
'****  END BALL ROLLING AND DROP SOUNDS
'******************************************************


' *********************************************************************
'                  END Fleep  Supporting Ball & Sound Functions
' *********************************************************************


' *********************************************************************
'                  Swap Plastics and Flippers Functions
' *********************************************************************
Dim object

Sub SwapPlastics()
	if (PG_Plastics = 1) then
		for each Object in PlasticsCol : object.image = "Plastics1B" : next	
	end if
End Sub

Sub SwapFlippers()
	if (BarbWire_Flippers = 0) then
		for each Object in FlipperCol : object.image = "gottlieb_flipper_red": next
	end if
End Sub
' *********************************************************************
'                 End Swap Plastics and Flippers Functions
' *********************************************************************
