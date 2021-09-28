
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

entity real_time_counter is
  port(
    clk       : in  std_ulogic;
    reset     : in  std_ulogic;
    rtc_clk   : in  std_ulogic;
    setting   : in  integer;
    increment : in  std_ulogic;
    time_in   : in  time_data_type;
    time_out  : out time_data_type
    );
end real_time_counter;

architecture rtl of real_time_counter is

  type month_array_type is array (integer range 1 to 12) of integer;

  constant month_array    : month_array_type := (31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);
  constant month_array_ly : month_array_type := (31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);

  signal second_tick      : std_logic;
  signal tick_count       : integer range 0 to 49999999;
  signal second_i         : integer range 0 to 60;

  signal minute_i         : integer range 0 to 59;
  signal hour_i           : integer range 1 to 12;
  signal pm_i             : std_ulogic;
  signal day_i            : integer range 1 to 31;
  signal month_i          : integer range 1 to 12;
  signal year_i           : integer range 1985 to 4095;
  signal year_u           : std_ulogic_vector(11 downto 0);

  signal rtc_clk_reg      : std_ulogic_vector(2 downto 0);
  signal rtc_clk_pos_edge : std_ulogic;
  signal rtc_clk_count    : integer;

begin

  second_tick_proc: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        second_tick <= '0';
        tick_count  <= 0;
      else
        second_tick <= '0';

        if(rtc_clk_pos_edge = '1') then
          if(tick_count = 32767) then
            second_tick <= '1';
            tick_count  <= 0;
          else
            tick_count  <= tick_count + 1;
          end if;
        end if;
      end if;
    end if;
  end process second_tick_proc;

  time_counter_proc: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        second_i <= 0;
        minute_i <= 21;
        hour_i   <= 1;
        pm_i     <= '0';
        day_i    <= 26;
        month_i  <= 10;
        year_i   <= 1985;
        year_u   <= (others =>'0');
      else
        year_u <= std_ulogic_vector(to_unsigned(year_i, 12));

        if(setting = 1) then
          if(increment = '1') then
            if(month_i = 12) then
              month_i <= 1;
            else
              month_i <= month_i + 1;
            end if;
          end if;
        elsif(setting = 2) then
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
        elsif(setting = 3) then
          if(increment = '1') then
            year_i <= year_i + 1;
          end if;
        elsif(setting = 4) then
          if(increment = '1') then
            pm_i <= not(pm_i);
          end if;
        elsif(setting = 5) then
          if(increment = '1') then
            if(hour_i = 12) then
              hour_i <= 1;
            else
              hour_i <= hour_i + 1;
            end if;
          end if;
        elsif(setting = 6) then
          second_i <= 0;

          if(increment = '1') then
            if(minute_i = 59) then
              minute_i <= 0;
            else
              minute_i <= minute_i + 1;
            end if;
          end if;

        elsif(second_tick = '1') then
          if(second_i = 59) then
            second_i <= 0;

            if(minute_i = 59) then
              minute_i <= 0;

              if(hour_i = 11) then
                pm_i <= not(pm_i);
                hour_i <= 12;

              elsif(hour_i = 12) then
                hour_i <= 1;

                if(pm_i = '1') then
                  if(year_u(1 downto 0) = "00") then
                    if(day_i = month_array_ly(month_i)) then
                      day_i <= 1;

                      if(month_i = 12) then
                        month_i <= 1;

                        if(year_i < 4095) then
                          year_i  <= year_i + 1;
                        end if;
                      else
                        month_i <= month_i + 1;
                      end if;
                    else
                      day_i <= day_i + 1;
                    end if;
                  else
                    if(day_i = month_array(month_i)) then
                      day_i <= 1;

                      if(month_i = 12) then
                        month_i <= 1;

                        if(year_i < 4095) then
                          year_i  <= year_i + 1;
                        end if;
                      else
                        month_i <= month_i + 1;
                      end if;
                    else
                      day_i <= day_i + 1;
                    end if;
                  end if;
                end if;
              else
                hour_i <= hour_i + 1;
              end if;
            else
              minute_i <= minute_i + 1;
            end if;
          else
            second_i <= second_i + 1;
          end if;
        end if;
      end if;
    end if;
  end process time_counter_proc;

  rtc_clk_reg_proc: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        rtc_clk_reg      <= (others => '0');
        rtc_clk_count    <= 0;
        rtc_clk_pos_edge <= '0';
      else
        rtc_clk_pos_edge <= '0';

        if(rtc_clk_count = 124) then
          rtc_clk_reg(2 downto 1) <= rtc_clk_reg(1 downto 0);
          rtc_clk_reg(0)          <= rtc_clk;
          rtc_clk_count           <= 0;

          if(rtc_clk_reg(2 downto 1) = "01") then
            rtc_clk_pos_edge <= '1';
          else
            rtc_clk_pos_edge <= '0';
          end if;
        else
          rtc_clk_count <= rtc_clk_count + 1;
        end if;
      end if;
    end if;
  end process rtc_clk_reg_proc;

  time_out.second <= second_i;
  time_out.minute <= minute_i;
  time_out.hour   <= hour_i;
  time_out.pm     <= pm_i;
  time_out.day    <= day_i;
  time_out.month  <= month_i;
  time_out.year   <= year_i;

end rtl;
