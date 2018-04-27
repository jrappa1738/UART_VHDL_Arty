-- debouncer --
-- Joey Rappaport
-- Alan Douglas--
-- EE331 -- Winter 2017 --- 

library ieee; 
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity debouncer is
  port(
    btn    : in  std_logic;
    clk    : in  std_logic;
    result : out  std_logic
  );
end;

------------------------------------------------------------------------------------
architecture sim of debouncer is
------------------------------------------------------------------------------------

component counterGeneric
    generic(
        BITS_CNT : integer := 16 -- Default to 16 bit counter
    );
    port(
        clk      : in std_logic;
        sclr     : in std_logic;
        enable   : in std_logic;
        cntr     : out std_logic_vector(BITS_CNT-1 downto 0); -- Counter out
        cout     : out std_logic                              -- Carry out
    );
end component;


---------------------------- Signals -----------------------------------------------
signal Q1    : std_logic := '0';
signal Q2    : std_logic := '0';
signal Q3    : std_logic := '0';
signal CLR   : std_logic := '0';
signal CARRY : std_logic := '0';

------------------------------------------------------------------------------------

begin


    -------------------- Instantiate Counter ----------------------------------
	my_counter : counterGeneric 
    generic map(
        BITS_CNT  => 10
    )
    port map(
        clk       => clk,
        sclr      => CLR,
        enable    => CARRY,
        cout      => CARRY
    );
    ----------------------------------------------------------------------------
    
    
    
    ---------------------- FF1 process -----------------------------------------
    process(clk) begin
        if rising_edge(clk) then
            Q1 <= btn;
        end if;
    end process;
    ----------------------------------------------------------------------------
    
    ---------------------- FF2 process -----------------------------------------
    process(clk) begin
        if rising_edge(clk) then
            Q2 <= Q1;
        end if;
    end process;
    ----------------------------------------------------------------------------
    
    ---------------------- FF3 process -----------------------------------------
    process(clk) begin
        if rising_edge(clk) then
            if(CARRY = '1') then
                Q3 <= Q2;
            end if;
        end if;
    end process;
    ----------------------------------------------------------------------------
    
    
    CLR    <= Q1 xor Q2;
    result <= Q3;
    
end;
    
    
    