
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity ds3231_bus_model is
  port(
    rtc_reset : in    std_ulogic;
    rtc_scl   : inout std_logic;
    rtc_sda   : inout std_logic;
    rtc_clk   : out   std_ulogic
    );
end ds3231_bus_model;

architecture behavioral of ds3231_bus_model is

  type tx_fsm_state_type is (idle, start_tx, busy, a6, a5, a4, a3, a2, a1, a0, r_w, ack, wait_1, wait_2, d7, d6, d5, d4, d3, d2, d1, d0, stop);
  signal tx_fsm_state : tx_fsm_state_type;

  constant clk_period     : time := 500 ns;
  constant tick_period    : time := 2500 ns;
  constant rtc_clk_period : time := 30518 ns;

  signal i2c_packet       : i2c_packet_type := ("0000000", '0', (others => '0'), 0, (others => X"00"));

  signal scl_in           : std_ulogic;
  signal scl_in_i         : std_ulogic;
  signal scl_in_buf       : std_ulogic_vector(2 downto 0);
  signal scl_state        : std_ulogic;
  signal sda_in           : std_ulogic;
  signal sda_in_i         : std_ulogic;
  signal sda_in_buf       : std_ulogic_vector(2 downto 0);
  signal sda_out          : std_ulogic;
  signal scl_rising_edge  : std_ulogic;
  signal scl_falling_edge : std_ulogic;
  signal sda_rising_edge  : std_ulogic;
  signal sda_falling_edge : std_ulogic;

begin

  scl_buf: iobuf
  generic map(
    drive      => 12,
    iostandard => "default",
    slew       => "slow"
  )
  port map(
    o  => scl_in,
    io => rtc_scl,
    i  => '1',
    t  => '1'
  );

  sda_buf: iobuf
  generic map(
    drive      => 12,
    iostandard => "default",
    slew       => "slow"
  )
  port map(
    o  => sda_in,
    io => rtc_sda,
    i  => '0',
    t  => sda_out
  );

  scl_in_i <= '0' when scl_in = '0' else '1';
  sda_in_i <= '0' when sda_in = '0' else '1';

  rx_reg_proc: process
  begin
    if(rtc_reset = '0') then
      scl_in_buf <= (others => '0');
      sda_in_buf <= (others => '0');
    else
      scl_in_buf(0)          <= scl_in_i;
      scl_in_buf(2 downto 1) <= scl_in_buf(1 downto 0);
      sda_in_buf(0)          <= sda_in_i;
      sda_in_buf(2 downto 1) <= sda_in_buf(1 downto 0);
    end if;

    wait for clk_period*2;
  end process rx_reg_proc;

  scl_rising_edge  <= not(scl_in_buf(2)) and scl_in_buf(1);
  scl_falling_edge <= scl_in_buf(2) and not(scl_in_buf(1));
  sda_rising_edge  <= not(sda_in_buf(2)) and sda_in_buf(1);
  sda_falling_edge <= sda_in_buf(2) and not(sda_in_buf(1));


  bus_process :process
  begin
    sda_out <= '1';
    wait for 20 us;

    while(sda_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;

    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    i2c_packet.addr(6) <= sda_in_i;

    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    i2c_packet.addr(5) <= sda_in_i;

    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    i2c_packet.addr(4) <= sda_in_i;

    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    i2c_packet.addr(3) <= sda_in_i;

    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    i2c_packet.addr(2) <= sda_in_i;

    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    i2c_packet.addr(1) <= sda_in_i;

    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    i2c_packet.addr(0) <= sda_in_i;

    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    i2c_packet.r_w <= sda_in_i;

    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.addr = "1101000") then
      sda_out <= '0';
    end if;

    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    sda_out <= '1';


    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(0)(7);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(0)(7) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(0)(6);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(0)(6) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(0)(5);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(0)(5) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(0)(4);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(0)(4) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(0)(3);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(0)(3) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(0)(2);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(0)(2) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(0)(1);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(0)(1) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(0)(0);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(0)(0) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    if(i2c_packet.r_w = '1') then
      sda_out <= '1';
    end if;
    wait for tick_period;


    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(1)(7);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(1)(7) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(1)(6);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(1)(6) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(1)(5);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(1)(5) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(1)(4);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(1)(4) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(1)(3);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(1)(3) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(1)(2);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(1)(2) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(1)(1);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(1)(1) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(1)(0);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(1)(0) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    if(i2c_packet.r_w = '1') then
      sda_out <= '1';
    end if;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(2)(7);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(2)(7) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(2)(6);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(2)(6) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(2)(5);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(2)(5) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(2)(4);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(2)(4) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(2)(3);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(2)(3) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(2)(2);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(2)(2) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(2)(1);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(2)(1) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(2)(0);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(2)(0) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    if(i2c_packet.r_w = '1') then
      sda_out <= '1';
    end if;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(3)(7);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(3)(7) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(3)(6);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(3)(6) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(3)(5);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(3)(5) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(3)(4);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(3)(4) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(3)(3);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(3)(3) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(3)(2);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(3)(2) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(3)(1);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(3)(1) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(3)(0);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(3)(0) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    if(i2c_packet.r_w = '1') then
      sda_out <= '1';
    end if;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(4)(7);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(4)(7) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(4)(6);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(4)(6) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(4)(5);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(4)(5) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(4)(4);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(4)(4) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(4)(3);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(4)(3) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(4)(2);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(4)(2) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(4)(1);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(4)(1) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(4)(0);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(4)(0) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    if(i2c_packet.r_w = '1') then
      sda_out <= '1';
    end if;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(5)(7);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(5)(7) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(5)(6);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(5)(6) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(5)(5);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(5)(5) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(5)(4);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(5)(4) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(5)(3);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(5)(3) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(5)(2);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(5)(2) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(5)(1);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(5)(1) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(5)(0);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(5)(0) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    if(i2c_packet.r_w = '1') then
      sda_out <= '1';
    end if;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(6)(7);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(6)(7) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(6)(6);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(6)(6) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(6)(5);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(6)(5) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(6)(4);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(6)(4) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(6)(3);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(6)(3) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(6)(2);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(6)(2) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(6)(1);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(6)(1) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;

    if(i2c_packet.r_w = '1') then
      sda_out <= i2c_packet.data(6)(0);
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    if(i2c_packet.r_w = '0') then
      i2c_packet.data(6)(0) <= sda_in_i;
    end if;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    if(i2c_packet.r_w = '1') then
      sda_out <= '1';
    end if;
    wait for tick_period;


    if(i2c_packet.r_w = '0') then
      sda_out <= '0';
    end if;
    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    while(scl_falling_edge = '0') loop
      wait for clk_period;
    end loop;
    wait for tick_period;
    sda_out <= '1';

    while(scl_rising_edge = '0') loop
      wait for clk_period;
    end loop;
    while(sda_rising_edge = '0') loop
      wait for clk_period;
    end loop;




    wait for clk_period;
  end process;


  rtc_clk_process :process
  begin
    rtc_clk <= '0';
    wait for rtc_clk_period/2;
    wait for rtc_clk_period/4;
    rtc_clk <= '1';
    wait for rtc_clk_period/4;
  end process;




end behavioral;
