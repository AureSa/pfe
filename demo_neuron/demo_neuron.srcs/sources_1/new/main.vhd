----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 22.02.2022 15:41:23
-- Design Name: 
-- Module Name: main - Behavioral
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


entity main is
  Port ( 
    btnC : in std_logic;
    clk : in std_logic;
    sw : in std_logic_vector(15 downto 0);
    seg : out std_logic_vector(6 downto 0);
    an : out std_logic_vector(7 downto 0);
    led : out std_logic_vector(15 downto 0)
  );
end main;

architecture Behavioral of main is

component neuron is
Port ( clk : in STD_LOGIC;
       v_out : out STD_LOGIC_VECTOR (31 downto 0);
       u_out : out STD_LOGIC_VECTOR (31 downto 0));
end component;

component clkdiv is
Port ( clk : in STD_LOGIC;
       reset : in STD_LOGIC;
       E190 : out STD_LOGIC;
       clk190 : out STD_LOGIC);
end component;

component btn_pulse is
Port ( inp : in STD_LOGIC;
       e : in STD_LOGIC;
       clk : in STD_LOGIC;
       outp : out STD_LOGIC);
end component;

component x7seg_fsm is
Port ( data : in STD_LOGIC_VECTOR (31 downto 0);
       seg_num : out STD_LOGIC_VECTOR (3 downto 0);
       anodes : out STD_LOGIC_VECTOR (7 downto 0);
       clk : in STD_LOGIC);
end component;

component x7seg is
Port ( inpt : in STD_LOGIC_VECTOR (3 downto 0);
       sevenseg : out STD_LOGIC_VECTOR (6 downto 0));
end component;


signal clk_neuron : std_logic :='0';
signal v : std_logic_vector(31 downto 0) := (others=>'0');
signal u : std_logic_vector(31 downto 0) := (others=>'0');

signal enable : std_logic := '0';
signal clk190 : std_logic := '0';

signal seg_data : std_logic_vector(3 downto 0);
begin

clk_div : clkdiv port map (clk=>clk, reset => '0', E190 => enable, clk190 => clk190);

btn_neuron_clk : btn_pulse port map (inp => btnC, e=> enable, clk => clk, outp=> clk_neuron);
neuron_impl : neuron port map(clk => clk_neuron, v_out => v, u_out => u);

fsm : x7seg_fsm port map(data => v, seg_num => seg_data, anodes => an, clk => clk190);
digit_display : x7seg port map(inpt => seg_data, sevenseg=> seg);

led <= sw;

end Behavioral;
