----------------------------------------------------------------------------------
-- Company: Rober Bosch GmbH - Multimedia Car
-- Engineer: Pedram Babakhani
-- 
-- Create Date: 08/29/2017 11:02:55 AM
-- Design Name: LSTM
-- Module Name: LSTM_Core - Behavioral
-- Project Name: LSTM
-- Target Devices: 
-- Tool Versions: Ultrascale+ MPSoC (ZCU102)
-- Description: 
-- Hardware Implementation of LSTM
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
PACKAGE Generic_size_of_matrices_pkg IS
        CONSTANT Number_of_input : POSITIVE := 28; -- number of inputs
        CONSTANT Number_of_output : POSITIVE := 56; -- Number of outputs
        CONSTANT Batch_size : POSITIVE :=1;
        CONSTANT Number_of_Bit : POSITIVE :=32;
        SUBTYPE Fixed_Point IS STD_LOGIC_VECTOR(Number_of_Bit-1 DOWNTO 0); -- Q16:16     Q-numbers
        TYPE Matrix IS ARRAY (INTEGER range <>, INTEGER range <>) OF Fixed_Point; -- Matrix Declaration
END Generic_size_of_matrices_pkg;
--------------------------------------------END OF PACKAGE--------------------------------------------------