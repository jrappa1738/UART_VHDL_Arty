-- RAM -- 
-- Joey Rappaport
-- Allan Douglas--
-- EE331 -- Winter 2017 --- 

library ieee; 
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;  

entity ram_2 is   
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
end ram_2;

architecture behavioral of ram_2 is

type ram_type is array (0 to 2**BITS_ADDRESS-1) of std_logic_vector(BITS_DATA-1 downto 0);
signal ram : ram_type;

begin
    test_data<=ram(0);
    process(clk) begin 
        if rising_edge(clk) then
            if (write_en = '1') then
                ram(conv_integer(address)) <= din;
            end if;
            dout <= ram(conv_integer(address));
        end if;
    end process;
    
end;