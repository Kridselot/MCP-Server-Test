unit Server;

interface

uses
  System.SysUtils, System.Classes
  , System.JSON, Rest.Types
  , IdHTTPServer, IdCustomHTTPServer, IdContext, IdSocketHandle;

type
  TMCPServer = class
  private
    FServer: TIdHTTPServer;
    procedure HandleRequest(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    function ProcessToolCall(const aJSON: TJSONObject): string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Start;
  end;

implementation
{ TMCPServer }

constructor TMCPServer.Create;
var
  Binding: TIdSocketHandle;
begin
  FServer := TIdHTTPServer.Create(nil);
  FServer.DefaultPort := 8090;

  // Bindung only local 127.0.0.1
  FServer.Bindings.Clear;
  Binding := FServer.Bindings.Add;
  Binding.IP := '127.0.0.1';
  Binding.Port := FServer.DefaultPort;

  FServer.OnCommandGet := HandleRequest;
end;

destructor TMCPServer.Destroy;
begin
  FServer.Free;
  inherited;
end;

procedure TMCPServer.HandleRequest(AContext: TIdContext; ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
var
  JSON: TJSONObject;
  ResponseText: string;
begin
  try
    JSON := TJSONObject.ParseJSONValue(ARequestInfo.te ContentText) as TJSONObject;
    if Assigned(JSON) then
    begin
      ResponseText := ProcessToolCall(JSON);
      AResponseInfo.ContentType := CONTENTTYPE_APPLICATION_JSON;
      AResponseInfo.ContentText := ResponseText;
    end
    else
      raise Exception.Create('Ungültige JSON-Anfrage');
  except
    on E: Exception do
    begin
      AResponseInfo.ResponseNo := 400;
      AResponseInfo.ContentText := '{"error": "' + E.Message + '"}';
    end;
  end;

end;

function TMCPServer.ProcessToolCall(const aJSON: TJSONObject): string;
const
  csToolCall = 'tool_call';
  csParameters = 'parameters';
var
  sToolCall, sName: string;
  hParams: TJSONObject;
  hResponse: TJSONObject;
begin
  ToolCall := JSON.GetValue<string>(csToolCall);
  Params := JSON.GetValue<TJSONObject>(csParameters);
  Response := TJSONObject.Create;

  if ToolCall = 'say_hello' then
  begin
    Name := '';
    if Assigned(Params) then
      Name := Params.GetValue<string>('name');
    Response.AddPair('response', 'Hallo ' + Name + '!');
  end
  else if ToolCall = 'get_server_info' then
  begin
    Response.AddPair('name', 'Hello MCP Server');
    Response.AddPair('version', '0.1');
    Response.AddPair('description', 'Ein einfacher MCP-Testserver in Delphi');
  end
  else
    raise Exception.Create('Unbekannter tool_call: ' + ToolCall);

  Result := Response.ToJSON;
end;

procedure TMCPServer.Start;
begin
  FServer.Active := True;
  Writeln('MCP Server läuft auf Port ', FServer.DefaultPort, '...');
  Writeln('Zum beenden Enter drücken');
  Readln;
  FServer.Active := False;
end;

end.
