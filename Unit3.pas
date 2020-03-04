unit Unit3;

interface

uses
  System.SysUtils, System.Classes, FireDAC.Stan.Intf, FireDAC.Stan.Option,
  FireDAC.Stan.Param, FireDAC.Stan.Error, FireDAC.DatS, FireDAC.Phys.Intf,
  FireDAC.DApt.Intf, FireDAC.Stan.Async, FireDAC.DApt, FireDAC.UI.Intf,
  FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Phys, FireDAC.Phys.MySQL,
  FireDAC.Phys.MySQLDef, Data.DB, FireDAC.Comp.Client, FireDAC.Comp.DataSet,
  System.JSON;

type
  TDataModule3 = class(TDataModule)
    reader: TFDTable;
    readerreaderId: TIntegerField;
    readerreaderName: TStringField;
    readermail: TStringField;
    readerpassword: TStringField;
    readerday: TDateField;
    FDTable2: TFDTable;
    FDTable2admin: TStringField;
    FDTable2password: TStringField;
    user: TFDTable;
    useruserId: TIntegerField;
    useruser: TStringField;
    usermail: TStringField;
    userpassword: TStringField;
    userday: TDateField;
    mag: TFDTable;
    magmagId: TIntegerField;
    magmagName: TStringField;
    magcomment: TMemoField;
    magday: TDateField;
    maglastDay: TDateField;
    magenable: TBooleanField;
    FDTable1: TFDTable;
    FDTable1no: TIntegerField;
    FDTable1magId: TIntegerField;
    FDTable1userId: TIntegerField;
    FDTable1readerId: TIntegerField;
    MagazineConnection: TFDConnection;
    news: TFDTable;
    newsnewsId: TIntegerField;
    newsupdated: TBooleanField;
    newsday: TDateField;
    FDQuery1: TFDQuery;
    newsfile: TBlobField;
    newsmagId: TIntegerField;
    newsenabled: TBooleanField;
    indexTable: TFDTable;
    indexTablereaderId: TIntegerField;
    indexTableday: TDateField;
    indexTablemagId: TIntegerField;
    magList: TFDTable;
    magListuserId: TIntegerField;
    magListmagId: TIntegerField;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private 宣言 }
    function makeTable(Sender: TObject): TJSONObject;
  public
    { Public 宣言 }
    function checkUserPassword(id: integer; password: string): Boolean;
    procedure deleteUser(id: integer);
    procedure readuserData(id: integer; out Data: TJSONObject);
    procedure updateUserId(id: integer; Data: TJSONObject);
    procedure createUserId(Data: TJSONObject);
    procedure getView(id: integer; out Data: TJSONObject); overload;
    procedure getView(id, num: integer; out Data: TJSONObject); overload;
    procedure backNumber(id: integer; out Data: TJSONObject);
    procedure deleteNumber(id, num: integer);
    procedure deleteMagazine(id: integer);
    procedure postMessage(id: integer; Data: TJSONObject);
    procedure PostUser(Data: TJSONObject);
    procedure AddMagazine(id: integer; out Data: TJSONObject);
    procedure magData(id: integer; out Data: TJSONObject);
    procedure magazines(id: integer; out Data: TJSONObject);
    procedure magIdOff(id, magid: integer);
    procedure magIdOn(id, magid: integer);
    procedure custView(id: integer; out Data: TJSONObject);
    procedure custData(id: integer; data: TJSONObject);
    procedure titleView(id: integer; Data: TJSONObject);
    procedure userView(id: integer; out Data: TJSONObject);
    function magid(name: string): integer;
  end;

var
  DataModule3: TDataModule3;

implementation

uses System.Variants, System.Generics.Collections;

{ %CLASSGROUP 'Vcl.Controls.TControl' }

{$R *.dfm}

procedure TDataModule3.AddMagazine(id: integer; out Data: TJSONObject);
var
  i: integer;
  na, com: string;
