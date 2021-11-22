with Interfaces; use Interfaces;

with Ada.Exceptions;

with BRBON.Header;
with BRBON.Container;


package body BRBON.Block is

   -- ==========================================================================
   -- == BRBON.Header.Header_Interface implementation                         ==
   -- ==========================================================================

   procedure Set_Synchronization_Byte_1 (I: in out Instance) is
   begin
      I.Container.Set_Unsigned_8 (BRBON.Header.Block_Synchronization_Byte_1_Offset, BRBON.Header.Block_Synchronization_Byte_1_Expected_Value);
   end Set_Synchronization_Byte_1;


   function Verify_Synchronization_Byte_1 (I: in out Instance) return Boolean is
   begin
      return I.Container.Get_Unsigned_8 (Block_Synchronization_Byte_1_Offset) = Block_Synchronization_Byte_1_Expected_Value;
   end Verify_Synchronization_Byte_1;


   procedure Set_Synchronization_Byte_2 (I: in out Instance) is
   begin
      I.Container.Set_Unsigned_8 (Block_Synchronization_Byte_2_Offset, Block_Synchronization_Byte_2_Expected_Value);
   end Set_Synchronization_Byte_2;


   function Verify_Synchronization_Byte_2 (I: in out Instance) return Boolean is
   begin
      return I.Container.Get_Unsigned_8 (Block_Synchronization_Byte_2_Offset) = Block_Synchronization_Byte_2_Expected_Value;
   end Verify_Synchronization_Byte_2;


   procedure Set_Synchronization_Byte_3 (I: in out Instance) is
   begin
      I.Container.Set_Unsigned_8 (Block_Synchronization_Byte_3_Offset, Block_Synchronization_Byte_3_Expected_Value);
   end Set_Synchronization_Byte_3;


   function Verify_Synchronization_Byte_3 (I: in out Instance) return Boolean is
   begin
      return I.Container.Get_Unsigned_8 (Block_Synchronization_Byte_3_Offset) = Block_Synchronization_Byte_3_Expected_Value;
   end Verify_Synchronization_Byte_3;


   procedure Set_Synchronization_Byte_4 (I: in out Instance) is
   begin
      if I.Container.Uses_Endianness = Little then
         I.Container.Set_Unsigned_8 (Block_Synchronization_Byte_4_Offset, Block_Synchronization_Byte_4_Little_Endian_Expected_Value);
      else
         I.Container.Set_Unsigned_8 (Block_Synchronization_Byte_4_Offset, Block_Synchronization_Byte_4_Big_Endian_Expected_Value);
      end if;
   end Set_Synchronization_Byte_4;


   function Verify_Synchronization_Byte_4 (I: in out Instance) return Boolean is
   begin
      if I.Container.Get_Unsigned_8 (Block_Synchronization_Byte_4_Offset) = Block_Synchronization_Byte_4_Little_Endian_Expected_Value then
         I.Container.Set_Data_Endianness (Little);
         return true;
      elsif I.Container.Get_Unsigned_8 (Block_Synchronization_Byte_4_Offset) = Block_Synchronization_Byte_4_Big_Endian_Expected_Value then
         I.Container.Set_Data_Endianness (Big);
         return true;
      else
         return false;
      end if;
   end Verify_Synchronization_Byte_4;


   -- Block defined operations

   function Type_Of_Block (I: in out Instance) return Block_Type is
   begin
      return BRBON.Header.Get_Block_Type (I.Container);
   end Type_Of_Block;


   procedure Write_To_File (I: in out Instance; To_Path: String) is
   begin
      I.Ensure_Block_Consistency;
      I.Container.Write_To_File (To_Path);
   end Write_To_File;


   function Test_Serializer (I: in out Instance) return Serializable.Instance is
   begin
      return Serializable.Create_Without_Copy
        (Use_In_Place => I.Memory_Ptr,
         First        => I.Memory_Ptr.all'First,
         Last         => I.Memory_Ptr.all'Last);
   end Test_Serializer;


   procedure Ensure_Block_Consistency (I: in out Instance) is
   begin
      raise BRBON.Types.Not_Implemented_Yet;
   end Ensure_Block_Consistency;


   function Add_To_Header_Field (I: in out Instance; Value: String) return Unsigned_16 is
      Free_Bytes: Unsigned_16 := (I.Last_Free_Byte_In_Header_Field_Storage + 1) - I.First_Free_Byte_In_Header_Field_Storage; -- Sequence prevents negative intermediate
      Origin_Offset: Unsigned_16;
   begin
      -- Check if there is space available for the string in the header field
      if Value'Length > Free_Bytes then
         return 0; -- not enough space available
      else
         Container.Set_String (I.Container, Unsigned_32 (I.First_Free_Byte_In_Header_Field_Storage), Value);
         Origin_Offset := I.First_Free_Byte_In_Header_Field_Storage;
         I.First_Free_Byte_In_Header_Field_Storage := I.First_Free_Byte_In_Header_Field_Storage + Unsigned_16 (Value'Length);
         return Origin_Offset;
      end if;
   end Add_To_Header_Field;


--   function Get_Block_Origin (I: in out Instance) return String is
--      Offset: Unsigned_32 := Unsigned_32 (Get_Block_Origin_Offset (I.Container));
--      Byte_Count: Unsigned_32 := Unsigned_32 (Get_Block_Origin_Byte_Count (I.Container));
--      Crc_16: Unsigned_16 := Get_Block_Origin_Crc16 (I.Container);
--      Str: String := C.Get_String (Offset, Byte_Count);
--      Cal_Crc_16: Unsigned_16 := CRC_Package.Calculate_CRC_16 (Str);
--   begin
--      if Crc_16 = Cal_Crc_16 then
--         return Str;
--      else
--         Ada.Exceptions.Raise_Exception (Block_Header_Error'Identity, "Origin CRC-16 validation error.\n The stored CRC-16 is not equal to the CRC-16 calculated over the stored string");
--      end if;
--   end Get_Block_Origin;

end BRBON.Block;
