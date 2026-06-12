with Ada.Text_IO;

with API;
with System.RPC;


procedure Client
is
   procedure log (Message : in String := "") renames ada.Text_IO.Put_Line;

begin
   System.RPC.open_Socket;


   log;
   log ("Calling 'API.Hello_World' remote function ...");

   declare
      Text  : constant String := API.Hello_World ("Charlie");
   begin
      log ("Reply is '" & Text & "'");
   end;


   log;
   log;
   log ("Calling 'API.ping' remote procedure ...");

   API.ping;
   delay 1.0;


   log;
   log ("... Done.");
end Client;
