----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.01.2022 12:01:11
-- Design Name: 
-- Module Name: model_sync - Behavioral
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

-- inspiré du modèle 4 mais synthétisable.

entity model_sync is
Port (     Vin : in std_logic_vector(31 downto 0);
           Uin : in std_logic_vector(31 downto 0);
           Iin : in std_logic_vector(31 downto 0);
           a : in std_logic_vector(31 downto 0);
           b : in std_logic_vector(31 downto 0);
           c : in std_logic_vector(31 downto 0);
           d : in std_logic_vector(31 downto 0);
           clk : in std_logic;
           Vout : out std_logic_vector(31 downto 0);
           Uout : out std_logic_vector(31 downto 0);
           Iout : out std_logic_vector(31 downto 0) );
end model_sync;

architecture Behavioral of model_sync is

begin



process (clk)
    
    -- constnant for computation
    variable Const004:std_logic_vector(31 downto 0) := "00000000000000000000101000111101"; --0.04
    variable Const5:std_logic_vector(31 downto 0) := "00000000000001010000000000000000"; -- 5
    variable Const140:std_logic_vector(31 downto 0) := "00000000100011000000000000000000"; -- 140
    variable dt : std_logic_vector (31 downto 0) := "00000000000000001000000000000000";
    
    -- treshold value
    variable treshold : std_logic_vector (31 downto 0) := "00000000000111100000000000000000"; -- 30.0
    
    -- value with spike is not emited
    variable vout_no_spike : signed(31 downto 0);
    variable uout_no_spike : signed(31 downto 0);
    
    -- value when spike is detected    
    variable uout_spike : signed(31 downto 0);
    variable vout_spike :signed(31 downto 0);
    
    -- variable for computation
    variable v_1 : signed(63 downto 0) :=(others=>'0');
    variable v_2 : signed(31 downto 0) :=(others=>'0');
    variable v_3 : signed(63 downto 0) :=(others=>'0');
    variable v_4 : signed(31 downto 0) :=(others=>'0');
    variable v_5 : signed(63 downto 0) :=(others=>'0');
    
    variable u_1 : signed(63 downto 0);
    variable u_2 : signed(31 downto 0);
    variable u_3 : signed(63 downto 0);
    
begin
    

    if rising_edge (clk) then
        
        -- Calcul de v dans le cas g�n�rale 
        -- D�composition du calcul en deux �tapes pour la stabilit� num�rique
        
        v_1 := signed(Vin) * signed(Const004);                              -- v_1 = Vin * 0.04
        v_2 := v_1(47 downto 16) + signed(Const5);                  -- v_2 = Vin * 0.04 + 5
        v_3 := v_2 * signed(Vin);                                           -- v_3 = (Vin * 0.04 + 5) * Vin
        v_4 := v_3(47 downto 16) + signed(Const140) - signed(Uin) + signed(Iin);    -- v_4 = (Vin * 0.04 + 5) * Vin - Uin + Iin
        v_5 := v_4 * signed(dt);                                    -- v_5 = 0.5 * ( (Vin * 0.04 + 5) * Vin - Uin + Iin )
    
        vout_no_spike  := signed(Vin) + v_5(47 downto 16);
        
        v_1 := vout_no_spike * signed(Const004);                    -- v_1 = Vout_no_spike * 0.04
        v_2 := v_1(47 downto 16) + signed(Const5);                  -- v_2 = Vout_no_spike * 0.04 + 5
        v_3 := v_2 * vout_no_spike ;                                -- v_3 = (Vout_no_spike * 0.04 +5) * Vout_no_spike
        v_4 := v_3(47 downto 16) + signed(Const140) - signed(Uin) + signed(Iin);    -- v_4 = (Vout_no_spike * 0.04 + 5) * Vout_no_spike - Uin + Iin
        v_5 := v_4 * signed(dt);                                    -- v_5 = 0.5 * ( (Vout_no_spike * 0.04 + 5) * Vout_no_spike - Uin + Iin)
        
        -- valeyur final de Vout_no_spike 
        vout_no_spike  := vout_no_spike  + v_5(47 downto 16);
        
        
        -- Calcul de u
        u_1 := signed(b) * vout_no_spike ;
        u_2 := u_1(47 downto 16) - signed(Uin);
        u_3 := u_2 * signed(a);
        
        uout_no_spike  := signed(Uin) + u_3(47 downto 16);
        
        -- si le valeur de v calculer est sup�rieur a la tension de seuil
        if (vout_no_spike >= signed(treshold )) then
        
            uout_spike := uout_no_spike + signed(d);
            
            -- Calcul du nouveau V avec pour tension initiale c ( = -65.0 en g�n�ral)
            v_1 := signed(c) * signed(Const004);    
            v_2 := v_1(47 downto 16) + signed(Const5);   
            v_3 := v_2 * signed(c);               
            v_4 := v_3(47 downto 16) + signed(Const140) - uout_spike + signed(Iin);
            v_5 := v_4 * signed(dt);
        
            vout_spike  := signed(c) + v_5(47 downto 16);
            
            v_1 := vout_spike * signed(Const004);    
            v_2 := v_1(47 downto 16) + signed(Const5);   
            v_3 := v_2 * vout_spike ;               
            v_4 := v_3(47 downto 16) + signed(Const140) - uout_spike + signed(Iin);
            v_5 := v_4 * signed(dt);
            
            vout_spike  := vout_spike  + v_5(47 downto 16);
            
            u_1 := signed(b) * vout_spike ;
            u_2 := u_1(47 downto 16) - uout_spike;
            u_3 := signed(a) * u_2;
            
            Uout <= std_logic_vector(uout_spike + u_3 (47 downto 16));
            Vout <= std_logic_vector(vout_spike);
            
        else    -- si pas de d�passement de seuil est d�tect�
            Vout <= std_logic_vector(vout_no_spike);
            Uout <= std_logic_vector(uout_no_spike);
            
        end if;
    end if;
    
    
end process;


end Behavioral;
