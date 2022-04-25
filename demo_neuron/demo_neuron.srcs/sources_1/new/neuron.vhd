----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.02.2022 15:57:52
-- Design Name: 
-- Module Name: neuron - Behavioral
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

entity neuron is
generic(
bits:integer := 31
);
Port ( clk : in STD_LOGIC;
       v_out : out STD_LOGIC_VECTOR (31 downto 0);
       u_out : out STD_LOGIC_VECTOR (31 downto 0));
end neuron;

architecture Behavioral of neuron is

component model_sync_5 is
Port (     Iin : in std_logic_vector(bits downto 0);
           a : in std_logic_vector(bits downto 0);
           b : in std_logic_vector(bits downto 0);
           c : in std_logic_vector(bits downto 0);
           d : in std_logic_vector(bits downto 0);
           clk : in std_logic;
           Vout : out std_logic_vector(bits downto 0);
           Uout : out std_logic_vector(bits downto 0) );
end component;



signal neuron_clk : std_logic;
signal constA : std_logic_vector(bits downto 0) := "00000000000000000000010100011110"; -- 0.02
signal constB : std_logic_vector(bits downto 0) := "00000000000000000011001100110011"; --0.2
signal constC : std_logic_vector (bits downto 0) := "11111111101111110000000000000000"; -- -65
signal constD : std_logic_vector(bits downto 0) := "00000000000010000000000000000000"; -- 8

signal v : std_logic_vector(bits downto 0) := (others=>'0');
signal u : std_logic_vector(bits downto 0) := (others => '0');
signal I : std_logic_vector(bits downto 0) := "00000000000010100000000000000000"; -- 10
begin

model : model_sync_5 port map (Iin => I, 
                         a => constA, b => constB, c => constC, d => constD,
                         clk => clk,
                         Vout => v, Uout => u);

v_out <= v;
u_out <= u;

end Behavioral;
