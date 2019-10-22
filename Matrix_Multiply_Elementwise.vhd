----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/06/2017 04:20:11 PM
-- Design Name: 
-- Module Name: Multiply_of_row_column - Behavioral
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

ENTITY Matrix_Multiply_Elementwise is
        PORT (--CLK :IN STD_LOGIC;
              Matrix_1: IN Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1);
              Matrix_2: IN Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1);
              Matrix_res : OUT Matrix(0 TO Number_of_output-1,0 TO Batch_size-1));
END Matrix_Multiply_Elementwise;

ARCHITECTURE Behavioral OF Matrix_Multiply_Elementwise IS
SIGNAL i,j,k : integer:=0;
COMPONENT Multiply 
   PORT (A: IN Fixed_Point;
         B: IN Fixed_Point;
         C : OUT Fixed_Point);
END COMPONENT;

BEGIN

       LABLE1: FOR i IN 0 TO Number_of_output-1 GENERATE
          LABLE2: FOR j IN 0 TO Batch_size-1 GENERATE
                   U: Multiply PORT MAP
                     (A => Matrix_1(i,j),
                      B => Matrix_2(i,j),
                      C => Matrix_res(i,j));
            END GENERATE LABLE2;
      END GENERATE LABLE1;
END Behavioral;
