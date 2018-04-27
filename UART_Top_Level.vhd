-- Top Level Lab 4 --
-- Homework 8 - UART Transmitter 
-- Joey Rappaport
-- Allan Douglas --
-- EE331 -- Winter 2017 --- 

library ieee; 
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all; 
use IEEE.std_logic_arith.all; 


entity UART is
    port(
        clk          : in std_logic;
        btn1         : in std_logic;
        btn2         : in std_logic;
        uart_tx_in   : in std_logic;
        uart_rx_out  : out std_logic;
        ja0          : out std_logic;
        ja1          : out std_logic
    );
end UART;

architecture synth of UART is

----------------------- Component Declaration -------------------------
component ila_0
    port(
       clk    : in std_logic;
       probe0 : std_logic_vector (23 downto 0)
  );
end component;


component RAM_SM
    port(
        clk         : in std_logic;
        empty       : in std_logic;
        full        : in std_logic;
        btn1        : in std_logic;
        btn2        : in std_logic;
        wr_addr     : out std_logic_vector (7 downto 0);
        we_RAM      : out std_logic;
        we_TRANS    : out std_logic;
        re_RECEIVE  : out std_logic;
        state_out   : out std_logic_vector(2 downto 0)
    );
end component;

component uart_receiver
    port(
        clk          : in std_logic;
        reset        : in std_logic;
        uart_tx_in   : in std_logic;
        re           : in std_logic;
        empty        : out std_logic;
        data_out     : out std_logic_vector(7 downto 0)
    );
end component;

component uart_transmitter
    port(
        clk         : in std_logic;
        din         : in std_logic_vector(7 downto 0);
        we          : in std_logic;
        start       : in std_logic;
        reset       : in std_logic;
        full        : out std_logic;
        Fifo_data_out : out std_logic_vector(7 downto 0);
        trans_shift_reg : out std_logic_vector (7 downto 0);
        mux_sel_debug  : out std_logic_vector (1 downto 0);
        load_shift : out std_logic;
        uart_rx_out : out std_logic
    );
end component;

component ram_2
    generic(
        BITS_ADDRESS   : integer := 8;
        BITS_DATA      : integer := 8
    );
    port(
        clk            : in std_logic;
        address        : in std_logic_vector(BITS_ADDRESS-1 downto 0);
        write_en       : in std_logic;
        din            : in std_logic_vector(BITS_DATA-1 downto 0);
        test_data      : out std_logic_vector(BITS_DATA-1 downto 0);
        dout           : out std_logic_vector(BITS_DATA-1 downto 0)
    );
end component;

component debouncer
  port(
    btn    : in  std_logic;
    clk    : in  std_logic;
    result : out  std_logic
  );
end component;

component pulse_gen
  port(
    sig_in       : in std_logic;
    clk          : in std_logic;
    pulse_out    : out std_logic
  );
end component;


---------------------------- Signal Declaration ------------------------
signal bounce_pulse1 : std_logic;
signal bounce_pulse2 : std_logic;
signal pulse_SM      : std_logic;
signal pulse_reset   : std_logic;
signal data_in       : std_logic_vector (7 downto 0);
signal data_out      : std_logic_vector (7 downto 0);
signal re_RECEIVE    : std_logic;
signal empty         : std_logic;
signal full          : std_logic;
signal wr_addr       : std_logic_vector (7 downto 0);
signal we_TRANS      : std_logic;
signal we_RAM        : std_logic;
signal uart_out      : std_logic;
signal statesig      : std_logic_vector (2 downto 0);
signal test_data     : std_logic_vector(7 downto 0);
signal Fifo_data_out : std_logic_vector (7 downto 0);
signal load_shift    : std_logic;
signal trans_shift_reg : std_logic_vector(7 downto 0);
signal mux_sel_debug       : std_logic_vector (1 downto 0);


begin
    
    ja0 <= uart_tx_in;
    ja1 <= uart_out;
    
    -------------------- Instantiate ----------------------------------
    my_ila_0 : ila_0
        port map(
           clk    => clk,
            probe0(7 downto 0)  => trans_shift_reg,
            probe0(23 downto 16)  => Fifo_data_out,
            probe0(8) => btn2,
            --probe0(9) => btn2,
            probe0(11 downto 9) => statesig,
            probe0(12) => we_TRANS,
            probe0(13) => load_shift,
            probe0(14) => uart_out,
            probe0(15) => full
            --probe0(15) => full
        );
        
    
	my_RAM_SM : RAM_SM 
    port map(
        clk          => clk,
        empty        => empty,
        full         => full,
        btn1         => pulse_SM,
        btn2         => pulse_reset,
        wr_addr      => wr_addr,
        we_RAM       => we_RAM,
        we_TRANS     => we_TRANS,
        re_RECEIVE   => re_RECEIVE,
        state_out    => statesig
    );
    
    
   my_uart_receiver : uart_receiver 
    port map(
        clk          => clk,
        reset        => pulse_reset,
        uart_tx_in   => uart_tx_in,
        re           => re_RECEIVE,
        empty        => empty,
        data_out     => data_in
    );
    
   my_uart_transmitter : uart_transmitter
    port map(
        clk            => clk,
        din            => data_out,
        we             => we_TRANS,
        start          => '1',
        reset          => pulse_reset,
        full           => full,
        Fifo_data_out => Fifo_data_out,
        mux_sel_debug       => mux_sel_debug,
        load_shift    => load_shift,
        trans_shift_reg => trans_shift_reg,
        uart_rx_out    => uart_out
    );
    
    
    my_ram_2 : ram_2
    generic map(
        BITS_ADDRESS   => 8,
        BITS_DATA      => 8
    )
    port map(
        clk           => clk,
        address       => wr_addr,
        write_en      => we_RAM,
        din           => data_in,
        test_data     => test_data,
        dout          => data_out
    );
    
   my_pulse_gen1 : pulse_gen 
    port map(
        sig_in      => bounce_pulse1,
        clk         => clk,
        pulse_out   => pulse_SM
    );
    
   my_pulse_gen2 : pulse_gen 
    port map(
        sig_in      => bounce_pulse2,
        clk         => clk,
        pulse_out   => pulse_reset
    );
    
   my_debouncer1: debouncer
    port map(
         btn     => btn1,
         clk     => clk,
         result  => bounce_pulse1
    );
    
   my_debouncer2 : debouncer 
    port map(
         btn     => btn2,
         clk     => clk,
         result  => bounce_pulse2
    );
    -------------------------------------------------------------------------

    uart_rx_out <= uart_out;
    
end;


