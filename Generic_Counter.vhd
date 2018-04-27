-- Generic Counter --
-- Joey Rappaport
-- Alan Douglas--
-- EE331 -- Winter 2017 --- 

library ieee; 
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity counterGeneric is   
    generic(
        BITS_CNT : integer := 16 -- Default to 16 bit counter
    );
    port(
        clk      : in std_logic;
        sclr     : in std_logic;
        enable   : in std_logic;
        cntr     : out std_logic_vector(BITS_CNT-1 downto 0); -- Counter out
        cout     : out std_logic := '0'                  -- Carry out
    );
end counterGeneric;

architecture behavioral of counterGeneric is

signal count : std_logic_vector(BITS_CNT-1 downto 0) := (others=>'0');
signal carry : std_logic := '0';

begin
    process(clk) begin
        if rising_edge(clk) then
        
        ---------------- Clear gets priority, then enable ----------------------
            if (sclr = '0') then
                if (enable = '0') then
                    count <= count + '1';
                end if;
            else
                count <= (others=>'0');
            end if;
            
            
        ------------ If the counter is full, cout = 1 on next clock cycle ------
            if (count = "1111111111") then
                carry <= '1';
            end if;
            if (count = "0000000000") then
                carry <= '0';
            end if;
            
        end if;
    end process;
    
    cout <= carry;
    cntr <= count;
end;
            
