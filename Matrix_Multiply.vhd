
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

ENTITY Matrix_Multiply is
        PORT (CLK : IN STD_LOGIC;
              Matrix_1: IN Matrix(0 TO Number_of_output-1, 0 TO Number_of_output-1);
              Matrix_2: IN Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1);
              Matrix_res : OUT Matrix(0 TO Number_of_output-1,0 TO Batch_size-1));
END Matrix_Multiply;

ARCHITECTURE Behavioral OF Matrix_Multiply IS
SIGNAL i,j,k : integer:=0;
SIGNAL MUL_in  : Matrix(0 TO Number_of_output-1,0 TO Number_of_output-1):=(OTHERS => (OTHERS => (OTHERS => '0')));
SIGNAL MUL_out  : Matrix(0 TO Number_of_output-1,0 TO Number_of_output-1):=(OTHERS => (OTHERS => (OTHERS => '0')));
SIGNAL TEMP : Matrix(0 TO Number_of_output-1, 0 TO Number_of_output-1):=(OTHERS => (OTHERS => (OTHERS => '0')));
COMPONENT Multiply 
   PORT (A: IN Fixed_Point;
         B: IN Fixed_Point;
         C : OUT Fixed_Point);
END COMPONENT;

COMPONENT Ripple_Sum 
   PORT (A: IN Fixed_Point;
         B: IN Fixed_Point;
         C : OUT Fixed_Point);
END COMPONENT;
BEGIN

PROCESS(CLK)
 BEGIN
    IF(CLK'EVENT AND CLK='1') THEN
      MUL_out <= MUL_in;
    END IF;
 END PROCESS;
       LABLE1: FOR i IN 0 TO Number_of_output-1 GENERATE
          LABLE2: FOR j IN 0 TO Batch_size-1 GENERATE
            LABLE3: FOR k IN 0 TO Number_of_output-1 GENERATE
                   U: Multiply PORT MAP
                     (A => Matrix_1(i,k),
                      B => Matrix_2(k,j),
                      C => MUL_in(i,k));
                      LABLE7:IF k=0 GENERATE
                      V: Ripple_Sum PORT MAP
                              (A => "00000000000000000000000000000000",
                               B => MUL_out(i,k),
                               C => TEMP(i,k));
                       END GENERATE LABLE7;
                       LABLE8:IF k>0 GENERATE
                       W: Ripple_Sum PORT MAP
                                 (A => TEMP(i,k-1),
                                  B => MUL_out(i,k),
                                  C => TEMP(i,k));
                       END GENERATE LABLE8;
                       LABLE9:IF k=Number_of_output-1 GENERATE
                       X: Ripple_Sum PORT MAP
                                    (A => TEMP(i,k-1),
                                     B => MUL_out(i,k),
                                     C => Matrix_res(i,j));
                      END GENERATE LABLE9;
                   END GENERATE LABLE3;
            END GENERATE LABLE2;
      END GENERATE LABLE1;
     
END Behavioral;
