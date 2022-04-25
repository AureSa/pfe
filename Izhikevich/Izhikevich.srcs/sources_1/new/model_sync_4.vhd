----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 07.02.2022 16:58:02
-- Design Name: 
-- Module Name: model_sync_4 - Behavioral
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

-- identique au model_sync_3 mais en remplacant tous les signed par des std_logic_vector pour consommer moins de ressources

entity model_sync_4 is
generic(
bits:integer := 63;
bup:integer := 95;
bdown:integer := 32
);
Port (     Iin : in std_logic_vector(bits downto 0);
           a : in std_logic_vector(bits downto 0);
           b : in std_logic_vector(bits downto 0);
           c : in std_logic_vector(bits downto 0);
           d : in std_logic_vector(bits downto 0);
           clk : in std_logic;
           Vout : out std_logic_vector(bits downto 0);
           Uout : out std_logic_vector(bits downto 0) );
end model_sync_4;

architecture Behavioral of model_sync_4 is

constant Const004:std_logic_vector(bits downto 0) := "0000000000000000000000000000000000001010001111010111000010100011"; --0.04
constant Const5:std_logic_vector(bits downto 0) := "0000000000000000000000000000010100000000000000000000000000000000"; -- 5
constant Const140:std_logic_vector(bits downto 0) := "0000000000000000000000001000110000000000000000000000000000000000"; -- 140
constant dt : std_logic_vector (bits downto 0) := "0000000000000000000000000000000001000000000000000000000000000000"; -- 0.25
constant treshold : std_logic_vector (bits downto 0) := "0000000000000000000000000001111000000000000000000000000000000000"; -- 30.0

signal init : std_logic := '1';

begin


process (clk)

    -- value with spike is not emited
    variable vout_no_spike : std_logic_vector(bits downto 0);
    variable uout_no_spike : std_logic_vector(bits downto 0);
    
    -- value when spike is detected    
    variable uout_spike : std_logic_vector(bits downto 0);
    variable vout_spike :std_logic_vector(bits downto 0);
    
    -- variable for computation
    variable v_1 : std_logic_vector(bits*2+1 downto 0) :=(others=>'0');
    variable v_2 : std_logic_vector(bits downto 0) :=(others=>'0');
    variable v_3 : std_logic_vector(bits*2+1 downto 0) :=(others=>'0');
    variable v_4 : std_logic_vector(bits downto 0) :=(others=>'0');
    variable v_5 : std_logic_vector(bits*2+1 downto 0) :=(others=>'0');
    
    variable u_1 : std_logic_vector(bits*2+1 downto 0) := (others=>'0');
    variable u_2 : std_logic_vector(bits downto 0) :=(others=>'0');
    variable u_3 : std_logic_vector(bits*2+1 downto 0) :=(others=>'0');  
    variable u_4 : std_logic_vector(bits*2+1 downto 0) := (others=>'0');
    
    variable Vold : std_logic_vector(bits downto 0) := (others=>'0');
    variable Uold : std_logic_vector(bits downto 0) := (others=>'0');

begin


if rising_edge (clk) then

           -- when it's the first call : initialisation of Vold and Uold
        if init = '1' then
            
            -- Vinit = c
            Vold := c;
            Vout <= c;
            
            -- Uinit = Vinit * b
            u_1 := std_logic_vector (signed(c) * signed(b));
            
            Uold := std_logic_vector(u_1(bup downto bdown));
            Uout <= std_logic_vector(u_1(bup downto bdown));
            
            -- only one initialisation
            init <= '0';
        
        else
            
            -- calculation of v in general case
            
            v_1 := std_logic_vector( signed(Vold) * signed(Const004) );                                     -- v_1 = Vin * 0.04
            v_2 := std_logic_vector( signed(v_1(bup downto bdown)) + signed(Const5));                                  -- v_2 = Vin * 0.04 + 5
            v_3 := std_logic_vector( signed(v_2) * signed(Vold));                                                  -- v_3 = (Vin * 0.04 + 5) * Vin
            v_4 := std_logic_vector( signed(v_3(bup downto bdown)) + signed(Const140) - signed(Uold) + signed(Iin));   -- v_4 = (Vin * 0.04 + 5) * Vin - Uin + Iin
            v_5 := std_logic_vector(signed(v_4) * signed(dt));                                                    -- v_5 = 0.5 * ( (Vin * 0.04 + 5) * Vin - Uin + Iin )
        
            vout_no_spike  := std_logic_vector(signed(Vold) + signed(v_5(bup downto bdown)));
            
            
            
            -- calculation of u with general v value
            u_1 := std_logic_vector( signed(b) * signed(vout_no_spike)) ;
            u_2 := std_logic_vector( signed(u_1(bup downto bdown)) - signed(Uold));
            u_3 := std_logic_vector(signed(u_2) * signed(a));
            u_4 := std_logic_vector(signed(u_3(bup downto bdown)) * signed(dt));
            
            uout_no_spike  := std_logic_vector( signed(Uold) + signed(u_4(bup downto bdown)));
            
            -- if v (general case) > threshold (30.0):
            -- next v and u will be calculate with reset value
            if (signed(vout_no_spike) >= signed(treshold )) then
                
                -- reset value of u
                uout_spike := std_logic_vector(signed(uout_no_spike) + signed(d));
                
                -- reset value of v with Vin = c
                v_1 := std_logic_vector(signed(c) * signed(Const004));                                        -- v_1 = c * 0.04
                v_2 := std_logic_vector(signed(v_1(bup downto bdown)) + signed(Const5));                                  -- v_2 = c*0.04+5
                v_3 := std_logic_vector(signed(v_2) * signed(c));                                                     -- v_3 = (c*0.04+5)*c
                v_4 := std_logic_vector(signed(v_3(bup downto bdown)) + signed(Const140) - signed(uout_spike) + signed(Iin));     -- v_4 = (c*0.04+5)*c+140-u_reset+I
                v_5 := std_logic_vector(signed(v_4) * signed(dt));                                                    -- v_5 = 0.5*((c*0.04+5)*c+140-u_reset+I)
                
                vout_spike  := std_logic_vector(signed(c) + signed(v_5(bup downto bdown)));
                
                
                -- calculation of u when spike is dectected
                u_1 := std_logic_vector(signed(b) * signed(vout_spike)) ;
                u_2 := std_logic_vector(signed(u_1(bup downto bdown)) - signed(uout_spike));
                u_3 := std_logic_vector(signed(a) * signed(u_2));
                u_4 := std_logic_vector(signed(dt) * signed(u_3(bup downto bdown)));
                
                uout_spike := std_logic_vector( signed(uout_spike) + signed(u_4(bup downto bdown)));
                
                -- update value for next computation and 
                Vold := vout_spike;
                Uold := uout_spike;
                
                -- set output value
                Vout <= vout_spike;
                Uout <= uout_spike;
            else    -- v (general case) < threshold 
                
                -- update value for next computation and 
                Vold := vout_no_spike;
                Uold := uout_no_spike;
                
                -- set output value
                Vout <= vout_no_spike;
                Uout <= uout_no_spike;
                
            end if;
        end if;

end if;


end process;

end Behavioral;
