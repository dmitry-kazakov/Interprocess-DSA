pragma Style_Checks (Off);
--                                                                    --
--  package                         Copyright (c)  Dmitry A. Kazakov  --
--     System.RPC                                  Luebeck            --
--                                                 Spring, 2018       --
--  Interface                                                         --
--                                Last revision :  16:09 11 May 2008  --
--                                                                    --
--  This  library  is  free software; you can redistribute it and/or  --
--  modify it under the terms of the GNU General Public  License  as  --
--  published by the Free Software Foundation; either version  2  of  --
--  the License, or (at your option) any later version. This library  --
--  is distributed in the hope that it will be useful,  but  WITHOUT  --
--  ANY   WARRANTY;   without   even   the   implied   warranty   of  --
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU  --
--  General  Public  License  for  more  details.  You  should  have  --
--  received  a  copy  of  the GNU General Public License along with  --
--  this library; if not, write to  the  Free  Software  Foundation,  --
--  Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.    --
--                                                                    --
--  As a special exception, if other files instantiate generics from  --
--  this unit, or you link this unit with other files to produce  an  --
--  executable, this unit does not by  itself  cause  the  resulting  --
--  executable to be covered by the GNU General Public License. This  --
--  exception  does not however invalidate any other reasons why the  --
--  executable file might be covered by the GNU Public License.       --
--____________________________________________________________________--
--
--  This  package  provides   an   implementation   of   the   Partition
--  Communication  Subsystem as defined in Ada Reference Manual E.5. The
--  implementation  is  based on inter-process communication primitives.
--  Therefore all partitions must run on the same  system  as  different
--  processes.
--
with Ada.Streams;
with Storage_Streams;

with Synchronization.Interprocess.Process_Call_Service.Manager;

package System.RPC is
--
-- Max_Process_Count -- The maximum number of processes
--
   Max_Process_Count : constant := 4;
--
--
-- Partition_ID -- The partitions of  the system. The partition ID is
--                 the process ID.
--
   type Partition_ID is range 0..Integer'Last;
--
-- Buffer_Size -- Parameters  stream  buffer size.  When  parameters  or
--                result are copied the size of the buffer is determined
--                by this parameter.
--
   Buffer_Size : constant Ada.Streams.Stream_Element_Count := 1024;
--
-- Request_Queue_Size -- The size of the requests queue - 1
--
   Request_Queue_Size : constant Positive := 100;
--
-- Request_Stream_Size -- The size  of the buffer of shared  memory used
--                        for the inter-process parameters stream.  Each
--                        partition has a buffer of its own.
--
   Request_Stream_Size : constant Ada.Streams.
                                  Stream_Element_Count := 1024;
--
-- Response_Stream_Size -- The size of the buffer of shared  memory used
--                         for the inter-process response stream.   Each
--                         partition has a buffer of its own.
--
   Response_Stream_Size : constant Ada.Streams.
                                   Stream_Element_Count := 1024;
--
-- Shared_Name -- The name of the shared memory mapping/file
--
   Shared_Name : constant String := "system-rpc";

   Communication_Error : exception;
--
-- Params_Stream_Type -- The  stream  used  to  hold  parameters and the
--                       result of  a  remote  procedure  call.  On  the
-- caller's size the stream is backed by a storage stream.  The  storage
-- stream  block  size is definted by Initial_Size. On the callee's size
-- the stream is backed directly by an inter-process stream.
--
   type Params_Stream_Type
        (  Initial_Size : Ada.Streams.Stream_Element_Count
        )  is new Ada.Streams.Root_Stream_Type with private;

   procedure Read
             (  Stream : in out Params_Stream_Type;
                Item   : out Ada.Streams.Stream_Element_Array;
                Last   : out Ada.Streams.Stream_Element_Offset
             );
   procedure Write
             (  Stream : in out Params_Stream_Type;
                Item   : Ada.Streams.Stream_Element_Array
             );
   procedure Do_RPC
             (  Partition : Partition_ID;
                Params    : access Params_Stream_Type;
                Result    : access Params_Stream_Type
             );
   procedure Do_APC
             (  Partition : Partition_ID;
                Params    : access Params_Stream_Type
             );

   type RPC_Receiver is access procedure
        (  Params : access Params_Stream_Type;
           Result : access Params_Stream_Type
        );

   procedure Establish_RPC_Receiver
             (  Partition : Partition_ID;
                Receiver  : RPC_Receiver
             );
private
   type Stream_Ptr is access all Ada.Streams.Root_Stream_Type'Class;

   type RPC_Method is
      new Synchronization.Interprocess.Process_Call_Service.
          Abstract_Method with null record;

   procedure Execute
             (  Method     : in out RPC_Method;
                Parameters : in out Ada.Streams.Root_Stream_Type'Class;
                Results    : in out Ada.Streams.Root_Stream_Type'Class;
                Caller     : in out Synchronization.Interprocess.
                                    Process_Call_Service.
                                    Call_Service'Class;
                No         : Synchronization.Interprocess.
                             Process_Call_Service.Sequence_No
             );

--     package Partition_Arrays is
--        new Synchronization.Interprocess.Process_Call_Service.
--            Generic_Call_Service_Arrays
--            (  Process_ID           => Partition_ID,
--               Request_Queue_Size   => Request_Queue_Size,
--               Request_Stream_Size  => Request_Stream_Size,
--               Response_Stream_Size => Response_Stream_Size
--            );

   type RPC_Manager is
      new Synchronization.Interprocess.Process_Call_Service.Manager.
          Call_Service_Manager
          (  Size                 => Max_Process_Count,
             Request_Queue_Size   => Request_Queue_Size,
             Request_Stream_Size  => Request_Stream_Size,
             Response_Stream_Size => Response_Stream_Size
          )  with null record;

   type RPC_Service is
      new Synchronization.Interprocess.Abstract_Shared_Environment with
   record
      Handler : RPC_Receiver;
      Method  : RPC_Method;
      Service : RPC_Manager;
   end record;
   type Root_Stream_Ptr is access
      all Ada.Streams.Root_Stream_Type'Class;
   type Params_Stream_Type
        (  Initial_Size : Ada.Streams.Stream_Element_Count
        )  is new Ada.Streams.Root_Stream_Type with
   record
      Default  : Storage_Streams.Storage_Stream (Initial_Size);
      External : Root_Stream_Ptr;
   end record;

   pragma Inline (Read);
   pragma Inline (Write);

end System.RPC;
