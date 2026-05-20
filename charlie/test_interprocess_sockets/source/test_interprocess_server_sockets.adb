--  This is a test procedure for interprocess sockets (server-side).
--

with Ada.Exceptions;           use Ada.Exceptions;
with Ada.Text_IO;              use Ada.Text_IO;
with System.Storage_Elements;  use System.Storage_Elements;

with Synchronization.Interprocess.Sockets.IO;


procedure Test_Interprocess_Server_Sockets
is
   package Sockets    is new Synchronization.Interprocess.Sockets;
   package Sockets_IO is new Sockets.IO;

begin
   Put_Line ("Testing Server interprocess sockets ...");

   declare
      use Sockets,
          Sockets_IO;

      Socket_1 : aliased Sockets.Master;
      Socket_2 : aliased Sockets.Master;

   begin
      Create (Socket_1, Name => "Socket_1");
      Create (Socket_2, Name => "Socket_2");

      put_Line ("Shared size" & Storage_Count'Image (Get_Size (Socket_1)));


      String'Output (Socket_1.Stream_out, "'Hello, world' from Server using '" & Socket_1.Name & "'.");
      Output (To   => Socket_2,
              Data => "'Hello, world' from Server using '" & Socket_2.Name & "'.");


      put_Line (String'Input (Socket_1.Stream_in));
      put_Line (Input (Socket_2));
   end;

   Put_Line ("... Done");


exception
   when Error : others =>
      Put_Line ("Error: " & Exception_Information (Error));
end Test_Interprocess_Server_Sockets;
