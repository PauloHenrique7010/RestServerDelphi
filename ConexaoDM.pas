unit ConexaoDM;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Error, FireDAC.UI.Intf, FireDAC.Phys.Intf, FireDAC.Stan.Def,
  FireDAC.Stan.Pool, FireDAC.Stan.Async, FireDAC.Phys, FireDAC.VCLUI.Wait,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet, FireDAC.Comp.Client, FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef;

type
  TConexaoDtm = class(TDataModule)
    Conexao: TFDConnection;
    qryAtendimento: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
  public
    sqlAtendimento : string;
  end;

var
  ConexaoDtm: TConexaoDtm;

implementation

{%CLASSGROUP 'Vcl.Controls.TControl'}

{$R *.dfm}

procedure TConexaoDtm.DataModuleCreate(Sender: TObject);
begin
  sqlAtendimento := 'SELECT a.cod_atendimento, '+
                              'a.dt_atendimento, '+
                              'a.hr_atendimento, '+
                              'a.cod_sistema, '+
                              'a.cod_cliente, '+
                              'a.cod_tipo_atendimento, '+
                              'a.pendente, '+
                              'a.assunto, '+
                              'a.descricao, '+
                              'a.cod_usuario_atendimento, '+
                              'a.KM, '+
                              'a.gastos '+
                        'FROM atendimento a ';
end;

end.
