package API
is
   pragma Remote_Call_Interface;


   function  Hello_World (Text : String) return String;
   procedure ping;

end API;
