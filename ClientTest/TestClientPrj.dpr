program TestClientPrj;

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Classes, IdHTTP;

var
  HTTP: TIdHTTP;
  Response: string;

begin
  HTTP := TIdHTTP.Create(nil);
  try
    try
      Response := HTTP.Get('http://localhost:8090');
      Writeln('Antwort vom Server: ' + Response);
      Writeln('Enter drücken');
      Readln;
    except
      on E: Exception do
        raise Exception.Create('Fehler beim Abrufen der Antwort: ' + E.Message);
    end;
  finally
    HTTP.Free;
  end;
end.

