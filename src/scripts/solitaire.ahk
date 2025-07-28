#Requires AutoHotkey v2.0+

; SPDX-License-Identifier: CC-BY-NC-4.0
; Copyright (c) Leandro Lopes Pereira. Some rights reserved.
; See LICENSE file for full details.

SetToolTip(text, duration := 2000) {
    ToolTip(text)
    SetTimer(() => ToolTip(), -duration)
}

SetToolTip("Hotkeys for SQLite Solitaire is ON")

;Oneline HotStrings
;******************
::nw::insert into moves(action) values('new');select * from game_view;{enter}
::rs::insert into moves(action) values('reset');select * from game_view;{enter}

; Turn stock pile card
::dd::insert into Moves (action) values('deal');select * from game_view;{enter}
; :o:.d::,('deal'){esc}

; Waste -> Foundation 
::wf::insert into moves(action) values('to-foundation');select * from game_view;{enter}

; Move 4 first columns to foundation
::aa::insert into moves(action, source) values('to-foundation',1),('to-foundation',2),('to-foundation',3),('to-foundation',4);select * from game_view;{enter}

; Clear current line
:o:cc::{End}{Backspace 200}

; Current game
::..::select * from game_view;{enter}

; HotStrings using parameters
; ***************************
; 1 parameter (either Source or Target)
; Move Waste -> Tableau        call it using "wt" or "wt1" to "wt7"
; Move Tableau -> Foundation   call it using "tf" or "tf1" to "tf7"

; 2 Parameters (Source and Target)
; Move Foundation -> Tableau   call it using "ft" or "ft" + source + target
; Tableau -> Tableau           call it using "mv" or "tt" plus source and target
;                              e.g. - mv13 moves from column 1 to 3
;                                     tt54 moves from column 5 to 4

sendMovement(cmd, trigger, source_target) {
    
    sendleft :=(source_target = "")
    prefix := "insert into moves"
    
    if (cmd = "wt")
        prefix .= "(target) values("
    else if (cmd = "tf")
        prefix .= "(action, source) values('to-foundation',"
    else if (cmd = "tt" or cmd = "mv" or cmd = "ft")
    {
        prefix .= "(action, source, target) values("
        
        if cmd = "ft"
            prefix .= "'from-foundation',"
        else
            prefix .= "'move',"

        if source_target != ""{        
            source_target := SubStr(source_target,1,1) . "," . SubStr(source_target,2,1)
            sendleft := (StrLen(source_target) = 2)
        }
    }

    SendText(prefix . (source_target = "" ? "" : source_target) . ");select * from game_view;")

    if (sendleft)
        Send("{Left 26}")
    else
        Send("{Enter}")
}

; Crates hotstrings dynamicaly
commands := ["wt", "ft", "tf", "tt", "mv"]
numbers  := [1, 2, 3, 4, 5, 6, 7]
for cmd in commands {
    ; Without Parameter
    defineHotstring(cmd, "")

    for _, t in numbers {
        ; Either source or target (like wt1, ft7)
        defineHotstring(cmd, t)

        ; Both source or target (like tt15 mv45)
        if (cmd = "tt" or cmd = "mv" or cmd = "ft") {
            for _, s in numbers {
                if (s != t or cmd = "ft") 
                    defineHotstring(cmd, s . t)
            }
        }
    }
}

defineHotstring(cmd, params) {
    Hotstring(":o:" . cmd . params, (trigger) => sendMovement(cmd, trigger, params))
}

Esc::{
    SetToolTip("Bye!")
    ExitApp
}