-- -----------------------------------------------------------------------------
--
--  Title      :  Edge-Detection design project - task 2.
--             :
--  Developers :  Edgar Lakis <s081553@student.dtu.dk>
--             :
--  Purpose    :  Synthesizable memory for task2.
--             :  Has single port for Accelerator + signal to triger saving of
--             :  the processed image to file.
--             :  File name for processed image is based on initial file name:
--             :     save_file_name = load_file_name & "_result.pgm"
--             :
--  Revision   :  1.0    8-10-09     Initial version
--             :  
--  Special    :
--  thanks to  :  Jonas Benjamin Borch - s052435@student.dtu.dk
--             
-- -----------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use work.types.all;

entity memory2 is
   generic (
      -- Don't use tristates for the dataR
      skip_tristate  : boolean := false;
      -- Size of the memory
      mem_size       : positive;
      -- File initialisation of the memory
      load_file_name : string
      );
   port (
      -- Read/Write port for Accelerator
      clk        : in  std_logic;
      addr       : in  word_t;
      dataR      : out halfword_t;
      dataW      : in  halfword_t;
      rw         : in  std_logic;
      req        : in  std_logic;
      -- Signal to dump processed image to file
      dump_image : in  std_logic
      );

end entity memory2;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

architecture behaviour of memory2 is
   -- Where to store processed image
   constant save_file_name : string := load_file_name & "_result.pgm";

   type word_array is array (natural range <>) of halfword_t;
   constant high_address : natural := mem_size - 1;



   impure function InitRamFromFile (RamFileName : in string) return word_array is
      file RamFile         : text open read_mode is RamFileName;
      variable RamFileLine : line;
      variable RAM         : word_array(0 to high_address);
      variable w           : bit_vector(halfword_t'range);
      variable i           : natural;
   begin
      for i in 0 to high_address loop
         if endfile(RamFile) then
            RAM(i to high_address) := (others => (others => '0'));
            exit;
         else
            readline (RamFile, RamFileLine);
            read (RamFileLine, w);
            Ram(i) := halfword_t(to_stdlogicvector(w));
         end if;
      end loop;
      assert endfile(RamFile)
         report "Memory initialisation file is too big" severity error;
      
      return RAM;
   end function;

   signal do  : halfword_t;
   signal mem : word_array(0 to high_address) := InitRamFromFile(load_file_name);
   

begin

   -----------------------------------
   -- Accelerator port
   process (clk)
   begin
      if clk'event and clk = '0' and req = '1' then
         if rw = '0' then
            -- do write
            mem(to_integer(unsigned(addr))) <= dataW;
         -- Using "no change" mode, uncomment following to
         -- -- enable "write first" 
         -- do <= dataW;
         else
            -- Synchronous read to infer Block RAM
            do <= To_X01(std_logic_vector(mem(to_integer(unsigned(addr)))));
         end if;
      end if;
   end process;

   skip_tri : if skip_tristate generate
      -- Output is always valid
      dataR <= do;
   end generate skip_tri;
   use_tri : if not skip_tristate generate
      -- Output is 'Z' when not a read request
      dataR <= do when req = '1' and rw = '1'
               else (others => 'Z');
   end generate use_tri;


   -----------------------------------
   -- Triger dumping of image
   process (dump_image) is
      procedure WriteImage (
         constant FileName     : in string;
         constant StartAddress : in integer;
         constant Width        : in integer;
         constant Height       : in integer) is

         file imgFile      : text open write_mode is FileName;
         variable l        : line;
         variable addr     : integer := 0;
         variable lastAddr : integer := 0;
         variable tmp      : integer := 0;
         variable b        : natural := 0;
      begin
         lastAddr := StartAddress + Width/2 * Height - 1;

         -- Write header
         write(l, string'("P2"));
         writeline(imgFile, l);
         write(l, string'("# CREATOR: VHDL Edge-Detection"));
         writeline(imgFile, l);
         write(l, string'(integer'image(Width) &" " & integer'image(Height)));
         writeline(imgFile, l);
         write(l, string'("255"));
         writeline(imgFile, l);

         -- Write content
         for addr in StartAddress to lastAddr loop
            for b in 0 to 1 loop
               tmp := to_integer(unsigned(mem(addr) ((7 + b*8) downto (0 + b*8))));
               write(l, integer'image(tmp));
               writeline(imgFile, l);
            end loop;
         end loop;

         report "Processed image has been saved to: " & FileName severity failure;
      end WriteImage;

   constant img_width  : natural := 352;
   constant img_height : natural := 288;
   -- start address of processed image in memory
   constant mem_start  : natural := img_width/2*img_height;
   begin
      if dump_image = '1' then
         assert save_file_name /= ""
            report "Output image file not specified"
            severity failure;
         WriteImage(save_file_name, mem_start, img_width, img_height);
      end if;
   end process;

end architecture behaviour;
