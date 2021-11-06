with Interfaces; use Interfaces;
with BRBON.Types; use BRBON.Types;


-- Contains methods to convert types into a stream of bytes.
--
package Serializable is


   -- A serializable returns bytes and True as long as a valid byte is supplied.
   -- When no valid byte can be supplied it returns False.
   -- Once False is returned it will not be called again.
   --
   type Instance is private;

   -- Copies the next byte from this instance into the out parameter.
   -- Returns true if a copy was made, false if not.
   -- Note that after returning false once this instance is no longer usable.
   -- @parameter Source The Serializable.Instance
   -- @parameter Byte The location where the next byte should be copied to.
   -- @retuns True if a byte was copied, false if not (and the instance is exhausted).
   --
   function Copy_Next_Byte (Source: in out Instance; Byte: out Unsigned_8) return Boolean;


   -- Creates a new Serializable.Instanceby copying all the bytes from the given string.
   -- @parameter Copy_Bytes_From The string from which the bytes will be copied.
   -- @returns The new instance.
   --
   function New_Instance (Copy_Bytes_From: String) return Instance;

   -- Creates a new Serializable.Instanceby copying all the bytes from the given array.
   -- @parameter Copy_Bytes_From The array from which the bytes will be copied.
   -- @returns The new instance.
   --
   function New_Instance (Copy_Bytes_From: Array_Of_Unsigned_8) return Instance;


private


   type Instance is
      record
         Base_Ptr: Array_Of_Unsigned_8_Ptr;
         Remaining: Unsigned_32;
      end record;


end Serializable;
