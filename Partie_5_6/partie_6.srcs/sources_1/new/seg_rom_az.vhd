library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seg_rom_az is
  port(
    idx  : in  unsigned(4 downto 0);        -- 0..25
    seg7 : out std_logic_vector(6 downto 0) -- a..g active-low
  );
end entity;

architecture rtl of seg_rom_az is
  type rom_t is array (0 to 25) of std_logic_vector(6 downto 0);

  -- ROM initialisée (Vivado peut l'implémenter en LUTROM ou BRAM suivant taille)
  constant ROM : rom_t := (
    0  => "0001000", -- A
    1  => "1100000", -- b
    2  => "0110001", -- C
    3  => "1000010", -- d
    4  => "0110000", -- E
    5  => "0111000", -- F
    6  => "0100001", -- G
    7  => "1101000", -- H
    8  => "1111001", -- I
    9  => "1000011", -- J
    10 => "1111000", -- K (approx)
    11 => "1110001", -- L
    12 => "0101010", -- M (approx)
    13 => "1101010", -- n
    14 => "0000001", -- O
    15 => "0011000", -- P
    16 => "0001100", -- q (approx)
    17 => "1111010", -- r
    18 => "0100100", -- S
    19 => "1110000", -- t
    20 => "1000001", -- U
    21 => "1100011", -- v (approx)
    22 => "1010101", -- W (approx)
    23 => "1001000", -- x (approx)
    24 => "1000100", -- y (approx)
    25 => "0010010"  -- Z (approx)
  );

begin
  seg7 <= ROM(to_integer(idx));
end architecture;
