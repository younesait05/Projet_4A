library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package meta_pkg is
  type u32_arr is array (0 to 25) of unsigned(31 downto 0);
  constant START_ADDR : u32_arr := (
    to_unsigned(0, 32),
    to_unsigned(9024, 32),
    to_unsigned(19200, 32),
    to_unsigned(29760, 32),
    to_unsigned(40128, 32),
    to_unsigned(48960, 32),
    to_unsigned(59904, 32),
    to_unsigned(70464, 32),
    to_unsigned(81600, 32),
    to_unsigned(90432, 32),
    to_unsigned(100800, 32),
    to_unsigned(110592, 32),
    to_unsigned(120960, 32),
    to_unsigned(131328, 32),
    to_unsigned(141696, 32),
    to_unsigned(150528, 32),
    to_unsigned(160320, 32),
    to_unsigned(170112, 32),
    to_unsigned(180480, 32),
    to_unsigned(191424, 32),
    to_unsigned(201600, 32),
    to_unsigned(210432, 32),
    to_unsigned(220800, 32),
    to_unsigned(233472, 32),
    to_unsigned(244608, 32),
    to_unsigned(257472, 32)
  );

  constant LENGTHS : u32_arr := (
    to_unsigned(9024, 32),
    to_unsigned(10176, 32),
    to_unsigned(10560, 32),
    to_unsigned(10368, 32),
    to_unsigned(8832, 32),
    to_unsigned(10944, 32),
    to_unsigned(10560, 32),
    to_unsigned(11136, 32),
    to_unsigned(8832, 32),
    to_unsigned(10368, 32),
    to_unsigned(9792, 32),
    to_unsigned(10368, 32),
    to_unsigned(10368, 32),
    to_unsigned(10368, 32),
    to_unsigned(8832, 32),
    to_unsigned(9792, 32),
    to_unsigned(9792, 32),
    to_unsigned(10368, 32),
    to_unsigned(10944, 32),
    to_unsigned(10176, 32),
    to_unsigned(8832, 32),
    to_unsigned(10368, 32),
    to_unsigned(12672, 32),
    to_unsigned(11136, 32),
    to_unsigned(12864, 32),
    to_unsigned(11520, 32)
  );
end package;
