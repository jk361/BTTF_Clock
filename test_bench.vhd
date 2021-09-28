
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity test_bench is
end test_bench;

architecture behavioral of test_bench is

  component top_level
  port(
    clk        : in    std_ulogic;
    reset      : in    std_ulogic;
    button_in  : in    std_ulogic_vector(1 downto 0);
    rtc_reset  : out   std_ulogic;
    rtc_scl    : inout std_logic;
    rtc_sda    : inout std_logic;
    year_row   : out   std_ulogic_vector(13 downto 0);
    month_row  : out   std_ulogic_vector(15 downto 0);
    day_row    : out   std_ulogic_vector(6 downto 0);
    hour_row   : out   std_ulogic_vector(6 downto 0);
    min_row    : out   std_ulogic_vector(6 downto 0);
    seg_col    : out   std_ulogic_vector(1 downto 0);
    month_col  : out   std_ulogic_vector(2 downto 0);
    am_pm_leds : out   std_ulogic_vector(1 downto 0);
    colon_leds : out   std_ulogic_vector(1 downto 0);
    led        : out   std_ulogic_vector(7 downto 0)
    );
  end component top_level;

  component ds3231_bus_model
  port(
    rtc_reset : in    std_ulogic;
    rtc_scl   : inout std_logic;
    rtc_sda   : inout std_logic;
    rtc_clk   : out   std_ulogic
    );
  end component ds3231_bus_model;

  constant clk_period : time := 20 ns;
  constant rtc_period : time := 30518 ns;
  signal   clk        : std_ulogic := '0';
  signal   reset      : std_ulogic := '0';
  signal   button_in  : std_ulogic_vector(1 downto 0) := (others => '0');
  signal   rtc_reset  : std_ulogic;
  signal   rtc_scl    : std_logic := '1';
  signal   rtc_sda    : std_logic := '1';
  signal   rtc_clk    : std_ulogic := '0';
  signal   year_row   : std_ulogic_vector(13 downto 0);
  signal   month_row  : std_ulogic_vector(15 downto 0);
  signal   day_row    : std_ulogic_vector(6 downto 0);
  signal   hour_row   : std_ulogic_vector(6 downto 0);
  signal   min_row    : std_ulogic_vector(6 downto 0);
  signal   seg_col    : std_ulogic_vector(1 downto 0);
  signal   month_col  : std_ulogic_vector(2 downto 0);
  signal   am_pm_leds : std_ulogic_vector(1 downto 0);
  signal   colon_leds : std_ulogic_vector(1 downto 0);
  signal   led        : std_ulogic_vector(7 downto 0);

begin

  uut: top_level
  port map(
    clk        => clk,
    reset      => reset,
    button_in  => button_in,
    rtc_reset  => rtc_reset,
    rtc_scl    => rtc_scl,
    rtc_sda    => rtc_sda,
    month_row  => month_row,
    month_col  => month_col,
    year_row   => year_row,
    day_row    => day_row,
    hour_row   => hour_row,
    min_row    => min_row,
    seg_col    => seg_col,
    am_pm_leds => am_pm_leds,
    colon_leds => colon_leds,
    led        => led
    );

--ds3231_bus_model_i: ds3231_bus_model
--port map(
--  rtc_reset => reset,
--  rtc_scl   => rtc_scl,
--  rtc_sda   => rtc_sda,
--  rtc_clk   => rtc_clk
--  );

  clk_process :process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;

  stim_proc: process
  begin
    reset     <= '0';
    button_in <= (others => '1');
    wait for clk_period * 100;

    reset <= '1';
    wait for clk_period * 100000;

--  button_in <= "01";
--  wait for clk_period * 101000000;
--  button_in <= "11";
--  wait for clk_period * 25000000;
--
--  button_in <= "10";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 25000000;
--  button_in <= "10";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 50000000;
--
--  button_in <= "01";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 25000000;
--  button_in <= "10";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 25000000;
--  button_in <= "10";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 50000000;
--
--  button_in <= "01";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 25000000;
--  button_in <= "10";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 25000000;
--  button_in <= "10";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 50000000;
--
--  button_in <= "01";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 25000000;
--  button_in <= "10";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 25000000;
--  button_in <= "10";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 50000000;
--
--  button_in <= "01";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 25000000;
--  button_in <= "10";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 25000000;
--  button_in <= "10";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 50000000;
--
--  button_in <= "01";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 25000000;
--  button_in <= "10";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 25000000;
--  button_in <= "10";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 50000000;
--
--  button_in <= "01";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 100000000;
--
--
--
--
--
--  button_in <= "01";
--  wait for clk_period * 101000000;
--  button_in <= "11";
--  wait for clk_period * 25000000;
--
--  button_in <= "10";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 25000000;
--  button_in <= "10";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 50000000;
--
--  button_in <= "01";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 25000000;
--  button_in <= "10";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 25000000;
--  button_in <= "10";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 50000000;
--
--  button_in <= "01";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 25000000;
--  button_in <= "10";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 25000000;
--  button_in <= "10";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 50000000;
--
--  button_in <= "01";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 25000000;
--  button_in <= "10";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 25000000;
--  button_in <= "10";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 50000000;
--
--  button_in <= "01";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 25000000;
--  button_in <= "10";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 25000000;
--  button_in <= "10";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 50000000;
--
--  button_in <= "01";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 25000000;
--  button_in <= "10";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 25000000;
--  button_in <= "10";
--  wait for clk_period * 250000;
--  button_in <= "11";
--  wait for clk_period * 50000000;
--
--  button_in <= "01";
--  wait for clk_period * 250000;
--  button_in <= "11";

    wait;
   end process;

end behavioral;
