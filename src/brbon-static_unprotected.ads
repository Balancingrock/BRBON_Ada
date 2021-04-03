with Interfaces; use Interfaces;

with BRBON.Types; use BRBON.Types;
with BRBON.Container; use BRBON.Container;


package BRBON.Static_Unprotected is

   -- The store that contains a static BRBON hierarchy on which unprotected access is possible.
   -- This is the fasted possible acces to items in a BRBON store.
   --
   type Static_Unprotected_Store is tagged private;

   -- Access type for the static unprotected store.
   --
   type Static_Unprotected_Store_Ptr is access all Static_Unprotected_Store;


   -- Controls access to the static unprotected items in the block.
   --
--   type BR_Static_Unprotected_Item is tagged private;

   -- The possible status of a file info request.
   --
--   type File_Status is (Not_Found, Cannot_Read, OK);

   -- Contains information about a file that can be used to open a file in a Byte_Store.
   --
--   type Block_Info is record
--      Block_Byte_Count: Unsigned_32; -- The byte count necessary to read a file, note that this may be smaller than the file size itself.
--      Using_Endianness: Endianness;  -- The endianess for the buffer to read the file into.
--   end record;

   -- Retrieves the block info from the block header of a file.
   -- @param Path Designates the file to be read.
   -- @return The block info for the first block in the file.
   -- @exception File_IO_Error if the file could not be read
   -- @exception Block_Error if the block header is not valid
   --
--   function Get_Block_Info (Path: String) return Block_Info;


   -- Create a new single-item-file type block.
   -- @param With_Item_Type The type of item to create in the block.
   -- @param In_Byte_Store The byte store to use, note that any data in it will be overwritten.
   -- @return The new BR-Block.
   --
   procedure Create_Block_Single_Item_File (S: out Static_Unprotected_Store'Class; With_Item_Type: BR_Item_Type := BR_Dictionary);

   -- Open an existing byte store as a block.
   -- @param S A byte store with a single-item-file block in it.
   -- @return The block as it was openend.
   -- @exception Invalid_Block When the block is invalid.
   --
   --function Block_Factory_Open_Single_Item_File (Path: String) return Boolean;

   -- Return the number of items in the block.
   -- @param B The block from which to get the number of item.
   -- @return The number of items in the block.
   --
--   function Get_Number_Of_Items (B: in out Static_Unprotected_Store'Class) return Unsigned_32;

   -- Return the N-th item in the block
   -- @param B The block from which to extract the item
   -- @param Index The index of the item to return, starts at 1.
   -- @return The requested item.
   -- @exception Index_Out_Of_Range if the requested item does not exist.
   --
--   function Get_Item (B: in out Static_Unprotected_Store'Class; Index: Unsigned_32 := 1) return BR_Static_Unprotected_Item;

   -- Write the block to permanent storage.
   --
--   procedure Write_To_File (B: in out Static_Unprotected_Store'Class; Filepath: String);

   -- For testing
   --
--   procedure Test_Support_Update_Header_CRC (B: in out Static_Unprotected_Store'Class);

private

   type Static_Unprotected_Store is tagged
      record
         Store_Ptr: BRBON.Container.Store_Ptr; -- This makes it impossible to access this store with low level operations
         Block_Type: BR_Block_Type;
         First_Item_Offset: Unsigned_32;
         Free_Area_Offset: Unsigned_32;
      end record;

--   type BR_Static_Unprotected_Item is tagged
--      record
--         Store: Store_Ptr;
--         Offset: Unsigned_32;
--      end record;

--   procedure Create_Block_Header (B: in out Static_Unprotected_Store'Class);

   procedure Create_Block_Type_1_Single_Item_File (S: in out Static_Unprotected_Store'Class);

   procedure Update_Free_Area_Offset (S: in out Static_Unprotected_Store'Class; Increment: Unsigned_32);

--   procedure Update_Header_Crc (B: in out Static_Unprotected_Store'Class);

end BRBON.Static_Unprotected;
