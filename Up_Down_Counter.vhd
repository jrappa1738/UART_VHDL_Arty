-- Generic Up/Down Counter --
-- Joey Rappaport
-- Alan Douglas--
-- EE331 -- Winter 2017 --- 

library ieee; 
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;  

entity ud_counter is
  generic(
    BITS_CNT      : integer := 16 -- Default to 16 bit counter
  );
  port(
    clk       : in  std_logic;
    up        : in  std_logic;
    down      : in  std_logic;
    reset     : in  std_logic;
    count     : out  std_logic_vector(BITS_CNT-1 downto 0) := (others=>'0')
  );
end ud_counter;

-------------------------------------------------------------------------------
architecture behavioral of ud_counter is
-------------------------------------------------------------------------------

signal counter : std_logic_vector(BITS_CNT-1 downto 0) := (others=>'0');

begin
    
    process(clk) begin 
        if rising_edge(clk) then 
            if (reset = '1') then
                counter <= (others=>'0');
            elsif((up = '1') and (down = '0')) then
                if (counter = (2**(BITS_CNT-1))) then
                    counter <= "1000000";  -- This is not generic!!!
                else
                    counter <= counter + '1';
                end if;
            elsif((up = '0') and (down = '1')) then
                if (counter = "0") then
                    counter <= (others => '0');
                else
                    counter <= counter - '1';
                end if;
            end if;
        end if;
    end process;
    
        
    count <= counter;
end;





