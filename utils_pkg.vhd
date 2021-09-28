
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package utils_pkg is

  type alpha_array_type  is array (integer range 0 to 18) of std_ulogic_vector(15 downto 0);
  type month_array_type  is array (integer range 0 to 2)  of std_ulogic_vector(15 downto 0);
  type month_lookup_type is array (integer range 1 to 12) of month_array_type;

  constant alph_array   : alpha_array_type := ("1110001111000100", "1100101010010111", "1110000001000011", "1100101000010111", "1110000111000011", "1110000101000000", "1110000011000111", "0000001001000111",
                                               "0010000001000011", "0011011001000100", "0011001001001100", "1110001001000111", "1110001111000000", "1110001111001000", "1110000110000111", "1100100000010000",
                                               "0010001001000111", "0010010001100000", "0001010000010000");

  constant month_jan    : month_array_type := (alph_array(7),  alph_array(0),  alph_array(10));
  constant month_feb    : month_array_type := (alph_array(5),  alph_array(4),  alph_array(1));
  constant month_mar    : month_array_type := (alph_array(9),  alph_array(0),  alph_array(13));
  constant month_apr    : month_array_type := (alph_array(0),  alph_array(12), alph_array(13));
  constant month_may    : month_array_type := (alph_array(9),  alph_array(0),  alph_array(18));
  constant month_jun    : month_array_type := (alph_array(7),  alph_array(16), alph_array(10));
  constant month_jul    : month_array_type := (alph_array(7),  alph_array(16), alph_array(8));
  constant month_aug    : month_array_type := (alph_array(0),  alph_array(16), alph_array(6));
  constant month_sep    : month_array_type := (alph_array(14), alph_array(4),  alph_array(12));
  constant month_oct    : month_array_type := (alph_array(11), alph_array(2),  alph_array(15));
  constant month_nov    : month_array_type := (alph_array(10), alph_array(11), alph_array(17));
  constant month_dec    : month_array_type := (alph_array(3),  alph_array(4),  alph_array(2));
  constant month_lookup : month_lookup_type := (month_jan, month_feb, month_mar, month_apr, month_may, month_jun, month_jul, month_aug, month_sep, month_oct, month_nov, month_dec);

  type seg_array_type  is array (integer range 0 to 9) of std_ulogic_vector(6 downto 0);
  constant seg_array    : seg_array_type := ("1101111", "0001001", "1011110", "1011011", "0111001", "1110011", "1110111", "1001001", "1111111", "1111011");
  constant seg_array_nz : seg_array_type := ("0000000", "0001001", "1011110", "1011011", "0111001", "1110011", "1110111", "1001001", "1111111", "1111011");

  type int_array_type is array (integer range 0 to 3) of integer range 0 to 9999;
  type i2c_data_array_type is array (integer range 0 to 6) of std_ulogic_vector(7 downto 0);

  type time_data_type is record
    second : integer range 0 to 59;
    minute : integer range 0 to 59;
    hour   : integer range 1 to 12;
    pm     : std_ulogic;
    day    : integer range 1 to 31;
    month  : integer range 1 to 12;
    year   : integer;
  end record time_data_type;

  type i2c_packet_type is record
    addr : std_ulogic_vector(6 downto 0);
    r_w  : std_ulogic;
    reg  : std_ulogic_vector(7 downto 0);
    dlen : integer;
    ack  : std_ulogic_vector(8 downto 0);
    data : i2c_data_array_type;
  end record i2c_packet_type;

  function conv_bcd(input : time_data_type) return i2c_data_array_type;

end utils_pkg;

