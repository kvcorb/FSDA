; Script generated by the Inno Setup Script Wizard.
; SEE THE DOCUMENTATION FOR DETAILS ON CREATING INNO SETUP SCRIPT FILES!

[Setup]
; NOTE: The value of AppId uniquely identifies this application.
; Do not use the same AppId value in installers for other applications.
; (To generate a new GUID, click Tools | Generate GUID inside the IDE.)
AppId=FSDA
AppName=FSDA toolbox for MATLAB
AppVerName=FSDA toolbox Release 2017b (03-jun-16) for MATLAB >R2009b
AppPublisher=University of Parma and European Union
AppPublisherURL=http://www.riani.it/MATLAB.htm
AppSupportURL=http://www.riani.it/MATLAB.htm
AppUpdatesURL=http://www.riani.it/MATLAB.htm
DefaultDirName={pf}
AppendDefaultDirName=no
DefaultGroupName=FSDA toolbox for MATLAB
LicenseFile=licence.txt
InfoBeforeFile=before inst.txt
InfoAfterFile=after inst.txt
OutputDir=.\
OutputBaseFilename=FSDAtoolbox_for_MATLAB-setup
SetupIconFile=logo.ico
Compression=lzma
SolidCompression=yes
VersionInfoProductTextVersion=2.1.0.0
VersionInfoProductVersion=2.1.0.0
VersionInfoTextVersion=2.1.0.0
VersionInfoVersion=2.1.0.0
WizardSmallImageFile=FSDA_logo_trasp_58.bmp
WizardImageFile=fsda_black_trasp_300dpi_recol.bmp

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[CustomMessages]
OpenProgram=Open %1

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
; Source: "FSDA\examples\examples_regression.m"; DestDir: "{app}\FSDA"; Flags: ignoreversion
Source: "FSDA\*"; DestDir: "{app}\FSDA"; Flags: ignoreversion recursesubdirs createallsubdirs
; NOTE: Don't use "Flags: ignoreversion" on any shared system files

[Icons]
Name: "{group}\FSDA toolbox for MATLAB"; Filename: "{code:MyMatlabVersion}"; Parameters: " -r "" open '{app}\FSDA\examples\examples_regression.m' ; open '{app}\FSDA\examples\examples_multivariate.m' ; open '{app}\FSDA\examples\examples_categorical.m' ; {code:doc_func} "" "
Name: "{group}\{cm:UninstallProgram,FSDA toolbox for MATLAB}"; Filename: "{uninstallexe}" ; IconFilename: "{app}\FSDA\logo.ico"
Name: "{commondesktop}\FSDA toolbox for MATLAB"; Filename: "{code:MyMatlabVersion}"; Parameters: " -r "" open '{app}\FSDA\examples\examples_regression.m' ; open '{app}\FSDA\examples\examples_multivariate.m' ; open '{app}\FSDA\examples\examples_categorical.m' ; {code:doc_func} "" " ; Tasks: desktopicon

[Run]
Filename: "{code:MyMatlabVersion}"; Parameters: " -wait -automation -nodesktop -r "" addpath '{app}\FSDA\examples' ; addpath '{app}\FSDA\utilities' ; addpath '{app}\FSDA\combinatorial' ; addpath '{app}\FSDA\FSDAdemos' ; addpath '{app}\FSDA\graphics' ; addpath '{app}\FSDA\utilities_stat' ; addpath '{app}\FSDA\utilities_help' ;addpath '{app}\FSDA\datasets\multivariate' ; addpath '{app}\FSDA\datasets\regression' ; addpath '{app}\FSDA\datasets\multivariate_regression' ; addpath '{app}\FSDA\datasets\clustering' ; addpath '{app}\FSDA\clustering' ;addpath '{app}\FSDA\regression' ; addpath '{app}\FSDA\multivariate' ; addpath '{app}\FSDA' ; savepath ; exit "" " ; StatusMsg: "Setting MATLAB environment ..." ; Flags: shellexec waituntilterminated
Filename: "{code:MyMatlabVersion}"; Parameters: " -r "" open '{app}\FSDA\examples\examples_multivariate.m' ; open '{app}\FSDA\examples\examples_regression.m' ; open '{app}\FSDA\examples\examples_categorical.m' ; {code:doc_func} "" " ; Description: "{cm:LaunchProgram,MATLAB and FSDA toolbox with a set of examples and open documentation pages}"; Flags: shellexec postinstall skipifsilent
Filename: "{code:adobe_name}"; Parameters: " /n ""{app}\FSDA\InstallationNotes.pdf"" " ; Description: "{cm:OpenProgram, Installation Notes ( Acrobat Reader is required )}"; Flags: shellexec postinstall skipifsilent unchecked

