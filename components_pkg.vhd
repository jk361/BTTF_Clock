
library ieee;
use ieee.std_logic_1164.all;
use work.utils_pkg.all;

package components_pkg is

  component reset_rtl
  port(
    clk       : in  std_ulogic;
    reset_in  : in  std_ulogic;
    reset_out : out std_ulogic
    );
  end component reset_rtl;

  component real_time_counter is
  port(
    clk       : in  std_ulogic;
    reset     : in  std_ulogic;
    rtc_clk   : in  std_ulogic;
    setting   : in  integer;
    increment : in  std_ulogic;
    time_in   : in  time_data_type;
    time_out  : out time_data_type
    );
  end component real_time_counter;

  component display_driver is
  port(
    clk        : in  std_ulogic;
    reset      : in  std_ulogic;
    setting    : in  integer;
    time_in    : in  time_data_type;
    year_row   : out std_ulogic_vector(13 downto 0);
    month_row  : out std_ulogic_vector(15 downto 0);
    day_row    : out std_ulogic_vector(6 downto 0);
    hour_row   : out std_ulogic_vector(6 downto 0);
    min_row    : out std_ulogic_vector(6 downto 0);
    seg_col    : out std_ulogic_vector(1 downto 0);
    month_col  : out std_ulogic_vector(2 downto 0);
    am_pm_leds : out std_ulogic_vector(1 downto 0);
    colon_leds : out std_ulogic_vector(1 downto 0)
    );
  end component display_driver;

  component set_time_int is
  port(
    clk       : in  std_ulogic;
    reset     : in  std_ulogic;
    button_in : in  std_ulogic_vector(1 downto 0);
    setting   : out integer;
    time_out  : out time_data_type;
    done      : out std_ulogic
    );
  end component set_time_int;

  component button_debounce is
  port(
    clk    : in  std_ulogic;
    reset  : in  std_ulogic;
    input  : in  std_ulogic;
    output : out std_ulogic
    );
  end component button_debounce;

  component rtc_infc is
  port(
    clk      : in    std_ulogic;
    reset    : in    std_ulogic;
    done     : in    std_ulogic;
    rtc_scl  : inout std_logic;
    rtc_sda  : inout std_logic;
    time_in  : in    time_data_type;
    time_out : out   time_data_type
    );
  end component rtc_infc;


end package components_pkg;
