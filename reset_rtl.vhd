
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

entity reset_rtl is
  port(
    clk       : in  std_ulogic;
    reset_in  : in  std_ulogic;
    reset_out : out std_ulogic
    );
end reset_rtl;

architecture rtl of reset_rtl is

  signal reset_count : integer range 0 to 511 := 0;

begin

  reset_gen: process(clk)
    constant reset_hold : integer := 500;
  begin
    if rising_edge(clk) then
      if(reset_in = '0') then
        reset_count <= 0;
        reset_out   <= '0';
      else
        reset_out <= '1';
        if(reset_count < reset_hold) then
          reset_out   <= '0';
          reset_count <= reset_count + 1;
        end if;
      end if;
    end if;
  end process reset_gen;

end rtl;