[UninstallRun]
Filename: "{code:MyMatlabVersion}"; Parameters: " -automation -nodesktop -r "" rmpath '{app}\FSDA\examples' ; rmpath '{app}\FSDA\utilities' ; rmpath '{app}\FSDA\combinatorial' ; rmpath '{app}\FSDA\FSDAdemos' ; rmpath '{app}\FSDA\graphics' ;  rmpath '{app}\FSDA\utilities_stat' ; rmpath '{app}\FSDA\utilities_help' ; rmpath '{app}\FSDA\datasets\multivariate' ; rmpath '{app}\FSDA\datasets\regression' ; rmpath '{app}\FSDA\datasets\multivariate_regression' ; rmpath '{app}\FSDA\datasets\clustering' ; rmpath '{app}\FSDA\clustering' ; rmpath '{app}\FSDA\regression' ; rmpath '{app}\FSDA\multivariate' ; rmpath '{app}\FSDA' ; savepath ; exit "" " ; StatusMsg: "Remove FSDA paths from MATLAB environment ..." ; Flags: shellexec waituntilterminated
Filename: "{code:MyMatlabVersion}"; Parameters: " -automation -nodesktop -r "" {code:app_uninst}  quit;"" "; StatusMsg: "Remove FSDA apps from MATLAB environment ..." ; Flags: shellexec waituntilterminated
Filename: "{code:MyMatlabVersion}"; Parameters: " -automation -nodesktop -r "" if exist([docroot '\FSDA'],'dir');rmdir( [docroot '\FSDA'],'s') ; end; quit;"" "; Flags: shellexec waituntilterminated

[UninstallDelete]
Type: filesandordirs; Name: "{app}\FSDA\helpfiles\FSDA";
Type: filesandordirs; Name: "{%MatlabPath}\help\FSDA";


[Registry]
Root: HKLM; Subkey: "Software\JRC-UNIPR"; Flags: uninsdeletekeyifempty
Root: HKLM; Subkey: "Software\JRC-UNIPR\FSDA";  ValueType: string; ValueName: "InstallPath"; ValueData: "{app}" ; Flags: uninsdeletekey



[Code]
/////
function GetNumber(var temp: String): Integer;    
 var   
   part: String;   
   pos1: Integer;   
 begin   
   if Length(temp) = 0 then   
   begin   
    Result := -1;   
     Exit;  
   end;  
     pos1 := Pos('.', temp);  
     if (pos1 = 0) then  
     begin  
       Result := StrToInt(temp);  
       temp := '';  
     end  
     else 
     begin  
       part := Copy(temp, 1, pos1 - 1); 
       temp := Copy(temp, pos1 + 1, Length(temp));  
       Result := StrToInt(part);  
     end;  
 end;  
///////////////////////////    
 function CompareInner(var temp1, temp2: String): Integer;  
 var  
   num1, num2: Integer;  
 begin  
   num1 := GetNumber(temp1);  
   num2 := GetNumber(temp2);  
   if (num1 = -1) or (num2 = -1) then  
   begin  
     Result := 0;  
     Exit;  
   end;  
       if (num1 > num2) then  
       begin  
         Result := 1;  
       end  
       else if (num1 < num2) then  
       begin  
         Result := -1;  
       end  
       else  
       begin  
         Result := CompareInner(temp1, temp2);  
       end;  
 end;  
    
 function CompareVersion(str1, str2: String): Integer;  
 var  
   temp1, temp2: String;  
 begin  
     temp1 := str1;  
     temp2 := str2;  
     Result := CompareInner(temp1, temp2);  
 end;
