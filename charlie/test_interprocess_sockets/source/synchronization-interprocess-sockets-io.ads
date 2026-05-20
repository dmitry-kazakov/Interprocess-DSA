generic
package Synchronization.Interprocess.Sockets.IO
is

   function  Input  is new Sockets.any_Input  (Boolean);
   procedure Output is new Sockets.any_Output (Boolean);

   function  Input  is new Sockets.any_Input  (Integer);
   procedure Output is new Sockets.any_Output (Integer);

   function  Input  is new Sockets.any_Input  (Short_Short_Integer);
   procedure Output is new Sockets.any_Output (Short_Short_Integer);

   function  Input  is new Sockets.any_Input  (Short_Integer);
   procedure Output is new Sockets.any_Output (Short_Integer);

   function  Input  is new Sockets.any_Input  (Long_Integer);
   procedure Output is new Sockets.any_Output (Long_Integer);

   function  Input  is new Sockets.any_Input  (Long_Long_Integer);
   procedure Output is new Sockets.any_Output (Long_Long_Integer);

   function  Input  is new Sockets.any_Input  (Long_Long_Long_Integer);
   procedure Output is new Sockets.any_Output (Long_Long_Long_Integer);

   function  Input  is new Sockets.any_Input  (Short_Float);
   procedure Output is new Sockets.any_Output (Short_Float);

   function  Input  is new Sockets.any_Input  (Float);
   procedure Output is new Sockets.any_Output (Float);

   function  Input  is new Sockets.any_Input  (Long_Float);
   procedure Output is new Sockets.any_Output (Long_Float);

   function  Input  is new Sockets.any_Input  (Long_Long_Float);
   procedure Output is new Sockets.any_Output (Long_Long_Float);

   function  Input  is new Sockets.any_Input  (Character);
   procedure Output is new Sockets.any_Output (Character);

   function  Input  is new Sockets.any_Input  (Wide_Character);
   procedure Output is new Sockets.any_Output (Wide_Character);

   function  Input  is new Sockets.any_Input  (Wide_Wide_Character);
   procedure Output is new Sockets.any_Output (Wide_Wide_Character);

   function  Input  is new Sockets.any_Input  (String);
   procedure Output is new Sockets.any_Output (String);

   function  Input  is new Sockets.any_Input  (Wide_String);
   procedure Output is new Sockets.any_Output (Wide_String);

   function  Input  is new Sockets.any_Input  (Wide_Wide_String);
   procedure Output is new Sockets.any_Output (Wide_Wide_String);

   function  Input  is new Sockets.any_Input  (Duration);
   procedure Output is new Sockets.any_Output (Duration);


end Synchronization.Interprocess.Sockets.IO;
