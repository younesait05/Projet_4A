library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity affichage_lettres_bram is
  port (
    CLK100MHZ  : in  std_logic;
    CPU_RESETN : in  std_logic;
    BTNR       : in  std_logic;

    CA : out std_logic;
    CB : out std_logic;
    CC : out std_logic;
    CD : out std_logic;
    CE : out std_logic;
    CF : out std_logic;
    CG : out std_logic;
    DP : out std_logic;

    AN : out std_logic_vector(7 downto 0)
  );
end entity;

architecture rtl of affichage_lettres_bram is

  -- Mémoire : 26 cases, chaque case stocke un index 0..25 (5 bits) 
  type ram_t is array (0 to 25) of unsigned(4 downto 0);

  -- Initialisation directe : mem(0)=0, mem(1)=1, ... mem(25)=25
  -- Vivado accepte ce style et garde l'init en FPGA.
  signal mem : ram_t := (
    0  => to_unsigned(0,5),
    1  => to_unsigned(1,5),
    2  => to_unsigned(2,5),
    3  => to_unsigned(3,5),
    4  => to_unsigned(4,5),
    5  => to_unsigned(5,5),
    6  => to_unsigned(6,5),
    7  => to_unsigned(7,5),
    8  => to_unsigned(8,5),
    9  => to_unsigned(9,5),
    10 => to_unsigned(10,5),
    11 => to_unsigned(11,5),
    12 => to_unsigned(12,5),
    13 => to_unsigned(13,5),
    14 => to_unsigned(14,5),
    15 => to_unsigned(15,5),
    16 => to_unsigned(16,5),
    17 => to_unsigned(17,5),
    18 => to_unsigned(18,5),
    19 => to_unsigned(19,5),
    20 => to_unsigned(20,5),
    21 => to_unsigned(21,5),
    22 => to_unsigned(22,5),
    23 => to_unsigned(23,5),
    24 => to_unsigned(24,5),
    25 => to_unsigned(25,5)
  );

  signal rst      : std_logic;
  signal rd_addr  : unsigned(4 downto 0) := (others => '0'); -- 0..25
  signal letter   : unsigned(4 downto 0) := (others => '0'); -- donnée lue
  signal seg7     : std_logic_vector(6 downto 0);

  --  Détection + anti-rebond bouton 
  signal btn_prev : std_logic := '0';
  signal btn_rise : std_logic := '0';

  constant DEBOUNCE_TICKS : natural := 2_000_000; -- ~20ms à 100MHz
  signal db_cnt  : natural range 0 to DEBOUNCE_TICKS := 0;
  signal db_busy : std_logic := '0';

begin
  rst <= not CPU_RESETN;

  -- Process lecture mémoire + bouton 
  process(CLK100MHZ)
  begin
    if rising_edge(CLK100MHZ) then
      if rst = '1' then
        rd_addr  <= (others => '0');
        letter   <= (others => '0');
        btn_prev <= '0';
        btn_rise <= '0';
        db_cnt   <= 0;
        db_busy  <= '0';

      else
        -- front montant
        btn_rise <= BTNR and (not btn_prev);
        btn_prev <= BTNR;

        -- anti-rebond
        if db_busy = '1' then
          if db_cnt = DEBOUNCE_TICKS then
            db_cnt  <= 0;
            db_busy <= '0';
          else
            db_cnt <= db_cnt + 1;
          end if;
        else
          if btn_rise = '1' then
            db_busy <= '1';

            -- adresse suivante 0..25
            if rd_addr = to_unsigned(25, 5) then
              rd_addr <= (others => '0');
            else
              rd_addr <= rd_addr + 1;
            end if;
          end if;
        end if;

        -- lecture mémoire (synchrone "simple")
        letter <= mem(to_integer(rd_addr));
      end if;
    end if;
  end process;

  -- Conversion letter (0..25) -> 7seg (active-low)
  process(letter)
    variable s : std_logic_vector(6 downto 0);
  begin
    s := (others => '1'); -- tout éteint

    case to_integer(letter) is
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
      when 24 => s := "1000100"; -- y 
      when 25 => s := "0010010"; -- Z 
      when others => s := (others => '1');
    end case;

    seg7 <= s;
  end process;

  -- Sorties 7 segments 
  CA <= seg7(6);
  CB <= seg7(5);
  CC <= seg7(4);
  CD <= seg7(3);
  CE <= seg7(2);
  CF <= seg7(1);
  CG <= seg7(0);

  DP <= '1';          -- off
  AN <= "11111110";   -- AN0 actif seulement (active-low)

end architecture;
