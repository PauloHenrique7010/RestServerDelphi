unit SysTypes;

interface

uses
  System.JSON, IdCustomHTTPServer;

Type
  TResultErro = record
     STATUS        : Integer;
     MENSAGEM      : String;
  end;

  TRequisicao = record
    URL : string;
    Tipo : THTTPCommandType;
    queryParams : string;
    bodyParams : string;

  end;

  TArguments = array of string;

implementation

end.
