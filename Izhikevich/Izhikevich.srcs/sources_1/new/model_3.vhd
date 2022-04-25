----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.01.2022 14:43:03
-- Design Name: 
-- Module Name: model_3 - Behavioral
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

-- modèle qui intégre le seuil maximale dans les valeurs de sortie
-- on calcul la nouvelle valeur de vout, si on détecte un dépassement de seuil on mets la tension de sortie a 30mV qui sera reset au prochain calcul
entity model_3 is
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
end model_3;

architecture Behavioral of model_3 is

signal vout_spike_1 : real;
signal vout_spike_2 : real;
signal vout_spike : real;
signal uout_30_spike : real;
signal uout_no_spike : real;
signal uout_spike : real;

begin

vout_spike_1 <= Vin + 0.5 * (0.04 * Vin ** 2 + 5 * Vin + 140.0 - Uin + Iin);
vout_spike_2 <= vout_spike_1 + 0.5 * (0.04 * vout_spike_1  ** 2 + 5 * vout_spike_1 + 140.0 - Uin + Iin);

uout_no_spike  <= Uin + a*(b*vout_spike_2 - Uin);
uout_30_spike <= Uin + a*(b*30.0 - Uin);
uout_spike <= Uin + d;

Vout <= c when ((Vin >= 30.0) and (clk'event) and (clk = '1'))else
        30.0 when ( (Vin <= 30.0) and (vout_spike_2 >= 30.0) and (clk'event) and (clk = '1')) else
        vout_spike_2 when ((clk'event) and (clk = '1')) else
        Vin;
        
Uout <= uout_spike  when ((Vin >= 30.0) and (clk'event) and (clk = '1') )else
        uout_30_spike when ( (Vin <= 30.0) and (vout_spike_2 >= 30.0) and (clk'event) and (clk = '1')) else
        uout_no_spike when ((clk'event) and (clk = '1')) else
        Uin;
        
end Behavioral;
