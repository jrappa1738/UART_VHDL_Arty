-- FIFO buffer --
-- Joey Rappaport
-- Allan Douglas--
-- EE331 -- Winter 2017 --- 
-- Testing Testing Testing --- 



library ieee; 
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all; 
use IEEE.std_logic_arith.all; 

entity fifo is
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
        --Fifo_wr_addr: 
        full     : out std_logic := '0';
        empty    : out std_logic := '1';
        count    : out std_logic_vector(FIFO_BITS_ADDRESS downto 0) := (others=>'0')
    );
end fifo;


architecture synth of fifo is

--------------------------- Component Declaration ----------------------------------
component ram
    generic(
        BITS_ADDRESS   : integer := 8;
        BITS_DATA      : integer := 8
    );
    port(
        clk_rd        : in std_logic;
        clk_wr        : in std_logic;
        write_address  : in std_logic_vector(BITS_ADDRESS-1 downto 0);
        read_address   : in std_logic_vector(BITS_ADDRESS-1 downto 0);
        write_en       : in std_logic;
        read_en        : in std_logic;
        din            : in std_logic_vector(BITS_DATA-1 downto 0);
        Fifo_data_out : out std_logic_vector(BITS_DATA-1 downto 0);
        dout           : out std_logic_vector(BITS_DATA-1 downto 0)
    );
end component;


component counterGeneric
    generic(
        BITS_CNT : integer := 16 
    );
    port(
        clk       : in std_logic;
        sclr      : in std_logic;
        enable    : in std_logic;                           -- active low enable
        cntr      : out std_logic_vector(BITS_CNT-1 downto 0); -- Counter out
        cout      : out std_logic := '0'                       -- Carry out
    );
end component;


component ud_counter
    generic(
        BITS_CNT       : integer := 16 -- Default to 16 bit counter
    );
    port(
        clk       : in  std_logic;
        up        : in  std_logic;
        down      : in  std_logic;
        reset     : in  std_logic;
        count     : out  std_logic_vector(BITS_CNT-1 downto 0) := (others=>'0')
  );
end component;
------------------------------------------------------------------------------------


------------------ Signal Declarations ------------------------------------
signal wr_ptr         : std_logic_vector(FIFO_BITS_ADDRESS-1 downto 0) := (others=>'0');
signal rd_ptr         : std_logic_vector(FIFO_BITS_ADDRESS-1 downto 0) := (others=>'0');
signal count_to_flag  : std_logic_vector(FIFO_BITS_ADDRESS downto 0) := (others=>'0');
signal empty_sig      : std_logic := '1';
signal full_sig       : std_logic := '0';
signal cout           : std_logic := '0';
signal wr_not         : std_logic := '0';
signal rd_not         : std_logic := '0';
---------------------------------------------------------------------------

begin
wr_not <= not wr;
rd_not <= not rd;
    -------------------- Instantiate Ram ----------------------------------
	my_ram : ram 
    generic map(
        BITS_ADDRESS => FIFO_BITS_ADDRESS,
        BITS_DATA    => FIFO_BITS_DATA
    )
    port map(
		clk_wr         => clk,
		clk_rd         => clk,
        write_address  => wr_ptr,
        read_address   => rd_ptr,
        write_en       => wr,
        read_en        => rd,
        din            => din,
        Fifo_data_out  => Fifo_data_out,
        dout           => dout
    );
    ------------------------------------------------------------------------
    
    -------------------- Instantiate counters ------------------------------
	write_address_counter : counterGeneric 
    generic map(
        BITS_CNT => FIFO_BITS_ADDRESS
    )
    port map(
        clk     => clk,     
        sclr    => reset,
        enable  => wr_not,
        cntr    => wr_ptr,
        cout    => cout
    );
    
    
	read_address_counter : counterGeneric 
    generic map(
        BITS_CNT => FIFO_BITS_ADDRESS
    )
    port map(
        clk     => clk,     
        sclr    => reset,
        enable  => rd_not,
        cntr    => rd_ptr,
        cout    => cout
    );
    
    up_down_counter : ud_counter
    generic map(
        BITS_CNT => FIFO_BITS_ADDRESS+1
    )
    port map(
        clk     => clk,
        up      => wr,
        down    => rd,
        reset   => reset,
        count   => count_to_flag
    );
    -----------------------------------------------------------------------
    
    
    
    ------------------------ Full/Empty Flag process ----------------------
    process(clk) begin
        if rising_edge(clk) then
           
            ---- Empty Flag -----
            if ((rd = '1') and (wr = '0')) then
                if (count_to_flag = FIFO_BITS_ADDRESS-(FIFO_BITS_ADDRESS-1)) then
                    empty_sig <= '1';
                end if;
            elsif((count_to_flag = FIFO_BITS_ADDRESS-FIFO_BITS_ADDRESS) and (empty_sig = '1')) then
                empty_sig <= '1';
           -- elsif((count_to_flag = FIFO_BITS_ADDRESS - FIFO_BITS_ADDRESS)) then
           --        empty_sig <= '1';
            else
                empty_sig <= '0';
            end if;
            
            ---- Full Flag -----
            if ((rd = '0') and (wr = '1')) then
                if (count_to_flag = "0111111") then
                    full_sig <= '1';
                end if;
            elsif ((count_to_flag = "1000000") and (full_sig = '1')) then
                full_sig <= '1';
            else
                full_sig <= '0';
            end if;
            
        end if;
    end process;
    
    empty <= empty_sig;
    full <= full_sig;
    count <= count_to_flag;    

end;

