#NoEnv  
#Warn  
SendMode Input
#SingleInstance Force  
SetWorkingDir %A_ScriptDir%  
#Include %A_ScriptDir%\lib\CameraControl_lib.ahk

currentAction := "idle"
workerActive := "No"
delay := 0
currentCycle := 1
blocksMined := 0
global delay, delays, currentAction, workerActive, pos, layerColours, activeLayer, activated, currentCycle, blocksMined

; colour list
layerColours := [0x14175C, 0xBF6792, 0x7C3E5A, 0x7D2A38, 0x060633, 0x110E0B]
colours := [0x7D2A38, 0x060633, 0x110E0B]
activeLayer := 1

; delays
delays := [200, 200, 200, 650, 4000]
; coordinates to click on
center := [966, 620]
topLeft := [661, 259]
topRight := [1309, 237]
bottomLeft := [633, 821]
bottomRight := [1289, 805]
pos := [703, 565]
chestPos := [779, 621]
; house icon cords
houseCords := [967, 931]

Gui, +AlwaysOnTop
Gui, Color, FFFFFF 
Gui, Font, s14
Gui, Add, Text, x10 y10, Script Enabled:
Gui, Add, Text, x140 y10 w100 h30 Left vWorkerText, % workerActive
Gui, Add, Text, x10 y40, Current Action: 
Gui, Add, Text, x140 y40 w250 h60 Left vActionText, % currentAction 

; info
Gui, Add, Text, x10 y70, Delay:
Gui, Add, Text, x140 y70 w100 h30 Left vDelayText, % delay 
Gui, Show, x10 y10 w350 h170, Collector's PS99 Mining Macro

F1::
    activated := true
    GuiControl,, WorkerText, Yes
    GuiControl,, ActionText, Initialising

    WinActivate, Roblox
    Sleep, 100

    Loop, 10
    {
        Click, WheelUp
        Sleep, 100
    }

    Loop, 6
    {
        Click, WheelDown
        Sleep, 100
    }

    Initialise(houseCords)

    while (activated = true) 
    {   
        if (activeLayer = 3)
        {
            Click, up
            Initialise(houseCords)
        }
        else
        {
            CheckColour()
            Sleep, 100
            AutoMine(center, topLeft, topRight, bottomLeft, bottomRight, pos, chestPos)
        }
    }

    return

F2::
    Click, up
    Reload
    return

F3::
    WinActivate, Roblox
    Sleep, 100
    TestFunc2(chestPos)
    return

F6:: 
    WinActivate, Roblox
    Sleep, 50
    MouseGetPos, MouseX, MouseY
    SplashImage, , m2 fm20, ,%MouseX% %MouseY%, Tip Card
    return

AutoMine(center, topLeft, topRight, bottomLeft, bottomRight, pos, chestPos)
{
    GuiControl,, ActionText, Mining
    Click, down

    if (activeLayer > 6)
    {
        ; top left
        MouseMove % topLeft[1], topLeft[2] 
        Sleep, 50
        MouseMove % topLeft[1] + 3, topLeft[2]
        Sleep, 150

        ; top right
        MouseMove % topRight[1], topRight[2] 
        Sleep, 50
        MouseMove % topRight[1] + 3, topRight[2]
        Sleep, 150

        ; bottom left
        MouseMove % bottomLeft[1], bottomLeft[2] 
        Sleep, 50
        MouseMove % bottomLeft[1] + 3, bottomLeft[2]
        Sleep, 150

        ; bottom right
        MouseMove % bottomRight[1], bottomRight[2] 
        Sleep, 50
        MouseMove % bottomRight[1] + 3, bottomRight[2]
        Sleep, 150
    }

    ; check if you landed on top of chest, will cause player to re-center themselves
    posX := chestPos[1]
    posY := chestPos[2]

    colour = layerColours[activeLayer]
    PixelSearch, OutputVarX, OutputVarY, %posX%, %posY%, %posX%, %posY%, %colour%, 7, Fast

    ; mine block below player
    MouseMove % center[1], center[2]
    Sleep, 50
    MouseMove % center[1] + 3, center[2]
    Sleep % delays[activeLayer]
    Click, up
    Sleep, 800
    Click, down

    if (ErrorLevel = 1 && blocksMined > 4)
    {   
        Click, up
        Send, {s down}
        Sleep, 1000
        Send, {s up}
        Sleep, 1000
        Send, {w down}
        Sleep, 280
        Send, {w up}
        Sleep, 800
        Click, down
    }

    blocksMined++
}
    
