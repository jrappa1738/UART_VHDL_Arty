-- Synchronizer Circuit - Joey Rappaport

library ieee; 
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;  -- So that we can use

entity sync is
  port(
    clk     : in   std_logic;
    din     : in   std_logic;
    reset   : in   std_logic;
    dout    : out  std_logic
  );
end;

architecture synth of sync is

signal q : std_logic;


begin

process (clk) begin
    if rising_edge (clk) then
        if (reset = '1') then
            q <= '0';
        else 
            q <= din;
        end if;
    end if;
end process;

process (clk) begin
    if rising_edge (clk) then
        if (reset = '1') then
            dout <= '0';
        else
            dout <= q;
        end if;
    end if;
end process;

end;
    
    