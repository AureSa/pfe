----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 21.01.2022 12:52:43
-- Design Name: 
-- Module Name: model_4 - Behavioral
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
use ieee.float_pkg.all;

-- calcul de deux tensions de sortie, l'une en fonction de vin, l'autre en fonction de c dans le cas ou un reset à eu lieu
-- en fonction de la tension calculer aveec vin en envoie la tension reset ou non
-- modèle le plus précis pour le moment

entity model_4 is
    Port ( Vin : in float32;
           Uin : in float32;
           Iin : in float32;
           a : in float32;
           b : in float32;
           c : in float32;
           d : in float32;
           clk : in std_logic;
           Vout : out float32;
           Uout : out float32;
           Iout : out float32 );
end model_4;

architecture Behavioral of model_4 is


signal vout_no_spike_1 : float32;
signal vout_no_spike_2 : float32;
signal uout_no_spike : float32;

signal vout_spike_1 : float32;
signal vout_spike_2 : float32;
signal uout_spike : float32;
signal u_spike : float32;

begin

vout_no_spike_1 <= Vin + 0.5 * (0.04 * (Vin * Vin) + 5 * Vin + 140.0 - Uin + Iin);
vout_no_spike_2 <= vout_no_spike_1 + 0.5 * (0.04 * (vout_no_spike_1 * vout_no_spike_1 ) + 5 * vout_no_spike_1 + 140.0 - Uin + Iin);

uout_no_spike  <= Uin + a*(b*vout_no_spike_2 - Uin);

u_spike <= uout_no_spike + d;
vout_spike_1 <= -65.0 + 0.5 * (0.04 * (-65.0) ** 2 + 5*(-65.0)+ 140.0 - u_spike + Iin);
vout_spike_2 <= vout_spike_1 + 0.5 * (0.04 * (vout_spike_1 * vout_spike_1 ) + 5 * vout_spike_1 +140.0 - u_spike + Iin);
uout_spike <= u_spike + a*(b*vout_spike_2 - u_spike); 


Vout <= vout_spike_2  when ((vout_no_spike_2  >= 30.0) and (clk'event) and (clk = '1'))else
        vout_no_spike_2 when ((clk'event) and (clk = '1')) else
        Vin;
        
Uout <= u_spike  when ((vout_no_spike_2  >= 30.0) and (clk'event) and (clk = '1') )else
        uout_no_spike when ((clk'event) and (clk = '1')) else
        Uin;
        
end Behavioral;
