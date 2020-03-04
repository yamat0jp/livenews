unit Unit4;

interface

uses
  MVCFramework, MVCFramework.Commons;

type

  [MVCPath('/')]
  TTopController = class(TMVCController)
  public
    [MVCPath('/top')]
    [MVCHTTPMethod([httpGET])]
    procedure Index;

  end;

implementation

uses
  System.SysUtils, MVCFramework.Logger, System.StrUtils, System.Classes, Unit3;

 { TTopController }

procedure TTopController.Index;
var
  s: TMemoryStream;
begin
  // use Context property to access to the HTTP request and response
  s:=TMemoryStream.Create;
  s.LoadFromFile('..\..\templates\index.html');
  Render(s);
end;

end.
