----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.02.2022 13:51:25
-- Design Name: 
-- Module Name: model_sync_3 - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- model_sync mais avec les tensions V et U internalisé au modèle

entity model_sync_3 is
Port (     Iin : in std_logic_vector(31 downto 0);
           a : in std_logic_vector(31 downto 0);
           b : in std_logic_vector(31 downto 0);
           c : in std_logic_vector(31 downto 0);
           d : in std_logic_vector(31 downto 0);
           clk : in std_logic;
           Vout : out std_logic_vector(31 downto 0);
           Uout : out std_logic_vector(31 downto 0) );
end model_sync_3;

architecture Behavioral of model_sync_3 is

constant Const004:std_logic_vector(31 downto 0) := "00000000000000000000101000111101"; --0.04
constant Const5:std_logic_vector(31 downto 0) := "00000000000001010000000000000000"; -- 5
constant Const140:std_logic_vector(31 downto 0) := "00000000100011000000000000000000"; -- 140
constant dt : std_logic_vector (31 downto 0) := "00000000000000001000000000000000"; -- 0.5
constant treshold : std_logic_vector (31 downto 0) := "00000000000111100000000000000000"; -- 30.0

signal init : std_logic := '1';

begin



process (clk)
        
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
    
    variable u_1 : signed(63 downto 0) := (others=>'0');
    variable u_2 : signed(31 downto 0) :=(others=>'0');
    variable u_3 : signed(63 downto 0) :=(others=>'0');  
    
    variable Vold : std_logic_vector(31 downto 0) := (others=>'0');
    variable Uold : std_logic_vector(31 downto 0) := (others=>'0');
begin
    

    if rising_edge (clk) then
        
        -- when it's the first call : initialisation of Vold and Uold
        if init = '1' then
            
            -- Vinit = c
            Vold := c;
            Vout <= c;
            
            -- Uinit = Vinit * b
            u_1 := signed(c) * signed(b);
            
            Uold := std_logic_vector(u_1(47 downto 16));
            Uout <= std_logic_vector(u_1(47 downto 16));
            
            -- only one initialisation
            init <= '0';
        
        else
            
            -- calculation of v in general case
            
            v_1 := signed(Vold) * signed(Const004);                                     -- v_1 = Vin * 0.04
            v_2 := v_1(47 downto 16) + signed(Const5);                                  -- v_2 = Vin * 0.04 + 5
            v_3 := v_2 * signed(Vold);                                                  -- v_3 = (Vin * 0.04 + 5) * Vin
            v_4 := v_3(47 downto 16) + signed(Const140) - signed(Uold) + signed(Iin);   -- v_4 = (Vin * 0.04 + 5) * Vin - Uin + Iin
            v_5 := v_4 * signed(dt);                                                    -- v_5 = 0.5 * ( (Vin * 0.04 + 5) * Vin - Uin + Iin )
        
            vout_no_spike  := signed(Vold) + v_5(47 downto 16);
            
            v_1 := vout_no_spike * signed(Const004);                                    -- v_1 = Vout_no_spike * 0.04
            v_2 := v_1(47 downto 16) + signed(Const5);                                  -- v_2 = Vout_no_spike * 0.04 + 5
            v_3 := v_2 * vout_no_spike ;                                                -- v_3 = (Vout_no_spike * 0.04 +5) * Vout_no_spike
            v_4 := v_3(47 downto 16) + signed(Const140) - signed(Uold) + signed(Iin);   -- v_4 = (Vout_no_spike * 0.04 + 5) * Vout_no_spike - Uin + Iin
            v_5 := v_4 * signed(dt);                                                    -- v_5 = 0.5 * ( (Vout_no_spike * 0.04 + 5) * Vout_no_spike - Uin + Iin)
            
            -- final value of v in general case
            vout_no_spike  := vout_no_spike  + v_5(47 downto 16);
            
            
            -- calculation of u with general v value
            u_1 := signed(b) * vout_no_spike ;
            u_2 := u_1(47 downto 16) - signed(Uold);
            u_3 := u_2 * signed(a);
            
            uout_no_spike  := signed(Uold) + u_3(47 downto 16);
            
            -- if v (general case) > threshold (30.0):
            -- next v and u will be calculate with reset value
            if (vout_no_spike >= signed(treshold )) then
                
                -- reset value of u
                uout_spike := uout_no_spike + signed(d);
                
                -- reset value of v with Vin = c
                v_1 := signed(c) * signed(Const004);                                        -- v_1 = c * 0.04
                v_2 := v_1(47 downto 16) + signed(Const5);                                  -- v_2 = c*0.04+5
                v_3 := v_2 * signed(c);                                                     -- v_3 = (c*0.04+5)*c
                v_4 := v_3(47 downto 16) + signed(Const140) - uout_spike + signed(Iin);     -- v_4 = (c*0.04+5)*c+140-u_reset+I
                v_5 := v_4 * signed(dt);                                                    -- v_5 = 0.5*((c*0.04+5)*c+140-u_reset+I)
                
                -- mid value of v
                vout_spike  := signed(c) + v_5(47 downto 16);
                
                v_1 := vout_spike * signed(Const004);                                       -- v_1 = vout_spike*0.04
                v_2 := v_1(47 downto 16) + signed(Const5);                                  -- v_2 = vout_spike*0.04+5
                v_3 := v_2 * vout_spike ;                                                   -- v_3 = (vout_spike*0.04+5)*vout_spike
                v_4 := v_3(47 downto 16) + signed(Const140) - uout_spike + signed(Iin);     -- v_4 = (vout_spike*0.04+5)*vout_spike+140-u_rest+I
                v_5 := v_4 * signed(dt);                                                    -- v_5 = 0.5*((vout_spike*0.04+5)*vout_spike+140-u_rest+I)
                
                -- final value of v with spike 
                vout_spike  := vout_spike  + v_5(47 downto 16);
                
                -- calculation of u when spike is dectected
                u_1 := signed(b) * vout_spike ;
                u_2 := u_1(47 downto 16) - uout_spike;
                u_3 := signed(a) * u_2;
                
                uout_spike := uout_spike + u_3(47 downto 16);
                
                Vold := std_logic_vector(vout_spike);
                Vout <= std_logic_vector(vout_spike);
                
                Uold := std_logic_vector(uout_spike);
                Uout <= std_logic_vector(uout_spike);
            else    -- v (general case) < threshold 
                
                Vold := std_logic_vector(vout_no_spike);
                Vout <= std_logic_vector(vout_no_spike);
                
                Uold := std_logic_vector(uout_no_spike);
                Uout <= std_logic_vector(uout_no_spike);
                
            end if;
        end if;

            
    end if;
    
    
end process;

end Behavioral;
