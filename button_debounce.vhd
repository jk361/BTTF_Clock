
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

  entity button_debounce is
  port(
    clk    : in  std_ulogic;
    reset  : in  std_ulogic;
    input  : in  std_ulogic;
    output : out std_ulogic
    );
  end button_debounce;

architecture rtl of button_debounce is

  signal count        : integer;
  signal deb_clk      : std_ulogic;
  signal debounce_reg : std_ulogic_vector(9 downto 0);

begin

  clk_div: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        count   <= 0;
        deb_clk <= '0';
      else
        if(count = 239999) then
          count   <= 0;
          deb_clk <= '1';
        else
          count   <= count + 1;
          deb_clk <= '0';
        end if;
      end if;
    end if;
  end process clk_div;

  debounce: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        debounce_reg <= (others => '1');
      elsif(deb_clk = '1') then
        debounce_reg(9) <= debounce_reg(8);
        debounce_reg(8) <= debounce_reg(7);
        debounce_reg(7) <= debounce_reg(6);
        debounce_reg(6) <= debounce_reg(5);
        debounce_reg(5) <= debounce_reg(4);
        debounce_reg(4) <= debounce_reg(3);
        debounce_reg(3) <= debounce_reg(2);
        debounce_reg(2) <= debounce_reg(1);
        debounce_reg(1) <= debounce_reg(0);
        debounce_reg(0) <= input;
      end if;
    end if;
  end process debounce;

  output <= debounce_reg(0) and debounce_reg(1) and debounce_reg(2) and debounce_reg(3) and debounce_reg(4) and
            debounce_reg(5) and debounce_reg(6) and debounce_reg(7) and debounce_reg(8) and debounce_reg(9);

end rtl;
