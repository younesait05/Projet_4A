library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity key_to_idx is
  port(
    clk100    : in  std_logic;
    rst       : in  std_logic;
    scancode  : in  std_logic_vector(7 downto 0);
    sc_valid  : in  std_logic;

    idx       : out unsigned(4 downto 0);
    idx_valid : out std_logic
  );
end entity;

architecture rtl of key_to_idx is
  signal seen_f0 : std_logic := '0';
  signal seen_e0 : std_logic := '0';

  function sc_to_idx(sc : std_logic_vector(7 downto 0)) return integer is
  begin
    -- Table Set 2 (lettres)
    case sc is
      when x"15" => return 0;  -- A
      when x"32" => return 1;  -- B
      when x"21" => return 2;  -- C
      when x"23" => return 3;  -- D
      when x"24" => return 4;  -- E
      when x"2B" => return 5;  -- F
      when x"34" => return 6;  -- G
      when x"33" => return 7;  -- H
      when x"43" => return 8;  -- I
      when x"3B" => return 9;  -- J
      when x"42" => return 10; -- K
      when x"4B" => return 11; -- L
      when x"4C" => return 12; -- M
      when x"31" => return 13; -- N
      when x"44" => return 14; -- O
      when x"4D" => return 15; -- P
      when x"1C" => return 16; -- Q
      when x"2D" => return 17; -- R
      when x"1B" => return 18; -- S
      when x"2C" => return 19; -- T
      when x"3C" => return 20; -- U
      when x"2A" => return 21; -- V
      when x"1A" => return 22; -- W
      when x"22" => return 23; -- X
      when x"35" => return 24; -- Y
      when x"1D" => return 25; -- Z
      when others => return -1;
    end case;
  end function;

begin
  process(clk100)
    variable i : integer;
  begin
    if rising_edge(clk100) then
      if rst = '1' then
        idx       <= (others => '0');
        idx_valid <= '0';
        seen_f0   <= '0';
        seen_e0   <= '0';
      else
        idx_valid <= '0';

        if sc_valid = '1' then
          -- gestion préfixes
          if scancode = x"E0" then
            seen_e0 <= '1';
          elsif scancode = x"F0" then
            seen_f0 <= '1';
          else
            -- si c'était un break : on ignore et on clear seen_f0
            if seen_f0 = '1' then
              seen_f0 <= '0';
              seen_e0 <= '0';
            else
              -- make code normal : convertir
              i := sc_to_idx(scancode);
              if (i >= 0) and (i <= 25) then
                idx <= to_unsigned(i, 5);
                idx_valid <= '1';
              end if;
              seen_e0 <= '0';
            end if;
          end if;
        end if;
      end if;
    end if;
  end process;

end architecture;
