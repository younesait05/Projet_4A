library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_keyboard_7seg is
  port (
    CLK100MHZ  : in  std_logic;
    CPU_RESETN : in  std_logic;

    -- PS/2 depuis le port USB-HOST (via PIC24 sur Nexys4 DDR)
    PS2_CLK    : in  std_logic;
    PS2_DATA   : in  std_logic;

    -- 7-seg
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

architecture rtl of top_keyboard_7seg is
  signal rst : std_logic;

  -- Sortie bloc PS2 receiver
  signal scancode  : std_logic_vector(7 downto 0);
  signal sc_valid  : std_logic;

  -- Sortie bloc filtrage + traduction
  signal idx       : unsigned(4 downto 0);
  signal idx_valid : std_logic;

  -- ROM 7seg
  signal seg7      : std_logic_vector(6 downto 0);

  -- registre d'affichage (garde la dernière lettre valide)
  signal seg7_reg  : std_logic_vector(6 downto 0) := (others => '1');

begin
  rst <= not CPU_RESETN;

  -- A) Récepteur PS/2 : trame 11 bits -> scancode + pulse valid
  u_ps2: entity work.ps2_receiver
    port map(
      clk100   => CLK100MHZ,
      rst      => rst,
      ps2_clk  => PS2_CLK,
      ps2_data => PS2_DATA,
      data_out => scancode,
      valid    => sc_valid
    );

  -- B+C) Filtre make/break + conversion scancode(Set2) -> index 0..25
  u_key: entity work.key_to_idx
    port map(
      clk100    => CLK100MHZ,
      rst       => rst,
      scancode  => scancode,
      sc_valid  => sc_valid,
      idx       => idx,
      idx_valid => idx_valid
    );

  -- D) ROM (style BRAM) : index -> pattern 7 segments
  u_rom: entity work.seg_rom_az
    port map(
      idx  => idx,
      seg7 => seg7
    );

  -- Registre d'affichage : on met à jour seulement si lettre valide
  process(CLK100MHZ)
  begin
    if rising_edge(CLK100MHZ) then
      if rst = '1' then
        seg7_reg <= (others => '1');
      else
        if idx_valid = '1' then
          seg7_reg <= seg7;
        end if;
      end if;
    end if;
  end process;

  -- Sorties 7 segments (active-low)
  CA <= seg7_reg(6);
  CB <= seg7_reg(5);
  CC <= seg7_reg(4);
  CD <= seg7_reg(3);
  CE <= seg7_reg(2);
  CF <= seg7_reg(1);
  CG <= seg7_reg(0);

  DP <= '1';        -- off
  AN <= "11111110"; -- AN0 actif seulement (active-low)

end architecture;
