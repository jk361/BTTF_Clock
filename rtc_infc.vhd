
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.utils_pkg.all;

library unisim;
use unisim.vcomponents.all;

entity rtc_infc is
  port(
    clk      : in    std_ulogic;
    reset    : in    std_ulogic;
    done     : in    std_ulogic;
    rtc_scl  : inout std_logic;
    rtc_sda  : inout std_logic;
    time_in  : in    time_data_type;
    time_out : out   time_data_type
    );
end rtc_infc;

architecture rtl of rtc_infc is

  constant ds3231_addr    : std_ulogic_vector(6 downto 0) := "1101000";

  type rx_tx_fsm_state_type is (idle, start, busy, a6, a5, a4, a3, a2, a1, a0, r_w, ack_1, ra7, ra6, ra5, ra4, ra3, ra2, ra1, ra0, ack_2, d7, d6, d5, d4, d3, d2, d1, d0, ack_3, stop_1, stop_2);
  signal rx_tx_fsm_state : rx_tx_fsm_state_type;

  signal i2c_packet       : i2c_packet_type;
  signal tx_i2c_packet    : i2c_packet_type;
  signal rx_i2c_packet    : i2c_packet_type;

  signal time_out_i       : time_data_type;

  signal tick             : std_ulogic;
  signal tick_count       : integer;
  signal init_count       : integer;

  signal scl_out          : std_ulogic;
  signal scl_state        : std_ulogic_vector(1 downto 0);
  signal sda_in           : std_ulogic;
  signal sda_in_i         : std_ulogic;
  signal sda_in_buf       : std_ulogic_vector(2 downto 0);
  signal sda_out          : std_ulogic;
  signal sda_falling_edge : std_ulogic;
  signal byte_num         : integer;
  signal pack_num         : integer;

  signal send_flag        : std_ulogic;
  signal clr_send_flag    : std_ulogic;
  signal busy_flag        : std_ulogic;
  signal busy_count       : integer;

  signal year_cent        : integer;

