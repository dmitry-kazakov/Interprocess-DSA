--                                                                    --
--  procedure                       Copyright (c)  Dmitry A. Kazakov  --
--     Test_DSA_Client                             Luebeck            --
--                                                 Spring, 2018       --
--                                                                    --
--                                Last revision :  23:22 29 Sep 2017  --
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

with Ada.Exceptions;             use Ada.Exceptions;
with Ada.Text_IO;                use Ada.Text_IO;
with Test_DSA_Server_Interface;  use Test_DSA_Server_Interface;

procedure Test_DSA_Client is
begin
   Increment_Count;
   Put_Line ("Count:" & Integer'Image (Get_Count));
   Publish ("Message 1");
   Publish ("Message 2");
exception
   when Error : others =>
      Put_Line ("Error: " & Exception_Information (Error));
end Test_DSA_Client;
