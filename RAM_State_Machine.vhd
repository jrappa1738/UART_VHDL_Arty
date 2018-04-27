-- RAM state machine -- 
-- Joey Rappaport
-- Allan Douglas --
-- EE331 -- Winter 2017 --- 

library ieee; 
use ieee.std_logic_1164.all;
use IEEE.std_logic_unsigned.all; 
use IEEE.std_logic_arith.all; 

entity RAM_SM is
    port(
        clk         : in std_logic;
        empty       : in std_logic;
        full        : in std_logic;
        btn1        : in std_logic;
        btn2        : in std_logic;
        wr_addr     : out std_logic_vector (7 downto 0);
        we_RAM      : out std_logic;
        we_TRANS    : out std_logic;
        re_RECEIVE  : out std_logic;
        state_out   : out std_logic_vector (2 downto 0)
    );
end RAM_SM;

architecture synth of RAM_SM is

-- State signals ---- states are fully encoded
signal state         : std_logic_vector (2 downto 0);
signal next_state    : std_logic_vector (2 downto 0);
--signal ram_empty     : std_logic;
signal wr_addr_cntr  : std_logic_vector(7 downto 0) := "00000000";
signal count         : std_logic_vector(1 downto 0) := "00";


begin
    state_out <= state;
    -------------- State -> Next State process ---------------------
    process(clk) begin
        if rising_edge(clk) then
            if (btn2 = '1') then
                state <= "000";
            else
                state <= next_state;
            end if;
        end if;
	end process;
    
    ---------- Write address counters for central RAM -----
    process(clk) begin
        if rising_edge(clk) then
            if (btn2 = '1') then
                wr_addr_cntr <= "00000000";
            elsif (state = "000") then 
                if (wr_addr_cntr = "11111111") then              
                    wr_addr_cntr <= "00000000";
                end if;
            elsif (state = "001") then
                if (count = "001") then
                    wr_addr_cntr <= wr_addr_cntr + '1';
                end if;
            elsif (state = "010") then
                wr_addr_cntr <= wr_addr_cntr + '1';
            elsif (state = "101") then
                wr_addr_cntr <= wr_addr_cntr + '1';
            elsif (state = "100") then
                wr_addr_cntr <= "00000000";
            end if;
        end if;
    end process;
    --ram_empty <= '1' when rd_addr_cntr = (wr_addr_cntr) else '0'; 
    wr_addr <= wr_addr_cntr;
    
    --- 2 bit counter so that read/writes happen one cycle apart.
    process(clk) begin
        if rising_edge(clk) then
            if (state = "001") then
                count <= count + '1';
            elsif (state = "010") then
                count <= count + '1';
            else
                count <= "00";
            end if;
        end if;
    end process;
        

    
    ------------- Next State Logic ---------------------------------
    process(state, btn1, empty, full, wr_addr_cntr) begin
        case(state) is
            
            when "000" =>
                if (btn1 = '1') then
                    next_state <= "100";
                else
                    if (empty = '1') then
                        next_state <= "000";
                    else
                        next_state <= "001";
                    end if;
                end if;
            
            when "001" =>
                if (btn1 = '1') then
                    next_state <= "100";
                else 
                    if (count = "00") then
                        next_state <= "001";
                    else
                        next_state <= "000";
                    end if;
                end if;

            when "010" =>
                if (wr_addr_cntr = "11111111") then
                    next_state <= "000";
                else
                    if (full = '0') then
                        next_state <= "010";
                    else
                        next_state <= "011";
                    end if;
                end if;
             
            when "011" =>
                if (wr_addr_cntr = "11111111") then
                    next_state <= "000";
                else
                    if (full = '0') then
                        next_state <= "010";
                    else
                        next_state <= "011";
                    end if;
                end if;
                
            when "100" =>
                    next_state <= "101";
            
            when "101" =>
                    next_state <= "010";
                
            when others =>
                next_state <= "000";
            
        end case;
    end process;
    
    ------------- Output Forming Logic -------------------------
    process(state, count, full) begin
        case(state) is
            
            when "000" =>
                we_RAM     <= '0';
                we_TRANS   <= '0';
                re_RECEIVE <= '0';
                
            when "001" =>
                if (count = "00") then
                    we_RAM     <= '0';
                    we_TRANS   <= '0';
                    re_RECEIVE <= '1';
                else
                    we_RAM     <= '1';
                    we_TRANS   <= '0';
                    re_RECEIVE <= '0';
                end if;
                
            when "010" =>
                if(full = '1') then
                    we_RAM     <= '0';
                    we_TRANS   <= '0';
                    re_RECEIVE <= '0';
                else
                    we_RAM     <= '0';
                    we_TRANS   <= '1';
                    re_RECEIVE <= '0';
                end if;
                
            when "011" =>
                we_RAM     <= '0';
                we_TRANS   <= '0';
                re_RECEIVE <= '0';
                
            when "100" =>
                we_RAM     <= '0';
                we_TRANS   <= '0';
                re_RECEIVE <= '0';
                
            when others =>
                we_RAM     <= '0';
                we_TRANS   <= '0';
                re_RECEIVE <= '0';
                
        end case;
   end process;
        
        
end;
                