////////////////////////
var
MatlabExe: String;
MatlabPath: String;
doc_command: String;
adobe_comm: String;
command: String;
Rel8: Boolean; 
Rel2015 : Boolean;
MatlabIsInstalled: Boolean;

function MyMatlabVersion(param: String): String;
var
   
  VersionMatlab: TArrayOfString;
  I: Integer;
  I_Iteratore: Integer;
  LevMatlab: String;
 begin
  //MsgBox('inizio:', mbInformation, MB_OK);
  if (MatlabIsInstalled = False) then
  begin
  if IsWin64 then
    begin
           RegGetSubKeyNames(HKLM64, 'SOFTWARE\MathWorks\MATLAB' , VersionMatlab);
   end
 else
    begin
           RegGetSubKeyNames(HKEY_LOCAL_MACHINE, 'SOFTWARE\MathWorks\MATLAB' , VersionMatlab);
  end;

  I:=GetArrayLength(VersionMatlab)-1;
  if ( I < 0 ) then
   begin
      MsgBox('FSDA works under MATLAB: please install it', mbError, MB_OK );
      abort;
   end;
  if ( I = 0 ) then
   begin
     LevMatlab:=VersionMatlab[I];
     if (CompareVersion (LevMatlab, '7.9') < 0) then
     begin
      MsgBox('FSDA Toolbox needs a MATLAB release greater than R2009b. Installation aborted.', mbError, MB_OK );
      abort;
     end;
         
     if IsWin64 then
      begin
           RegQueryStringValue(HKLM64, 'SOFTWARE\MathWorks\MATLAB\'+ LevMatlab, 'MATLABROOT', MatlabPath);
      end
     else
      begin
           RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\MathWorks\MATLAB\'+ LevMatlab ,  'MATLABROOT', MatlabPath);
      end
   end
  else
   begin
// Scorro tutti gli elementi nell'array
    MsgBox('There are different MATLAB versions in this system. The setup will ask you to choose where FSDA Toolbox has to be installed.', mbInformation, MB_OK );
    For I_Iteratore := 0 To I Do
      Begin  
          LevMatlab := VersionMatlab[I_Iteratore];
          if IsWin64 then
           begin
            RegQueryStringValue(HKLM64, 'SOFTWARE\MathWorks\MATLAB\'+ LevMatlab, 'MATLABROOT', MatlabPath);
           end
          else
           begin
            RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\MathWorks\MATLAB\'+ LevMatlab ,  'MATLABROOT', MatlabPath);
           end;
          if MsgBox('FSDA Toolbox will be installed in MATLAB version '+ #13 + MatlabPath + #13 +' Are you sure?', mbConfirmation, MB_YESNO or MB_DEFBUTTON1) = IDYES then
           begin
    // user clicked Yes
             I_Iteratore := I
           end
           else
           begin
             if (I_Iteratore = I) then
             begin
              MsgBox('FSDA Toolbox works under MATLAB : please, choose a MATLAB version where FSDA will be installed. Installation aborted.', mbError, MB_OK );
              abort;
             end;
           end;
      end;
     if (CompareVersion (LevMatlab, '7.9') < 0) then
      begin
       MsgBox('FSDA Toolbox is maintained from MATLAB release R2009b. Installation aborted.', mbError, MB_OK );
       abort;
      end;
    end;

if (CompareVersion (LevMatlab, '8') >= 0) then
 begin
    Rel8 := True;
    if (CompareVersion (LevMatlab, '8.5') >= 0) then
     begin
          Rel2015 := True;
     end;
 end;

  MatlabIsInstalled := True;
    
  if MatlabExe = '' then
  begin
    MsgBox('FSDA will run on this MATLAB release:' + #13 + MatlabPath, mbInformation, MB_OK);
  end;

  MatlabExe := ExpandConstant ( MatlabPath + '\bin\matlab.exe');
  end;

  Result := MatlabExe;


end;
  

/////////////////////////////////////////////////////////////////////

function GetUninstallString(): String;
var
  sUnInstPath: String;
  sUnInstallString: String;


begin
  sUnInstPath := ExpandConstant('SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{{DE14F41F-5D4E-4464-AE2C-A4A8EA42C3E4}_is1');
  sUnInstallString := '';
//  MsgBox('uninstpath:' + sUnInstPath, mbInformation, MB_OK);

  if not RegQueryStringValue(HKLM , sUnInstPath, 'UninstallString', sUnInstallString) then
  begin
    if not RegQueryStringValue(HKCU, sUnInstPath, 'UninstallString', sUnInstallString)  then
     begin
     sUnInstPath := ExpandConstant('Software\Microsoft\Windows\CurrentVersion\Uninstall\{{DE14F41F-5D4E-4464-AE2C-A4A8EA42C3E4}_is1');
     sUnInstallString := '';
//    MsgBox('uninstpath:' + sUnInstPath, mbInformation, MB_OK);
     if not RegQueryStringValue(HKLM, sUnInstPath, 'UninstallString', sUnInstallString) then
      RegQueryStringValue(HKCU, sUnInstPath, 'UninstallString', sUnInstallString);
     end;
  end;
  if sUnInstallString = '' then
  begin
     sUnInstPath := ExpandConstant('SOFTWARE\JRC-UNIPR\FSDA');
     sUnInstallString := '';
     RegQueryStringValue (HKEY_LOCAL_MACHINE, sUnInstPath, 'InstallPath', sUnInstallString);
     if sUnInstallString <> '' then
      begin
         Insert ('\unins000.exe', sUnInstallString, Length(sUnInstallString)+ 1);
      end;
  end;
  Result := sUnInstallString;
end;


/////////////////////////////////////////////////////////////////////
function IsUpgrade(): Boolean;
begin
  Result := (GetUninstallString() <> '');
end;


/////////////////////////////////////////////////////////////////////
function UnInstallOldVersion(): Integer;
var
  sUnInstallString: String;
  iResultCode: Integer;
  msg_path: String;
  index: Integer;
begin
// Return Values:
// 1 - uninstall string is empty
// 2 - error executing the UnInstallString
// 3 - successfully executed the UnInstallString
// 4 - User Interrupt

  // default return value
  Result := 0;

  // get the uninstall string of the old app
  sUnInstallString := GetUninstallString();
  index := Pos('\unins000.exe' , sUnInstallString);
  msg_path := sUnInstallString ;
  Delete( msg_path , index , 14);

  if sUnInstallString <> '' then
  begin
    sUnInstallString := RemoveQuotes(sUnInstallString);
    if MsgBox('Previous FSDA releases are already installed: they will be removed.' + #13#13 + 'PLEASE BE SURE TO HAVE A COPY OF YOUR OWN FILES SAVED OUTSIDE THE FSDA FOLDER TREE.' + #13#13 + 'Do you want to continue and remove the existing FSDA folder ( ' + msg_path + ' ) ?' , mbConfirmation, MB_YESNO or MB_DEFBUTTON2) = IDYES then
    begin
    // user clicked Yes
    if Exec(sUnInstallString, '/SILENT /NORESTART /SUPPRESSMSGBOXES','', SW_HIDE, ewWaitUntilTerminated, iResultCode) then
      Result := 3
    else
      Result := 2;
    end
    else
    begin
      MsgBox('FSDA Toolbox installation aborted', mbError, MB_OK);
      Result := 4;
    end
  end
  else
    Result := 1;
end;

/////////////////////////////////////////////////////////////////////

function doc_func(param: String): String;
begin
//  if (Rel8) then
//    if (Rel2015) then
        doc_command := ExpandConstant('docsearchFS ')
//    else
//        doc_command := ExpandConstant('doc -classic ')
//  else
//    doc_command := ExpandConstant('doc ');
  Result := doc_command;
end;

/////////////////////////////////////////////////////////////////////

function adobe_name(param: String): String;
var
  VersionAdobe: TArrayOfString;
  J: Integer;

  begin

  if IsWin64 then
    begin
           RegGetSubKeyNames(HKLM64, 'SOFTWARE\Classes\.pdf\OpenWithList' , VersionAdobe);
   end
 else
    begin
           RegGetSubKeyNames(HKEY_LOCAL_MACHINE, 'SOFTWARE\Classes\.pdf\OpenWithList' , VersionAdobe);
  end;

  J:=GetArrayLength(VersionAdobe)-1;
  //J:=-1;
  if ( J < 0 ) then
   begin
      MsgBox('Installation Notes is a pdf file: please install a pdf reader', mbError, MB_OK );
      adobe_comm:= 'help.exe' ;
   end
  else
   begin
     adobe_comm:=VersionAdobe[0];
   end;

  //MsgBox('dopo adobe reg' + adobe_comm , mbInformation, MB_OK);
  Result := adobe_comm;
end;

/////////////////////////////////////////////////////////////////////

function app_uninst(param: String): String;
begin
  if (Rel8) then
   command := ExpandConstant(' matlab.apputil.uninstall(''brushRESAPP''); matlab.apputil.uninstall(''brushFANAPP''); matlab.apputil.uninstall(''brushROBAPP''); ')
  else
   command := ExpandConstant(' ; ');
  Result := command;
end;

/////////////////////////////////////////////////////////////////////

procedure CurStepChanged(CurStep: TSetupStep);
var
  ResultCode: Integer;
begin
  if (CurStep=ssInstall) then
  begin
     Rel8 := False;
     Rel2015 := False;
     MatlabIsInstalled := False;
     MyMatlabVersion('');
     doc_func('');
     app_uninst('');

       if (IsUpgrade()) then
     begin
      if (UnInstallOldVersion()=4) then
      abort;
     end;
  end;
  if (CurStep=ssPostInstall) then
  begin
   if (Rel8) then
     begin
       Exec(ExpandConstant('{app}\FSDA\mgmhlpR8.bat'), ExpandConstant(' "{app}" '+'"'+ MatlabPath +'"'), '', SW_SHOW,ewWaitUntilTerminated, ResultCode);
       Exec(MatlabExe, ExpandConstant(' -wait -automation -nodesktop -r " cd ''{app}\FSDA'' ; matlab.apputil.install(''brushRES''); matlab.apputil.install(''brushFAN''); matlab.apputil.install(''brushROB''); quit; " '), '', SW_SHOW, ewWaitUntilTerminated, ResultCode);
    
// MsgBox('dopo app install' + ExpandConstant('"{app}\FSDA\mgmhlpR8.bat"') + ExpandConstant(' "{app}" '+'"'+ MatlabPath +'"') , mbInformation, MB_OK);
//      if Exec(ExpandConstant('{app}\FSDA\mgmhlpR8.bat'), ExpandConstant('{app}'), '', SW_SHOW,ewWaitUntilTerminated, ResultCode) then
//      begin
    // handle success if necessary; ResultCode contains the exit code
//       MsgBox('mgmhlpR8 eseguito con successo', mbInformation, MB_OK);
//      end
//      else begin
    // handle failure if necessary; ResultCode contains the error code
//        MsgBox('mgmhlpR8 failed', mbInformation, MB_OK);
//    end;
     end
   else 
    begin
     Exec(ExpandConstant('{app}\FSDA\mgmhlpR7.bat'), ExpandConstant(' "{app}" '+'"'+ MatlabPath +'"'), '', SW_SHOW,ewWaitUntilTerminated, ResultCode);
//      Exec(ExpandConstant('{app}\FSDA\mgmhlpR7.bat'), ExpandConstant('"{app}"'), '', SW_SHOW,ewWaitUntilTerminated, ResultCode);
//     MsgBox('esecuzione di mgm7' + ExpandConstant('{app}\FSDA\mgmhlpR7.bat {app}'), mbInformation, MB_OK);
//    if Exec(ExpandConstant('{app}\FSDA\mgmhlpR7.bat'), ExpandConstant('{app}'), '', SW_SHOW,ewWaitUntilTerminated, ResultCode) then
//      begin
    // handle success if necessary; ResultCode contains the exit code
//       MsgBox('mgmhlpR7 eseguito con successo', mbInformation, MB_OK);
//      end
//      else begin
    // handle failure if necessary; ResultCode contains the error code
//        MsgBox('mgmhlpR7 failed', mbInformation, MB_OK);
//      end;
    end;
  end;
end;



/////////////////////////////////////////////////////////////////////























































































