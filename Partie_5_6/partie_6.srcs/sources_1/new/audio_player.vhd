library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.meta_pkg.all;

entity audio_player is
  port(
    clk100     : in  std_logic;
    rst        : in  std_logic;

    idx        : in  unsigned(4 downto 0);
    idx_valid  : in  std_logic;

    -- ROM interface
    rom_dout   : in  std_logic_vector(7 downto 0);
    rom_addr   : out unsigned(31 downto 0);

    -- output sample
    sample_out : out std_logic_vector(7 downto 0);
    busy       : out std_logic
  );
end entity;

architecture rtl of audio_player is
  -- 8 kHz tick from 100 MHz: 100e6 / 8000 = 12500
  constant FS_DIV : unsigned(13 downto 0) := to_unsigned(12500-1, 14);
  signal div_cnt  : unsigned(13 downto 0) := (others=>'0');
  signal tick     : std_logic := '0';

  signal addr     : unsigned(31 downto 0) := (others=>'0');
  signal remain   : unsigned(31 downto 0) := (others=>'0');
  signal playing  : std_logic := '0';
begin
  rom_addr   <= addr;
  sample_out <= rom_dout;
  busy       <= playing;

  -- generate 8kHz tick
  process(clk100)
  begin
    if rising_edge(clk100) then
      if rst='1' then
        div_cnt <= (others=>'0');
        tick    <= '0';
      else
        tick <= '0';
        if div_cnt = FS_DIV then
          div_cnt <= (others=>'0');
          tick <= '1';
        else
          div_cnt <= div_cnt + 1;
        end if;
      end if;
    end if;
  end process;

  -- playback control
  process(clk100)
  begin
    if rising_edge(clk100) then
      if rst='1' then
        addr    <= (others=>'0');
        remain  <= (others=>'0');
        playing <= '0';
      else
        -- start new sound on idx_valid
        if idx_valid='1' then
          addr    <= START_ADDR(to_integer(idx));
          remain  <= LENGTHS(to_integer(idx));
          playing <= '1';
        elsif (playing='1') and (tick='1') then
          if remain = 0 then
            playing <= '0';
          else
            addr   <= addr + 1;
            remain <= remain - 1;
          end if;
        end if;
      end if;
    end if;
  end process;
end architecture;