package body utils_pkg is

  function conv_bcd(input : time_data_type) return i2c_data_array_type is
  variable minute_i  : std_ulogic_vector(7 downto 0);
  variable hour_i    : std_ulogic_vector(7 downto 0);
  variable day_i     : std_ulogic_vector(7 downto 0);
  variable month_i   : std_ulogic_vector(7 downto 0);
  variable year_i    : std_ulogic_vector(7 downto 0);
  variable year_cent : integer;
  begin
    if(input.minute > 49) then
      minute_i := X"5" & std_ulogic_vector(to_unsigned(input.minute - 50, 4));
    elsif(input.minute > 39) then
      minute_i := X"4" & std_ulogic_vector(to_unsigned(input.minute - 40, 4));
    elsif(input.minute > 29) then
      minute_i := X"3" & std_ulogic_vector(to_unsigned(input.minute - 30, 4));
    elsif(input.minute > 19) then
      minute_i := X"2" & std_ulogic_vector(to_unsigned(input.minute - 20, 4));
    elsif(input.minute > 9) then
      minute_i := X"1" & std_ulogic_vector(to_unsigned(input.minute - 10, 4));
    else
      minute_i := X"0" & std_ulogic_vector(to_unsigned(input.minute, 4));
    end if;

    if(input.hour > 9) then
      hour_i := "01" & not(input.pm) & '1' & std_ulogic_vector(to_unsigned(input.hour - 10, 4));
    else
      hour_i := "01" & not(input.pm) & '0' & std_ulogic_vector(to_unsigned(input.hour, 4));
    end if;

    if(input.day > 29) then
      day_i := X"3" & std_ulogic_vector(to_unsigned(input.day - 30, 4));
    elsif(input.day > 19) then
      day_i := X"2" & std_ulogic_vector(to_unsigned(input.day - 20, 4));
    elsif(input.day > 9) then
      day_i := X"1" & std_ulogic_vector(to_unsigned(input.day - 10, 4));
    else
      day_i := X"0" & std_ulogic_vector(to_unsigned(input.day, 4));
    end if;

    if(input.year > 2099) then
      day_i(7)  := '1';
      year_cent := 100;
    else
      day_i(7)  := '0';
      year_cent := 0;
    end if;

    if(input.month > 9) then
      month_i(6 downto 0) := "001" & std_ulogic_vector(to_unsigned(input.month - 10, 4));
    else
      month_i(6 downto 0) := "000" & std_ulogic_vector(to_unsigned(input.month, 4));
    end if;

    if((input.year - year_cent) > 2089) then
      year_i := X"9" & std_ulogic_vector(to_unsigned(input.year - year_cent - 90, 4));
    elsif((input.year - year_cent) > 2079) then
      year_i := X"8" & std_ulogic_vector(to_unsigned(input.year - year_cent - 80, 4));
    elsif((input.year - year_cent) > 2069) then
      year_i := X"7" & std_ulogic_vector(to_unsigned(input.year - year_cent - 70, 4));
    elsif((input.year - year_cent) > 2059) then
      year_i := X"6" & std_ulogic_vector(to_unsigned(input.year - year_cent - 60, 4));
    elsif((input.year - year_cent) > 2049) then
      year_i := X"5" & std_ulogic_vector(to_unsigned(input.year - year_cent - 50, 4));
    elsif((input.year - year_cent) > 2039) then
      year_i := X"4" & std_ulogic_vector(to_unsigned(input.year - year_cent - 40, 4));
    elsif((input.year - year_cent) > 2029) then
      year_i := X"3" & std_ulogic_vector(to_unsigned(input.year - year_cent - 30, 4));
    elsif((input.year - year_cent) > 2019) then
      year_i := X"2" & std_ulogic_vector(to_unsigned(input.year - year_cent - 20, 4));
    elsif((input.year - year_cent) > 2009) then
      year_i := X"1" & std_ulogic_vector(to_unsigned(input.year - year_cent - 10, 4));
    else
      year_i := X"0" & std_ulogic_vector(to_unsigned(input.year - year_cent, 4));
    end if;

    return (X"00", minute_i, hour_i, X"00", day_i, month_i, year_i);
  end conv_bcd;

end utils_pkg;

--  A B C D E F G J L M N O P R S T U V Y
--  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8

--   _ _    _ _    _ _    _ _    _ _    _ _    _ _                                _ _    _ _    _ _    _ _    _ _
--  |   |    | |  |        | |  |      |      |          |  |      |\ /|  |\  |  |   |  |   |  |   |  |        |    |   |  |  /    \ /
--   - -      -                  - -    -        -                                       - -    - -    - -
--  |   |    | |  |        | |  |      |      |   |  |   |  |      |   |  |  \|  |   |  |      |  \       |    |    |   |  |/       |
--          - -    - -    - -    - -           - -    - -    - -                  - -                  - -           - -

-- A = 1 10001 11 10001 0
-- B = 1 00101 01 00101 1
-- C = 1 10000 00 10000 1
-- D = 1 00101 00 00101 1
-- E = 1 10000 11 10000 1
-- F = 1 10000 10 10000 0
-- G = 1 10000 01 10001 1
-- J = 0 00001 00 10001 1
-- L = 0 10000 00 10000 1
-- M = 0 11011 00 10001 0
-- N = 0 11001 00 10011 0
-- O = 1 10001 00 10001 1
-- P = 1 10001 11 10000 0
-- R = 1 10001 11 10010 0
-- S = 1 10000 11 00001 1
-- T = 1 00100 00 00100 0
-- U = 0 10001 00 10001 1
-- V = 0 10010 00 11000 0
-- Y = 0 01010 00 00100 0
