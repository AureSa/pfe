----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06.04.2021 16:56:51
-- Design Name: 
-- Module Name: btn_pulse - Behavioral
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

entity btn_pulse is
    Port ( inp : in STD_LOGIC;
           e : in STD_LOGIC;
           clk : in STD_LOGIC;
           outp : out STD_LOGIC);
end btn_pulse;

architecture Behavioral of btn_pulse is

signal q0 : std_logic;
signal q1 : std_logic;
signal q2 : std_logic;
signal q3 : std_logic;
signal q4 : std_logic;
signal q5 : std_logic;

begin

process(clk)
begin
 if (clk'event and clk = '1') then
 
    if (e = '1') then
     q0 <= inp;
     q1 <= q0;
     q2 <= q1;
    end if;
     
     q3 <= q0 and q1 and q2;
     q4 <= q3;
     q5 <= q4;
     
     outp <= q3 and q4 and (not q5);
  end if;
end process;

end Behavioral;
