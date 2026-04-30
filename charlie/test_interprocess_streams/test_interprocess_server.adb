--  This is a test procedure for interprocess synchronization
--
with Ada.Command_Line;         use Ada.Command_Line;
with Ada.Exceptions;           use Ada.Exceptions;
with Ada.Characters.Handling;  use Ada.Characters.Handling;
with Ada.Text_IO;              use Ada.Text_IO;
with System.Storage_Elements;  use System.Storage_Elements;
with Test_Interprocess_Data;   use Test_Interprocess_Data;

with Synchronization.Interprocess.Events;
use  Synchronization.Interprocess.Events;


with Synchronization.Interprocess.Mutexes;
use  Synchronization.Interprocess.Mutexes;

with Synchronization.Interprocess.Pulse_Events;
use  Synchronization.Interprocess.Pulse_Events;

with Synchronization.Interprocess.Streams;
use  Synchronization.Interprocess.Streams;

with Ada.Unchecked_Deallocation;
with System.Address_To_Access_Conversions;
with Synchronization.Interprocess.Memory_Pools;
--with System.Exception_Traces;

procedure Test_Interprocess_Server
is
   use Shared_Integer;
   use Shared_Integer_Queue;
   Name   : constant String := "sync_test";
   Master : Boolean;

   package Y_Of is
     new System.Address_To_Access_Conversions (Integer);

   procedure Put_Pool_Statistics
     (  Pool : Synchronization.Interprocess.Memory_Pools.
          Interprocess_Pool;
        Text : String
       )  is
      use Synchronization.Interprocess.Memory_Pools;
      Free_Blocks : Natural;
      Used_Blocks : Natural;
      Free_Space  : Storage_Count;
      Used_Space  : Storage_Count;
   begin
      Get_Statistics
        (  Pool        => Pool,
           Free_Blocks => Free_Blocks,
           Used_Blocks => Used_Blocks,
           Free_Space  => Free_Space,
           Used_Space  => Used_Space
          );
      Put_Line (Text);
      Put_Line ("   Free blocks:" & Integer'Image (Free_Blocks));
      Put_Line ("   Used blocks:" & Integer'Image (Used_Blocks));
      Put_Line ("   Free space: " & Storage_Count'Image (Free_Space));
      Put_Line ("   Used_Space: " & Storage_Count'Image (Used_Space));
   end Put_Pool_Statistics;
begin
   --     System.Exception_Traces.Trace_On
   --     (  System.Exception_Traces.Every_Raise
   --     );
   Put_Line ("Testing Server interprocess synchronization ...");
   declare
      Data : Shared_Data_Master;

      --  type String_Ptr is access all String;
      --  for String_Ptr'Storage_Pool use Data.Pool;
      --  type Integer_Ptr is access all Integer;
      --  for Integer_Ptr'Storage_Pool use Data.Pool;
      --  procedure Free is
      --    new Ada.Unchecked_Deallocation (String, String_Ptr);
   begin
      Create (Data, Name);
      Put_Line
        (  "Shared size"
           &  Storage_Count'Image (Get_Size (Data))
          );
      Put_Line ("Writing stream");

      declare
         File   : File_Type;
         Buffer : String (1..2048);
         Last   : Integer;
      begin
         Open
           (  File,
              In_File,
              "test_interprocess_server.adb"
             );
         loop
            Get_Line (File, Buffer, Last);
            String'Output (Data.Stream'Access, Buffer (1..Last));
            --     String'Output (Data.Stream'Access, "Hello, world.");
         end loop;
      exception
         when End_Error =>
            Close (File);
            Close (Data.Stream);
      end;
   end;
   Put_Line ("... Done");
exception
   when Error : others =>
      Put_Line ("Error: " & Exception_Information (Error));
end Test_Interprocess_Server;
