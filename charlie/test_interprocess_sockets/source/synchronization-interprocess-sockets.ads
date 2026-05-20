with Synchronization.Interprocess.Events;

with Synchronization.Interprocess.Streams;
use  Synchronization.Interprocess.Streams;



generic
   Master_Stream_out_Size : in Stream_Element_Count := 1025;
   Master_Stream_in_Size  : in Stream_Element_Count := 1025;

package Synchronization.Interprocess.Sockets
is

   ----------
   --- Socket
   --

   type Socket is abstract new Abstract_Shared_Environment with private;

   function Name (of_Socket : in Socket) return String;


   function Stream_in  (From : access Socket) return access  Input_Stream is abstract;
   function Stream_out (To   : access Socket) return access Output_Stream is abstract;


   generic
      type Data_Type (<>) is private;

   function any_Input (From : in out Socket'Class) return Data_Type;


   generic
      type Data_Type (<>) is private;

   procedure any_Output (To : in out Socket'Class;   Data : in Data_Type);



   ----------
   --- Master
   --

   type Master is new Socket with private;

   function Stream_in  (From : access Master) return access  Input_Stream;
   function Stream_out (To   : access Master) return access Output_Stream;



   ---------
   --- Slave
   --

   type Slave is new Socket with private;

   function Stream_in  (From : access Slave) return access  Input_Stream;
   function Stream_out (To   : access Slave) return access Output_Stream;



private

   use Synchronization.Interprocess.Events;


   type Socket is abstract new Abstract_Shared_Environment with null record;



   ----------
   --- Master
   --

   type Master is new Socket
     with
      record
         Not_Full_Event_out  : Event;
         Not_Empty_Event_out : Event;
         Stream_out          : aliased Output_Stream (Master_Stream_out_Size);

         Not_Full_Event_in  : Event;
         Not_Empty_Event_in : Event;
         Stream_in          : aliased Input_Stream (Master_Stream_in_Size);
      end record;



   ----------
   --- Slave
   --

   type Slave is new Socket
     with
      record
         Not_Full_Event_in  : Event;
         Not_Empty_Event_in : Event;
         Stream_in          : aliased Input_Stream (Master_Stream_out_Size);

         Not_Full_Event_out  : Event;
         Not_Empty_Event_out : Event;
         Stream_out          : aliased Output_Stream (Master_Stream_in_Size);
      end record;


end Synchronization.Interprocess.Sockets;
