
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

entity display_driver is
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
end display_driver;

architecture rtl of display_driver is

  type bcd_calc_state_type is (idle, start, calc_3, calc_2, calc_1, calc_0, assign);
  signal bcd_calc_state : bcd_calc_state_type;

  type bcd_calc_field_type is (mm, hh, dd, yy);
  signal bcd_calc_field : bcd_calc_field_type;

  signal year_bcd_array     : int_array_type;
  signal day_bcd_array      : int_array_type;
  signal hour_bcd_array     : int_array_type;
  signal minute_bcd_array   : int_array_type;
  signal array_buf          : int_array_type;
  signal input_i            : integer range 0 to 9999 := 0;
  signal seg_col_i          : std_ulogic_vector(1 downto 0);
  signal month_char         : integer range 0 to 2 := 0;
  signal disp_tick          : std_logic;
  signal tick_count         : integer range 0 to 399999;
  signal month_disp_tick    : std_logic;
  signal month_tick_count   : integer range 0 to 399999;
  signal disp_blink         : std_logic;
  signal blink_count        : integer range 0 to 24999999;
  signal colon_count        : integer range 0 to 49999999;
  signal colon_leds_i       : std_ulogic_vector(1 downto 0);
  signal prev_minute        : integer range 0 to 59;
  signal prev_year          : integer range 2000 to 2199;
  signal prev_day           : integer range 1 to 31;
  signal prev_hour          : integer range 1 to 12;
  signal start_count        : integer range 0 to 99999999;
  signal start_flag         : std_logic;