begin
  FDQuery1.Open('select MAX(magId) as id from mag;');
  i := FDQuery1.FieldByName('id').AsInteger + 1;
  na := Data.Values['magName'].Value;
  com := Data.Values['comment'].Value;
  mag.AppendRecord([i, na, com, Date, Date, true]);
  magList.AppendRecord([id, i]);
end;

procedure TDataModule3.backNumber(id: integer; out Data: TJSONObject);
const
  con = 'この記事は公開制限があります.';
var
  d: TJSONObject;
  mem: TStringList;
  blob: TStream;
begin
  with FDQuery1.Params do
  begin
    Clear;
    ParamByName('id').AsInteger := id;
  end;
  Data := TJSONObject.Create;
  d := Data;
  mem := TStringList.Create;
  with FDQuery1 do
  begin
    Open('select file,enabled from news where magId = :id order by day;');
    First;
    while Eof = false do
    begin
      blob := CreateBlobStream(FieldByName('text'), bmRead);
      mem.LoadFromStream(blob);
      if FieldByName('enabled').AsBoolean = true then
        d.AddPair('text', mem.Text)
      else
        d.AddPair('text', con);
      blob.Free;
      Next;
    end;
  end;
  mem.Free;
end;

function TDataModule3.checkUserPassword(id: integer; password: string): Boolean;
begin
  result := user.Lookup('id', id, 'password') = password;
end;

procedure TDataModule3.createUserId(Data: TJSONObject);
var
  i: integer;
  na, ma, pa: string;
  d: TDateTime;
begin
  user.Last;
  i := user.FieldByName('id').AsInteger + 1;
  na := Data.ParseJSONValue('name').Value;
  pa := Data.ParseJSONValue('password').Value;
  d := StrToDate(Data.ParseJSONValue('day').Value);
  user.AppendRecord([i, na, ma, pa, d]);
end;

procedure TDataModule3.DataModuleCreate(Sender: TObject);
begin
  if FDTable1.Exists = false then
    FDTable1.CreateTable;
  if FDTable2.Exists = false then
    FDTable1.CreateTable;
  if mag.Exists = false then
    mag.CreateTable;
  if user.Exists = false then
    user.CreateTable;
  if reader.Exists = false then
    reader.CreateTable;
  if news.Exists = false then
    news.CreateTable;
  if indexTable.Exists = false then
    indexTable.CreateTable;
  if magList.Exists = false then
    magList.CreateTable;
  mag.Open;
  user.Open;
  reader.Open;
  news.Open;
  indexTable.Open;
  magList.Open;
end;

procedure TDataModule3.deleteMagazine(id: integer);
  procedure main(DB: string);
  begin
    FDQuery1.Open(Format('select * from %s where magId = :id;', [DB]));
    FDQuery1.First;
    while FDQuery1.Eof = false do
      FDQuery1.Delete;
  end;

begin
  if mag.Locate('magId', id) = true then
  begin
    mag.Delete;
    FDQuery1.Params.Clear;
    FDQuery1.Params.ParamByName('id').AsInteger := id;
    main('news');
    main('database');
    main('indexTable');
  end;
end;

procedure TDataModule3.deleteNumber(id, num: integer);
begin
  if news.Locate('magId;newsId', VarArrayOf([id, num])) = true then
    news.Delete;
end;

procedure TDataModule3.deleteUser(id: integer);
var
  i: integer;
  list: TList<integer>;
begin
  FDQuery1.Params.Clear;
  FDQuery1.Params.ParamByName('id').AsInteger := id;
  FDQuery1.Open('select * from maglist where userid = :id;');
  list := TList<integer>.Create;
  while FDQuery1.Eof = false do
  begin
    list.Add(FDQuery1.FieldByName('magid').AsInteger);
    FDQuery1.Delete;
  end;
  for i in list do
    deleteMagazine(i);
  list.Free;
