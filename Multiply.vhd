----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/06/2017 01:54:15 PM
-- Design Name: 
-- Module Name: Multiply - Behavioral
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


LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
LIBRARY WORK;
USE WORK.Generic_size_of_matrices_pkg.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

ENTITY Multiply IS
   PORT (A: IN Fixed_Point;
         B: IN Fixed_Point;
         C : OUT Fixed_Point);
END Multiply;

ARCHITECTURE Behavioral OF Multiply IS

SIGNAL Temp : STD_LOGIC_VECTOR((2*Number_of_Bit)-1 DOWNTO 0); 

BEGIN

    Temp <= STD_LOGIC_VECTOR(SIGNED(A) * SIGNED(B));
    C <= Temp((Number_of_Bit+(Number_of_Bit/2))-1 DOWNTO (Number_of_Bit/2));

END Behavioral;
