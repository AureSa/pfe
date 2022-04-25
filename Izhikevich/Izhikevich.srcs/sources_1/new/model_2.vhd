----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.01.2022 14:18:30
-- Design Name: 
-- Module Name: model_2 - Behavioral
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
use ieee.numeric_std.all;
use ieee.math_real.all;

-- on détecte le dépassement de seuil en fonction de la nouvelle valeur de v calculer et non en fonction de la tension de membranes d'entrée
entity model_2 is
    Port ( Vin : in real;
           Uin : in real;
           Iin : in real;
           a : in real;
           b : in real;
           c : in real;
           d : in real;
           clk : in std_logic;
           Vout : out real;
           Uout : out real;
           Iout : out real );
end model_2;

architecture Behavioral of model_2 is

signal vout_no_spike_1 : real;
signal vout_no_spike_2 : real;
signal uout_no_spike : real;
signal uout_spike : real;

begin

vout_no_spike_1 <= Vin + 0.5 * (0.04 * Vin ** 2 + 5 * Vin + 140.0 - Uin + Iin);
vout_no_spike_2 <= vout_no_spike_1 + 0.5 * (0.04 * vout_no_spike_1  ** 2 + 5 * vout_no_spike_1 + 140.0 - Uin + Iin);

uout_no_spike  <= Uin + a*(b*vout_no_spike_2 - Uin);
uout_spike <= Uin + d;

Vout <= c when ((vout_no_spike_2  >= 30.0) and (clk'event) and (clk = '1'))else
        vout_no_spike_2 when ((clk'event) and (clk = '1')) else
        Vin;
        
Uout <= uout_spike  when ((vout_no_spike_2  >= 30.0) and (clk'event) and (clk = '1') )else
        uout_no_spike when ((clk'event) and (clk = '1')) else
        Uin;
        
end Behavioral;