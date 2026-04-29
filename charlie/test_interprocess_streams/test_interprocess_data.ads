with Synchronization.Interprocess;  use Synchronization.Interprocess;

with Synchronization.Interprocess.Events;
use  Synchronization.Interprocess.Events;

with Synchronization.Interprocess.Memory_Pools;
use  Synchronization.Interprocess.Memory_Pools;

with Synchronization.Interprocess.Mutexes;
use  Synchronization.Interprocess.Mutexes;

with Synchronization.Interprocess.Pulse_Events;
use  Synchronization.Interprocess.Pulse_Events;

with Synchronization.Interprocess.Streams;
use  Synchronization.Interprocess.Streams;

with Synchronization.Interprocess.Generic_Blackboard;
with Synchronization.Interprocess.Generic_FIFO;
with Synchronization.Interprocess.Generic_Shared_Object;

package Test_Interprocess_Data is

   package Shared_Integer is
      new Synchronization.Interprocess.
          Generic_Shared_Object (Integer);
   package Shared_Reference is
      new Synchronization.Interprocess.
          Generic_Shared_Object (Reference);

   package Shared_Integer_Queue is
      new Synchronization.Interprocess.Generic_FIFO (Integer);

   package Test_Boards is
      new Synchronization.Interprocess.Generic_Blackboard (String);

   type Shared_Data_Master is
      new Abstract_Shared_Environment with record
      --  Event_1         : Event;
      --  Event_2         : Pulse_Event;
      --  Mutex_1         : Mutex;
      --  Int_1           : Shared_Integer.Shared_Object;
      --  Reference_1     : Shared_Reference.Shared_Object;
      Not_Full_Event  : Event;
      Not_Empty_Event : Event;
      Queue           : Shared_Integer_Queue.FIFO_In (10);        -- Required else crash but not directly used.
      Stream          : aliased Output_Stream (11);
      --  Pool            : Interprocess_Pool (400);
      --  Board           : Test_Boards.Blackboard (1_000);
   end record;

   type Shared_Data_Slave is
      new Abstract_Shared_Environment with record
      --  Event_1         : Event;
      --  Event_2         : Pulse_Event;
      --  Mutex_1         : Mutex;
      --  Int_1           : Shared_Integer.Shared_Object;
      --  Reference_1     : Shared_Reference.Shared_Object;
      Not_Full_Event  : Event;
      Not_Empty_Event : Event;
      Queue           : Shared_Integer_Queue.FIFO_Out (10);       -- Required else crash but not directly used.
      Stream          : aliased Input_Stream (11);
      --  Pool            : Interprocess_Pool (400);
      --  Board           : Test_Boards.Blackboard (1_000);
   end record;

end Test_Interprocess_Data;
