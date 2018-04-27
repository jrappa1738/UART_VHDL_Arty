-- Homework 8 - UART Transmitter 
-- Joey Rappaport
-- Allan Douglas --
-- EE331 -- Winter 2017 --- 

library ieee; 
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all; 
use IEEE.std_logic_arith.all; 

entity uart_transmitter is
    port(
        clk         : in std_logic;
        din         : in std_logic_vector(7 downto 0);
        we          : in std_logic;
        start       : in std_logic;
        reset       : in std_logic;
        full        : out std_logic;
        Fifo_data_out : out std_logic_vector(7 downto 0);
        trans_shift_reg : out std_logic_vector (7 downto 0);
        load_shift : out std_logic;
        mux_sel_debug  : out std_logic_vector (1 downto 0);
        uart_rx_out : out std_logic
    );
end uart_transmitter;



architecture synth of uart_transmitter is

--------------------------- Component Declaration ----------------------------------
component fifo
    generic(
        FIFO_BITS_ADDRESS   : integer := 8;  --- FIFO defaults to 255x8
        FIFO_BITS_DATA      : integer := 8
    );   
    port(
        clk      : in std_logic;
        wr       : in std_logic;
        rd       : in std_logic;
        din      : in std_logic_vector(FIFO_BITS_DATA-1 downto 0);
        reset    : in std_logic;
        dout     : out std_logic_vector(FIFO_BITS_DATA-1 downto 0);
        Fifo_data_out : out std_logic_vector(FIFO_BITS_DATA-1 downto 0);
        full     : out std_logic;
        empty    : out std_logic;
        count    : out std_logic_vector(FIFO_BITS_ADDRESS downto 0) := (others=>'0')
    );
end component;


component transmit_SM
    port(
        clk         : in std_logic;
        start       : in std_logic;
        count       : in std_logic_vector (9 downto 0);
        empty       : in std_logic;
        reset       : in std_logic;
        count_reset : out std_logic;
        re          : out std_logic;
        load        : out std_logic;
        shift       : out std_logic;
        mux_sel     : out std_logic_vector(1 downto 0)  
    );
end component;


-------------------------------- Signal Declaration ------------------------------
signal count        : std_logic_vector(9 downto 0);
signal count_reset  : std_logic;
signal re           : std_logic;
signal empty        : std_logic;
signal load         : std_logic;
signal shift        : std_logic;
signal mux_sel      : std_logic_vector(1 downto 0);
signal data_out     : std_logic_vector(7 downto 0);
signal shift_reg    : std_logic_vector(7 downto 0);
--signal FIFO_test_data : std_logic_vector(7 downto 0);


begin
    mux_sel_debug <= mux_sel;
    trans_shift_reg <= shift_reg;
    load_shift <= load;
    -------------------- Instantiate FIFO ----------------------------------
	my_fifo : fifo 
    generic map(
        FIFO_BITS_ADDRESS => 6,
        FIFO_BITS_DATA    => 8
    )
    port map(
        clk      =>  clk,
        wr       =>  we,
        rd       =>  re,
        din      =>  din,
        reset    =>  reset,
        dout     =>  data_out,
        Fifo_data_out => Fifo_data_out,
        full     =>  full,
        empty    =>  empty,
        count    =>  open
    );
    -------------------------------------------------------------------------
    
    -------------------- Instantiate State Machine --------------------------
	my_transmit_SM : transmit_SM 
    port map(
        clk          => clk,
        start        => start,
        count        => count,
        empty        => empty,
        reset        => reset,
        count_reset  => count_reset,
        re           => re,
        load         => load,
        shift        => shift, 
        mux_sel      => mux_sel
    );
    -------------------------------------------------------------------------
    
    
    
    --------------------- Baud Rate Generator --------------------------------
    process(clk) begin
        if rising_edge(clk) then
            if ((reset = '1') or (count_reset = '1')) then
                count <= (others=>'0');
            else 
                if (count = "1101100100") then  --- Count should go to 868 for proper baudrate
                    count <= (others=> '0');
                else 
                    count <= count + '1';
                end if;
            end if;
        end if;
    end process;
    
    
    
    -------------------- Shift Register ---------------------------------------
    process(clk) begin
        if rising_edge(clk) then
            if (reset = '1') then
                shift_reg <= (others => '0');
            else
                if (load = '1') then
                    shift_reg <= data_out;
                end if;
                if (shift = '1') then
                    shift_reg(6 downto 0) <= shift_reg(7 downto 1);
                end if;
            end if;
        end if;  
    end process;
    
    
    
    
    -------------------- Mux Process ----------------------------------------
    process(shift_reg(0), mux_sel) begin
        if (mux_sel = "00") then
            uart_rx_out <= '0';
        elsif(mux_sel = "01") then
            uart_rx_out <= '1';
        elsif(mux_sel = "10") then
            uart_rx_out <= shift_reg(0);
        else
            uart_rx_out <= '0';
        end if;
    end process;
    
end;

