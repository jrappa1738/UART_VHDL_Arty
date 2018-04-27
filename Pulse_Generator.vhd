-- pulsegen --
-- Joey Rappaport
-- Allan Douglas--
-- EE331 -- Winter 2017 --- 

library ieee; 
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all; 
use IEEE.std_logic_arith.all;

entity pulse_gen is
  port(
    sig_in       : in std_logic;
    clk          : in std_logic;
    pulse_out    : out std_logic
  );
end;


architecture synth of pulse_gen is

signal Q1 : std_logic;
signal Q2 : std_logic;

begin

    process(clk) begin
        if rising_edge(clk) then
            Q1<=sig_in;
            Q2<=Q1;
        end if;
    end process;
    
    pulse_out <= Q1 and (not Q2);

end;

