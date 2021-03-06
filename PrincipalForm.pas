unit PrincipalForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  IdBaseComponent, IdComponent, IdCustomTCPServer, IdCustomHTTPServer,
  IdHTTPServer, Vcl.AppEvnts, Vcl.Buttons, IdContext, ServerUtils, IdHeaderList,
  Vcl.DdeMan;

type
  TPrincipalFrm = class(TForm)
    lblNome: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    txtInfoLabel: TStaticText;
    btnAtivar: TBitBtn;
    btnParar: TBitBtn;
    memoReq: TMemo;
    memoResp: TMemo;
    apl1: TApplicationEvents;
    TrayIcon1: TTrayIcon;
    IdHTTPServer1: TIdHTTPServer;
    DdeServerConv1: TDdeServerConv;
    procedure IdHTTPServer1CommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure TrayIcon1Click(Sender: TObject);
    procedure apl1Minimize(Sender: TObject);
    procedure btnAtivarClick(Sender: TObject);
    procedure btnPararClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure IdHTTPServer1CommandOther(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure FormDestroy(Sender: TObject);
  private
    ServerParams : TServerParams;
    procedure LoglastRequest (ARequestInfo: TIdHTTPRequestInfo);
    procedure LogLastResponse (AResponseInfo: TIdHTTPResponseInfo);
  public
    { Public declarations }
  end;

var
  PrincipalFrm: TPrincipalFrm;
  CriticalSection: TRTLCriticalSection;

implementation

{$R *.dfm}

Uses
  Systypes, ServerMethodsUnit1, IdGlobal, System.JSON, ConexaoDM;

procedure TPrincipalFrm.apl1Minimize(Sender: TObject);
begin
     Self.Hide();
     Self.WindowState := wsMinimized;
     TrayIcon1.Visible := True;
     TrayIcon1.Animate := True;
     TrayIcon1.ShowBalloonHint;
end;

procedure TPrincipalFrm.btnAtivarClick(Sender: TObject);
begin
  IdHTTPServer1.Active := True;
  txtInfoLabel.Caption := 'Aguardando requisições...';
end;

procedure TPrincipalFrm.btnPararClick(Sender: TObject);
begin
     IdHTTPServer1.Active := False;
     txtInfoLabel.Caption := 'WebService parado.';
end;

procedure TPrincipalFrm.FormCreate(Sender: TObject);
begin
  Application.CreateForm(TConexaoDtm, ConexaoDtm);
  btnAtivarClick(self);
  ServerParams := TServerParams.Create;
//  ServerParams.HasAuthentication := True;
//  ServerParams.UserName          := 'user';
//  ServerParams.Password          := 'passwd';
end;

procedure TPrincipalFrm.FormDestroy(Sender: TObject);
begin
  ServerParams.Free;
  Conexaodtm.free;
end;

procedure TPrincipalFrm.IdHTTPServer1CommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
Var
     Requisicao    : TRequisicao;
     ServerMethod1 : TServerMethods1;
     JSONStr       : string;
     stream : TStream;

     reqJson : TJSONOBject;
begin
  stream := ARequestInfo.PostStream;
  if (Assigned(stream)) then
  begin
    reqJson := TJSONObject.ParseJSONValue(ReadStringFromStream(stream, -1, IndyTextEncoding_UTF8)) as TJsonObject;
    Requisicao.bodyParams := reqJson.ToString;
  end;
  Requisicao.URL := StringReplace(ARequestInfo.Document,'/','',[rfReplaceAll]);
  Requisicao.Tipo := ARequestInfo.CommandType;
  Requisicao.queryParams := ARequestInfo.QueryParams;

  If (ServerParams.HasAuthentication) then Begin
    if Not ((ARequestInfo.AuthUsername = ServerParams.Username) and
           (ARequestInfo.AuthPassword = ServerParams.Password))
     Then Begin
       AResponseInfo.AuthRealm := 'RestWebServer';
       AResponseInfo.WriteContent;
       Exit;
     End;
  End;
  if (Requisicao.Tipo = hcGet) or
      (Requisicao.Tipo = hcPost) then
  Begin
    ServerMethod1 := TServerMethods1.Create (nil);
    Try
       LoglastRequest (ARequestInfo);
       If (Requisicao.Tipo = hcGet) Then
          JSONStr := ServerMethod1.CallGETServerMethod(Requisicao);
       If (Requisicao.Tipo = hcPost) Then
//          JSONStr := ServerMethod1.CallPOSTServerMethod(Argumentos, reqJson);
        showmessage('post');

       AResponseInfo.ContentText := JSONStr;
       AResponseInfo.ContentType := 'application/json';
       AResponseInfo.CharSet := 'utf-8';
       AResponseInfo.WriteContent;
    Finally
       ServerMethod1.Free;
    End;
  end;
end;

procedure TPrincipalFrm.IdHTTPServer1CommandOther(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
Var
     Cmd           : String;
     Argumentos    : TArguments;
     ServerMethod1 : TServerMethods1;
     JSONStr       : string;
begin
     Cmd := ARequestInfo.RawHTTPCommand;
     If (ServerParams.HasAuthentication) then Begin
        if Not ((ARequestInfo.AuthUsername = ServerParams.Username) and
               (ARequestInfo.AuthPassword = ServerParams.Password))
         Then Begin
           AResponseInfo.AuthRealm := 'RestWebServer';
           AResponseInfo.WriteContent;
           Exit;
         End;
     End;
     if (UpperCase(Copy (Cmd, 1, 3)) = 'PUT') OR
        (UpperCase(Copy (Cmd, 1, 6)) = 'DELETE')
     then Begin
        Argumentos    := TServerUtils.ParseRESTURL (ARequestInfo.URI);
        ServerMethod1 := TServerMethods1.Create (nil);
        Try
           LoglastRequest (ARequestInfo);
           If UpperCase(Copy (Cmd, 1, 3)) = 'PUT' Then
              JSONStr := ServerMethod1.CallPUTServerMethod(Argumentos);
           If UpperCase(Copy (Cmd, 1, 6)) = 'DELETE' Then
              JSONStr := ServerMethod1.CallDELETEServerMethod(Argumentos);

           AResponseInfo.ContentText := JSONStr;
           LoglastResponse (AResponseInfo);
           AResponseInfo.WriteContent;
        Finally
           ServerMethod1.Free;
        End;
     end;
end;

procedure TPrincipalFrm.LoglastRequest(ARequestInfo: TIdHTTPRequestInfo);
begin
  EnterCriticalSection(CriticalSection);
  memoReq.Lines.Add(ARequestInfo.UserAgent + #13 + #10 +
                       ARequestInfo.RawHTTPCommand);
  LeaveCriticalSection(CriticalSection);
end;

procedure TPrincipalFrm.LogLastResponse(AResponseInfo: TIdHTTPResponseInfo);
begin
   EnterCriticalSection(CriticalSection);
     memoResp.Lines.Add(AResponseInfo.ContentText);
     LeaveCriticalSection(CriticalSection);
end;

procedure TPrincipalFrm.TrayIcon1Click(Sender: TObject);
begin
  TrayIcon1.Visible := False;
  Show();
  WindowState := wsNormal;
  Application.BringToFront();
end;

initialization
  InitializeCriticalSection(CriticalSection);

finalization
  DeleteCriticalSection(CriticalSection);

end.
