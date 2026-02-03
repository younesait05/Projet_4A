library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity lettres_fichier is
  port(
    letter_idx : in  unsigned(4 downto 0);
    seg        : out std_logic_vector(6 downto 0)
  );
end entity;

architecture rtl of lettres_fichier is
begin
  process(letter_idx)
    variable s : std_logic_vector(6 downto 0);
  begin
    s := (others => '1');
    case to_integer(letter_idx) is
      when 0  => s := "0001000";
      when 1  => s := "1100000";
      when 2  => s := "0110001";
      when 3  => s := "1000010";
      when 4  => s := "0110000";
      when 5  => s := "0111000";
      when 6  => s := "0100001";
      when 7  => s := "1101000";
      when 8  => s := "1111001";
      when 9  => s := "1000011";
      when 10 => s := "1111000";
      when 11 => s := "1110001";
      when 12 => s := "0101010";
      when 13 => s := "1101010";
      when 14 => s := "0000001";
      when 15 => s := "0011000";
      when 16 => s := "0001100";
      when 17 => s := "1111010";
      when 18 => s := "0100100";
      when 19 => s := "1110000";
      when 20 => s := "1000001";
      when 21 => s := "1100011";
      when 22 => s := "1010101";
      when 23 => s := "1001000";
      when 24 => s := "1000100";
      when 25 => s := "0010010";
      when others => s := (others => '1');
    end case;
    seg <= s;
  end process;
end architecture;

