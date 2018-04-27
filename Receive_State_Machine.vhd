-- UART receiver state machine --  

library ieee; 
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all; 
use IEEE.std_logic_arith.all; 

entity receive_SM is
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
end receive_SM;

architecture synth of receive_SM is

-- State signals ---- states are fully encoded
signal state         : std_logic_vector (1 downto 0);
signal next_state    : std_logic_vector (1 downto 0);
signal bits_progress : std_logic_vector (3 downto 0); 

begin

    -------------- State -> Next State process ---------------------
    process(clk, reset) begin
        if (reset = '1') then
            state <= "00";
        elsif rising_edge(clk) then
            state <= next_state;
        end if;
	end process;
    
    ------------- Next State Logic ---------------------------------
    process(state, count, start, full, bits_progress) begin
        case(state) is
        
            when "00" =>
                if (start = '0') then
                    if(full = '0') then
                        next_state <= "01";
                    else
                        next_state <= "00";
                    end if;
                else
                    next_state <= "00";
                end if;
                
            when "01" =>
                if (count = "1101100100") then 
                    next_state <= "10";
                else 
                    next_state <= "01";
                end if;
            
            when "10" =>
                if(count = "1101100100") then
                    if bits_progress = "0111" then
                        next_state <= "11";
                    else
                        next_state <= "10";
                    end if;
                else 
                    next_state <= "10";
                end if;
                
            when "11" =>
                next_state <= "00";
                
            when others =>
                next_state <= "00";
                
        end case;
    end process;
    
    
    ----------------------- Output Forming Logic -------------------------
    process(state, count) begin
        case(state) is
        
            when "00" =>
                count_reset   <= '1';
                shift         <= '0';
                we            <= '0';
                
                
            when "01" =>
                count_reset   <= '0'; 
                shift         <= '0'; 
                we            <= '0'; 
               
                    
                    
            when "10" =>
                if (count = "0110110010") then
                    count_reset   <= '0'; 
                    shift         <= '1'; 
                    we            <= '0'; 
                else
                    count_reset   <= '0'; 
                    shift         <= '0'; 
                    we            <= '0'; 
                end if;
                    
            when "11" =>
                count_reset   <= '0'; 
                shift         <= '0'; 
                we            <= '1'; 
                  
            
            when others =>
                count_reset   <= '0'; 
                shift         <= '0'; 
                we            <= '0'; 
                
                
        end case;
    end process;
    
    process(clk) begin
        if rising_edge(clk) then
            if (state = "10") then
                if (count = "1101100100") then
                    bits_progress <= bits_progress + '1';
                end if;
            else
                bits_progress <= "0000";
            end if;
        end if;
    end process;
        
                 
            
        
    
end;
                
                        
