-- UART receiver -- 

library ieee; 
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all; 
use IEEE.std_logic_arith.all; 

entity uart_receiver is
    port(
        clk          : in std_logic;
        reset        : in std_logic;
        uart_tx_in   : in std_logic;
        re           : in std_logic;
        empty        : out std_logic;
        data_out     : out std_logic_vector(7 downto 0)
    );
end uart_receiver;

architecture synth of uart_receiver is



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
        full     : out std_logic;
        empty    : out std_logic;
        count    : out std_logic_vector(FIFO_BITS_ADDRESS downto 0) := (others=>'0')
    );
end component;

component receive_SM
    port(
        clk         : in std_logic;
        start       : in std_logic;
        count       : in std_logic_vector (9 downto 0);
        full        : in std_logic;
        reset       : in std_logic;
        count_reset : out std_logic;
        we          : out std_logic;
        shift       : out std_logic
    );
end component;

component sync
    port(
        clk         : in  std_logic;
        din         : in  std_logic;
        dout        : out  std_logic
    );
end component;


-------------------------------- Signal Declaration ------------------------------
signal count        : std_logic_vector(9 downto 0);
signal count_reset  : std_logic;
signal we           : std_logic;
signal full         : std_logic;
signal shift        : std_logic;
signal data_in      : std_logic_vector(7 downto 0);
signal shift_reg    : std_logic_vector(7 downto 0);
signal start        : std_logic;


begin
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
        reset    =>  reset,
        din      =>  data_in,
        dout     =>  data_out,
        full     =>  full,
        empty    =>  empty,
        count    =>  open
    );

    
    
    -------------------- Instantiate State Machine --------------------------
	my_receive_SM : receive_SM 
    port map(
        clk          => clk,
        start        => start,
        count        => count,
        full         => full,
        reset        => reset,
        count_reset  => count_reset,
        we           => we,
        shift        => shift
    );

    
    -------------------- Instantiate Synchronizer --------------------------
	my_sync : sync
    port map(
        clk    => clk, 
        din    => uart_tx_in,
        dout   => start
    );
    
    
    --------------------- Shift Register Process --------------------------
    process(clk) begin
        if rising_edge(clk) then
            if (reset = '1') then
                shift_reg <= (others => '0');
            else
                if (shift = '1') then
                    shift_reg(6 downto 0) <= shift_reg(7 downto 1);
                    shift_reg(7) <= uart_tx_in;
                end if;
            end if;
        end if;  
    end process;
    data_in <= shift_reg;
    
    
    
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
    
end;
    


