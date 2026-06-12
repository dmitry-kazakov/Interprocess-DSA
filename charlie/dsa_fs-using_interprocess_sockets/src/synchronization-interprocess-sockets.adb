package body Synchronization.Interprocess.Sockets
is

   ----------
   --- Socket
   --

   function Name (of_Socket : in Socket) return String
   is
   begin
      return Value (of_Socket.Name);
   end Name;



   function any_Input (From : in out Socket'Class) return Data_Type
   is
   begin
      return Data_Type'Input (From.Stream_in);
   end any_Input;



   procedure any_Output (To : in out Socket'Class;   Data : in Data_Type)
   is
   begin
      Data_Type'Output (To.Stream_out, Data);
   end any_Output;



   -----------
   --- Actuals
   --

   package body Actuals
   is

      ----------
      --- Master
      --

      function Stream_in (From : access Master) return access Input_Stream
      is
      begin
         return From.Stream_in'Access;
      end Stream_in;



      function Stream_out (To : access Master) return access Output_Stream
      is
      begin
         return To.Stream_out'Access;
      end Stream_out;




      ---------
      --- Slave
      --

      function Stream_in (From : access Slave) return access Input_Stream
      is
      begin
         return From.Stream_in'Access;
      end Stream_in;



      function Stream_out (To : access Slave) return access Output_Stream
      is
      begin
         return To.Stream_out'Access;
      end Stream_out;


   end Actuals;


end Synchronization.Interprocess.Sockets;