begin

  scl_buf: iobuf
  generic map(
    drive      => 12,
    iostandard => "default",
    slew       => "slow"
  )
  port map(
    o  => open,
    io => rtc_scl,
    i  => '0',
    t  => scl_out
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

  sda_in_i <= '0' when sda_in = '0' else '1';

  tick_proc: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        tick       <= '0';
        tick_count <= 0;
      else
        if(tick_count = 124) then
          tick       <= '1';
          tick_count <= 0;
        else
          tick       <= '0';
          tick_count <= tick_count + 1;
        end if;
      end if;
    end if;
  end process tick_proc;

  rx_reg_proc: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        sda_in_buf <= (others => '0');
      else
        sda_in_buf(0)          <= sda_in_i;
        sda_in_buf(2 downto 1) <= sda_in_buf(1 downto 0);
      end if;
    end if;
  end process rx_reg_proc;

  sda_falling_edge <= sda_in_buf(2) and not(sda_in_buf(1));

  packet_proc: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        init_count    <= 24999999;
        tx_i2c_packet <= (ds3231_addr, '0', X"00", 0, (others => '0'), (others => X"00"));
        send_flag     <= '0';
        pack_num      <= 1;
        time_out_i    <= (0, 0, 1, '0', 1, 1, 0);
        year_cent     <= 2000;
      else
        if((busy_flag = '1') or (send_flag = '1')) then
        elsif(init_count = 49999999) then
          if(pack_num = 0) then
            tx_i2c_packet <= (ds3231_addr, '0', X"00", 7, (others => '0'), conv_bcd(time_in));
            send_flag     <= '1';
            pack_num      <= 1;
          elsif(pack_num = 1) then
            tx_i2c_packet <= (ds3231_addr, '0', X"00", 0, (others => '0'), (others => X"00"));
            send_flag     <= '1';
            pack_num      <= 2;
          elsif(pack_num = 2) then
            tx_i2c_packet <= (ds3231_addr, '1', X"00", 1, (others => '0'), (others => X"00"));
            send_flag     <= '1';
            pack_num      <= 3;
          elsif(pack_num = 3) then
            time_out_i.second <= (10 * to_integer(unsigned(rx_i2c_packet.data(0)(7 downto 4)))) + to_integer(unsigned(rx_i2c_packet.data(0)(3 downto 0)));
            pack_num          <= 4;
          elsif(pack_num = 4) then
            tx_i2c_packet <= (ds3231_addr, '0', X"01", 0, (others => '0'), (others => X"00"));
            send_flag     <= '1';
            pack_num      <= 5;
          elsif(pack_num = 5) then
            tx_i2c_packet <= (ds3231_addr, '1', X"00", 1, (others => '0'), (others => X"00"));
            send_flag     <= '1';
            pack_num      <= 6;
          elsif(pack_num = 6) then
            time_out_i.minute <= (10 * to_integer(unsigned(rx_i2c_packet.data(0)(7 downto 4)))) + to_integer(unsigned(rx_i2c_packet.data(0)(3 downto 0)));
            pack_num          <= 7;
          elsif(pack_num = 7) then
            tx_i2c_packet <= (ds3231_addr, '0', X"02", 0, (others => '0'), (others => X"00"));
            send_flag     <= '1';
            pack_num      <= 8;
          elsif(pack_num = 8) then
            tx_i2c_packet <= (ds3231_addr, '1', X"00", 1, (others => '0'), (others => X"00"));
            send_flag     <= '1';
            pack_num      <= 9;
          elsif(pack_num = 9) then
            time_out_i.pm <= not(rx_i2c_packet.data(0)(5));

            if(rx_i2c_packet.data(0)(4) = '1') then
              time_out_i.hour <= 10 + to_integer(unsigned(rx_i2c_packet.data(0)(3 downto 0)));
            else
              time_out_i.hour <= to_integer(unsigned(rx_i2c_packet.data(0)(3 downto 0)));
            end if;

            pack_num <= 10;
          elsif(pack_num = 10) then
            tx_i2c_packet <= (ds3231_addr, '0', X"04", 0, (others => '0'), (others => X"00"));
            send_flag     <= '1';
            pack_num      <= 11;
          elsif(pack_num = 11) then
            tx_i2c_packet <= (ds3231_addr, '1', X"00", 1, (others => '0'), (others => X"00"));
            send_flag     <= '1';
            pack_num      <= 12;
          elsif(pack_num = 12) then
            time_out_i.day <= (10 * to_integer(unsigned(rx_i2c_packet.data(0)(5 downto 4)))) + to_integer(unsigned(rx_i2c_packet.data(0)(3 downto 0)));
            pack_num       <= 13;
          elsif(pack_num = 13) then
            tx_i2c_packet <= (ds3231_addr, '0', X"05", 0, (others => '0'), (others => X"00"));
            send_flag     <= '1';
            pack_num      <= 14;
          elsif(pack_num = 14) then
            tx_i2c_packet <= (ds3231_addr, '1', X"00", 1, (others => '0'), (others => X"00"));
            send_flag     <= '1';
            pack_num      <= 15;
          elsif(pack_num = 15) then
            if(rx_i2c_packet.data(0)(7) = '1') then
              year_cent <= 2100;
            else
              year_cent <= 2000;
            end if;

            if(rx_i2c_packet.data(0)(4) = '1') then
              time_out_i.month <= 10 + to_integer(unsigned(rx_i2c_packet.data(0)(3 downto 0)));
            else
              time_out_i.month <= to_integer(unsigned(rx_i2c_packet.data(0)(3 downto 0)));
            end if;

            pack_num <= 16;
          elsif(pack_num = 16) then
            tx_i2c_packet <= (ds3231_addr, '0', X"06", 0, (others => '0'), (others => X"00"));
            send_flag     <= '1';
            pack_num      <= 17;
          elsif(pack_num = 17) then
            tx_i2c_packet <= (ds3231_addr, '1', X"00", 1, (others => '0'), (others => X"00"));
            send_flag     <= '1';
            pack_num      <= 18;
          elsif(pack_num = 18) then
            time_out_i.year <= year_cent + (10 * to_integer(unsigned(rx_i2c_packet.data(0)(7 downto 4)))) + to_integer(unsigned(rx_i2c_packet.data(0)(3 downto 0)));
            pack_num        <= 19;
          else
            time_out   <= time_out_i;
            init_count <= 0;
            pack_num   <= 1;
          end if;
        elsif(init_count < 50000000) then
          init_count <= init_count + 1;
        end if;

        if(clr_send_flag = '1') then
          send_flag <= '0';
        end if;

        if(done = '1') then
          pack_num   <= 0;
        end if;
      end if;
    end if;
  end process packet_proc;

  rx_tx_fsm_proc: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        i2c_packet      <= ("0000000", '0', (others => '0'), 0, (others => '0'), (others => X"00"));
        rx_i2c_packet   <= ("0000000", '0', (others => '0'), 0, (others => '0'), (others => X"00"));
        clr_send_flag   <= '0';
        scl_out         <= '1';
        scl_state       <= (others => '0');
        sda_out         <= '1';
        byte_num        <= 0;
        rx_tx_fsm_state <= idle;
      else

        case rx_tx_fsm_state is

          when idle =>
            scl_state <= (others => '0');
            scl_out   <= '1';
            sda_out   <= '1';

            if(tick = '1') then
              if(send_flag = '1') then
                clr_send_flag   <= '1';
                byte_num        <= 0;
                i2c_packet      <= tx_i2c_packet;
                rx_tx_fsm_state <= start;
              end if;
            end if;

          when start =>
            if(tick = '1') then
              if(scl_state = "00") then
                clr_send_flag <= '0';
                sda_out       <= '0';
                scl_state     <= "01";
              elsif(scl_state = "01") then
                scl_state <= "10";
              elsif(scl_state = "10") then
                scl_state <= "11";
              else
                scl_out         <= '0';
                rx_tx_fsm_state <= a6;
                scl_state       <= "00";
              end if;
            end if;

          when a6 =>
            if(tick = '1') then
              if(scl_state = "00") then
                sda_out   <= i2c_packet.addr(6);
                scl_state <= "01";
              elsif(scl_state = "01") then
                scl_out   <= '1';
                scl_state <= "10";
              elsif(scl_state = "10") then
                scl_state <= "11";
              else
                scl_out         <= '0';
                rx_tx_fsm_state <= a5;
                scl_state       <= "00";
              end if;
            end if;

          when a5 =>
            if(tick = '1') then
              if(scl_state = "00") then
                sda_out <= i2c_packet.addr(5);
                scl_state <= "01";
              elsif(scl_state = "01") then
                scl_out   <= '1';
                scl_state <= "10";
              elsif(scl_state = "10") then
                scl_state <= "11";
              else
                scl_out         <= '0';
                rx_tx_fsm_state <= a4;
                scl_state       <= "00";
              end if;
            end if;

          when a4 =>
            if(tick = '1') then
              if(scl_state = "00") then
                sda_out <= i2c_packet.addr(4);
                scl_state <= "01";
              elsif(scl_state = "01") then
                scl_out   <= '1';
                scl_state <= "10";
              elsif(scl_state = "10") then
                scl_state <= "11";
              else
                scl_out         <= '0';
                rx_tx_fsm_state <= a3;
                scl_state       <= "00";
              end if;
            end if;

          when a3 =>
            if(tick = '1') then
              if(scl_state = "00") then
                sda_out <= i2c_packet.addr(3);
                scl_state <= "01";
              elsif(scl_state = "01") then
                scl_out   <= '1';
                scl_state <= "10";
              elsif(scl_state = "10") then
                scl_state <= "11";
              else
                scl_out         <= '0';
                rx_tx_fsm_state <= a2;
                scl_state       <= "00";
              end if;
            end if;

          when a2 =>
            if(tick = '1') then
              if(scl_state = "00") then
                sda_out <= i2c_packet.addr(2);
                scl_state <= "01";
              elsif(scl_state = "01") then
                scl_out   <= '1';
                scl_state <= "10";
              elsif(scl_state = "10") then
                scl_state <= "11";
              else
                scl_out         <= '0';
                rx_tx_fsm_state <= a1;
                scl_state       <= "00";
              end if;
            end if;

          when a1 =>
            if(tick = '1') then
              if(scl_state = "00") then
                sda_out <= i2c_packet.addr(1);
                scl_state <= "01";
              elsif(scl_state = "01") then
                scl_out   <= '1';
                scl_state <= "10";
              elsif(scl_state = "10") then
                scl_state <= "11";
              else
                scl_out         <= '0';
                rx_tx_fsm_state <= a0;
                scl_state       <= "00";
              end if;
            end if;

          when a0 =>
            if(tick = '1') then
              if(scl_state = "00") then
                sda_out <= i2c_packet.addr(0);
                scl_state <= "01";
              elsif(scl_state = "01") then
                scl_out   <= '1';
                scl_state <= "10";
              elsif(scl_state = "10") then
                scl_state <= "11";
              else
                scl_out         <= '0';
                rx_tx_fsm_state <= r_w;
                scl_state       <= "00";
              end if;
            end if;

          when r_w =>
            if(tick = '1') then
              if(scl_state = "00") then
                sda_out <= i2c_packet.r_w;
                scl_state <= "01";
              elsif(scl_state = "01") then
                scl_out   <= '1';
                scl_state <= "10";
              elsif(scl_state = "10") then
                scl_state <= "11";
              else
                scl_out         <= '0';
                rx_tx_fsm_state <= ack_1;
                scl_state       <= "00";
              end if;
            end if;

          when ack_1 =>
            if(tick = '1') then
              if(scl_state = "00") then
                sda_out <= '1';
                scl_state <= "01";
              elsif(scl_state = "01") then
                scl_out   <= '1';
                scl_state <= "10";
              elsif(scl_state = "10") then
                scl_state <= "11";
              else
                if(sda_in_i = '0') then
                  rx_i2c_packet.ack(0) <= sda_in_i;
                end if;

                if(i2c_packet.r_w = '0') then
                  rx_tx_fsm_state <= ra7;
                else
                  rx_tx_fsm_state <= d7;
                end if;

                scl_out         <= '0';
                scl_state       <= "00";
              end if;
            end if;

          when ra7 =>
            if(tick = '1') then
              if(scl_state = "00") then
                sda_out <= i2c_packet.reg(7);
                scl_state <= "01";
              elsif(scl_state = "01") then
                scl_out   <= '1';
                scl_state <= "10";
              elsif(scl_state = "10") then
                scl_state <= "11";
              else
                scl_out         <= '0';
                rx_tx_fsm_state <= ra6;
                scl_state       <= "00";
              end if;
            end if;

          when ra6 =>
            if(tick = '1') then
              if(scl_state = "00") then
                sda_out <= i2c_packet.reg(6);
                scl_state <= "01";
              elsif(scl_state = "01") then
                scl_out   <= '1';
                scl_state <= "10";
              elsif(scl_state = "10") then
                scl_state <= "11";
              else
                scl_out         <= '0';
                rx_tx_fsm_state <= ra5;
                scl_state       <= "00";
              end if;
            end if;

          when ra5 =>
            if(tick = '1') then
              if(scl_state = "00") then
                sda_out <= i2c_packet.reg(5);
                scl_state <= "01";
              elsif(scl_state = "01") then
                scl_out   <= '1';
                scl_state <= "10";
              elsif(scl_state = "10") then
                scl_state <= "11";
              else
                scl_out         <= '0';
                rx_tx_fsm_state <= ra4;
                scl_state       <= "00";
              end if;
            end if;

          when ra4 =>
            if(tick = '1') then
              if(scl_state = "00") then
                sda_out <= i2c_packet.reg(4);
                scl_state <= "01";
              elsif(scl_state = "01") then
                scl_out   <= '1';
                scl_state <= "10";
              elsif(scl_state = "10") then
                scl_state <= "11";
              else
                scl_out         <= '0';
                rx_tx_fsm_state <= ra3;
                scl_state       <= "00";
              end if;
            end if;

          when ra3 =>
            if(tick = '1') then
              if(scl_state = "00") then
                sda_out <= i2c_packet.reg(3);
                scl_state <= "01";
              elsif(scl_state = "01") then
                scl_out   <= '1';
                scl_state <= "10";
              elsif(scl_state = "10") then
                scl_state <= "11";
              else
                scl_out         <= '0';
                rx_tx_fsm_state <= ra2;
                scl_state       <= "00";
              end if;
            end if;

          when ra2 =>
            if(tick = '1') then
              if(scl_state = "00") then
                sda_out <= i2c_packet.reg(2);
                scl_state <= "01";
              elsif(scl_state = "01") then
                scl_out   <= '1';
                scl_state <= "10";
              elsif(scl_state = "10") then
                scl_state <= "11";
              else
                scl_out         <= '0';
                rx_tx_fsm_state <= ra1;
                scl_state       <= "00";
              end if;
            end if;

          when ra1 =>
            if(tick = '1') then
              if(scl_state = "00") then
                sda_out <= i2c_packet.reg(1);
                scl_state <= "01";
              elsif(scl_state = "01") then
                scl_out   <= '1';
                scl_state <= "10";
              elsif(scl_state = "10") then
                scl_state <= "11";
              else
                scl_out         <= '0';
                rx_tx_fsm_state <= ra0;
                scl_state       <= "00";
              end if;
            end if;

          when ra0 =>
            if(tick = '1') then
              if(scl_state = "00") then
                sda_out <= i2c_packet.reg(0);
                scl_state <= "01";
              elsif(scl_state = "01") then
                scl_out   <= '1';
                scl_state <= "10";
              elsif(scl_state = "10") then
                scl_state <= "11";
              else
                scl_out         <= '0';
                rx_tx_fsm_state <= ack_2;
                scl_state       <= "00";
              end if;
            end if;

          when ack_2 =>
            if(tick = '1') then
              if(scl_state = "00") then
                sda_out <= '1';
                scl_state <= "01";
              elsif(scl_state = "01") then
                scl_out   <= '1';
                scl_state <= "10";
              elsif(scl_state = "10") then
                scl_state <= "11";
              else
                if(sda_in_i = '0') then
                  rx_i2c_packet.ack(2) <= sda_in_i;
                end if;

                if(i2c_packet.dlen = 0) then
                  rx_tx_fsm_state <= stop_1;
                else
                  rx_tx_fsm_state <= d7;
                end if;

                scl_out         <= '0';
                scl_state       <= "00";
              end if;
            end if;

          when d7 =>
            if(tick = '1') then
              if(scl_state = "00") then
                if(i2c_packet.r_w = '0') then
                  sda_out <= i2c_packet.data(byte_num)(7);
                end if;

                scl_state <= "01";
              elsif(scl_state = "01") then
                scl_out   <= '1';
                scl_state <= "10";
              elsif(scl_state = "10") then
                if(i2c_packet.r_w = '1') then
                  rx_i2c_packet.data(byte_num)(7) <= sda_in_i;
                end if;

                scl_state <= "11";
              else
                scl_out         <= '0';
                rx_tx_fsm_state <= d6;
                scl_state       <= "00";
              end if;
            end if;

          when d6 =>
            if(tick = '1') then
              if(scl_state = "00") then
                if(i2c_packet.r_w = '0') then
                  sda_out <= i2c_packet.data(byte_num)(6);
                end if;

                scl_state <= "01";
              elsif(scl_state = "01") then
                scl_out   <= '1';
                scl_state <= "10";
              elsif(scl_state = "10") then
                if(i2c_packet.r_w = '1') then
                  rx_i2c_packet.data(byte_num)(6) <= sda_in_i;
                end if;

                scl_state <= "11";
              else
                scl_out         <= '0';
                rx_tx_fsm_state <= d5;
                scl_state       <= "00";
              end if;
            end if;

          when d5 =>
            if(tick = '1') then
              if(scl_state = "00") then
                if(i2c_packet.r_w = '0') then
                  sda_out <= i2c_packet.data(byte_num)(5);
                end if;

                scl_state <= "01";
              elsif(scl_state = "01") then
                scl_out   <= '1';
                scl_state <= "10";
              elsif(scl_state = "10") then
                if(i2c_packet.r_w = '1') then
                  rx_i2c_packet.data(byte_num)(5) <= sda_in_i;
                end if;

                scl_state <= "11";
              else
                scl_out         <= '0';
                rx_tx_fsm_state <= d4;
                scl_state       <= "00";
              end if;
            end if;

          when d4 =>
            if(tick = '1') then
              if(scl_state = "00") then
                if(i2c_packet.r_w = '0') then
                  sda_out <= i2c_packet.data(byte_num)(4);
                end if;

                scl_state <= "01";
              elsif(scl_state = "01") then
                scl_out   <= '1';
                scl_state <= "10";
              elsif(scl_state = "10") then
                if(i2c_packet.r_w = '1') then
                  rx_i2c_packet.data(byte_num)(4) <= sda_in_i;
                end if;

                scl_state <= "11";
              else
                scl_out         <= '0';
                rx_tx_fsm_state <= d3;
                scl_state       <= "00";
              end if;
            end if;

          when d3 =>
            if(tick = '1') then
              if(scl_state = "00") then
                if(i2c_packet.r_w = '0') then
                  sda_out <= i2c_packet.data(byte_num)(3);
                end if;

                scl_state <= "01";
              elsif(scl_state = "01") then
                scl_out   <= '1';
                scl_state <= "10";
              elsif(scl_state = "10") then
                if(i2c_packet.r_w = '1') then
                  rx_i2c_packet.data(byte_num)(3) <= sda_in_i;
                end if;

                scl_state <= "11";
              else
                scl_out         <= '0';
                rx_tx_fsm_state <= d2;
                scl_state       <= "00";
              end if;
            end if;

          when d2 =>
            if(tick = '1') then
              if(scl_state = "00") then
                if(i2c_packet.r_w = '0') then
                  sda_out <= i2c_packet.data(byte_num)(2);
                end if;

                scl_state <= "01";
              elsif(scl_state = "01") then
                scl_out   <= '1';
                scl_state <= "10";
              elsif(scl_state = "10") then
                if(i2c_packet.r_w = '1') then
                  rx_i2c_packet.data(byte_num)(2) <= sda_in_i;
                end if;

                scl_state <= "11";
              else
                scl_out         <= '0';
                rx_tx_fsm_state <= d1;
                scl_state       <= "00";
              end if;
            end if;

          when d1 =>
            if(tick = '1') then
              if(scl_state = "00") then
                if(i2c_packet.r_w = '0') then
                  sda_out <= i2c_packet.data(byte_num)(1);
                end if;

                scl_state <= "01";
              elsif(scl_state = "01") then
                scl_out   <= '1';
                scl_state <= "10";
              elsif(scl_state = "10") then
                if(i2c_packet.r_w = '1') then
                  rx_i2c_packet.data(byte_num)(1) <= sda_in_i;
                end if;

                scl_state <= "11";
              else
                scl_out         <= '0';
                rx_tx_fsm_state <= d0;
                scl_state       <= "00";
              end if;
            end if;

          when d0 =>
            if(tick = '1') then
              if(scl_state = "00") then
                if(i2c_packet.r_w = '0') then
                  sda_out <= i2c_packet.data(byte_num)(0);
                end if;

                scl_state <= "01";
              elsif(scl_state = "01") then
                scl_out   <= '1';
                scl_state <= "10";
              elsif(scl_state = "10") then
                if(i2c_packet.r_w = '1') then
                  rx_i2c_packet.data(byte_num)(0) <= sda_in_i;
                end if;

                scl_state <= "11";
              else
                if(i2c_packet.r_w = '0') then
                  sda_out <= '1';
                end if;

                rx_tx_fsm_state <= ack_3;
                scl_out         <= '0';
                scl_state       <= "00";
              end if;
            end if;

          when ack_3 =>
            if(tick = '1') then
              if(scl_state = "00") then
                if(i2c_packet.r_w = '1') then
                  if(byte_num = (i2c_packet.dlen - 1)) then
                    sda_out <= '1';
                  else
                    sda_out <= '0';
                  end if;
                end if;

                scl_state <= "01";
              elsif(scl_state = "01") then
                scl_out   <= '1';
                scl_state <= "10";
              elsif(scl_state = "10") then
                if(i2c_packet.r_w = '0') then
                  rx_i2c_packet.ack(byte_num+2) <= sda_in_i;
                end if;

                scl_state <= "11";
              else
                if(byte_num = (i2c_packet.dlen - 1)) then
                  rx_tx_fsm_state <= stop_1;
                else
                  byte_num        <= byte_num + 1;
                  rx_tx_fsm_state <= d7;
                end if;

                scl_out         <= '0';
                scl_state       <= "00";
              end if;
            end if;

          when stop_1 =>
            if(tick = '1') then
              if(scl_state = "00") then
                sda_out   <= '0';
                scl_state <= "01";
              elsif(scl_state = "01") then
                scl_out   <= '1';
                scl_state <= "10";
              elsif(scl_state = "10") then
                scl_state <= "11";
              else
                rx_tx_fsm_state <= stop_2;
                scl_state       <= "00";
              end if;
            end if;

          when stop_2 =>
            if(tick = '1') then
              if(scl_state = "00") then
                sda_out   <= '1';
                scl_state <= "01";
              elsif(scl_state = "01") then
                scl_state <= "10";
              elsif(scl_state = "10") then
                scl_state <= "11";
              else
                rx_tx_fsm_state <= idle;
                scl_state       <= "00";
              end if;
            end if;

          when others =>
            rx_tx_fsm_state <= idle;

        end case;

      end if;
    end if;
  end process rx_tx_fsm_proc;

  busy_flag_proc: process(clk)
  begin
    if rising_edge(clk) then
      if(reset = '0') then
        busy_flag  <= '0';
        busy_count <= 49999;
      else
        if((send_flag = '1') or (sda_in_i = '0') or (scl_out = '0')) then
          busy_flag  <= '1';
          busy_count <= 0;
        elsif(busy_count = 49999) then
          busy_flag  <= '0';
        else
          busy_count <= busy_count + 1;
        end if;
      end if;
    end if;
  end process busy_flag_proc;

end rtl;