end;

procedure TDataModule3.readuserData(id: integer; out Data: TJSONObject);
var
  i: Integer;
begin
  if reader.Locate('readerid', id) = true then
  begin
    Data := TJSONObject.Create;
    for i := 1 to reader.Fields.Count-1 do
      Data.AddPair(reader.Fields[i].FieldName, reader.Fields[i].AsString);
  end;
end;

procedure TDataModule3.userView(id: integer; out Data: TJSONObject);
var
  i: integer;
  list: TList<integer>;
begin
  Data := TJSONObject.Create;
  list := TList<integer>.Create;
  FDQuery1.Params.Clear;
  FDQuery1.Params.ParamByName('id').AsInteger := id;
  FDQuery1.Open('select * from indexTable where readerid = :id;');
  while FDQuery1.Eof = false do
    list.Add(FDQuery1.FieldByName('magid').AsInteger);
  for i in list do
    titleView(i, Data);
  list.Free;
end;

procedure TDataModule3.custData(id: integer; data: TJSONObject);
var
  i: Integer;
begin
  if user.Locate('userid',id) = true then
    for i := 1 to user.Fields.Count-2 do
      user.Fields[i].AsString:=data.Values[user.Fields[i].FieldName].Value;
end;

procedure TDataModule3.custView(id: integer; out Data: TJSONObject);
var
  i: integer;
  list: TList<integer>;
begin
  Data := TJSONObject.Create;
  list := TList<integer>.Create;
  FDQuery1.Params.Clear;
  FDQuery1.Params.ParamByName('id').AsInteger := id;
  FDQuery1.Open('select * from maglist where userid = :id;');
  while FDQuery1.Eof = false do
  begin
    list.Add(FDQuery1.FieldByName('magid').AsInteger);
    FDQuery1.Next;
  end;
  for i in list do
    titleView(i, Data);
  list.Free;
end;

procedure TDataModule3.getView(id, num: integer; out Data: TJSONObject);
begin
  with FDQuery1.Params do
  begin
    Clear;
    ParamByName('id').AsInteger := id;
    ParamByName('num').AsInteger := num;
  end;
  with FDQuery1.SQL do
  begin
    Clear;
    Add('select updated,day,file from news');
    Add(' where magId = :id and newsId = :num');
    Add(' order by day;');
  end;
  FDQuery1.Open;
  Data := makeTable(FDQuery1);
end;

procedure TDataModule3.getView(id: integer; out Data: TJSONObject);
begin
  FDQuery1.Params.Clear;
  FDQuery1.Params.ParamByName('id').AsInteger := id;
  with FDQuery1.SQL do
  begin
    Clear;
    Add('select updated,day,file from indexTable,news');
    Add(' where readerId = :id and indexTable.magId = news.magId');
    Add(' and enabled = true order by day;');
  end;
  FDQuery1.Open;
  Data := makeTable(FDQuery1);
end;

procedure TDataModule3.magData(id: integer; out Data: TJSONObject);
begin
  with FDQuery1.Params do
  begin
    Clear;
    ParamByName('id').AsInteger := id;
  end;
  FDQuery1.Open('select * from mag where magid = :id;');
  if FDQuery1.FieldByName('enable').AsBoolean = true then
  begin
    Data := TJSONObject.Create;
    Data.AddPair('name', FDQuery1.FieldByName('name').AsString);
    Data.AddPair('comment', FDQuery1.FieldByName('comment').AsString);
    Data.AddPair('day', FDQuery1.FieldByName('day').AsString);
    Data.AddPair('last', FDQuery1.FieldByName('lastDay').AsString);
    FDQuery1.Open('select COUNT(*) as count do mag where magid = :id;');
    Data.AddPair('count', FDQuery1.FieldByName('count').AsString);
  end;
end;

function TDataModule3.magid(name: string): integer;
begin
  result := mag.Lookup('magname', name, 'magid');
