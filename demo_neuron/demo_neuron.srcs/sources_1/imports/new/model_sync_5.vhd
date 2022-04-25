----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.02.2022 12:10:25
-- Design Name: 
-- Module Name: model_sync_5 - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity model_sync_5 is
generic(
bits:integer := 31;
bup:integer := 47;  -- (bits*2+1)-(bits+1)/2
bdown:integer := 16 -- (bits+1)/2
);
Port (     Iin : in std_logic_vector(bits downto 0);
           a : in std_logic_vector(bits downto 0);
           b : in std_logic_vector(bits downto 0);
           c : in std_logic_vector(bits downto 0);
           d : in std_logic_vector(bits downto 0);
           clk : in std_logic;
           Vout : out std_logic_vector(bits downto 0);
           Uout : out std_logic_vector(bits downto 0) );
end model_sync_5;

architecture Behavioral of model_sync_5 is

constant Const004:std_logic_vector(bits downto 0) := "00000000000000000000101000111101"; --0.04
constant Const5:std_logic_vector(bits downto 0) := "00000000000001010000000000000000"; -- 5
constant Const140:std_logic_vector(bits downto 0) := "00000000100011000000000000000000"; -- 140
constant dt : std_logic_vector (bits downto 0) := "00000000000000001000000000000000"; -- 0.25
constant treshold : std_logic_vector (bits downto 0) := "00000000000111100000000000000000"; -- 30.0

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
                
                vout_spike := c;
                
                
                Vold := vout_spike;
                Vout <= vout_spike;
                
                Uold := uout_spike;
                Uout <= uout_spike;
            else    -- v (general case) < threshold 
                
                Vold := vout_no_spike;
                Vout <= vout_no_spike;
                
                Uold := uout_no_spike;
                Uout <= uout_no_spike;
                
            end if;
        end if;

end if;


end process;


end Behavioral;