begin

  start_proc: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        start_flag  <= '0';
        start_count <= 0;
      else
        if(start_count = 49999999) then
          start_flag <= '1';
        else
          start_count <= start_count + 1;
        end if;
      end if;
    end if;
  end process start_proc;

  tick_proc: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        disp_tick  <= '0';
        tick_count <= 0;
      else
        if(tick_count = 399999) then
          disp_tick  <= '1';
          tick_count <= 0;
        else
          disp_tick  <= '0';
          tick_count <= tick_count + 1;
        end if;
      end if;
    end if;
  end process tick_proc;

  month_tick_proc: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        month_disp_tick  <= '0';
        month_tick_count <= 0;
      else
        if(month_tick_count = 249999) then
          month_disp_tick  <= '1';
          month_tick_count <= 0;
        else
          month_disp_tick  <= '0';
          month_tick_count <= month_tick_count + 1;
        end if;
      end if;
    end if;
  end process month_tick_proc;

  blink_proc: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        disp_blink  <= '0';
        blink_count <= 0;
      else
        if(blink_count = 24999999) then
          disp_blink  <= not disp_blink;
          blink_count <= 0;
        else
          blink_count <= blink_count + 1;
        end if;
      end if;
    end if;
  end process blink_proc;

  disp_year_proc: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        year_row <= (others => '0');
      else
        if(((setting = 3) and (disp_blink = '0')) or (start_flag = '0')) then
          year_row <= (others => '0');
        else
          if(disp_tick = '1') then
            if(seg_col_i = "10") then
              year_row(13 downto 7) <= seg_array(year_bcd_array(3));
              year_row(6 downto 0)  <= seg_array(year_bcd_array(1));
            elsif(seg_col_i = "01") then
              year_row(13 downto 7) <= seg_array(year_bcd_array(2));
              year_row(6 downto 0)  <= seg_array(year_bcd_array(0));
            end if;
          end if;
        end if;
      end if;
    end if;
  end process disp_year_proc;

  disp_month_proc: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        month_row  <= (others => '0');
        month_col  <= (others => '0');
        month_char <= 0;
      else
        if(((setting = 1) and (disp_blink = '0')) or (start_flag = '0')) then
          month_row  <= (others => '0');
          month_col  <= (others => '0');
          month_char <= 0;
        else
          if(month_disp_tick = '1') then
            if(month_char = 0) then
              month_char <= 1;
              month_row  <= month_lookup(time_in.month)(2);
              month_col  <= "100";
            elsif(month_char = 1) then
              month_char <= 2;
              month_row  <= month_lookup(time_in.month)(1);
              month_col  <= "010";
            elsif(month_char = 2) then
              month_char <= 0;
              month_row  <= month_lookup(time_in.month)(0);
              month_col  <= "001";
            end if;
          end if;
        end if;
      end if;
    end if;
  end process disp_month_proc;

  disp_day_proc: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        day_row <= (others => '0');
      else
        if(((setting = 2) and (disp_blink = '0')) or (start_flag = '0')) then
          day_row <= (others => '0');
        else
          if(disp_tick = '1') then
            if(seg_col_i = "10") then
              day_row <= seg_array_nz(day_bcd_array(1));
            elsif(seg_col_i = "01") then
              day_row <= seg_array(day_bcd_array(0));
            end if;
          end if;
        end if;
      end if;
    end if;
  end process disp_day_proc;

  disp_hour_proc: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        hour_row <= (others => '0');
      else
        if(((setting = 5) and (disp_blink = '0')) or (start_flag = '0')) then
          hour_row <= (others => '0');
        else
          if(disp_tick = '1') then
            if(seg_col_i = "10") then
              hour_row <= seg_array_nz(hour_bcd_array(1));
            elsif(seg_col_i = "01") then
              hour_row <= seg_array(hour_bcd_array(0));
            end if;
          end if;
        end if;
      end if;
    end if;
  end process disp_hour_proc;

  disp_minute_proc: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        min_row <= (others => '0');
      else
        if(((setting = 6) and (disp_blink = '0')) or (start_flag = '0')) then
          min_row <= (others => '0');
        else
          if(disp_tick = '1') then
            if(seg_col_i = "10") then
              min_row <= seg_array(minute_bcd_array(1));
            elsif(seg_col_i = "01") then
              min_row <= seg_array(minute_bcd_array(0));
            end if;
          end if;
        end if;
      end if;
    end if;
  end process disp_minute_proc;

  seg_col_proc: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        seg_col   <= (others => '0');
        seg_col_i <= (others => '0');
      else
        seg_col <= seg_col_i;

        if(disp_tick = '1') then
          if(seg_col_i = "10") then
            seg_col_i <= "01";
          else
            seg_col_i <= "10";
          end if;
        end if;
      end if;
    end if;
  end process seg_col_proc;

  leds_proc: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        colon_leds_i <= (others => '0');
        colon_count  <= 0;
        am_pm_leds   <= (others => '0');
      else
        if((setting = 0) and (start_flag = '1')) then
          if(colon_count = 24999999) then
            colon_count <= 0;
            colon_leds_i <= not colon_leds_i;
          else
            colon_count <= colon_count + 1;
          end if;
        else
          colon_leds_i <= (others => '0');
        end if;

        if(((setting = 4) and (disp_blink = '0')) or (start_flag = '0')) then
          am_pm_leds  <= (others => '0');
        else
          am_pm_leds <= time_in.pm & not(time_in.pm);
        end if;
      end if;
    end if;
  end process leds_proc;

  colon_leds <= colon_leds_i;

  bcd_proc: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        prev_year        <= 2000;
        prev_day         <= 1;
        prev_hour        <= 1;
        prev_minute      <= 0;
        year_bcd_array   <= (others => 0);
        day_bcd_array    <= (others => 0);
        hour_bcd_array   <= (others => 0);
        minute_bcd_array <= (others => 0);
        array_buf        <= (others => 0);
        bcd_calc_state   <= idle;
        bcd_calc_field   <= mm;
      else

        case bcd_calc_state is

          when idle =>
            if(time_in.year /= prev_year) or (time_in.day /= prev_day) or (time_in.hour /= prev_hour) or (time_in.minute /= prev_minute) then
              bcd_calc_state <= start;
            end if;

          when start =>
            array_buf      <= (others => 0);
            bcd_calc_state <= calc_3;

            if(bcd_calc_field = mm) then
              input_i <= time_in.minute;
            elsif(bcd_calc_field = hh) then
              input_i <= time_in.hour;
            elsif(bcd_calc_field = dd) then
              input_i <= time_in.day;
            elsif(bcd_calc_field = yy) then
              input_i <= time_in.year;
            end if;

          when calc_3 =>
            if(input_i > 999) then
              array_buf(3) <= array_buf(3) + 1;
              input_i      <= input_i - 1000;
            else
              bcd_calc_state <= calc_2;
            end if;

          when calc_2 =>
            if(input_i > 99) then
              array_buf(2) <= array_buf(2) + 1;
              input_i      <= input_i - 100;
            else
              bcd_calc_state <= calc_1;
            end if;

          when calc_1 =>
            if(input_i > 9) then
              array_buf(1) <= array_buf(1) + 1;
              input_i      <= input_i - 10;
            else
              bcd_calc_state <= calc_0;
            end if;

          when calc_0 =>
            array_buf(0)   <= input_i;
            bcd_calc_state <= assign;

          when assign =>
            if(bcd_calc_field = mm) then
              minute_bcd_array <= array_buf;
              bcd_calc_state   <= start;
              bcd_calc_field   <= hh;
            elsif(bcd_calc_field = hh) then
              hour_bcd_array <= array_buf;
              bcd_calc_state <= start;
              bcd_calc_field <= dd;
            elsif(bcd_calc_field = dd) then
              day_bcd_array  <= array_buf;
              bcd_calc_state <= start;
              bcd_calc_field <= yy;
            elsif(bcd_calc_field = yy) then
              year_bcd_array <= array_buf;
              bcd_calc_state <= idle;
              bcd_calc_field <= mm;
            end if;

          when others =>
            bcd_calc_state <= idle;

        end case;

        prev_year   <= time_in.year;
        prev_day    <= time_in.day;
        prev_hour   <= time_in.hour;
        prev_minute <= time_in.minute;
      end if;
    end if;
  end process bcd_proc;

end rtl;

