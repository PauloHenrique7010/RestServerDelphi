unit Atendimento;

interface

Uses
  System.SysUtils, System.Classes, System.JSON,
     Dialogs, ServerUtils, SysTypes;

type
  TAtendimento = class
  private
    FcodAtendimento: integer;
    Fassunto: string;
    procedure Setassunto(const Value: string);
    procedure SetcodAtendimento(const Value: integer);
  public
    property codAtendimento : integer read FcodAtendimento write SetcodAtendimento;
    property assunto  : string read Fassunto write Setassunto;
    function pegarAtendimento(parametros:string):string;
  end;



implementation

{ TAtendimento }

uses ConexaoDM;

function TAtendimento.pegarAtendimento(parametros:string): string;
Var
  i : integer;
  LJson       : TJSONObject;
  LJsonObject : TJSONObject;
  LArr        : TJSONArray;
  str : string;
  arrayParametro : TStringlist;
  pesquisa : string;

Begin
  pesquisa := '';
  if (parametros <> '') then
  begin
    arrayParametro := TStringlist.Create;
    arrayParametro.Clear;

    arrayParametro.Delimiter := '&';
    arrayParametro.DelimitedText := parametros;


    for i := 0 to arrayParametro.Count-1 do
    begin
      pesquisa := pesquisa + arrayParametro.Strings[i] + ' = '+arrayParametro.Strings[i+1];
      break;
    end;
    showMessage(arrayParametro.Strings[0]);
  end;
  estou tentando receber parametros e formatalos para o pesquisa funcinoar




  LJsonObject := TJSONObject.Create;
  LArr        := TJSONArray.Create;
  try
    conexaoDtm.qryAtendimento.Close;
    ConexaoDtm.qryAtendimento.SQL.Clear;
    ConexaoDtm.qryAtendimento.SQL.Add(ConexaoDtm.sqlAtendimento);
    if (CodAtendimento > 0) then
    begin
      ConexaoDtm.qryAtendimento.SQL.Add('WHERE cod_atendimento=:codigo');
      ConexaoDtm.qryAtendimento.ParamByName('codigo').AsInteger := codAtendimento;
    end;
    ConexaoDtm.qryAtendimento.Open();


    while not (ConexaoDtm.qryAtendimento.Eof) do
    begin
      LJson := TJSONObject.Create;
      LJson.AddPair(TJSONPair.Create('cod_atendimento', TJSONNumber.Create(ConexaoDtm.qryAtendimento.FieldByName('cod_atendimento').AsInteger)));
      LJson.AddPair(TJSONPair.Create('assunto', ConexaoDtm.qryAtendimento.FieldByName('assunto').AsString));
      LJson.AddPair(TJSONPair.Create('data_criado_string', FormatDateTime('dd/MM/yyyy',ConexaoDtm.qryAtendimento.FieldByName('dt_atendimento').AsDateTime)));
      LJson.AddPair(TJSONPair.Create('data_criado_number', TJSONNumber.Create(ConexaoDtm.qryAtendimento.FieldByName('dt_atendimento').AsDateTime)));

      LArr.Add(LJson);
      ConexaoDtm.qryAtendimento.Next;
    end;
    LJsonObject.AddPair(TJSONPair.Create('Registros', LArr));
    str := lJsonObject.ToString;
    str := StringReplace(str,'\/','/',[rfReplaceAll]);
    str := StringReplace(str,'\\','\',[rfReplaceAll]);

    Result := str;
  Finally
     LJsonObject.Free;
  end;
end;

procedure TAtendimento.Setassunto (const Value: string);
begin
  Fassunto := Value;
end;

procedure TAtendimento.SetcodAtendimento(const Value: integer);
begin
  FcodAtendimento := Value;
end;

end.
