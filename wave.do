
divider add "Clk & Reset"
wave add -radix bin      test_bench/uut/clk
wave add -radix bin      test_bench/uut/reset
wave add -radix bin      test_bench/uut/reset_int
wave add -radix bin      test_bench/uut/rtc_clk

divider add "Counters"
wave add -radix bin      test_bench/uut/real_time_counter_i/rtc_clk_reg
wave add -radix unsigned test_bench/uut/real_time_counter_i/rtc_clk_count
wave add -radix unsigned test_bench/uut/real_time_counter_i/tick_count
wave add -radix bin      test_bench/uut/real_time_counter_i/second_tick
wave add -radix unsigned test_bench/uut/real_time_counter_i/second_i

divider add "Button Input"
wave add                 test_bench/uut/button_in(1)
wave add                 test_bench/uut/button_in(0)

# divider add "Time"
# wave add -radix unsigned test_bench/uut/year
# wave add -radix unsigned test_bench/uut/month
# wave add -radix unsigned test_bench/uut/day
# wave add -radix bin      test_bench/uut/pm
# wave add -radix unsigned test_bench/uut/hour
# wave add -radix unsigned test_bench/uut/minute

# divider add "Time Set FSM"
# wave add                 test_bench/uut/set_time_int_i/set_time_state
# wave add -radix unsigned test_bench/uut/set_time_int_i/mode_count
# wave add -radix bin      test_bench/uut/set_time_int_i/increment

divider add "RTC I2C I/F"
wave add -radix bin      test_bench/uut/rtc_infc_i/tick
wave add -radix bin      test_bench/uut/rtc_infc_i/send_flag
wave add -radix bin      test_bench/uut/rtc_infc_i/busy_flag
wave add -radix unsigned test_bench/uut/rtc_infc_i/pack_num
#wave add -radix bin      test_bench/ds3231_bus_model_i/sda_in_i
#wave add -radix bin      test_bench/ds3231_bus_model_i/scl_in_i
wave add -radix bin      test_bench/uut/rtc_infc_i/sda_out
#wave add -radix bin      test_bench/ds3231_bus_model_i/sda_out
#wave add -radix bin      test_bench/uut/rtc_infc_i/sda_in_buf
#wave add -radix bin      test_bench/uut/rtc_infc_i/scl_in_buf
#wave add -radix bin      test_bench/uut/rtc_infc_i/scl_out
#wave add -radix bin      test_bench/uut/rtc_infc_i/rtc_scl
#wave add -radix bin      test_bench/uut/rtc_clk
wave add                 test_bench/uut/rtc_infc_i/rx_tx_fsm_state
wave add                 test_bench/uut/rtc_infc_i/scl_state

divider add "DS3231 Model"
#wave add -radix bin      test_bench/ds3231_bus_model_i/i2c_packet
#wave add -radix bin      test_bench/ds3231_bus_model_i/sda_out
#wave add -radix bin      test_bench/ds3231_bus_model_i/scl_rising_edge
#wave add -radix bin      test_bench/ds3231_bus_model_i/scl_falling_edge
#wave add -radix bin      test_bench/ds3231_bus_model_i/sda_rising_edge
#wave add -radix bin      test_bench/ds3231_bus_model_i/sda_falling_edge




# divider add "LED Drive Output"
# wave add -radix hex      test_bench/uut/month_row
# wave add -radix hex      test_bench/uut/month_col
# wave add -radix hex      test_bench/uut/day_row
# wave add -radix hex      test_bench/uut/year_row
# wave add -radix hex      test_bench/uut/hour_row
# wave add -radix hex      test_bench/uut/min_row
# wave add -radix hex      test_bench/uut/seg_col
# wave add -radix hex      test_bench/uut/am_pm_leds
# wave add -radix hex      test_bench/uut/colon_leds

restart

#isim force add {/test_bench/uut/can_i/c_initial_wait} 999 -radix dec

run 250ms

# marker add 100ms

#quit -f

