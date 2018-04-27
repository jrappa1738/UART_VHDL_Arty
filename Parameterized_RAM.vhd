-- Parametrized ram --
-- Joey Rappaport
-- Allan Douglas--
-- EE331 -- Winter 2017 --- 

library ieee; 
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;  

entity ram is   
    generic(
        BITS_ADDRESS   : integer := 8;
        BITS_DATA      : integer := 8
    );
    port(
        clk_rd        : in std_logic;
        clk_wr        : in std_logic;
        write_address : in std_logic_vector(BITS_ADDRESS-1 downto 0);
        read_address  : in std_logic_vector(BITS_ADDRESS-1 downto 0);
        write_en      : in std_logic;
        read_en       : in std_logic;
        din           : in std_logic_vector(BITS_DATA-1 downto 0);
        Fifo_data_out : out std_logic_vector(BITS_DATA-1 downto 0);
        dout          : out std_logic_vector(BITS_DATA-1 downto 0)
    );
end ram;

architecture behavioral of ram is

type ram_type is array (0 to 2**BITS_ADDRESS-1) of std_logic_vector(BITS_DATA-1 downto 0);
signal ram : ram_type;

attribute ram_style : string;
attribute ram_style of ram : signal is "block";

begin
    Fifo_data_out <= ram(0);
    process(clk_wr) begin 
        if rising_edge(clk_wr) then
            if (write_en = '1') then
                ram(conv_integer(write_address)) <= din;
            end if;
        end if;
    end process;
    
    process(clk_rd) begin
        if rising_edge(clk_rd) then
            if(read_en = '1') then
                dout <= ram(conv_integer(read_address));
            end if;
        end if;
    end process;
    
end;
   
            

    
    

