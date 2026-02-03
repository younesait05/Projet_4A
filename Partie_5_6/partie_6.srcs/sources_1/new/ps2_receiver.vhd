library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ps2_receiver is
  port(
    clk100   : in  std_logic;
    rst      : in  std_logic;

    ps2_clk  : in  std_logic;
    ps2_data : in  std_logic;

    data_out : out std_logic_vector(7 downto 0);
    valid    : out std_logic
  );
end entity;

architecture rtl of ps2_receiver is
  -- synchronisation (anti-metastabilité)
  signal ps2c_ff : std_logic_vector(2 downto 0) := (others => '1');
  signal ps2d_ff : std_logic_vector(2 downto 0) := (others => '1');

  signal ps2c_prev : std_logic := '1';
  signal fall_ps2c : std_logic := '0';

  signal bit_cnt   : unsigned(3 downto 0) := (others => '0'); -- 0..10
  signal data_byte : std_logic_vector(7 downto 0) := (others => '0');
  signal parity_x  : std_logic := '0';
  signal parity_b  : std_logic := '0';

  signal v : std_logic := '0';
begin
  valid <= v;

  process(clk100)
    variable d : std_logic;
  begin
    if rising_edge(clk100) then
      if rst = '1' then
        ps2c_ff   <= (others => '1');
        ps2d_ff   <= (others => '1');
        ps2c_prev <= '1';
        fall_ps2c <= '0';

        bit_cnt   <= (others => '0');
        data_byte <= (others => '0');
        parity_x  <= '0';
        parity_b  <= '0';
        data_out  <= (others => '0');
        v         <= '0';
      else
        -- sync
        ps2c_ff <= ps2c_ff(1 downto 0) & ps2_clk;
        ps2d_ff <= ps2d_ff(1 downto 0) & ps2_data;

        -- front descendant (calculé à partir d'échantillons déjà synchronisés)
        fall_ps2c <= ps2c_prev and (not ps2c_ff(2));
        ps2c_prev <= ps2c_ff(2);

        v <= '0'; -- pulse 1 clk

        if fall_ps2c = '1' then
          d := ps2d_ff(2);

          case to_integer(bit_cnt) is
            when 0 =>
              -- START doit être 0
              if d = '0' then
                bit_cnt  <= bit_cnt + 1;
                parity_x <= '0';
              else
                bit_cnt <= (others => '0'); -- resync
              end if;

            when 1 to 8 =>
              -- 8 bits data, LSB first
              data_byte(to_integer(bit_cnt) - 1) <= d;
              parity_x <= parity_x xor d; -- XOR des bits data
              bit_cnt  <= bit_cnt + 1;

            when 9 =>
              -- parity bit
              parity_b <= d;
              bit_cnt  <= bit_cnt + 1;

            when 10 =>
              -- STOP doit être 1 + check parité impaire
              -- parité impaire => (xor(data) xor parity_bit) doit valoir 1
              if (d = '1') and ((parity_x xor parity_b) = '1') then
                data_out <= data_byte;
                v <= '1';
              end if;
              bit_cnt <= (others => '0');

            when others =>
              bit_cnt <= (others => '0');
          end case;
        end if;
      end if;
    end if;
  end process;
end architecture;
