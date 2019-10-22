----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/11/2017 01:44:03 PM
-- Design Name: 
-- Module Name: Matrix_Sigmoid - Behavioral
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

ENTITY Matrix_Tanh IS
    PORT (Matrix_In : IN Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1);
          Matrix_Out : OUT Matrix(0 TO Number_of_output-1,0 TO  Batch_size-1));
end Matrix_Tanh;

ArCHITECTURE Behavioral OF Matrix_Tanh IS
SIGNAL i,j,k : integer:=0;
COMPONENT Tanh
   PORT (Din: IN Fixed_Point;
         Dout : OUT Fixed_Point);
END COMPONENT;
BEGIN
 LABLE1: FOR i IN 0 TO Number_of_output-1 GENERATE
          LABLE2: FOR j IN 0 TO Batch_size-1 GENERATE
                   U: Tanh PORT MAP
                     (Din => Matrix_IN(i,j),
                      Dout => Matrix_Out(i,j));
            END GENERATE LABLE2;
      END GENERATE LABLE1;

END Behavioral;

