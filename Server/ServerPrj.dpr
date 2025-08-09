program ServerPrj;

{$APPTYPE CONSOLE}

uses
  Server in 'Server.pas';

var
  Server: TMCPServer;

begin
  Server := TMCPServer.Create;
  try
    Server.Start;
  finally
    Server.Free;
  end;
end.

