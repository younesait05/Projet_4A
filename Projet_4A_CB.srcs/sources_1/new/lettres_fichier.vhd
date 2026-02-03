library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lettres_fichier is
  port(
    letter_idx : in  unsigned(4 downto 0);        -- 0..25
    seg        : out std_logic_vector(6 downto 0)  -- a..g (active-low)
  );
end entity;

architecture rtl of lettres_fichier is
begin
  process(letter_idx)
    variable s : std_logic_vector(6 downto 0);
  begin
    s := (others => '1'); -- OFF

    case to_integer(letter_idx) is
      when 0  => s := "0001000"; -- A
      when 1  => s := "1100000"; -- b
      when 2  => s := "0110001"; -- C
      when 3  => s := "1000010"; -- d
      when 4  => s := "0110000"; -- E
      when 5  => s := "0111000"; -- F
      when 6  => s := "0100001"; -- G
      when 7  => s := "1101000"; -- H
      when 8  => s := "1111001"; -- I
      when 9  => s := "1000011"; -- J
      when 10 => s := "1111000"; -- K (approx)
      when 11 => s := "1110001"; -- L
      when 12 => s := "0101010"; -- M (approx)
      when 13 => s := "1101010"; -- n
      when 14 => s := "0000001"; -- O
      when 15 => s := "0011000"; -- P
      when 16 => s := "0001100"; -- q (approx)
      when 17 => s := "1111010"; -- r
      when 18 => s := "0100100"; -- S
      when 19 => s := "1110000"; -- t
      when 20 => s := "1000001"; -- U
      when 21 => s := "1100011"; -- v (approx)
      when 22 => s := "1010101"; -- W (approx)
      when 23 => s := "1001000"; -- x (approx)
      when 24 => s := "1000100"; -- y (approx)
      when 25 => s := "0010010"; -- Z (approx)
      when others => s := (others => '1');
    end case;

    seg <= s;
  end process;
end architecture;