CheckColour()
{
    GuiControl,, ActionText, Checking colour
    GuiControl, , DelayText, % delay

    posX := pos[1]
    posY := pos[2]
    groundCol := 0x96E4FF

    colour := layerColours[activeLayer + 1]
    PixelSearch, OutputVarX, OutputVarY, %posX%, %posY%, %posX%, %posY%, %colour%, 3, Fast

    if (ErrorLevel = 0)
    {
        activeLayer++

        if (activeLayer = 6 && currentCycle = 1)
        {
            currentCycle = 2
        }
        else if (activeLayer = 6 && currentCycle = 2)
        {
            currentCycle = 1
        }
    }
    if (ErrorLevel = 1)
    {
        PixelSearch, OutputVarX, OutputVarY, A_ScreenWidth / 4, A_ScreenHeight / 2, A_ScreenWidth / 4, A_ScreenHeight / 2, %groundCol%, 7, Fast

        if (ErrorLevel = 0)
        {
            activeLayer := 6
        }
    }

    return
}

FirstCycle()
{
    ; walk to left corner of digsite
    MouseMove, A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight / 2)
    Sleep, 5000
    MouseMove, A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight / 2 + 3)
    Sleep, 50
    MouseMove, A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight / 2)
    sleep, 50
    Send, {w down}{a down}
    Sleep, 2000
    Send, {a up}
    Sleep, 1200
    Send, {w up}{a down}
    Sleep, 1000
    Send, {a up}{s down}
    Sleep, 400
    Send, {s up}{a down}
    Sleep, 400
    Send, {a up}

    ; camera angling
    Sleep, 100
    Click, right down
    Sleep, 50
    MouseMove, A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight / 2 - 50)
    Sleep, 50
    Click, right up
    Sleep, 500
    MouseMove, A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight / 2)
    Sleep, 50
    Click, right down
    Sleep, 50
    MouseMove, A_ScreenWidth - (A_ScreenWidth / 2) + 17, A_ScreenHeight - (A_ScreenHeight / 2)
    Sleep, 50
    Click, right up
    Sleep, 50

    ; walk to tile
    Send, {w down}
    Sleep, 820
    Send, {w up}
    
    return
}

SecondCycle()
{
    ; walk to right corner of digsite
    MouseMove, A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight / 2)
    Sleep, 5000
    MouseMove, A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight / 2 + 3)
    Sleep, 50
    MouseMove, A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight / 2)
    sleep, 50
    Send, {w down}{d down}
    Sleep, 2000
    Send, {d up}
    Sleep, 1200
    Send, {w up}{d down}
    Sleep, 1000
    Send, {d up}{s down}
    Sleep, 200
    Send, {s up}{d down}
    Sleep, 400
    Send, {d up}

    ; camera angling
    Sleep, 100
    Click, right down
    Sleep, 50
    MouseMove, A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight / 2 - 50)
    Sleep, 50
    Click, right up
    Sleep, 500
    MouseMove, A_ScreenWidth - (A_ScreenWidth / 2), A_ScreenHeight - (A_ScreenHeight / 2)
    Sleep, 50
    Click, right down
    Sleep, 50
    MouseMove, A_ScreenWidth - (A_ScreenWidth / 2) - 18, A_ScreenHeight - (A_ScreenHeight / 2)
    Sleep, 50
    Click, right up
    Sleep, 50
    
    ; walk to tile
    Send, {w down}
    Sleep, 820
    Send, {w up}
    
    return
}

ResetCharacterPos(houseCords)
{
    ; tp outside of mini game
    MouseMove % houseCords[1], houseCords[2]
    Sleep, 50
    MouseMove % houseCords[1] + 2, houseCords[2] 
    Sleep, 50
    Click

    ; walk back through portal
    Sleep, 6000
    Send, {s Down}
    Sleep, 1000
    Send, {s Up}

    return
}

Initialise(houseCords)
{
    activeLayer := 0
    blocksMined := 0
    if (currentCycle = 1)
    {
        ResetCharacterPos(houseCords) 
        FirstCycle()
    }
    else if (currentCycle = 2)
    {
        ResetCharacterPos(houseCords) 
        SecondCycle()
    }
}

TestFunc()
{
    col1 := layerColours[activeLayer]

    MouseGetPos, posX, posY
    PixelSearch, OutputVarX, OutputVarY, %posX%, %posY%, %posX%, %posY%, %col1%, 7, Fast

    if (ErrorLevel = 0)
    {
        MsgBox, colour found
    }
    else
    {
        MsgBox, colour not found
    }
}

TestFunc2(chestPos)
{
    posX := chestPos[1]
    posY := chestPos[2]

    MouseMove, posX, posY
    activeLayer := 2
    colour := layerColours[activeLayer]
    PixelSearch, OutputVarX, OutputVarY, %posX%, %posY%, %posX%, %posY%, %colour%, 7, Fast

    if (ErrorLevel = 1)
    {
        MsgBox, kill yourself
    }
}