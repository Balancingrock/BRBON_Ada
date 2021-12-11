-- with Ada.Streams.Stream_IO; use Ada.Streams.Stream_IO;
with Ada.Text_IO; use Ada.Text_IO;

with Ada.Unchecked_Conversion;
with Ada.Exceptions;

with BRBON.Utils;
with BRBON.Block; use BRBON.Block;
with BRBON.Footer;
with BRBON.Header;
with BRBON.Name_Field_Assistent;



package body BRBON.Block.Static_Unprotected is


   -- Body internals

   function Get_Bool (C: Container.Instance; Item_Offset: Unsigned_32) return Boolean is
   begin
      return Container.Get_Bool (C, Item.Get_Value_Offset (C, Item_Offset));
   end Get_Bool;

   procedure Set_Bool (C: Container.Instance; Item_Offset: Unsigned_32; Value: Boolean) is
   begin
      Container.Set_Bool (C, Item.Get_Value_Offset (C, Item_Offset), Value);
   end Set_Bool;




   -- Implement API

   function Factory
      (
       Type_Of_Block: Block_Type;
       Minimum_Byte_Count: Unsigned_32;
       Header_Field_Storage_Byte_Count: Unsigned_16 := 1;
       Options: Block_Options := No_Block_Options;
       Using_Endianness: Endianness := Configure.Machine_Endianness;
       Origin: String := "";
       Identifier: String := "";
       Extension: String := "";
       Path_Prefix: String := "";
       Acquisition_URL: String := "";
       Target_List: String := "";
       Public_Key_URL: String := "";
       Creation_Timestamp: Unsigned_64 := Utils.Milli_Sec_Since_Jan_1_1970;
       Expiry_Timestamp: Unsigned_64 := 16#7FFF_FFFF_FFFF_FFFF#
      ) return Instance is

      Field_Storage_Byte_Count: Unsigned_16;
      Header_Type_Dependent_Byte_count: Unsigned_16;
      Header_Byte_Count: Unsigned_16;

      Content_Byte_Count: Unsigned_32;
      Block_Byte_Count: Unsigned_32;

      New_Block: Instance;

   begin


      -- Check if block type is supported
      --
      if Type_Of_Block /= Single_Item then
         Ada.Exceptions.Raise_Exception (Illegal_Block_Type'Identity, "Block type not (yet) supported (" & Type_Of_Block'Image & ")");
      end if;


      -- Calculate the size of the storage field in de header
      --
      Field_Storage_Byte_Count :=
        Utils.Round_Up_To_Nearest_Multiple_of_8
          (
           Unsigned_16
             (
              Origin'Length
              + Identifier'Length
              + Extension'Length
              + Path_Prefix'Length
              + Acquisition_URL'Length
              + Target_List'Length
              + Public_Key_URL'Length
             )
          );


      -- Get the type dependent size
      --
      case Type_Of_Block is
         when Illegal => Ada.Exceptions.Raise_Exception (Illegal_Block_Type'Identity, "Impossible to create an illegal-type block");
         when Single_Item => Header_Type_Dependent_Byte_Count := 0;
      end case;


      -- Calculate the header size
      --
      Header_Byte_Count := Header.Fixed_Part_Byte_Count + Header_Type_Dependent_Byte_Count + Field_Storage_Byte_Count + Header.Past_Field_Storage_Byte_Count;


      -- Calculate the size of the block content field
      --
      Content_Byte_Count := Utils.Round_Up_To_Nearest_Multiple_of_8 (Minimum_Byte_Count);


      -- Calculate the size of the block
      --
      Block_Byte_Count := Unsigned_32 (Unsigned_32 (Header_Byte_Count) + Content_Byte_Count + Footer.Footer_Byte_Count (Single_Item));


      -- Allocate memory area for the container that will enclose the block
      --
      New_Block.Memory_Ptr := new Types.Array_Of_Unsigned_8 (0 .. Block_Byte_Count - 1);


      -- Create the container for the block
      --
      New_Block.Container := Container.Factory (Buffer_Ptr => New_Block.Memory_Ptr, Using_Endianness => Using_Endianness);


      -- Create the block header
      --
      Block.Create_Single_Item_Block_Header
        (
         In_Block           => New_Block,
         Field_Storage_Byte_Count => Field_Storage_Byte_Count,
         Header_Byte_Count  => Header_Byte_Count,
         Options            => Options,
         Origin             => Origin,
         Identifier         => Identifier,
         Extension          => Extension,
         Path_Prefix        => Path_Prefix,
         Acquisition_URL    => Acquisition_URL,
         Target_List        => Target_List,
         Public_Key_URL     => Public_Key_URL,
         Creation_Timestamp => Creation_Timestamp,
         Expiry_Timestamp   => Expiry_Timestamp
        );


      New_Block.First_Free_Byte_In_Payload := Unsigned_32 (Header_Byte_Count);
      New_Block.Last_Free_Byte_In_Payload := Container.Byte_Count (New_Block.Container) - Footer.Footer_Byte_Count (Types.Single_Item) - 1;

      return New_Block;

   end Factory;


   procedure Finalization (I: in out Instance) is
   begin
      Deallocate_Array_Of_Unsigned_8 (I.Memory_Ptr);
   end Finalization;


   -- Operational Interface

   function Free_Area_Byte_Count (I: in out Instance) return Unsigned_32 is
      B: constant Unsigned_32 := I.Byte_Count;
      F: constant Unsigned_32 := I.First_Free_Byte_In_Payload;
      V: constant Unsigned_32 := F + Footer.Footer_Byte_Count (Types.Single_Item);
   begin
      if V > B then
         return 0; -- cannot return negative
      else
         return B - V;
      end if;
   end Free_Area_Byte_Count;


   procedure Add_Root_Item (I: in out Instance; Of_Type: Types.Item_Type; With_Byte_Count: Unsigned_32; With_Name: String) is

      Name_Assistent: Name_Field_Assistent.Instance := Name_Field_Assistent.Create_Name_Field_Assistent (With_Name);
      Item_Byte_Count: Unsigned_32;

   begin

      -- Don't create illegal types
      --
      if Of_Type = Types.Illegal then
         Ada.Exceptions.Raise_Exception (Illegal_Item_Type'Identity, "Cannot create top level item 'illegal'");
      end if;

      -- Don't accept names that are too long
      --
      if With_Name'Length > Types.Max_Name_Length then
         Ada.Exceptions.Raise_Exception (Name_Error'Identity, "Name length exceeds maximum (" & Types.Max_Name_Length'Image & ")");
      end if;

      -- Determine the byte count of the new item
      --
      Item_Byte_Count :=
        Name_Field_Assistent.Get_Minimum_Item_Byte_Count (Name_Assistent)
        + Types.Item_Overhead_Byte_Count (Of_Type)
        + Utils.Round_Up_To_Nearest_Multiple_of_8 (With_Byte_Count);

      -- Ensure the type fits in the available area
      --
      if Item_Byte_Count > I.Free_Area_Byte_Count then
         Ada.Exceptions.Raise_Exception (Storage_Warning'Identity, "Block storage insufficient for requested byte count");
      end if;

      -- Create the item structure
      --
      Item.Create_Layout (Of_Type          => Of_Type,
                        In_Container     => I.Container,
                        At_Offset        => I.First_Free_Byte_In_Payload,
                        With_Name        => Name_Assistent,
                        Using_Byte_Count => Item_Byte_Count,
                        Parent_Offset    => 0);

      -- Set the free byte pointer
      --
      I.First_Free_Byte_In_Payload := I.First_Free_Byte_In_Payload + Item.Get_Byte_Count (I.Container, I.First_Free_Byte_In_Payload);

   end Add_Root_Item;


   function Get_Bool (P: Portal) return Boolean is
   begin
      return Container.Get_Bool (P.Container.all, P.Item_Offset + Item.Small_Value_Offset);
   end Get_Bool;
   --
   procedure Set_Bool (P: Portal; Value: Boolean) is
   begin
      Container.Set_Bool (P.Container.all, P.Item_Offset + Item.Small_Value_Offset, Value);
   end Set_Bool;


   function Get_Int_8 (P: Portal) return Integer_8) is
   begin
      return Container.Get_Integer_8 (P.Container.all, P.Item_Offset + Item.Small_Value_Offset);
   end Get_Int_8;
   --
   procedure Set_Int_8 (P: Portal; Value: Integer_8) is
   begin
      Container.Set_Integer_8 (P.Container.all, P.Item_Offset + Item.Small_Value_Offset, Value);
   end Set_Int_8;


   function Get_Int_16 (P: Portal) return Integer_16) is
   begin
      return Container.Get_Integer_16 (P.Container.all, P.Item_Offset + Item.Small_Value_Offset);
   end Get_Int_16;
   --
   procedure Set_Int_16 (P: Portal; Value: Integer_16) is
   begin
      Container.Set_Integer_16 (P.Container.all, P.Item_Offset + Item.Small_Value_Offset, Value);
   end Set_Int_16;


   function Get_Int_32 (P: Portal) return Integer_32) is
   begin
      return Container.Get_Integer_32 (P.Container.all, P.Item_Offset + Item.Small_Value_Offset);
   end Get_Int_32;
   --
   procedure Set_Int_32 (P: Portal; Value: Integer_32) is
   begin
      Container.Set_Integer_32 (P.Container.all, P.Item_Offset + Item.Small_Value_Offset, Value);
   end Set_Int_32;


   function Get_Int_64 (P: Portal) return Integer_64) is
   begin
      return Container.Get_Integer_64 (P.Container.all, P.Item_Offset + Item.Small_Value_Offset);
   end Get_Int_64;
   --
   procedure Set_Int_64 (P: Portal; Value: Integer_64) is
   begin
      Container.Set_Integer_64 (P.Container.all, P.Item_Offset + Item.Small_Value_Offset, Value);
   end Set_Int_64;


   function Get_UInt_8 (P: Portal) return Unsigned_8) is
   begin
      return Container.Get_Unsigned_8 (P.Container.all, P.Item_Offset + Item.Small_Value_Offset);
   end Get_UInt_8;
   --
   procedure Set_UInt_8 (P: Portal; Value: Unsigned_8) is
   begin
      Container.Set_Unsigned_8 (P.Container.all, P.Item_Offset + Item.Small_Value_Offset, Value);
   end Set_UInt_8;


   function Get_UInt_16 (P: Portal) return Unsigned_16) is
   begin
      return Container.Get_Unsigned_16 (P.Container.all, P.Item_Offset + Item.Small_Value_Offset);
   end Get_UInt_16;
   --
   procedure Set_UInt_16 (P: Portal; Value: Unsigned_16) is
   begin
      Container.Set_Unsigned_16 (P.Container.all, P.Item_Offset + Item.Small_Value_Offset, Value);
   end Set_UInt_16;


   function Get_UInt_32 (P: Portal) return Unsigned_32) is
   begin
      return Container.Get_Unsigned_32 (P.Container.all, P.Item_Offset + Item.Small_Value_Offset);
   end Get_UInt_32;
   --
   procedure Set_UInt_32 (P: Portal; Value: Unsigned_32) is
   begin
      Container.Set_Unsigned_32 (P.Container.all, P.Item_Offset + Item.Small_Value_Offset, Value);
   end Set_UInt_32;


   function Get_UInt_64 (P: Portal) return Unsigned_64) is
   begin
      return Container.Get_Unsigned_64 (P.Container.all, P.Item_Offset + Item.Small_Value_Offset);
   end Get_UInt_64;
   --
   procedure Set_UInt_64 (P: Portal; Value: Unsigned_64) is
   begin
      Container.Set_Unsigned_64 (P.Container.all, P.Item_Offset + Item.Small_Value_Offset, Value);
   end Set_UInt_64;



   --
   function Get_String (P: Portal) return String) is
      Value_Offset: Unsigned_32 := Item.Get_Value_Offset (P.Container.all, P.Item_Offset);
      Byte_Count: Unsigned_32 := Container.Get_Unsigned_32 (P.Container.all, Value_Offset + String_Byte_Count_Offset);
   begin
      return Container.Get_String (P.Container.all, Value_Offset + String_Byte_Code_Offset, Byte_Count);
   end Get_String;
   --
   procedure Set_String (P: Portal; Value: String) is
      Value_Offset: Unsigned_32 := Item.Get_Value_Offset (P.Container.all, P.Item_Offset);
   begin
      Container.Set_String (P.Container.all, Value_Offset + String_Byte_Code_Offset);
      Container.Set_Unsigned_32 (P.Container.all, Value_Offset + String_Byte_Count_Offset, String'Length);
   end Set_String;


   Crc_String_Crc_Offset: Unsigned_32 := 0;
   Crc_String_Byte_Count_Offset: Unsigned_32 :=
   function Get_Crc_String (P: Portal) return String) is
   begin
      return Container.Get_Integer_8 (P.Container.all, P.Item_Offset + Item.Small_Value_Offset);
   end Get;
   --
   procedure Set_Crc_String (P: Portal; Value: String);


   function Get_Binary (P: Portal) return Array_Of_Unsigned_8) is
   begin
      return Container.Get_Integer_8 (P.Container.all, P.Item_Offset + Item.Small_Value_Offset);
   end Get;
   procedure Set_Binary (P: Portal; Value: Array_Of_Unsigned_8);
   --
   function Get_Crc_Binary (P: Portal) return Array_Of_Unsigned_8) is
   begin
      return Container.Get_Integer_8 (P.Container.all, P.Item_Offset + Item.Small_Value_Offset);
   end Get;
   procedure Set_Crc_Binary (P: Portal; Value: Array_Of_Unsigned_8);
   --
   function Get_UUID (P:Portal) return UUID is
   begin
      return Container.Get_Integer_8 (P.Container.all, P.Item_Offset + Item.Small_Value_Offset);
   end Get;
   procedure Set_UUID (P: Portal; Value: UUID);


end BRBON.Block.Static_Unprotected;
