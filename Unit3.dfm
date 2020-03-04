object DataModule3: TDataModule3
  OldCreateOrder = False
  OnCreate = DataModuleCreate
  Height = 258
  Width = 354
  object reader: TFDTable
    IndexFieldNames = 'readerId'
    Connection = MagazineConnection
    UpdateOptions.UpdateTableName = 'reader'
    TableName = 'reader'
    Left = 239
    Top = 24
    object readerreaderId: TIntegerField
      FieldName = 'readerId'
    end
    object readerreaderName: TStringField
      FieldName = 'readerName'
    end
    object readermail: TStringField
      FieldName = 'mail'
    end
    object readerpassword: TStringField
      FieldName = 'password'
    end
    object readerday: TDateField
      FieldName = 'day'
    end
  end
  object FDTable2: TFDTable
    Connection = MagazineConnection
    UpdateOptions.UpdateTableName = 'setting'
    TableName = 'setting'
    Left = 15
    Top = 88
    object FDTable2admin: TStringField
      FieldName = 'admin'
    end
    object FDTable2password: TStringField
      FieldName = 'password'
    end
  end
  object user: TFDTable
    IndexFieldNames = 'userId'
    Connection = MagazineConnection
    UpdateOptions.UpdateTableName = 'user'
    TableName = 'user'
    Left = 144
    Top = 142
    object useruserId: TIntegerField
      FieldName = 'userId'
    end
    object useruser: TStringField
      FieldName = 'user'
    end
    object usermail: TStringField
      FieldName = 'mail'
    end
    object userpassword: TStringField
      FieldName = 'password'
    end
    object userday: TDateField
      FieldName = 'day'
    end
  end
  object mag: TFDTable
    Filtered = True
    Filter = 'enabled = true'
    IndexFieldNames = 'magId'
    Connection = MagazineConnection
    UpdateOptions.UpdateTableName = 'mag'
    TableName = 'mag'
    Left = 144
    Top = 80
    object magmagId: TIntegerField
      FieldName = 'magId'
    end
    object magmagName: TStringField
      FieldName = 'magName'
    end
    object magcomment: TMemoField
      FieldName = 'comment'
      BlobType = ftMemo
    end
    object magday: TDateField
      FieldName = 'day'
    end
    object maglastDay: TDateField
      FieldName = 'lastDay'
    end
    object magenable: TBooleanField
      FieldName = 'enable'
    end
  end
  object FDTable1: TFDTable
    IndexFieldNames = 'no'
    Connection = MagazineConnection
    UpdateOptions.UpdateTableName = 'database'
    TableName = 'database'
    Left = 144
    Top = 24
    object FDTable1no: TIntegerField
      FieldName = 'no'
    end
    object FDTable1magId: TIntegerField
      FieldName = 'magId'
    end
    object FDTable1userId: TIntegerField
      FieldName = 'userId'
    end
    object FDTable1readerId: TIntegerField
      FieldName = 'readerId'
    end
  end
  object MagazineConnection: TFDConnection
    Params.Strings = (
      'ConnectionDef=magazine')
    LoginPrompt = False
    Left = 50
    Top = 26
  end
  object news: TFDTable
    IndexFieldNames = 'magId;newsId'
    MasterFields = 'magId'
    Connection = MagazineConnection
    Left = 144
    Top = 200
    object newsmagId: TIntegerField
      FieldName = 'magId'
    end
    object newsnewsId: TIntegerField
      FieldName = 'newsId'
    end
    object newsupdated: TBooleanField
      FieldName = 'updated'
    end
    object newsday: TDateField
      FieldName = 'day'
    end
    object newsfile: TBlobField
      FieldName = 'file'
    end
    object newsenabled: TBooleanField
      FieldName = 'enabled'
    end
  end
  object FDQuery1: TFDQuery
    Connection = MagazineConnection
    Left = 72
    Top = 88
  end
  object indexTable: TFDTable
    Filtered = True
    IndexFieldNames = 'readerId;magId'
    MasterFields = 'readerId'
    Connection = MagazineConnection
    Left = 240
    Top = 80
    object indexTablereaderId: TIntegerField
      FieldName = 'readerId'
    end
    object indexTablemagId: TIntegerField
      FieldName = 'magId'
    end
    object indexTableday: TDateField
      FieldName = 'day'
    end
  end
  object magList: TFDTable
    IndexFieldNames = 'userId;magId'
    Connection = MagazineConnection
    Left = 88
    Top = 144
    object magListuserId: TIntegerField
      FieldName = 'userId'
    end
    object magListmagId: TIntegerField
      FieldName = 'magId'
    end
  end
end
