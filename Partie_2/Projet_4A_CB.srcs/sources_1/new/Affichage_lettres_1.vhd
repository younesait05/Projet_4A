library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity affichage_lettres_1 is
  generic(
    STEP_TICKS : natural := 150_000_000  
  );
  port (
    CLK100MHZ  : in  std_logic;
    CPU_RESETN : in  std_logic; 
    
    BTNR : in std_logic;
    SW0       : in  std_logic;

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

architecture rtl of affichage_lettres_1 is
  signal rst    : std_logic;
  signal letter : unsigned(4 downto 0) := (others => '0'); 
  signal seg7   : std_logic_vector(6 downto 0);

  signal tick_cnt : natural range 0 to STEP_TICKS-1 := 0;
  
  signal btn_prev : std_logic := '0';
  signal btn_rise : std_logic := '0';

  constant DEBOUNCE_TICKS : natural := 2_000_000;
  signal db_cnt  : natural range 0 to DEBOUNCE_TICKS := 0;
  signal db_busy : std_logic := '0';
  
begin
  rst <= not CPU_RESETN;

  
  process(CLK100MHZ)
begin
  if rising_edge(CLK100MHZ) then
    if rst = '1' then
      tick_cnt <= 0;
      letter   <= (others => '0');

      btn_prev <= '0';
      btn_rise <= '0';
      db_cnt   <= 0;
      db_busy  <= '0';

    else
      -- détecter front montant du bouton
      btn_rise <= BTNR and (not btn_prev);
      btn_prev <= BTNR;

      -- =========================
      -- MODE AUTO (SW0 = 1)
      -- =========================
      if SW0 = '1' then
        -- en mode auto, pas besoin d'anti-rebond
        db_cnt  <= 0;
        db_busy <= '0';

        if tick_cnt = STEP_TICKS-1 then
          tick_cnt <= 0;

          if letter = to_unsigned(25, 5) then
            letter <= (others => '0');
          else
            letter <= letter + 1;
          end if;

        else
          tick_cnt <= tick_cnt + 1;
        end if;

      -- =========================
      -- MODE MANUEL (SW0 = 0)
      -- =========================
      else
        tick_cnt <= 0; 

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

            if letter = to_unsigned(25, 5) then
              letter <= (others => '0');
            else
              letter <= letter + 1;
            end if;
          end if;
        end if;

      end if;
    end if;
  end if;
end process;



  -- Lettre -> 7 segments (active-low, seg7 = a b c d e f g)
  process(letter)
    variable s : std_logic_vector(6 downto 0);
  begin
    s := (others => '1');

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

  -- Sorties segments
  CA <= seg7(6);
  CB <= seg7(5);
  CC <= seg7(4);
  CD <= seg7(3);
  CE <= seg7(2);
  CF <= seg7(1);
  CG <= seg7(0);

  DP <= '1'; -- OFF (active-low)
  AN <= "11111110"; -- active AN0 seulement (active-low)

end architecture;
