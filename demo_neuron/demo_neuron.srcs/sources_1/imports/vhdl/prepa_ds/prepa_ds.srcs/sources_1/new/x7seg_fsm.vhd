----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.04.2021 14:15:04
-- Design Name: 
-- Module Name: x7seg_fsm - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity x7seg_fsm is
    Port ( data : in STD_LOGIC_VECTOR (31 downto 0);
           seg_num : out STD_LOGIC_VECTOR (3 downto 0);
           anodes : out STD_LOGIC_VECTOR (7 downto 0);
           clk : in STD_LOGIC);
end x7seg_fsm;

architecture Behavioral of x7seg_fsm is

--Use descriptive names for the states, like st1_reset, st2_search
type state_type is (DIGIT1, DIGIT2, DIGIT3, DIGIT4, DIGIT5, DIGIT6, DIGIT7, DIGIT8);
signal state, next_state : state_type;
--Declare internal signals for all outputs of the state-machine
signal seg_num_i : std_logic_vector(3 downto 0);  -- example output signal
signal anodes_i : std_logic_vector(7 downto 0);
--other outputs

begin
SYNC_PROC: process (clk)
   begin
      if (clk'event and clk = '1') then
            state <= next_state;
            seg_num <= seg_num_i;
            anodes <= anodes_i;
         -- assign other outputs to internal signals
      end if;
   end process;

   --MOORE State-Machine - Outputs based on state only
   OUTPUT_DECODE: process (state)
   begin
      --insert statements to decode internal output signals
      --below is simple example
      case(state) is
        when DIGIT1 =>
            seg_num_i <= data(3 downto 0);
            anodes_i <= "11111110";
        when DIGIT2 =>
            seg_num_i <= data(7 downto 4);
            anodes_i <= "11111101";
        when DIGIT3 =>
            seg_num_i <= data(11 downto 8);
            anodes_i <= "11111011";
        when DIGIT4 => 
            seg_num_i <= data(15 downto 12);
            anodes_i <= "11110111";
        when DIGIT5 =>
            seg_num_i <= data(19 downto 16);
            anodes_i <= "11101111";
        when DIGIT6 =>
            seg_num_i <= data(23 downto 20);
            anodes_i <= "11011111";
        when DIGIT7 =>
            seg_num_i <= data(27 downto 24);
            anodes_i <= "10111111";
        when DIGIT8 =>
            seg_num_i <= data(31 downto 28);
            anodes_i <= "01111111";
        when others =>
            seg_num_i <= x"0";
            anodes_i <= "11111111";
      end case;
   end process;

   NEXT_STATE_DECODE: process (state, clk)
   begin
      --declare default state for next_state to avoid latches
      
      --insert statements to decode next_state
      --below is a simple example
      if(clk = '1') then
          next_state <= state;  --default is to stay in current state
          case (state) is
             when DIGIT1 =>
                next_state <= DIGIT2;
             when DIGIT2 =>
                next_state <= DIGIT3;
             when DIGIT3 =>
                next_state <= DIGIT4;
             when DIGIT4 =>
                next_state <= DIGIT5;
             when DIGIT5 =>
                next_state <= DIGIT6;
             when DIGIT6 =>
                next_state <= DIGIT7;
             when DIGIT7 =>
                next_state <= DIGIT8;
             when DIGIT8 =>
                next_state <= DIGIT1;
             when others =>
                next_state <= DIGIT1;
          end case;
      end if;
   end process;



end Behavioral;
