unit ComMainForm;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, CPort, CPortCtl;

type
  TForm1 = class(TForm)
    ComPort: TComPort;
    Memo: TMemo;
    Button_Open: TButton;
    Button_Settings: TButton;
    eb1: TEdit;
    Button_Send: TButton;
    Panel1: TPanel;
    ComLed1: TComLed;
    ComLed2: TComLed;
    ComLed3: TComLed;
    ComLed4: TComLed;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    ComLed5: TComLed;
    ComLed6: TComLed;
    Label1: TLabel;
    Label6: TLabel;
    Timer1: TTimer;
    eb2: TEdit;
    eb3: TEdit;
    eb4: TEdit;
    eb5: TEdit;
    eb6: TEdit;
    eb7: TEdit;
    eb8: TEdit;
    rb1: TRadioButton;
    rb2: TRadioButton;
    rb3: TRadioButton;
    rb4: TRadioButton;
    rb5: TRadioButton;
    rb6: TRadioButton;
    rb7: TRadioButton;
    rb8: TRadioButton;
    procedure Button_OpenClick(Sender: TObject);
    procedure Button_SettingsClick(Sender: TObject);
    procedure Button_SendClick(Sender: TObject);
    procedure ComPortOpen(Sender: TObject);
    procedure ComPortClose(Sender: TObject);
    procedure ComPortRxChar(Sender: TObject; Count: Integer);
    function StrToHex(source: string): string;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    Status : Shortint;
    Tick, Wait : Word;
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

function TForm1.StrToHex(source: String): String;
var i:integer;
    c:Char;
    s:String;
begin
    s := '';
    for i:=1 to Length(source) do
    begin
      c := source[i];
      s := s +'$'+IntToHex(Integer(c),2)+' ';
//      s := s +IntToHex(Ord(c),2)+' ';
    end;
    result := s;
end;

Function Byte2Bin (Chiffre : Byte) : String;
Var I, Temp : Byte;
    St      : String;
Begin
   St := '';
   For I := 7 Downto 0 do Begin
       Temp := (Chiffre and (1 shl I));
       If (Temp = 0) then St := St + '0' Else St := St + '1';
   End;
   Byte2Bin := St;
End;

function bintostr(const bin: array of byte): string;
const HexSymbols = '0123456789ABCDEF';
var i: integer;
begin
  SetLength(Result, 2*Length(bin));
  for i :=  0 to Length(bin)-1 do begin
    Result[1 + 2*i + 0] := HexSymbols[1 + bin[i] shr 4];
    Result[1 + 2*i + 1] := HexSymbols[1 + bin[i] and $0F];
  end;
end;

function bintoAscii(const bin: array of byte): AnsiString;
var i: integer;
begin
  SetLength(Result, Length(bin));
  for i := 0 to Length(bin)-1 do
    Result[1+i] := AnsiChar(bin[i]);
end;

function xHexToBin(const HexStr: String): String;
const HexSymbols = '0123456789ABCDEF';
var i, J: integer;
    B: Byte;
    R: array of byte;

begin
  SetLength(R, (Length(HexStr) + 1) shr 1);
  B:= 0;
  i :=  0;
  while I < Length(HexStr) do begin
    J:= 0;
    while J < Length(HexSymbols) do begin
      if HexStr[I + 1] = HexSymbols[J + 1] then Break;
      Inc(J);
    end;
    if J = Length(HexSymbols) then ; // error
    if Odd(I) then
      R[I shr 1]:= B shl 4 + J
    else
      B:= J;
    Inc(I);
  end;
  if Odd(I) then R[I shr 1]:= B;

  Result := bintoAscii(R);
end;

procedure WaitStatus;
begin
  With TForm1 do
{    begin
      TimeWait := GetTickCount;
    while (Status <> 4) do
    begin
      Sleep(1);
      if ((GetTickCount - TimeWait) > MaxTimeOut) and (Status in [2,3]) then
          Break;
    end;
  end;  }
end;

procedure TForm1.Button_OpenClick(Sender: TObject);
begin
  if ComPort.Connected then
    ComPort.Close
  else
    ComPort.Open;
end;

procedure TForm1.Button_SettingsClick(Sender: TObject);
//var i : Integer;
begin
{  if Cbr_CB.Checked then begin
    i := StrToInt(eSpeed.Text);
    ComPort.BaudRate := brCustom;
    ComPort.CustomBaudRate := i;
  end else begin
    ComPort.BaudRate := br19200;
    ComPort.CustomBaudRate := 19200;
  end;}
    ComPort.BaudRate := br57600;
  ComPort.ShowSetupDialog;
end;

procedure TForm1.Button_SendClick(Sender: TObject);
var
  Str: String;
begin
  if rb1.Checked then Str := xHexToBin(eb1.Text);
  if rb2.Checked then Str := xHexToBin(eb2.Text);
  if rb3.Checked then Str := xHexToBin(eb3.Text);
  if rb4.Checked then Str := xHexToBin(eb4.Text);
  if rb5.Checked then Str := xHexToBin(eb5.Text);
  if rb6.Checked then Str := xHexToBin(eb6.Text);
  if rb7.Checked then Str := xHexToBin(eb7.Text);
  if rb8.Checked then Str := xHexToBin(eb8.Text);
  Comport.WriteUnicodeString(Str);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  //Comport.WriteUnicodeString(Chr($AA)+Chr($00)+Chr($00)+Chr($00));
end;

procedure TForm1.ComPortOpen(Sender: TObject);
begin
  Button_Open.Caption := 'Close';
end;

procedure TForm1.ComPortClose(Sender: TObject);
begin
  if Button_Open <> nil then
    Button_Open.Caption := 'Open';
end;

procedure TForm1.ComPortRxChar(Sender: TObject; Count: Integer);
var
  Str, Str1, StrB1, StrB2 : String;
  nCheck, nDev, nPar, nVal: integer;
  bVal : array of byte;
begin
  ComPort.ReadStr(Str, Count);
  Count := 6;
  Str1:= StrToHex(Str);
  SetLength(bVal, 2);
  if Count > 2 then begin
   nCheck := Byte(Char(Str[1]));
   nDev := Byte(Char(Str[2]));
   nPar := Byte(Char(Str[3]));
   if Count >= 4 then bval[1] := Byte(Char(Str[4])) else bVal[1] := 0;
   if Count >= 5 then bval[0] := Byte(Char(Str[5])) else bVal[0] := 0;
   nVal := bVal[1] or (bVal[0] shl 8);
   StrB1 := Byte2Bin(bval[0]);
   StrB2 := Byte2Bin(bval[1]);
//   Str1 := Str1 + ' Check ' + IntTostr(nCheck) + ' dev '+IntTostr(nDev)+' param '+IntTostr(nPar)+ ' val '+IntTostr(nVal)+' - '+IntToStr(Integer(bVal[0]))+' '+IntToStr(Integer(bVal[1]))+' - '+StrB1+' '+StrB2;
   Str1 := Str1 + ' Check ' + IntTostr(nCheck) + ' dev '+IntTostr(nDev)+' param '+IntTostr(nPar)+ ' val '+IntTostr(nVal)+' - '+StrB1+' '+StrB2;
  end;
  Memo.Lines.Add(Str1);
end;

end.
