with
     ada.Text_IO;


package body API
is

   function Hello_World (Text : String) return String
   is
   begin
      return "Hello, " & Text & ".";
   end Hello_World;



   procedure ping
   is
      use ada.Text_IO;
   begin
      put_Line ("API: ping called.");
   end ping;

end API;
