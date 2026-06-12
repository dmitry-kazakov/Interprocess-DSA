with Ada.Streams;

package System.RPC
is

   procedure open_Socket;

   type Partition_ID is range 0 .. Integer'Last;

   Communication_Error : exception;

   type Params_Stream_Type
     (Initial_Size : Ada.Streams.Stream_Element_Count) is new
       Ada.Streams.Root_Stream_Type with private;

   overriding procedure Read
     (Stream : in out Params_Stream_Type;
      Item   : out Ada.Streams.Stream_Element_Array;
      Last   : out Ada.Streams.Stream_Element_Offset);

   overriding procedure Write
     (Stream : in out Params_Stream_Type;
      Item   : Ada.Streams.Stream_Element_Array);

   --  Synchronous call.

   procedure Do_RPC
     (Partition  : Partition_ID;
      Params     : access Params_Stream_Type;
      Result     : access Params_Stream_Type);

   --  Asynchronous call.

   procedure Do_APC
     (Partition  : Partition_ID;
      Params     : access Params_Stream_Type);

   --  The handler for incoming RPCs.

   type RPC_Receiver is
     access procedure
       (Params     : access Params_Stream_Type;
        Result     : access Params_Stream_Type);

   procedure Establish_RPC_Receiver
     (Partition : Partition_ID;
      Receiver  : RPC_Receiver);

private

   type Params_Stream_Type
     (Initial_Size : Ada.Streams.Stream_Element_Count) is new
       Ada.Streams.Root_Stream_Type with
      record
         Buffer : Ada.Streams.Stream_Element_Array (1 .. 512);
         From   : Ada.Streams.Stream_Element_Offset := 1;
         To     : Ada.Streams.Stream_Element_Offset := 0;
      end record;

end System.RPC;
