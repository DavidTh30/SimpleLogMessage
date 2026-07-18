unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, simpleipc, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ExtCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    CmdClear: TButton;
    Label1: TLabel;
    Memo1: TMemo;
    Shape1: TShape;
    SimpleIPCClient1: TSimpleIPCClient;
    procedure CmdClearClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
  private
    procedure OnIdle(Sender: TObject; var Done: boolean);
  public
    procedure SendMessage_(s:String);
  end;

var
  Form1: TForm1;
  NoNeedServer:boolean;
  ServerOnline:boolean;
  EventsList: TStringList;

implementation

{$R *.lfm}

{ TForm1 }
procedure TForm1.SendMessage_(s:String);
var
  IPCClient: TSimpleIPCClient;
  CandidateIDs: array[0..3] of string;// Or array of string for older FPC versions
  SrvID: string;
begin

  // List of IDs you expect or want to test for
  //CandidateIDs := ['ServerOne', 'ServerTwo', 'AppInstance_123', 'MyServerID'];
  CandidateIDs[0]:='MessageLogConsole20';
  CandidateIDs[1]:='MessageLogConsole50';
  CandidateIDs[2]:='MessageLogConsole100';
  CandidateIDs[3]:='MessageLogConsole200';

  IPCClient := TSimpleIPCClient.Create(nil);
  try
    ServerOnline:=false;
    for SrvID in CandidateIDs do
    begin
      IPCClient.ServerID := SrvID;
      //IPCClient.Global := True; // Match the Global setting of your servers

      if IPCClient.ServerRunning then
      begin
        IPCClient.Active:=true;
        IPCClient.Connect;
        ServerOnline:=true;
        IPCClient.SendStringMessage(s);
        break;
      end;
    end;
  finally
    IPCClient.Disconnect;
    IPCClient.Active:=false;
    IPCClient.Free;
  end;
  if ServerOnline then
  begin
    Label1.Caption:={$i %LINE%}+ ': '+'Connect';
    Shape1.Brush.Color:=clGreen;
  end;
  if not ServerOnline then
  begin
    Label1.Caption:={$i %LINE%}+ ': '+'Disonnect';
    Shape1.Brush.Color:=clSilver;
  end;
end;

procedure TForm1.OnIdle(Sender: TObject; var Done: boolean);
var
  RandomInteger: Integer;
  RandomRange: Integer;
begin
  //if NoNeedServer then
  //begin
  //  SimpleIPCClient1.Disconnect;
  //  SimpleIPCClient1.Active:=false;
  //  exit;
  //end;
  //
  //if NoNeedServer = false then
  //if not SimpleIPCClient1.ServerRunning then
  //begin
  //  ServerOnline:=false;
  //  Memo1.Append({$i %LINE%}+ ': '+'Disconnect');
  //  FindActiveServers();
  //end;
  //
  //if ServerOnline then
  //begin
  //  Randomize;
  //  RandomInteger := Random(100);
  //  RandomRange := 50 + Random(100 - 50 + 1);
  //  SimpleIPCClient1.SendStringMessage({$i %LINE%}+ ': '+RandomInteger.ToString+IntToHex(RandomRange,6));
  //end;
  //
  ////if SimpleIPCClient1.ServerRunning then  ServerOnline:=true;

  Randomize;
  RandomInteger := Random(100);
  RandomRange := 50 + Random(100 - 50 + 1);
  EventsList.Add({$i %LINE%}+ ': '+RandomInteger.ToString+IntToHex(RandomRange,6));
  SendMessage_({$i %LINE%}+ ': '+RandomInteger.ToString+IntToHex(RandomRange,6));

  if EventsList.Count > 20 then EventsList.Delete(0);
  Memo1.Lines.Assign(EventsList);

  form1.Refresh;
end;

procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  EventsList.Free;
  SendMessage_('clear');
  SendMessage_({$i %LINE%}+ ': Goodby');
end;

procedure TForm1.CmdClearClick(Sender: TObject);
begin
  SendMessage_('clear');
  EventsList.Clear;
  Memo1.Lines.Assign(EventsList);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  ServerOnline:=false;
  Application.OnIdle := @OnIdle;
  NoNeedServer:=false;
  EventsList:=TStringList.Create;
end;

end.

