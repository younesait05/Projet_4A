library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use std.textio.all;
use ieee.std_logic_textio.all;

entity tb_file_to_7seg is
end entity;

architecture tb of lettres_fichier is
  signal btn_next   : std_logic := '0'; -- simule un bouton (ex: BTNR)
  

  -- Convertit un caractère 'a'..'z' ou 'A'..'Z' en 0..25, sinon -1
  function char_to_idx(c : character) return integer is
  begin
    if (c >= 'a') and (c <= 'z') then
      return character'pos(c) - character'pos('a');
    elsif (c >= 'A') and (c <= 'Z') then
      return character'pos(c) - character'pos('A');
    else
      return -1;
    end if;
  end function;

begin
  -- DUT : conversion index -> 7seg
  dut: entity work.lettres_fichier
    port map(
      letter_idx => letter_idx,
      seg        => seg
    );

  -- Génère des appuis bouton en simulation (un pulse toutes les 200 ns)
  p_btn: process
  begin
    wait for 200 ns;
    for k in 1 to 40 loop
      btn_next <= '1';
      wait for 20 ns;
      btn_next <= '0';
      wait for 180 ns;
    end loop;
    wait;
  end process;

  -- Lecture du fichier à chaque appui + écriture résultat
  p_read_write: process
    file fin  : text open read_mode  is "letters_in.txt";
    file fout : text open write_mode is "letters_out.txt";

    variable L    : line;
    variable O    : line;
    variable c    : character;
    variable idx  : integer;
  begin
    -- attend le premier "appui"
    wait until rising_edge(btn_next);

    while not endfile(fin) loop
      readline(fin, L);

      -- prend le 1er caractère de la ligne
      if L'length > 0 then
        read(L, c);
        idx := char_to_idx(c);
      else
        idx := -1;
      end if;

      -- met à jour la lettre (si invalide: A par défaut)
      if (idx >= 0) and (idx <= 25) then
        letter_idx <= to_unsigned(idx, 5);
      else
        letter_idx <= (others => '0');
      end if;

      wait for 1 ns; -- laisse seg se stabiliser (combinatoire)

      -- écrit dans le fichier résultat: lettre + index + segments
      write(O, c);
      write(O, string'("  idx="));
      write(O, idx);
      write(O, string'("  seg="));
      write(O, seg);          -- écrit 7 bits (std_logic_vector)
      writeline(fout, O);

      -- attend appui suivant
      wait until rising_edge(btn_next);
    end loop;

    file_close(fin);
    file_close(fout);
    wait;
  end process;

end architecture;
