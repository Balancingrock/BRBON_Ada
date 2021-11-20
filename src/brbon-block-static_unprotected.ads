with Interfaces; use Interfaces;

with Ada.Finalization;

with BRBON.Types; use BRBON.Types;
with BRBON.Utils;
with BRBON.Configure;
with BRBON.Container; use BRBON.Container;
with BRBON.Block;
with Serializable;


package BRBON.Block.Static_Unprotected is


   -- The store that contains a static BRBON hierarchy on which unprotected access is possible.
   -- This is the fasted possible acces to items in a BRBON store.
   --
   type Instance is new BRBON.Block.Instance with null record;


   -- Access type for the static unprotected store.
   --
   --type Instance_Ptr is access all Instance;


   -- Creates a new instance with a header of the requested type.
   -- @param Block_Type The type of the block to be created.
   --   Exception Illegal_Buffer_Type is raised if this is not a Single_Item_File (The only type supported at this time)
   -- @param Minimum_Byte_Count The minimum number of bytes to allocate.
   --   The actual number of bytes allocated will be higher than this number, modified for alignement and overhead.
   --   Depending on the block type, the actual count can be about 100~150 bytes higher than requested.
   --   Use the operation Byte_Count to determine the actual byte count of the buffer.
   -- @param Using_Endianness The endianness to be used for multi-byte items.
   -- @returns A Static_Unprotected instance.
   --
   function Factory
      (
         Block_Type: BRBON.Block.Instance_Type;
         Minimum_Byte_Count: Unsigned_32;
         Options: BRBON.Block.Options := BRBON.Block.No_Options;
         Using_Endianness: Endianness := BRBON.Configure.Machine_Endianness;
         Origin: String := "";
         Identifier: String := "";
         Extension: String := "";
         Path_Prefix: String := "";
         Acquisition_URL: String := "";
         Target_List: String := "";
         Public_Key_URL: String := "";
         Creation_Timestamp: Unsigned_64 := BRBON.Utils.Milli_Sec_Since_Jan_1_1970;
         Expiry_Timestamp: Unsigned_64 := 16#7FFF_FFFF_FFFF_FFFF#
      ) return Instance;


   -- The byte count of the buffer, including overhead.
   -- Use the operation "Free_Byte_Count" to determine the remaining usable space.
   --
   overriding function Byte_Count (I: in out Instance) return Unsigned_32;



   function Free_Area_Byte_Count (I: in out Instance) return Unsigned_32;


end BRBON.Block.Static_Unprotected;
