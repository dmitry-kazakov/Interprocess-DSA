pragma Style_Checks (Off);
--                                                                    --
--  package                         Copyright (c)  Dmitry A. Kazakov  --
--     System.RPC                                  Luebeck            --
--                                                 Spring, 2018       --
--  Implementation                                                    --
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

with Ada.Exceptions;  use Ada.Exceptions;

with Generic_Map;

package body System.RPC is
   use Ada.Streams;
   use Storage_Streams;
   use Synchronization.Interprocess.Process_Call_Service;

   package Partition_ID_Maps is
      new Generic_Map (Partition_ID, Call_Service_Ptr);
   use Partition_ID_Maps;

   Partition_To_Service : Partition_ID_Maps.Map;

   Shared : RPC_Service;

   procedure Do_RPC
             (  Partition : Partition_ID;
                Params    : access Params_Stream_Type;
                Result    : access Params_Stream_Type
             )  is
      procedure Receive_Results
                (  Stream : in out Root_Stream_Type'Class
                )  is
         Buffer : Stream_Element_Array (1..Buffer_Size);
         Last   : Stream_Element_Offset;
      begin
         loop
            Read (Stream, Buffer, Last);
            exit when Last < Buffer'First;
            Write (Result.all, Buffer (1..Last));
         end loop;
      end Receive_Results;

      procedure Send_Parameters
                (  Stream : in out Root_Stream_Type'Class
                )  is
         Buffer : Stream_Element_Array (1..Buffer_Size);
         Last   : Stream_Element_Offset;
      begin
         loop
            Read (Params.all, Buffer, Last);
            exit when Last < Buffer'First;
            Write (Stream, Buffer (1..Last));
         end loop;
      end Send_Parameters;

      procedure Call is new Generic_Procedure_Call;
   begin
      Call
      (  Method  => Shared.Method,
         Callee  => Get (Partition_To_Service, Partition).all,
         Timeout => Duration'Last
      );
   exception
      when Error : others =>
         Raise_Exception
         (  Communication_Error'Identity,
            Exception_Message (Error)
         );
   end Do_RPC;

   procedure Do_APC
             (  Partition : Partition_ID;
                Params    : access Params_Stream_Type
             )  is
      procedure Send_Parameters
                (  Stream : in out Root_Stream_Type'Class
                )  is
         Buffer : Stream_Element_Array (1..Buffer_Size);
         Last   : Stream_Element_Offset;
      begin
         loop
            Read (Params.all, Buffer, Last);
            exit when Last < Buffer'First;
            Write (Stream, Buffer (1..Last));
         end loop;
      end Send_Parameters;

      procedure Post is new Generic_Post;
   begin
      Post
      (  Method  => Shared.Method,
         Callee  => Get (Partition_To_Service, Partition).all,
         Timeout => Duration'Last
      );
   exception
      when Error : others =>
         Raise_Exception
         (  Communication_Error'Identity,
            Exception_Message (Error)
         );
   end Do_APC;

   procedure Execute
             (  Method     : in out RPC_Method;
                Parameters : in out Root_Stream_Type'Class;
                Results    : in out Root_Stream_Type'Class;
                Caller     : in out Call_Service'Class;
                No         : Sequence_No
             )  is
      Parameters_Stream : aliased Params_Stream_Type (1);
      Results_Stream    : aliased Params_Stream_Type (1);
   begin
      Parameters_Stream.External := Parameters'Unchecked_Access;
      Results_Stream.External    := Results'Unchecked_Access;
      Shared.Handler
      (  Params => Parameters_Stream'Unchecked_Access,
         Result => Results_Stream'Unchecked_Access
      );
   end Execute;

   procedure Establish_RPC_Receiver
             (  Partition : Partition_ID;
                Receiver  : RPC_Receiver
             )  is
   begin
      Shared.Handler := Receiver;
      Add
      (  Partition_To_Service,
         Partition,
         Get_Service (Shared.Service, Call_Service_ID (Partition))
      );
      Set_Server (Get (Partition_To_Service, Partition).all);
      Open (Shared, Shared_Name, True);
   end Establish_RPC_Receiver;

   procedure Read
             (  Stream : in out Params_Stream_Type;
                Item   : out Stream_Element_Array;
                Last   : out Stream_Element_Offset
             )  is
   begin
      if Stream.External = null then
         Read (Stream.Default, Item, Last);
      else
         Read (Stream.External.all, Item, Last);
      end if;
   end Read;

   procedure Write
             (  Stream : in out Params_Stream_Type;
                Item   : Stream_Element_Array
             )  is
   begin
      if Stream.External = null then
         Write (Stream.Default, Item);
      else
         Write (Stream.External.all, Item);
      end if;
   end Write;

end System.RPC;
