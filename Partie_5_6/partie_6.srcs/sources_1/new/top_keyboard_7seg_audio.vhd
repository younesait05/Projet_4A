library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_keyboard_7seg_audio is
  generic(
    AUDIO_ADDR_W : natural := 19  -- largeur addra de l'IP audio_rom (ex: 19 bits => 18 downto 0)
  );
  port (
    CLK100MHZ  : in  std_logic;
    CPU_RESETN : in  std_logic;

    -- PS/2
    PS2_CLK    : in  std_logic;
    PS2_DATA   : in  std_logic;

    -- Audio PWM (jack mono)
    AUD_PWM    : out std_logic;

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

architecture rtl of top_keyboard_7seg_audio is
  signal rst : std_logic;

  -- PS/2 receiver
  signal scancode : std_logic_vector(7 downto 0);
  signal sc_valid : std_logic;

  -- Key decode
  signal idx       : unsigned(4 downto 0);
  signal idx_valid : std_logic;

  -- 7seg
  signal seg7     : std_logic_vector(6 downto 0);
  signal seg7_reg : std_logic_vector(6 downto 0) := (others => '1');

  -- Audio ROM interface
  signal rom_addr : unsigned(31 downto 0);
  signal rom_dout : std_logic_vector(7 downto 0);

  -- Audio sample
  signal sample   : std_logic_vector(7 downto 0);
  signal aud_busy : std_logic;

begin
  rst <= not CPU_RESETN;

  -- A) Récepteur PS/2
  u_ps2 : entity work.ps2_receiver
    port map(
      clk100   => CLK100MHZ,
      rst      => rst,
      ps2_clk  => PS2_CLK,
      ps2_data => PS2_DATA,
      data_out => scancode,
      valid    => sc_valid
    );

  -- B) Filtre make/break + conversion scancode -> idx (0..25)
  u_key : entity work.key_to_idx
    port map(
      clk100    => CLK100MHZ,
      rst       => rst,
      scancode  => scancode,
      sc_valid  => sc_valid,
      idx       => idx,
      idx_valid => idx_valid
    );

  -- C) ROM idx -> segments
  u_rom7 : entity work.seg_rom_az
    port map(
      idx  => idx,
      seg7 => seg7
    );

  -- D) Registre d'affichage (mise à jour uniquement si lettre valide)
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

  DP <= '1';
  AN <= "11111110";  -- AN0 seulement

  -- =====================
  -- ====== AUDIO ========
  -- =====================

  -- ROM audio (IP Block Memory Generator)
  -- NOTE: l'IP a été configurée avec ENA => connecter ena='1'
  u_audio_rom : entity work.audio_rom
    port map(
      clka  => CLK100MHZ,
      ena   => '1',
      addra => std_logic_vector(rom_addr(AUDIO_ADDR_W-1 downto 0)),
      douta => rom_dout
    );

  -- Lecteur audio : déclenché sur idx_valid (1 lettre -> 1 lecture)
  u_player : entity work.audio_player
    port map(
      clk100     => CLK100MHZ,
      rst        => rst,
      idx        => idx,
      idx_valid  => idx_valid,
      rom_dout   => rom_dout,
      rom_addr   => rom_addr,
      sample_out => sample,
      busy       => aud_busy
    );

  -- PWM open-drain -> sortie AUD_PWM
  u_pwm : entity work.pwm_dac_open_drain
    port map(
      clk100  => CLK100MHZ,
      rst     => rst,
      sample  => sample,
      aud_pwm => AUD_PWM
    );

end architecture;
