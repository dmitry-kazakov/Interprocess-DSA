with API;  --  To execute elaboration code of API
pragma Unreferenced (API);

with Ada.Streams;
with Ada.Text_IO;
with Ada.Characters.Latin_1;

with Interfaces;

with System.Partition_Interface;
with System.RPC;
with System.Storage_Elements;

with DSA_Sockets;


procedure Server
--
--  Here we execute "server task", that reads communication channel and
--  drives DSA to execute requests. In a real system this task belongs
--  to DSA implementation and launched via elaboration code, while user's
--  main subprogram works on users defined code.
--
is
   use ada.Text_IO,
       DSA_Sockets;


   DSA_Socket : aliased DSA_Sockets.Master;



   procedure log (Message : in String := "") renames ada.Text_IO.Put_Line;




   procedure DSA_Socket_put_Line (Message : in String)
   is
   begin
      String'Output (DSA_Socket.Stream_out,
                     Message & Ada.Characters.Latin_1.LF);
   end DSA_Socket_put_Line;



   function DSA_Socket_get_Line return String
   is
      Result : String (1 .. 1024);
      Last   : Natural := 0;
      C      : Character;
   begin
      loop
         C := Character'Input (DSA_Socket.Stream_in);

         exit when C = Ada.Characters.Latin_1.LF;

         Last := Last + 1;
         Result (Last) := C;
      end loop;

      return Result (1 .. Last);
   end DSA_Socket_get_Line;



   procedure Read_Stream (Stream : in out System.RPC.Params_Stream_Type);
   procedure Dump_Stream (Stream : in out System.RPC.Params_Stream_Type);



   -----------------
   -- Read_Stream --
   -----------------

   procedure Read_Stream (Stream : in out System.RPC.Params_Stream_Type)
   is
      use type Ada.Streams.Stream_Element;

      Item  : Ada.Streams.Stream_Element := 0;
      Next  : Character := ' ';
      First : Boolean := True;

   begin
      while Next /= '.'
      loop
         Next := Character'Input (DSA_Socket.Stream_in);
         put (Next);                                           -- Debug info.

         if Next in   '0' .. '9'
                    | 'a' .. 'f'
         then
            Item :=   Item * 16
                    + Character'Pos (Next)
                    + (if Next in '0' .. '9' then     -Character'Pos ('0')
                                             else 10 - Character'Pos ('a'));
            if not First
            then
               System.RPC.Write (Stream, (1 => Item));
            end if;

            First := not First;
         end if;

      end loop;
   end Read_Stream;



   -----------------
   -- Dump_Stream --
   -----------------

   procedure Dump_Stream (Stream : in out System.RPC.Params_Stream_Type)
   is
      use type Ada.Streams.Stream_Element;
      use type Ada.Streams.Stream_Element_Offset;

      Image : constant array (Ada.Streams.Stream_Element range 0 .. 15) of Character := ("0123456789abcdef");

      function Hex (Item : Ada.Streams.Stream_Element) return String
      is
        (  Image (Item /   16)
         & Image (Item mod 16));

      Buffer : Ada.Streams.Stream_Element_Array (1 .. 10);
      Last   : Ada.Streams.Stream_Element_Offset;

   begin
      loop
         Stream.Read (Buffer, Last);
         exit when Last < Buffer'First;

         for Item of Buffer (1 .. Last)
         loop
            String'Output (DSA_Socket.Stream_out,
                           Hex (Item));
            put (Hex (Item));                       -- Debug info.
         end loop;

      end loop;

      DSA_Socket_put_Line (".");
      put (".");                                    -- Debug info.
   end Dump_Stream;


begin
   Create (DSA_Socket, Name => "DSA_Socket");


   for i in 1 .. 2     -- Only serve 2 requests, for testing.
   loop
      new_Line (3);
      log ("i =" & i'Image);

      declare
         Ignore : String := DSA_Socket_get_Line;                  -- Skip "Do_RPC. Partition: X" debug data.
         Dummy  : String := "Params: ";
      begin
         Dummy := String'Input (DSA_Socket.Stream_in);     -- Skip "Params: " debug data.

         log ("Ignore '" & Ignore & "'");                  -- Debug info.
         log ("Dummy  '" & Dummy  & "'");                  -- Debug info.
      end;


      declare
         Ignore :          Interfaces.Unsigned_64;
         Params : aliased  System.RPC.Params_Stream_Type (0);
         Result : aliased  System.RPC.Params_Stream_Type (0);

         Int    : constant Interfaces.Unsigned_64           := System.Partition_Interface.Get_RCI_Package_Receiver ("API");     -- Hard-coded API receiver.
         Addr   : constant System.Address                   := System.Storage_Elements.To_Address (System.Storage_Elements.Integer_Address (Int));

         procedure Receiver (R : System.Partition_Interface.Request_Access)
           with Import,
                Address => Addr;
      begin
         log ("Server: reading parameter stream.");        -- Debug info.
         Read_Stream (Params);
         new_Line (2);

         Interfaces.Unsigned_64'Read (Params'Access,
                                      Ignore);
         --
         --  Read and ignore RCI_Package_Receiver address, because we use
         --  hardcoded API receiver in this demo. In a real system it should
         --  be used (to find???) as Receiver address.

         Receiver (R => (Params => Params'Unchecked_Access,
                         Result => Result'Unchecked_Access));

         new_Line;
         log ("Server: writing result stream.");           -- Debug info.

         String'Output (DSA_Socket.Stream_out,
                        "Result: ");
         Dump_Stream (Result);
      end;

   end loop;


   delay 2.0;

   new_Line (2);
   log ("... Done.");
end Server;
