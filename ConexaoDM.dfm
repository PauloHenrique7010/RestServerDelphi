object ConexaoDtm: TConexaoDtm
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 150
  Width = 215
  object Conexao: TFDConnection
    Params.Strings = (
      'Database=atendimento_dk'
      'Password='
      'User_Name='
      'Server=localhost'
      'DriverID=MySQL')
    LoginPrompt = False
    Left = 32
    Top = 24
  end
  object qryAtendimento: TFDQuery
    Connection = Conexao
    SQL.Strings = (
      'select cod_atendimento, '
      '       dt_atendimento, '
      '       hr_atendimento,'
      '       assunto'
      'from atendimento')
    Left = 136
    Top = 32
  end
end
