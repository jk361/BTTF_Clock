
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;
use work.components_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity top_level is
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
end top_level;

architecture struct of top_level is

  signal clk_int    : std_ulogic;

  signal reset_int  : std_ulogic;
  signal button_out : std_ulogic_vector(1 downto 0);
  signal disp_data  : time_data_type;
  signal stc_data   : time_data_type;
  signal rtc_data   : time_data_type;
  signal setting    : integer;
  signal increment  : std_ulogic;
  signal done       : std_ulogic;

begin

  clk_buf_inst: ibufg
  generic map(
    ibuf_low_pwr => true,
    iostandard   => "LVTTL"
  )
  port map(
    o => clk_int,
    i => clk
  );

  reset_i: reset_rtl
  port map(
    clk       => clk_int,
    reset_in  => reset,
    reset_out => reset_int
  );

  display_driver_i: display_driver
  port map(
    clk        => clk_int,
    reset      => reset_int,
    setting    => setting,
    time_in    => disp_data,
    year_row   => year_row,
    month_row  => month_row,
    day_row    => day_row,
    hour_row   => hour_row,
    min_row    => min_row,
    seg_col    => seg_col,
    month_col  => month_col,
    am_pm_leds => am_pm_leds,
    colon_leds => colon_leds
  );

  disp_data <= rtc_data when (setting = 0) else stc_data;
--disp_data <= rtc_data;

  set_time_int_i: set_time_int
  port map(
    clk       => clk_int,
    reset     => reset_int,
    button_in => button_in,
    setting   => setting,
    time_out  => stc_data,
    done      => done
  );

  rtc_infc_i: rtc_infc
  port map(
    clk      => clk_int,
    reset    => reset_int,
    done     => done,
    rtc_scl  => rtc_scl,
    rtc_sda  => rtc_sda,
    time_in  => stc_data,
    time_out => rtc_data
    );

  led       <= (others => '0');
  rtc_reset <= reset_int;

end struct;
