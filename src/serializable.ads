with Interfaces; use Interfaces;
with BRBON.Types; use BRBON.Types;


-- Contains methods to convert types into a stream of bytes.
--
package Serializable is


   -- A serializable returns bytes and True as long as a valid byte is supplied.
   -- When no valid byte can be supplied it returns False.
   -- Once False is returned it will not be called again.
   --
   type Instance is tagged private;


   -- Creates a new Serializable.Instanceby copying all the bytes from the given string.
   -- @parameter Copy_Bytes_From The string from which the bytes will be copied.
   -- @returns The new instance.
   --
   function Create_With_Copy (Copy_Bytes_From: String) return Instance;


   -- Creates a new Serializable.Instanceby copying all the bytes from the given array.
   -- @parameter Copy_Bytes_From The array from which the bytes will be copied.
   -- @returns The new instance.
   --
   function Create_With_Copy (Copy_Bytes_From: Array_Of_Unsigned_8) return Instance;


   -- Creates a new Serializable.Instance by referring to the bytes at the given location and length.
   --
   -- Note: The callee must guarantee that the bytes are available during the existence of the instance.
   --
   -- @parameter Use_In_Place A pointer to the array from which to return a series of bytes.
   -- @parameter First The index of the first byte to be returned. First must be <= Last.
   -- @parameter Last The index of the last byte to be returned. Last must be >= First.
   -- @returns The new instance
   --
   function Create_Without_Copy (Use_In_Place: Array_Of_Unsigned_8_Ptr; First: Unsigned_32; Last: Unsigned_32) return Instance;


   -- Copies the next byte from this instance into the out parameter.
   -- Returns true if a copy was made, false if not.
   -- Note that after returning false once this instance is no longer usable.
   -- @parameter Source The Serializable.Instance
   -- @parameter Byte The location where the next byte should be copied to.
   -- @retuns True if a byte was copied, false if not (and the instance is exhausted).
   --
   function Copy_Next_Byte (Source: in out Instance; Byte: out Unsigned_8) return Boolean;


   -- Returns true if the instance is empty.
   --
   function Is_Empty (Source: in out Instance) return Boolean;
   pragma Inline (Is_Empty);


   -- Returns the number of bytes left in the instance.
   --
   function Remaining_Bytes (Source: in out Instance) return Integer;
   pragma Inline (Remaining_Bytes);


   -- Returns the index of the last byte that was read.
   -- This function only returns a valid result after the first read.
   -- It raises the constraint_error exception when called before the first byte is read.
   --
   function Index_Of_Last_Byte (Source: in out Instance) return Unsigned_32;


   -- Compares a serializable (starting at the cursor) to a given array.
   -- The serializable will be updated for the number of examined bytes.
   -- If the operation returns False and the Remaining_Bytes is not zero
   -- then the Remaining_Bytes may be used to calculate which byte caused the fail using:
   --    (Index_Of_Failed_Byte := Source'Last - Source.Remaining_Bytes)
   -- If the operation returns True then the serializable has zero Remaining_Bytes.
   --
   function Compare (Source: in out Instance; Expected_Values: Array_Of_Unsigned_8) return Boolean;

   -- Compares a serializable (starting at the cursor) to a given array, ignoring bytes that have their 'Dont_Care' flag set.
   -- The serializable will be updated for the number of examined bytes.
   -- If the operation returns False and the Remaining_Bytes is not zero
   -- then the Remaining_Bytes may be used to calculate which byte caused the fail using:
   --    (Index_Of_Failed_Byte := Source'Last - Source.Remaining_Bytes)
   -- If the operation returns True then the serializable has zero Remaining_Bytes.
   -- Any byte which has a corresponding flag set in the Dont_Care array will be treated as equal.
   -- The Dont_Care array must have the same or more flags as there are bytes in the Expected_Values array.
   -- An exception will be raised (out of bounds) otherwise.
   --
   function Compare (Source: in out Instance; Expected_Values: Array_Of_Unsigned_8; Dont_Care: Array_Of_Boolean) return Boolean;


   -- Undocumented, used for test purposes only.
   --
   procedure Dump_2_Lines (Source: in out Instance; Around: Unsigned_32 := 0; Show_Cursor: Boolean := false);


   -- Undocumented, used for test purposes only.
   --
   procedure Put_All (Source: in out Instance);

private


   type Instance is tagged
      record
         Base_Ptr: Array_Of_Unsigned_8_Ptr;
         First: Unsigned_32;
         Cursor: Unsigned_32;
         Last: Unsigned_32;
         Must_Deallocate: Boolean;
      end record;


end Serializable;
