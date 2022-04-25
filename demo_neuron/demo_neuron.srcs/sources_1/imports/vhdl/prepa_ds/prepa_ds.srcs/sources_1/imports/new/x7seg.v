----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 16.03.2021 15:56:26
-- Design Name: 
-- Module Name: x7seg - Behavioral
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

entity x7seg is
    Port ( inpt : in STD_LOGIC_VECTOR (3 downto 0);
           sevenseg : out STD_LOGIC_VECTOR (6 downto 0));
end x7seg;

architecture Behavioral of x7seg is

begin

with inpt select
--           gfedcba
sevenseg <= "1000000" when "0000",  -- 0 -> a b c d e f 
            "1111001" when "0001",  -- 1 -> b c
            "0100100" when "0010",  -- 2 -> a b g e d
            "0110000" when "0011",  -- 3 -> a b c d g
            "0011001" when "0100",  -- 4 -> b c f g
            "0010010" when "0101",  -- 5 -> a f g c d
            "0000011" when "0110",  -- 6 -> f e d c g
            "1111000" when "0111",  -- 7 -> a b c 
            "0000000" when "1000",  -- 8 -> a b c d e f g
            "0011000" when "1001",  -- 9 -> f a b g c
            "0001000" when "1010",  -- A -> e f a b c g
            "0000011" when "1011",  -- B -> c d e f g
            "1000110" when "1100",  -- C -> a f e d
            "0100001" when "1101",  -- D -> b c d e g 
            "0000110" when "1110",  -- E -> a f g e d
            "0001110" when others;  -- F -> a f g e

end Behavioral;