end;

procedure TDataModule3.magIdOff(id, magid: integer);
begin
  if indexTable.Locate('userId;magId', VarArrayOf([id, magid])) = true then
    indexTable.Delete;
end;

procedure TDataModule3.magIdOn(id, magid: integer);
begin
  if (user.Locate('userid', id) = true) and (mag.Locate('magid', magid) = true)
  then
    indexTable.AppendRecord([id, magid]);
end;

procedure TDataModule3.magazines(id: integer; out Data: TJSONObject);
var
  d: TJSONObject;
begin
  FDQuery1.Params.Clear;
  FDQuery1.Params.ParamByName('id').AsInteger := id;
  FDQuery1.Open('select * from maglist where userid = :id;');
  Data := TJSONObject.Create;
  while FDQuery1.Eof = false do
  begin
    magData(FDQuery1.FieldByName('magId').AsInteger, d);
    Data.AddPair('id', d);
    FDQuery1.Next;
  end;
end;

function TDataModule3.makeTable(Sender: TObject): TJSONObject;
var
  blob: TStream;
  mem: TStringList;
begin
  result := TJSONObject.Create;
  mem := TStringList.Create;
  with Sender as TFDQuery do
  begin
    First;
    while Eof = false do
    begin
      if FieldByName('updated').AsBoolean = true then
        result.AddPair('hint', Format('この記事は更新されました:(%s)日.',
          [FieldByName('day').AsString]));
      blob := CreateBlobStream(FieldByName('file'), bmRead);
      mem.LoadFromStream(blob);
      blob.Free;
      result.AddPair('text', mem.Text);
      Next;
    end;
  end;
  mem.Free;
end;

procedure TDataModule3.postMessage(id: integer; Data: TJSONObject);
var
  i: integer;
begin
  FDQuery1.Params.Clear;
  FDQuery1.Params.ParamByName('id').AsInteger := id;
  FDQuery1.Open('select MAX(newsId) as id from news where magId = :id;');
  if FDQuery1.RecordCount > 0 then
  begin
    i := FDQuery1.FieldByName('id').AsInteger + 1;
    news.AppendRecord([id, i, false, Date, Data.Values['file'], true]);
  end;
end;

procedure TDataModule3.PostUser(Data: TJSONObject);
var
  i: integer;
  na, ma, pa: string;
begin
  ma := Data.Values['mail'].Value;
  if user.Locate('mail', ma) = false then
  begin
    FDQuery1.Open('select MAX(userId) as id from user;');
    i := FDQuery1.FieldByName('id').AsInteger;
    na := Data.Values['user'].Value;
    ma := Data.Values['mail'].Value;
    pa := Data.Values['password'].Value;
    user.AppendRecord([i, na, ma, pa, Date]);
  end;
end;

procedure TDataModule3.titleView(id: integer; Data: TJSONObject);
var
  d: TJSONObject;
  i: integer;
begin
  d := Data;
  FDQuery1.Params.Clear;
  FDQuery1.Params.ParamByName('id').AsInteger := id;
  FDQuery1.Open('select * from mag where magid = :id;');
  with FDQuery1 do
    while Eof = false do
    begin
      for i := 0 to Fields.Count - 1 do
        d.AddPair(Fields[i].FieldName, Fields[i].AsString);
      Next;
    end;
end;

procedure TDataModule3.updateUserId(id: integer; Data: TJSONObject);
var
  na, ma, pa: string;
  d: TDateTime;
begin
  na := Data.ParseJSONValue('user').Value;
  ma := Data.ParseJSONValue('mail').Value;
  pa := Data.ParseJSONValue('password').Value;
  with DataModule3.user do
  begin
    FieldByName('userId').AsInteger := id;
    FieldByName('user').AsString := na;
    FieldByName('mail').AsString := ma;
    FieldByName('password').AsString := pa;
  end;
end;

end.
