library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top_test_audio_btn is
  port (
    CLK100MHZ  : in  std_logic;
    CPU_RESETN : in  std_logic;

    BTNR       : in  std_logic;      -- bouton M17

    -- audio
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

architecture rtl of top_test_audio_btn is
  signal rst : std_logic;

  -- index lettre
  signal idx       : unsigned(4 downto 0) := (others=>'0'); -- 0..25
  signal idx_valid : std_logic := '0';

  -- 7seg
  signal seg7     : std_logic_vector(6 downto 0);
  signal seg7_reg : std_logic_vector(6 downto 0) := (others=>'1');

  -- audio rom interface
  signal rom_addr : unsigned(31 downto 0);
  signal rom_dout : std_logic_vector(7 downto 0);

  -- audio sample
  signal sample   : std_logic_vector(7 downto 0);
  signal aud_busy : std_logic;

  -- bouton: synch + debounce simple
  signal btn_ff : std_logic_vector(2 downto 0) := (others=>'0');
  signal btn_sync : std_logic := '0';

  -- anti-rebond par "cooldown" ~ 200ms
  signal cooldown : unsigned(24 downto 0) := (others=>'0'); -- 25 bits ~ 0.33s max
  constant COOLDOWN_MAX : unsigned(24 downto 0) := to_unsigned(20_000_000, 25); -- 0.2s @100MHz

  signal btn_event : std_logic := '0';
begin
  rst <= not CPU_RESETN;

  -- ROM 7seg
  u_rom7: entity work.seg_rom_az
    port map(
      idx  => idx,
      seg7 => seg7
    );

  -- registre affichage 7seg (garde la lettre)
  process(CLK100MHZ)
  begin
    if rising_edge(CLK100MHZ) then
      if rst='1' then
        seg7_reg <= (others=>'1');
      else
        seg7_reg <= seg7;
      end if;
    end if;
  end process;

  CA <= seg7_reg(6);
  CB <= seg7_reg(5);
  CC <= seg7_reg(4);
  CD <= seg7_reg(3);
  CE <= seg7_reg(2);
  CF <= seg7_reg(1);
  CG <= seg7_reg(0);

  DP <= '1';
  AN <= "11111110"; -- AN0 only

  -- synch bouton
  process(CLK100MHZ)
  begin
    if rising_edge(CLK100MHZ) then
      if rst='1' then
        btn_ff <= (others=>'0');
      else
        btn_ff <= btn_ff(1 downto 0) & BTNR;
      end if;
    end if;
  end process;

  btn_sync <= btn_ff(2);

  -- cooldown + génération d'un seul event par appui
  process(CLK100MHZ)
  begin
    if rising_edge(CLK100MHZ) then
      if rst='1' then
        cooldown  <= (others=>'0');
        btn_event <= '0';
        idx       <= (others=>'0');
        idx_valid <= '0';
      else
        btn_event <= '0';
        idx_valid <= '0';

        -- décrémenter cooldown si actif
        if cooldown /= 0 then
          cooldown <= cooldown - 1;
        end if;

        -- si bouton pressé et pas de cooldown => événement
        if (btn_sync='1') and (cooldown = 0) then
          btn_event <= '1';
          cooldown  <= COOLDOWN_MAX;

          -- next letter
          if idx = to_unsigned(25,5) then
            idx <= (others=>'0');
          else
            idx <= idx + 1;
          end if;

          -- déclenche audio pour la nouvelle lettre
          idx_valid <= '1';
        end if;
      end if;
    end if;
  end process;

  -- ===== AUDIO PATH =====
  -- IP audio_rom (adapte la largeur addra selon ton IP)
  -- SI ton addra est 19 bits: (18 downto 0)
  u_audio_rom : entity work.audio_rom
    port map(
      clka  => CLK100MHZ,
      ena   => '1',
      addra => std_logic_vector(rom_addr(18 downto 0)),
      douta => rom_dout
    );

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

  u_pwm : entity work.pwm_dac_open_drain
    port map(
      clk100  => CLK100MHZ,
      rst     => rst,
      sample  => sample,
      aud_pwm => AUD_PWM
    );

end architecture;
