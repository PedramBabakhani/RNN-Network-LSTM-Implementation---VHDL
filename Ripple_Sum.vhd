----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/08/2017 06:33:21 PM
-- Design Name: 
-- Module Name: Ripple_Sum - Behavioral
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

ENTITY Ripple_Sum IS
   PORT (A: IN Fixed_Point;
         B: IN Fixed_Point;
         C : OUT Fixed_Point);
END Ripple_Sum;

ARCHITECTURE Behavioral OF Ripple_Sum IS

BEGIN

  C <= STD_LOGIC_VECTOR(SIGNED(A) + SIGNED(B));
END Behavioral;
