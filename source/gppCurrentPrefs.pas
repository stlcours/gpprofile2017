unit gppCurrentPrefs;

interface

type

  TGlobalPreferences = class
  public
  class var
    ExcludedUnits         : string;
    MarkerStyle           : integer;
    CompilerVersion       : integer;
    HideNotExecuted       : boolean;
    SpeedSize             : integer;
    ShowAllFolders        : boolean;
    StandardDefines       : boolean;
    ProjectDefines        : boolean;
    DisableUserDefines    : boolean;
    UserDefines           : string;
    KeepFileDate          : boolean;
    UseFileDate           : boolean;
    PrfFilenameMakro      : string;
    ProfilingAutostart    : boolean;
    InstrumentAssembler   : boolean;
    MakeBackupOfInstrumentedFile : boolean;

    class procedure SetProjectPref(name: string; value: variant); overload; static;
    class function  GetProjectPref(name: string; defval: variant): variant; overload; static;
    class procedure DelProjectPref(name: string); static;
    class procedure SetProfilePref(name: string; value: variant); overload; static;
    class function  GetProfilePref(name: string; defval: variant): variant; overload; static;

    class procedure LoadPreferences;

    /// saves the (global) preferences in the registry
    class procedure SavePreferences;
  end;

var
  CurrentProjectName        : string;

  /// <summary>
  /// The selected product version, e.g. 10.3 Rio.
  /// </summary>
  selectedDelphi            : string;
  /// <summary>
  /// The output dir as defined in the project.
  /// </summary>
  ProjectOutputDir          : string;

function HasOpenProject: boolean;





implementation

uses
  winapi.windows,
  System.SysUtils,
  System.IniFiles,
  gppCommon,
  gpiff,
  gpregistry,
  gpPrfPlaceholders, 
  GpString,
  gppmain.types;

class procedure TGlobalPreferences.LoadPreferences;
begin
  with TGpRegistry.Create do
    try
      RootKey := HKEY_CURRENT_USER;
      OpenKey(cRegistryRoot+'\Preferences', True);
      try
        ExcludedUnits      := ReadString ('ExcludedUnits',defaultExcludedUnits);
        MarkerStyle        := ReadInteger('MarkerStyle',0);
        SpeedSize          := ReadInteger('SpeedSize',1);
        CompilerVersion    := ReadInteger('CompilerVersion',-1);
        HideNotExecuted    := ReadBool   ('HideNotExecuted',true);
        ShowAllFolders     := ReadBool   ('ShowAllFolders',false);
        StandardDefines    := ReadBool   ('StandardDefines',true);
        ProjectDefines     := ReadBool   ('ProjectDefines',true);
        DisableUserDefines := ReadBool   ('DisableUserDefines',false);
        UserDefines        := ReadString ('UserDefines','');
        ProfilingAutostart := ReadBool   ('ProfilingAutostart',true);
        InstrumentAssembler:= ReadBool   ('InstrumentAssembler',false);
        MakeBackupOfInstrumentedFile := ReadBool('MakeBackupOfInstrumentedFile', true);
        KeepFileDate       := ReadBool   ('KeepFileDate',false);
        UseFileDate        := ReadBool   ('UseFileDate',true);
        PrfFilenameMakro   := ReadString ('PrfFilenameMakro',TPrfPlaceholder.PrfPlaceholderToMacro(TPrfPlaceholderType.ModulePath));
      finally
        CloseKey;
      end;
    finally
      Free;
    end;
end; { LoadPreferences }

class procedure TGlobalPreferences.SavePreferences;
begin
  with TGpRegistry.Create do begin
    RootKey := HKEY_CURRENT_USER;
    OpenKey(cRegistryRoot+'\Preferences',true);
    WriteString ('ExcludedUnits',      ExcludedUnits);
    WriteInteger('MarkerStyle',        MarkerStyle);
    WriteInteger('SpeedSize',          SpeedSize);
    WriteInteger('CompilerVersion',    CompilerVersion);
    WriteBool   ('HideNotExecuted',    HideNotExecuted);
    WriteBool   ('ShowAllFolders',     ShowAllFolders);
    WriteBool   ('StandardDefines',    StandardDefines);
    WriteBool   ('ProjectDefines',     ProjectDefines);
    WriteBool   ('DisableUserDefines', DisableUserDefines);
    WriteString ('UserDefines',        UserDefines);
    WriteBool   ('ProfilingAutostart', ProfilingAutostart);
    WriteBool   ('InstrumentAssembler',InstrumentAssembler);
    WriteBool   ('MakeBackupOfInstrumentedFile', MakeBackupOfInstrumentedFile);

    WriteBool   ('KeepFileDate',       KeepFileDate);
    WriteBool   ('UseFileDate',        UseFileDate);
    WriteString ('PrfFilenameMakro',   PrfFilenameMakro);
    Free;
  end;
end; { SavePreferences }

class procedure TGlobalPreferences.SetProjectPref(name: string; value: variant);
begin
  TGpRegistryTools.SetPref('\Projects\'+ReplaceAll(CurrentProjectName,'\','/'),name,value);
end; { SetProjectPref }

class function TGlobalPreferences.GetProjectPref(name: string; defval: variant): variant;
begin
  if not HasOpenProject then
    Result := defval
  else
    Result := TGpRegistryTools.GetPref('\Projects\'+ReplaceAll(CurrentProjectName,'\','/'),name,defval);
end; { GetProjectPref }

class procedure TGlobalPreferences.DelProjectPref(name: string);
begin
  if HasOpenProject then TGpRegistryTools.DelPref('\Projects\'+ReplaceAll(CurrentProjectName,'\','/'),name);
end; { DelProjectPref }

class procedure TGlobalPreferences.SetProfilePref(name: string; value: variant);
begin
  TGpRegistryTools.SetPref('\Profiles\'+ReplaceAll(CurrentProjectName,'\','/'),name,value);
end; { SetProfilePref }

class function TGlobalPreferences.GetProfilePref(name: string; defval: variant): variant;
begin
  if not HasOpenProject then
    Result := defval
  else
    Result := TGpRegistryTools.GetPref('\Profiles\'+ReplaceAll(CurrentProjectName,'\','/'),name,defval);
end; { GetProfilePref }

function HasOpenProject: boolean;
begin
  result := Length(Trim(CurrentProjectName)) <> 0;
end; { HasOpenProject }

end.
