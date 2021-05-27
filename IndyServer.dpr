program IndyServer;

uses
  Vcl.Forms,
  PrincipalForm in 'PrincipalForm.pas' {Form1},
  ServerMethodsUnit1 in 'ServerMethodsUnit1.pas',
  ServerUtils in 'ServerUtils.pas',
  SysTypes in 'SysTypes.pas',
  ConexaoDM in 'ConexaoDM.pas' {ConexaoDtm: TDataModule},
  Atendimento in 'Atendimento.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TPrincipalFrm, PrincipalFrm);
  Application.Run;
end.
