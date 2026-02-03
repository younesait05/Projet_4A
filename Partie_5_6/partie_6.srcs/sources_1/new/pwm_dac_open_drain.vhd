library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pwm_dac_open_drain is
  port(
    clk100   : in  std_logic;
    rst      : in  std_logic;
    sample   : in  std_logic_vector(7 downto 0); -- 0..255 unsigned
    aud_pwm  : out std_logic                     -- open-drain: '0' or 'Z'
  );
end entity;

architecture rtl of pwm_dac_open_drain is
  signal cnt : unsigned(9 downto 0) := (others => '0'); -- 0..999 => 100kHz
  signal thr : unsigned(9 downto 0);
  signal pwm_bit : std_logic;
begin
  -- map sample 8-bit to threshold (approx *4)
  thr <= unsigned(sample) & "00"; -- 0..1020

  process(clk100)
  begin
    if rising_edge(clk100) then
      if rst='1' then
        cnt <= (others=>'0');
      else
        if cnt = to_unsigned(999,10) then
          cnt <= (others=>'0');
        else
          cnt <= cnt + 1;
        end if;
      end if;
    end if;
  end process;

  pwm_bit <= '1' when cnt < thr else '0';

  -- open-drain output (important for Nexys4 DDR audio)
  aud_pwm <= '0' when pwm_bit='0' else 'Z';
end architecture;
