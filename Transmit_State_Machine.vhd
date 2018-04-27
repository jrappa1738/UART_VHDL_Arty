-- Homework 8 --- Transmit State Machine
-- Joey Rappaport
-- Allan Douglas--
-- EE331 -- Winter 2017 --- 

library ieee; 
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all; 
use IEEE.std_logic_arith.all; 


entity transmit_SM is
    port(
        clk         : in std_logic;
        start       : in std_logic;
        count       : in std_logic_vector (9 downto 0);
        empty       : in std_logic;
        reset       : in std_logic;
        count_reset : out std_logic;
        re          : out std_logic;
        load        : out std_logic;
        shift       : out std_logic;
        mux_sel     : out std_logic_vector(1 downto 0)  
    );
end transmit_SM;

architecture synth of transmit_SM is

-- State signals ---- states are fully encoded
signal state         : std_logic_vector (1 downto 0);
signal next_state    : std_logic_vector (1 downto 0);
signal bits_progress : std_logic_vector (3 downto 0); 


begin

    -------------- State -> Next State process ---------------------
    process(clk, reset) begin
        if rising_edge(clk) then
            if (reset = '1') then
                state <= "00";
            else
                state <= next_state;
            end if;
        end if;
	end process;
    
    -------------- Bits Progress Counter --------------------------
    process(clk, reset) begin
        if rising_edge(clk) then
            if (state = "00") then
                bits_progress <= "0000";
            elsif (state = "01") then
                bits_progress <= "0000";
            elsif (state = "10") then
                if (count = "0000000000") then 
                    bits_progress <= bits_progress + '1';
                end if;
            else
                bits_progress <= "0000";
            end if;
        end if;
    end process;
    
    
    ------------- Next State Logic ---------------------------------
    process(state, count, start, empty, bits_progress) begin
        case(state) is
        
            when "00" =>
                if (start = '1') then
                    if (empty = '1') then
                        next_state <= "00";
                    else
                        next_state <= "01";
                    end if;
                else
                    next_state <= "00";
                end if;
        
            when "01" =>
                if (count >= "1101100100") then
                    next_state <= "10";
                else
                    next_state <= "01";
                end if;
                
            when "10" =>
                if ((count >= "1101100100") and (bits_progress = "1000")) then
                    next_state <= "11";
                else
                    next_state <= "10";
                end if;
                
            when "11" =>
                if ((count >= "1101100100") and (empty = '0')) then
                    next_state <= "01";
                elsif ((count >= "1101100100") and (empty = '1')) then
                    next_state <= "00";
                else 
                    next_state <= "11";
                end if;
                
            when others =>
                next_state <= "00";
                
            end case;
        end process;
        
        
        ------------- Output Forming Logic -------------------------
        process(state, count) begin
            case(state) is
            
                when "00" =>
                    mux_sel       <= "01";
                    count_reset   <= '1';
                    re            <= '0';
                    load          <= '0';
                    shift         <= '0';
                    
                when "01" =>
                    if (count = "0000000000") then
                        mux_sel       <= "00";  -- select a 0 to be output of mux
                        count_reset   <= '0';
                        re            <= '1';   -- read enable and load for one clock cycle
                        load          <= '0';
                        shift         <= '0';
                        
                    elsif (count = "0000000001") then
                        mux_sel       <= "00";  -- select a 0 to be output of mux
                        count_reset   <= '0';
                        re            <= '0';   -- read enable and load for one clock cycle
                        load          <= '1';
                        shift         <= '0';
                    else
                        mux_sel       <= "00"; 
                        count_reset   <= '0';
                        re            <= '0';
                        load          <= '0';
                        shift         <= '0';
                    end if;
                        
                when "10" =>
                    if (count = "1101100100") then
                        mux_sel       <= "10";  
                        count_reset   <= '1';
                        re            <= '0';
                        load          <= '0';
                        shift         <= '1';
                    else
                        mux_sel       <= "10";
                        count_reset   <= '0';
                        re            <= '0';
                        load          <= '0';
                        shift         <= '0';
                    end if;
                        
                when "11" =>
                    mux_sel       <= "01";  -- Select a 1 for output of mux
                    count_reset   <= '0';
                    re            <= '0';
                    load          <= '0';
                    shift         <= '0';
                    
                when others =>
                    mux_sel       <= "01";            
                    count_reset   <= '1';            
                    re            <= '0';            
                    load          <= '0';            
                    shift         <= '0';                              
            end case;
        end process;
        
    
end;
    
    
