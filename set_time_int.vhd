
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;
use work.components_pkg.all;

entity set_time_int is
  port(
    clk       : in  std_ulogic;
    reset     : in  std_ulogic;
    button_in : in  std_ulogic_vector(1 downto 0);
    time_out  : out time_data_type;
    setting   : out integer;
    done      : out std_ulogic
    );
end set_time_int;

architecture rtl of set_time_int is

  type set_time_state_type is (idle, set_month, set_day, set_year, set_pm, set_hour, set_min, latch_op);
  signal set_time_state : set_time_state_type;

  type month_array_type is array (integer range 1 to 12) of integer;
  constant month_array    : month_array_type := (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
  constant month_array_ly : month_array_type := (31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

  signal mode_count    : integer range 0 to 99999999;

  signal button_deb    : std_ulogic_vector(1 downto 0);
  signal button_0_reg  : std_ulogic_vector(2 downto 0);
  signal button_1_reg  : std_ulogic_vector(2 downto 0);
  signal button_0_edge : std_ulogic;
  signal button_1_edge : std_ulogic;
  signal setting_i     : integer;
  signal increment     : std_ulogic;
  signal minute_i      : integer range 0 to 59;
  signal hour_i        : integer range 1 to 12;
  signal pm_i          : std_ulogic;
  signal day_i         : integer range 1 to 31;
  signal month_i       : integer range 1 to 12;
  signal year_i        : integer range 1985 to 4095;
  signal year_u        : std_ulogic_vector(11 downto 0);

begin

  button_debounce_1: button_debounce
  port map(
    clk    => clk,
    reset  => reset,
    input  => button_in(1),
    output => button_deb(1)
  );

  button_debounce_0: button_debounce
  port map(
    clk    => clk,
    reset  => reset,
    input  => button_in(0),
    output => button_deb(0)
  );

  set_time_proc: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        setting_i      <= 0;
        increment      <= '0';
        done           <= '0';
        set_time_state <= idle;
      else
        done <= '0';

        case set_time_state is

          when idle =>
            setting_i <= 0;

            if(button_deb(1) = '0') then
              if(mode_count = 99999999) then
                set_time_state <= set_year;
                mode_count     <= 0;
              else
                mode_count <= mode_count + 1;
              end if;
            else
              mode_count <= 0;
            end if;

          when set_year =>
            setting_i <= 3;
            increment <= button_0_edge;

            if(button_1_edge = '1') then
              set_time_state <= set_month;
            end if;

          when set_month =>
            setting_i <= 1;
            increment <= button_0_edge;

            if(button_1_edge = '1') then
              set_time_state <= set_day;
            end if;

          when set_day =>
            setting_i <= 2;
            increment <= button_0_edge;

            if(button_1_edge = '1') then
              set_time_state <= set_pm;
            end if;

          when set_pm =>
            setting_i <= 4;
            increment <= button_0_edge;

            if(button_1_edge = '1') then
              set_time_state <= set_hour;
            end if;

          when set_hour =>
            setting_i <= 5;
            increment <= button_0_edge;

            if(button_1_edge = '1') then
              set_time_state <= set_min;
            end if;

          when set_min =>
            setting_i <= 6;
            increment <= button_0_edge;

            if(button_1_edge = '1') then
              done           <= '1';
              set_time_state <= idle;
            end if;

          when others =>
            set_time_state <= idle;

        end case;

      end if;
    end if;
  end process set_time_proc;

  setting <= setting_i;

  time_counter_proc: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        minute_i <= 21;
        hour_i   <= 1;
        pm_i     <= '1';
        day_i    <= 15;
        month_i  <= 7;
        year_i   <= 2005;
        year_u   <= (others =>'0');
      else
        year_u <= std_ulogic_vector(to_unsigned(year_i, 12));

        if(setting_i = 1) then
          if(increment = '1') then
            if(month_i = 12) then
              month_i <= 1;
            else
              month_i <= month_i + 1;
            end if;
          end if;
        elsif(setting_i = 2) then
          if(increment = '1') then
            if(year_u(1 downto 0) = "00") then
              if(day_i = month_array_ly(month_i)) then
                day_i <= 1;
              else
                day_i <= day_i + 1;
              end if;
            else
              if(day_i = month_array(month_i)) then
                day_i <= 1;
              else
                day_i <= day_i + 1;
              end if;
            end if;
          end if;
        elsif(setting_i = 3) then
          if(increment = '1') then
            year_i <= year_i + 1;
          end if;
        elsif(setting_i = 4) then
          if(increment = '1') then
            pm_i <= not(pm_i);
          end if;
        elsif(setting_i = 5) then
          if(increment = '1') then
            if(hour_i = 12) then
              hour_i <= 1;
            else
              hour_i <= hour_i + 1;
            end if;
          end if;
        elsif(setting_i = 6) then
          if(increment = '1') then
            if(minute_i = 59) then
              minute_i <= 0;
            else
              minute_i <= minute_i + 1;
            end if;
          end if;
        end if;
      end if;
    end if;
  end process time_counter_proc;

  time_out.second <= 0;
  time_out.minute <= minute_i;
  time_out.hour   <= hour_i;
  time_out.pm     <= pm_i;
  time_out.day    <= day_i;
  time_out.month  <= month_i;
  time_out.year   <= year_i;

  button_reg_proc: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        button_0_reg <= (others => '0');
        button_1_reg <= (others => '0');
      else
        button_0_reg(2) <= button_0_reg(1);
        button_0_reg(1) <= button_0_reg(0);
        button_0_reg(0) <= button_deb(0);
        button_1_reg(2) <= button_1_reg(1);
        button_1_reg(1) <= button_1_reg(0);
        button_1_reg(0) <= button_deb(1);
      end if;
    end if;
  end process button_reg_proc;

  button_0_edge <= button_0_reg(2) and not(button_0_reg(1));
  button_1_edge <= button_1_reg(2) and not(button_1_reg(1));

end rtl;

