----------------------------------------------------------------------------------
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
-----------------------------------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;

PACKAGE Generic_size_of_matrices_pkg IS
        CONSTANT Number_of_input : POSITIVE := 28; -- number of inputs
        CONSTANT Number_of_output : POSITIVE := 56; -- Number of outputs
        CONSTANT Batch_size : POSITIVE :=1;
        CONSTANT Number_of_Bit : POSITIVE :=32; --number of bits for numbers
        SUBTYPE Fixed_Point IS STD_LOGIC_VECTOR(Number_of_Bit-1 DOWNTO 0); -- Q16:16     Q-numbers
        TYPE Matrix IS ARRAY (INTEGER range <>, INTEGER range <>) OF Fixed_Point; -- Matrix Declaration
END Generic_size_of_matrices_pkg;

------------------------------------------------------------------------------------------------------------
------------------------------------------------ LSTM_Core -------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.numeric_std.ALL;
use STD.TEXTIO.all;
LIBRARY WORK;
USE WORK.Generic_size_of_matrices_pkg.ALL;

ENTITY LSTM_Core IS
        PORT ( CLK : IN STD_LOGIC; -- Clock
               RST : IN STD_LOGIC; -- Reset
               EN : IN STD_LOGIC; -- enable
               X_t : IN  Fixed_Point; -- X(t)
               H_t1 : IN  Fixed_Point; -- H(t-1)
               C_t1 : IN  Fixed_Point; -- C(t-1)
               H_t : OUT  Fixed_Point; -- H(t)
               C_t : OUT  Fixed_Point;-- C(t)
               Done : OUT STD_LOGIC); --calculation is done
END LSTM_Core;

ARCHITECTURE Behavioral OF LSTM_Core IS
 
 
 SIGNAL X_t_vector :  Matrix (0 TO Number_of_input-1 ,0 TO Batch_size-1);-- X(t)
 SIGNAL H_t1_vector : Matrix (0 TO Number_of_output-1,0 TO Batch_size-1);-- H(t-1)
 SIGNAL C_t1_vector : Matrix (0 TO Number_of_output-1,0 TO Batch_size-1);-- C(t-1)
 
 SIGNAL X_ttemp :  Matrix (0 TO Number_of_input-1 ,0 TO Batch_size-1);-- X(t)
 SIGNAL H_t1temp : Matrix (0 TO Number_of_output-1,0 TO Batch_size-1);-- H(t-1)
 SIGNAL C_t1temp : Matrix (0 TO Number_of_output-1,0 TO Batch_size-1);-- C(t-1)
 SIGNAL H_ttemp :  Matrix (0 TO Number_of_output-1,0 TO Batch_size-1);-- H(t)
 SIGNAL C_ttemp :  Matrix (0 TO Number_of_output-1,0 TO Batch_size-1);-- C(t)
 ----------------------Input,Forget gates and Memory cell-------------------------------------------------------------------------
 SIGNAL F_t : Matrix(0 TO Number_of_output-1 ,0 TO Batch_size-1);-- f(t)
 SIGNAL I_t : Matrix(0 TO Number_of_output-1 ,0 TO Batch_size-1);-- i(t)
 SIGNAL C_tilde_t : Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1);-- C_tilde(t)
 SIGNAL O_t : Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1); -- o(t)
 SIGNAL F_t_temp : Matrix(0 TO Number_of_output-1 ,0 TO Batch_size-1); -- f(t)
 SIGNAL I_t_temp : Matrix(0 TO Number_of_output-1 ,0 TO Batch_size-1);-- i(t)
 SIGNAL C_tilde_t_temp : Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1);-- C_tilde(t)
 SIGNAL O_t_temp : Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1);-- o(t)
 SIGNAL O_t_prime : Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1);-- o(t)
 ---------------------------------------------------------------------------------------------------------------------------------
 -------------------------Internal Weight Matrices-----------------------------------------------------------------------------------------
 SIGNAL Wxf : Matrix(0 TO Number_of_output-1,0 TO Number_of_input-1); -- weight matrix Wxf
 SIGNAL Wxi : Matrix(0 TO Number_of_output-1,0 TO Number_of_input-1); -- weight matrix Wxi
 SIGNAL Wxc : Matrix(0 TO Number_of_output-1,0 TO Number_of_input-1); -- weight matrix Wxc
 SIGNAL Wxo : Matrix(0 TO Number_of_output-1,0 TO Number_of_input-1); -- weight matrix Wxo
 SIGNAL Whf : Matrix(0 TO Number_of_output-1,0 TO Number_of_output-1);-- weight matrix Whf
 SIGNAL Whi : Matrix(0 TO Number_of_output-1,0 TO Number_of_output-1);-- weight matrix Whi
 SIGNAL Whc : Matrix(0 TO Number_of_output-1,0 TO Number_of_output-1);-- weight matrix Whc
 SIGNAL Who : Matrix(0 TO Number_of_output-1,0 TO Number_of_output-1);-- weight matrix Who
 ---------------------------------------------------------------------;-----------------------------------------------------------
 SIGNAL Wxf_add : STD_LOGIC_VECTOR(0 TO 10); -- address for reading data from ROM for Wxf
 SIGNAL Wxo_add : STD_LOGIC_VECTOR(0 TO 10); -- address for reading data from ROM for Wxi
 SIGNAL Wxc_add : STD_LOGIC_VECTOR(0 TO 10); -- address for reading data from ROM for Wxc
 SIGNAL Wxi_add : STD_LOGIC_VECTOR(0 TO 10); -- address for reading data from ROM for Wxo
 SIGNAL Whf_add : STD_LOGIC_VECTOR(0 TO 11); -- address for reading data from ROM for Whf
 SIGNAL Who_add : STD_LOGIC_VECTOR(0 TO 11); -- address for reading data from ROM for Whi
 SIGNAL Whc_add : STD_LOGIC_VECTOR(0 TO 11); -- address for reading data from ROM for Whc
 SIGNAL Whi_add : STD_LOGIC_VECTOR(0 TO 11); -- address for reading data from ROM for Who
 SIGNAL Wxf_temp : Fixed_Point; --output of ROM for Wxf 
 SIGNAL Wxo_temp : Fixed_Point; --output of ROM for Wxi 
 SIGNAL Wxc_temp : Fixed_Point; --output of ROM for Wxc 
 SIGNAL Wxi_temp : Fixed_Point; --output of ROM for Wxo 
 SIGNAL Whf_temp : Fixed_Point; --output of ROM for Whf 
 SIGNAL Who_temp : Fixed_Point; --output of ROM for Whi 
 SIGNAL Whc_temp : Fixed_Point; --output of ROM for Whc 
 SIGNAL Whi_temp : Fixed_Point; --output of ROM for Who 
 ---------------------------Bias Matrices--------------------------------------------------------------------------------------
 SIGNAL bf : Matrix(0 TO Number_of_output-1,0 TO Batch_size-1);  
 SIGNAL bi : Matrix(0 TO Number_of_output-1,0 TO Batch_size-1);
 SIGNAL bc : Matrix(0 TO Number_of_output-1,0 TO Batch_size-1); 
 SIGNAL bo : Matrix(0 TO Number_of_output-1,0 TO Batch_size-1);
 SIGNAL bf_add : STD_LOGIC_VECTOR(0 TO 5);
 SIGNAL bo_add : STD_LOGIC_VECTOR(0 TO 5);
 SIGNAL bc_add : STD_LOGIC_VECTOR(0 TO 5);
 SIGNAL bi_add : STD_LOGIC_VECTOR(0 TO 5); 
 SIGNAL bf_temp : Fixed_Point;
 SIGNAL bi_temp : Fixed_Point;
 SIGNAL bc_temp : Fixed_Point;
 SIGNAL bo_temp : Fixed_Point;
 -------------------------------------------------------------------------------------------------------------------------------
 -------------------------------------------------Temp Signals for F(t) -----------------------------------------------------------------
 SIGNAL Whf_Ht1 : Matrix(0 TO Number_of_output-1,0 TO Batch_size-1);-- result of maultiply W_hf and H_t1 
 SIGNAL Wxf_Xt  : Matrix(0 TO Number_of_output-1,0 TO Batch_size-1);-- result of maultiply W_xf and X_t
 SIGNAL Whf_Ht1_Wxf_Xt : Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1); -- result of adding  Whf_Ht1 and Wxf_Xt
 SIGNAL Whf_Ht1_Wxf_Xt_bf : Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1);-- result of adding  Whf_Ht1_Wxf_Xt and bias matrices b_f
 SIGNAL Whf_Ht1temp : Matrix(0 TO Number_of_output-1,0 TO Batch_size-1);-- result of maultiply W_hf and H_t1 
 SIGNAL Wxf_Xttemp : Matrix(0 TO Number_of_output-1,0 TO Batch_size-1);-- result of maultiply W_xf and X_t
 SIGNAL Whf_Ht1_Wxf_Xttemp : Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1);-- result of adding  Whf_Ht1 and Wxf_Xt
 SIGNAL Whf_Ht1_Wxf_Xt_bftemp : Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1);-- result of adding  Whf_Ht1_Wxf_Xt and bias matrices b_f
 -----------------------------------------------------------------------------------------------------------------------------------------
 -------------------------------------------------Temp Signals for i(t) ------------------------------------------------------------------
 SIGNAL Whi_Ht1 : Matrix(0 TO Number_of_output-1,0 TO Batch_size-1);-- result of maultiply W_hi and H_t1 
 SIGNAL Wxi_Xt  : Matrix(0 TO Number_of_output-1,0 TO Batch_size-1);-- result of maultiply W_xi and X_t  
 SIGNAL Whi_Ht1_Wxi_Xt  : Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1);-- result of adding  Whi_Ht1 and Wxi_Xt
 SIGNAL Whi_Ht1_Wxi_Xt_bi  : Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1); -- result of adding  Whi_Ht1_Wxi_Xt and bias matrices b_f
 SIGNAL Whi_Ht1temp : Matrix(0 TO Number_of_output-1,0 TO Batch_size-1);-- result of maultiply W_hi and H_t1 
 SIGNAL Wxi_Xttemp  : Matrix(0 TO Number_of_output-1,0 TO Batch_size-1); -- result of maultiply W_xi and X_t  
 SIGNAL Whi_Ht1_Wxi_Xttemp  : Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1); -- result of adding  Whi_Ht1 and Wxi_Xt
 SIGNAL Whi_Ht1_Wxi_Xt_bitemp  : Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1);-- result of adding  Whi_Ht1_Wxi_Xt and bias
 -----------------------------------------------------------------------------------------------------------------------------------------
 
 -------------------------------------------------Temp Signals for C_tilde(t) ------------------------------------------------------------------
 SIGNAL Whc_Ht1 : Matrix(0 TO Number_of_output-1,0 TO Batch_size-1);--result of maultiply W_hc and H_t1 
 SIGNAL Wxc_Xt  : Matrix(0 TO Number_of_output-1,0 TO Batch_size-1);-- result of maultiply W_xc and X_t  
 SIGNAL Whc_Ht1_Wxc_Xt  : Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1);-- result of adding  Whc_Ht1 and Wxc_Xt
 SIGNAL Whc_Ht1_Wxc_Xt_bc  : Matrix(0 TO Number_of_output-1,0 TO Batch_size-1);-- result of adding  Whc_Ht1_Wxc_Xt and bias matrices b_c
 SIGNAL Whc_Ht1temp : Matrix(0 TO Number_of_output-1,0 TO Batch_size-1);-- result of maultiply W_hc and H_t1 
 SIGNAL Wxc_Xttemp  : Matrix(0 TO Number_of_output-1,0 TO Batch_size-1);-- result of maultiply W_xc and X_t  
 SIGNAL Whc_Ht1_Wxc_Xttemp  : Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1);--result of adding  Whc_Ht1 and Wxc_Xt
 SIGNAL Whc_Ht1_Wxc_Xt_bctemp  : Matrix(0 TO Number_of_output-1,0 TO Batch_size-1);-- result of adding  Whc_Ht1_Wxc_Xt and bias matrices b_c
 -----------------------------------------------------------------------------------------------------------------------------------------
  
 --------------------------------------------------Temp Signals for O(t) ------------------------------------------------------------------
 SIGNAL Who_Ht1 : Matrix(0 TO Number_of_output-1,0 TO Batch_size-1);--result of maultiply W_ho and H_t1 
 SIGNAL Wxo_Xt  : Matrix(0 TO Number_of_output-1,0 TO Batch_size-1);-- result of maultiply W_xo and X_t  
 SIGNAL Who_Ht1_Wxo_Xt  : Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1);-- result of adding  Who_Ht1 and Wxo_Xt
 SIGNAL Who_Ht1_Wxo_Xt_bo  : Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1);-- result of adding  Who_Ht1_Wxo_Xt and bias matrices b_o
 SIGNAL Who_Ht1temp : Matrix(0 TO Number_of_output-1,0 TO Batch_size-1);-- result of maultiply W_ho and H_t1 
 SIGNAL Wxo_Xttemp  : Matrix(0 TO Number_of_output-1,0 TO Batch_size-1);-- result of maultiply W_xo and X_t  
 SIGNAL Who_Ht1_Wxo_Xttemp  : Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1);--result of adding  Who_Ht1 and Wxo_Xt
 SIGNAL Who_Ht1_Wxo_Xt_botemp  : Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1);-- result of adding  Who_Ht1_Wxo_Xt and bias matrices b_o
 ------------------------------------------------------------------------------------------------------------------------------------------
 --------------------------------------------------Temp Signals for C(t) ------------------------------------------------------------------
 SIGNAL Ft_Ct1 : Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1);-- result of maultiply F_t and C_t1 
 SIGNAL it_Ctildet  : Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1);-- result of maultiply i_t and C_tilde_t  
 SIGNAL Ft_Ct1_temp : Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1);-- result of maultiply F_t and C_t1 
 SIGNAL it_Ctildet_temp  : Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1);-- result of maultiply i_t and C_tilde_t  
 ------------------------------------------------------------------------------------------------------------------------------------------
 --------------------------------------------------Temp Signals for H(t) ------------------------------------------------------------------
 SIGNAL Ct_tanh : Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1);--:=(OTHE-- result of tanh(C(t))
 ------------------------------------------------------------------------------------------------------------------------------------------
 SIGNAL Weight_Matrix_H : STD_LOGIC := '0';
 SIGNAL X_t_flag : STD_LOGIC := '0';
 SIGNAL H_t1_flag : STD_LOGIC := '0';
 SIGNAL C_t1_flag : STD_LOGIC := '0';
 SIGNAL Weight_Matrix_X : STD_LOGIC := '0';
 SIGNAL Bias_Matrix : STD_LOGIC := '0';
 SIGNAL calculation_done : STD_LOGIC := '0';
 ------------------------------------------------------------------------------------------------------------------------------------------
 -----------------------------------------------------------------Components---------------------------------------------------------------
  
 COMPONENT Matrix_Sigmoid  --SIGMOID
   PORT (
         --CLK : IN STD_LOGIC;
         Matrix_In : IN Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1);
         Matrix_Out : OUT Matrix(0 TO Number_of_output-1,0 TO Batch_size-1)
         );
 END COMPONENT;
 COMPONENT Matrix_Tanh  --Tanh
   PORT (
         --CLK : IN STD_LOGIC;
         Matrix_In : IN Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1);
         Matrix_Out : OUT Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1)
         );
 END COMPONENT;
  
 COMPONENT Matrix_Multiply  --Matric Multiply for weight matrices and h(t-1)
   PORT (
         CLK : IN STD_LOGIC;
         Matrix_1: IN Matrix(0 TO Number_of_output-1,0 TO Number_of_output-1);
         Matrix_2: IN Matrix(0 TO Number_of_output-1,0 TO Batch_size-1);
         Matrix_res : OUT Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1)
         );
 END COMPONENT;
   
 COMPONENT Matrix_Multiply_Prime  --Matric Multiply for weight matrices and x(t)
   PORT (
         CLK : IN STD_LOGIC;
         Matrix_1: IN Matrix(0 TO Number_of_output-1, 0 TO Number_of_input-1);
         Matrix_2: IN Matrix(0 TO Number_of_input-1,0 TO Batch_size-1);
         Matrix_res : OUT Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1)
         );
 END COMPONENT;
      
 COMPONENT Matrix_add  --Matric adder
   PORT (
         Matrix_1: IN Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1);
         Matrix_2: IN Matrix(0 TO Number_of_output-1,0 TO Batch_size-1);
         Matrix_res : OUT Matrix(0 TO Number_of_output-1,0 TO Batch_size-1)
         );
 END COMPONENT;
   
 COMPONENT Matrix_Multiply_Elementwise  --Elementwise Matric Multiply 
   PORT (
         Matrix_1: IN Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1);
         Matrix_2: IN Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1);
         Matrix_res : OUT Matrix(0 TO Number_of_output-1, 0 TO Batch_size-1)
         );
  END COMPONENT;
 
    
 COMPONENT W_hc
    PORT (
         a : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
         spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
         );
  END COMPONENT;
  
  COMPONENT W_hi
    PORT (
          a : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
          spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
          );
  END COMPONENT;
    
  COMPONENT W_hf
    PORT (
          a : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
          spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
          );
  END COMPONENT;
      
   COMPONENT W_ho
     PORT (
           a : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
           spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
           );
   END COMPONENT;
        
   COMPONENT W_xi
     PORT (
           a : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
           spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
           );
   END COMPONENT;
       
  COMPONENT W_xf
      PORT (
            a : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
            spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
            );
   END COMPONENT;
        
  COMPONENT W_xo
       PORT (
             a : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
             spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
             );
   END COMPONENT;
      
     COMPONENT W_xc
         PORT (
               a : IN STD_LOGIC_VECTOR(10 DOWNTO 0);
               spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
               );
     END COMPONENT;
   
      COMPONENT B_c
             PORT (
               a : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
               spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
             );
     END COMPONENT;
     
      COMPONENT B_i
            PORT (
                    a : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
                    spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
                  );
      END COMPONENT;
      
      COMPONENT B_o
             PORT (
                     a : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
                     spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
                   );
       END COMPONENT;
       
      COMPONENT B_f
              PORT (
                     a : IN STD_LOGIC_VECTOR(5 DOWNTO 0);
                     spo : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
                   );
       END COMPONENT;
----------------------------------------------------------------------------------------------------------------------------------
BEGIN
-----------------------------------------------------------PORT MAP---------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------
 Process_1: PROCESS (CLK,RST, X_t, C_t1, H_t1)
     VARIABLE Wxf_add_temp: INTEGER ;  -- address for reading data from ROM for Wxf  
     VARIABLE Wxo_add_temp: INTEGER ;  -- address for reading data from ROM for Wxi  
     VARIABLE Wxc_add_temp: INTEGER ;  -- address for reading data from ROM for Wxc  
     VARIABLE Wxi_add_temp: INTEGER ;  -- address for reading data from ROM for Wxo  
     VARIABLE Whf_add_temp: INTEGER ;  -- address for reading data from ROM for Whf  
     VARIABLE Who_add_temp: INTEGER ;  -- address for reading data from ROM for Whi  
     VARIABLE Whc_add_temp: INTEGER ;  -- address for reading data from ROM for Whc  
     VARIABLE Whi_add_temp: INTEGER ;  -- address for reading data from ROM for Who  
     VARIABLE bf_add_temp:  INTEGER ;
     VARIABLE bo_add_temp:  INTEGER ;
     VARIABLE bc_add_temp:  INTEGER ;
     VARIABLE bi_add_temp:  INTEGER ;
    BEGIN
      IF (RST= '1') THEN
         Wxf_add_temp := 0;
         Wxo_add_temp := 0;
         Wxc_add_temp := 0;
         Wxi_add_temp := 0;
         Whf_add_temp := 0;
         Who_add_temp := 0;
         Whc_add_temp := 0;
         Whi_add_temp := 0;
         bf_add_temp := 0; 
         bo_add_temp := 0; 
         bc_add_temp := 0; 
         bi_add_temp := 0;
         Wxf_add <= "00000000000";
         Wxo_add <= "00000000000";
         Wxc_add <= "00000000000";
         Wxi_add <= "00000000000";
         Whf_add <= "000000000000";
         Who_add <= "000000000000";
         Whc_add <= "000000000000";
         Whi_add <= "000000000000";
         bf_add  <= "000000";
         bo_add  <= "000000";
         bc_add  <= "000000";
         bi_add  <= "000000";    
      ELSIF (RISING_EDGE(CLK) AND En='1') THEN 
        IF(Wxf_add_temp < 1568 AND Wxi_add_temp < 1568 AND Wxc_add_temp < 1568 AND Wxo_add_temp < 1568) THEN
         Wxf((TO_INTEGER(UNSIGNED(Wxf_add))/Number_of_input) , TO_INTEGER(UNSIGNED(Wxf_add)) REM Number_of_input) <= Wxf_temp;
         Wxi((TO_INTEGER(UNSIGNED(Wxi_add))/Number_of_input) , TO_INTEGER(UNSIGNED(Wxi_add)) REM Number_of_input) <= Wxi_temp;
         Wxo((TO_INTEGER(UNSIGNED(Wxo_add))/Number_of_input) , TO_INTEGER(UNSIGNED(Wxo_add)) REM Number_of_input) <= Wxo_temp;
         Wxc((TO_INTEGER(UNSIGNED(Wxc_add))/Number_of_input) , TO_INTEGER(UNSIGNED(Wxc_add)) REM Number_of_input) <= Wxc_temp;
         Wxf_add_temp := Wxf_add_temp + 1;
         Wxo_add_temp := Wxo_add_temp + 1;
         Wxc_add_temp := Wxc_add_temp + 1;
         Wxi_add_temp := Wxi_add_temp + 1;
        ELSE
        Weight_Matrix_X <= '1';
        END IF;
        IF(Whf_add_temp < 3136 AND Whi_add_temp < 3136 AND Whc_add_temp < 3136 AND Who_add_temp < 3136) THEN
         Whf((TO_INTEGER(UNSIGNED(Whf_add))/Number_of_output) , TO_INTEGER(UNSIGNED(Whf_add)) REM Number_of_output) <= Whf_temp;
         Whc((TO_INTEGER(UNSIGNED(Whc_add))/Number_of_output) , TO_INTEGER(UNSIGNED(Whc_add)) REM Number_of_output) <= Whc_temp;
         Whi((TO_INTEGER(UNSIGNED(Whi_add))/Number_of_output) , TO_INTEGER(UNSIGNED(Whi_add)) REM Number_of_output) <= Whi_temp;
         Who((TO_INTEGER(UNSIGNED(Who_add))/Number_of_output) , TO_INTEGER(UNSIGNED(Who_add)) REM Number_of_output) <= Who_temp;
         Whf_add_temp := Whf_add_temp + 1;
         Who_add_temp := Who_add_temp + 1;
         Whc_add_temp := Whc_add_temp + 1;
         Whi_add_temp := Whi_add_temp + 1; 
        ELSE
        Weight_Matrix_H <= '1';
        END IF;
        IF(bf_add_temp < 56 AND bi_add_temp < 56 AND bc_add_temp < 56 AND bo_add_temp < 56) THEN
         bf((TO_INTEGER(UNSIGNED(bf_add))REM Number_of_output) , 0) <= bf_temp;
         bc((TO_INTEGER(UNSIGNED(bc_add))REM Number_of_output), 0) <= bc_temp;
         bi((TO_INTEGER(UNSIGNED(bi_add))REM Number_of_output), 0) <= bi_temp;
         bo((TO_INTEGER(UNSIGNED(bo_add))REM Number_of_output) , 0) <= bo_temp;
         bf_add_temp := bf_add_temp + 1;
         bo_add_temp := bo_add_temp + 1;
         bc_add_temp := bc_add_temp + 1;
         bi_add_temp := bi_add_temp + 1;
        ELSE
        Bias_Matrix <= '1';
        END IF;
     END IF;
      Wxf_add <= STD_LOGIC_VECTOR(TO_UNSIGNED(Wxf_add_temp,11)); 
      Wxo_add <= STD_LOGIC_VECTOR(TO_UNSIGNED(Wxo_add_temp,11)); 
      Wxc_add <= STD_LOGIC_VECTOR(TO_UNSIGNED(Wxc_add_temp,11)); 
      Wxi_add <= STD_LOGIC_VECTOR(TO_UNSIGNED(Wxi_add_temp,11)); 
      Whf_add <= STD_LOGIC_VECTOR(TO_UNSIGNED(Whf_add_temp,12)); 
      Who_add <= STD_LOGIC_VECTOR(TO_UNSIGNED(Who_add_temp,12)); 
      Whc_add <= STD_LOGIC_VECTOR(TO_UNSIGNED(Whc_add_temp,12)); 
      Whi_add <= STD_LOGIC_VECTOR(TO_UNSIGNED(Whi_add_temp,12)); 
      bf_add <= STD_LOGIC_VECTOR(TO_UNSIGNED(bf_add_temp,6));
      bo_add <= STD_LOGIC_VECTOR(TO_UNSIGNED(bo_add_temp,6));
      bc_add <= STD_LOGIC_VECTOR(TO_UNSIGNED(bc_add_temp,6));
      bi_add <= STD_LOGIC_VECTOR(TO_UNSIGNED(bi_add_temp,6));
   END PROCESS;
 
Process_2: PROCESS (CLK,X_t) -- reading X(t) in 28 clock cycle
    VARIABLE counter_x_t:  INTEGER := 0; 
    BEGIN   
      IF (En='1') THEN
        IF(RISING_EDGE(CLK) AND counter_x_t < 28) THEN
        X_t_vector(counter_x_t , 0) <= X_t;
        counter_x_t := counter_x_t + 1;
        END IF;
        IF(counter_x_t = 28) THEN
         X_t_flag <= '1';
        END IF;
      END IF;
     END PROCESS;
       
Process_3: PROCESS (CLK,C_t1)  -- reading X(t) in 56 clock cycle
     VARIABLE Counter_c_t1:  INTEGER := 0;  
      BEGIN   
      IF (RISING_EDGE(CLK) AND En='1') THEN
        IF(counter_c_t1 < 56) THEN
         C_t1_vector(counter_c_t1 , 0) <= C_t1;
         counter_c_t1 := counter_c_t1 + 1;
        END IF;
        IF(counter_c_t1 = 56) THEN
         c_t1_flag <= '1';
        END IF; 
      END IF;
     END PROCESS; 
            
Process_4: PROCESS (CLK,H_t1)  -- reading X(t) in 28 clock cycle
     VARIABLE Counter_h_t1:  INTEGER := 0;   
      BEGIN   
      IF (RISING_EDGE(CLK) AND En='1') THEN
        IF(counter_h_t1 < 56) THEN
           H_t1_vector(counter_h_t1 , 0) <= H_t1;
           counter_h_t1 := counter_h_t1 + 1;
        END IF;
        IF (counter_h_t1 = 56) THEN
           h_t1_flag <= '1';
        END IF;
      END IF;
      END PROCESS;
          
 Process_5: Process(CLK,Weight_Matrix_H,Weight_Matrix_X,Bias_Matrix,H_t1_flag,C_t1_flag,X_t_flag) 
  VARIABLE Counter : INTEGER := 0;
  BEGIN
       IF(RISING_EDGE(CLK) AND Weight_Matrix_H='1' AND Weight_Matrix_X='1' AND Bias_Matrix= '1' AND H_t1_flag='1' AND C_t1_flag='1' AND X_t_flag='1' AND En='1') THEN
             Counter := Counter + 1;
             X_ttemp   <=  X_t_vector;
             H_t1temp  <=  H_t1_vector;
             C_t1temp  <=  C_t1_vector; 
                          
             Whf_Ht1   <= Whf_Ht1temp; --Register for result of Multiply_Whf_and_Ht1_1
             Wxf_Xt  <=  Wxf_Xttemp; -- Register for result of Multiply_Wxf_and_Xt_2
             Whf_Ht1_Wxf_Xt  <=  Whf_Ht1_Wxf_Xttemp; --Register for result of Add_Whf_Ht1_and_Wxf_Xt_3
             Whf_Ht1_Wxf_Xt_bf <=  Whf_Ht1_Wxf_Xt_bftemp; --Register for result of Add_Whf_Ht1_Wxf_Xt_4
             
             Whi_Ht1   <= Whi_Ht1temp; --Register for result of Multiply_Whi_and_Ht1_6
             Wxi_Xt  <=  Wxi_Xttemp; --Register for result of Multiply_Wxi_and_Xt_7
             Whi_Ht1_Wxi_Xt  <=  Whi_Ht1_Wxi_Xttemp; --Register for result of  Add_Whi_Ht1_and_Wxi_Xt_8
             Whi_Ht1_Wxi_Xt_bi <=  Whi_Ht1_Wxi_Xt_bitemp; --Register for result of Add_Whi_Ht1_Wxi_Xt_and_bi_9
             
             Whc_Ht1   <= Whc_Ht1temp; --Register for result of Multiply_Whc_and_Ht1_11
             Wxc_Xt  <=  Wxc_Xttemp; --Register for result of Multiply_Wxc_and_Xt_12
             Whc_Ht1_Wxc_Xt  <=  Whc_Ht1_Wxc_Xttemp; --Register for result of Add_Whc_Ht1_and_Wxc_Xt_13 
             Whc_Ht1_Wxc_Xt_bc <=  Whc_Ht1_Wxc_Xt_bctemp; --Register for result of Add_Whc_Ht1_Wxc_Xt_and_bc_14
             
             Who_Ht1   <= Who_Ht1temp; --Register for result of Multiply_Who_and_Ht1_16
             Wxo_Xt  <=  Wxo_Xttemp; --Register for result of Multiply_Wxo_and_Xt_17
             Who_Ht1_Wxo_Xt  <=  Who_Ht1_Wxo_Xttemp;--Register for result of Add_Who_Ht1_and_Wxo_Xt_18
             Who_Ht1_Wxo_Xt_bo <=  Who_Ht1_Wxo_Xt_botemp; --Register for result of Add_Who_Ht1_Wxo_Xt_and_bo_19
             
             F_t   <= F_t_temp; --Register For F(t)
             i_t  <=  i_t_temp; --Register For i(t)
             O_t <= O_t_temp;--Register For o(t)
             O_t_prime <= O_t; --Register For o(t)_temp
             C_tilde_t <= C_tilde_t_temp; --Register For F(t)
             
             Ft_Ct1 <= Ft_Ct1_temp; --Register for result of Multiply_Ft_and_Ct1_21
             it_Ctildet <= it_Ctildet_temp; --Register for result of  Multiply_it_and_Ctildet_22          
         IF (Counter = 8) THEN
            Calculation_done <= '1';
            Counter := 0;
         END IF;
       END IF;
  END PROCESS;
 
 Process_6: PROCESS (CLK,Calculation_done) -- writing data serially
       VARIABLE Counter:  INTEGER := 0;   
        BEGIN   
        IF (RISING_EDGE(CLK) AND Calculation_done='1') THEN
          IF(counter < 56) THEN
             H_t <= H_ttemp(counter,0);
             C_t <= C_ttemp(counter,0);
             counter := counter + 1;
          END IF;
          IF(counter = 56) THEN
             Done <= '1';
             counter := 0;
          END IF;
        END IF;
        END PROCESS;
 
  
 
------------------------------------------------------------ Weight matrices-ROM -----------------------------------------------------------------
Weight_hc : W_hc
  PORT MAP (
    a => Whc_add,
    spo => Whc_temp
  );
 
Weight_ho : W_ho
    PORT MAP (
      a => Who_add,
      spo => Who_temp
    );

Weight_hi : W_hi
  PORT MAP (
    a => Whi_add,
    spo => Whi_temp
  );
 
Weight_hf : W_hf
    PORT MAP (
      a => Whf_add,
      spo => Whf_temp
    );
 
Weight_xc : W_xc
      PORT MAP (
        a => Wxc_add,
        spo => Wxc_temp
      );
     
Weight_xo : W_xo
    PORT MAP (
      a => Wxo_add,
      spo => Wxo_temp
    );

Weight_xi : W_xi
  PORT MAP (
    a => Wxi_add,
    spo => Wxi_temp
  );
 
Weight_xf : W_xf
    PORT MAP (
      a => Wxf_add,
       spo => Wxf_temp
        );   
------------------------------------------------------------ Bias matrices-ROM -----------------------------------------------------------------
Bias_c : B_c
  PORT MAP (
    a => bc_add,
    spo => bc_temp
  );
 
Bias_f : B_o
    PORT MAP (
      a => bo_add,
      spo => bo_temp
    );

Bias_i : B_i
  PORT MAP (
    a => bi_add,
    spo => bi_temp
  );
 
Bias_o : B_f
    PORT MAP (
      a => bf_add,
      spo => bf_temp
    );
----------------------------------------------------------- F(t) -----------------------------------------------------------------
 Multiply_Whf_and_Ht1_1: Matrix_Multiply
 PORT MAP(
          CLK => CLK,
          Matrix_1 => Whf,
          Matrix_2 => H_t1temp,
          Matrix_res => Whf_Ht1temp);
          
 Multiply_Wxf_and_Xt_2: Matrix_Multiply_Prime
 PORT MAP(
          CLK => CLK,
          Matrix_1 => Wxf,
          Matrix_2 => X_ttemp,
          Matrix_res => Wxf_Xttemp);
          
          
 Add_Whf_Ht1_and_Wxf_Xt_3: Matrix_add
 PORT MAP(
           Matrix_1 => Whf_Ht1,
           Matrix_2 => Wxf_Xt,
           Matrix_res => Whf_Ht1_Wxf_Xttemp);
          
          
 Add_Whf_Ht1_Wxf_Xt_4: Matrix_add
 PORT MAP(
          Matrix_1 => Whf_Ht1_Wxf_Xt,
          Matrix_2 => bf,
          Matrix_res => Whf_Ht1_Wxf_Xt_bftemp);
          
          
 Sigmoid_Whf_Ht1_Wxf_Xt_bf_5: Matrix_Sigmoid
 PORT MAP(
          Matrix_In => Whf_Ht1_Wxf_Xt_bf,
          Matrix_Out => F_t_temp); 
                    
-----------------------------------------------------------------------------------------------------------------------------------         
          
------------------------------------------------------------ i(t) -----------------------------------------------------------------
 Multiply_Whi_and_Ht1_6: Matrix_Multiply
 PORT MAP(
          CLK => CLK,
          Matrix_1 => Whi,
          Matrix_2 => H_t1temp,
          Matrix_res => Whi_Ht1temp);
          
 Multiply_Wxi_and_Xt_7: Matrix_Multiply_Prime
 PORT MAP(
          CLK => CLK, 
          Matrix_1 => Wxi,
          Matrix_2 => X_ttemp,
          Matrix_res => Wxi_Xttemp);
                    
 Add_Whi_Ht1_and_Wxi_Xt_8: Matrix_add
 PORT MAP(
          Matrix_1 => Whi_Ht1,
          Matrix_2 => Wxi_Xt,
          Matrix_res => Whi_Ht1_Wxi_Xttemp);
                  
 Add_Whi_Ht1_Wxi_Xt_and_bi_9: Matrix_add
 PORT MAP(         
          Matrix_1 => Whi_Ht1_Wxi_Xt,
          Matrix_2 => bi,
          Matrix_res => Whi_Ht1_Wxi_Xt_bitemp);
                  
 Sigmoid_Whi_Ht1_Wxi_Xt_bi_10: Matrix_Sigmoid
 PORT MAP(
          Matrix_In => Whi_Ht1_Wxi_Xt_bi,
          Matrix_Out => i_t_temp); 
                    
-----------------------------------------------------------------------------------------------------------------------------------           
 
----------------------------------------------------------- C_tilde(t) -----------------------------------------------------------------

 Multiply_Whc_and_Ht1_11: Matrix_Multiply
 PORT MAP(
          CLK => CLK,
          Matrix_1 => Whc,
          Matrix_2 => H_t1temp,
          Matrix_res => Whc_Ht1temp);
  
 Multiply_Wxc_and_Xt_12: Matrix_Multiply_Prime
 PORT MAP(
          CLK => CLK,
          Matrix_1 => Wxc,
          Matrix_2 => X_ttemp,
          Matrix_res => Wxc_Xttemp);
  
 Add_Whc_Ht1_and_Wxc_Xt_13 : Matrix_add
 PORT MAP(
          Matrix_1 => Whc_Ht1,
          Matrix_2 => Wxc_Xt,
          Matrix_res => Whc_Ht1_Wxc_Xttemp);
  
 Add_Whc_Ht1_Wxc_Xt_and_bc_14: Matrix_add
 PORT MAP(
          Matrix_1 => Whc_Ht1_Wxc_Xt,
          Matrix_2 => bc,
          Matrix_res => Whc_Ht1_Wxc_Xt_bctemp);
  
 Tanh_Whc_Ht1_Wxc_Xt_bc_15: Matrix_Tanh
 PORT MAP(
          Matrix_In => Whc_Ht1_Wxc_Xt_bc,
          Matrix_Out => C_tilde_t_temp); 
           
---------------------------------------------------------------------------------------------------------------------------------- 

------------------------------------------------------------- O(t)----------------------------------------------------------------
  Multiply_Who_and_Ht1_16: Matrix_Multiply
  PORT MAP(
          CLK => CLK,
          Matrix_1 => Who,
          Matrix_2 => H_t1temp,
          Matrix_res => Who_Ht1temp);
 
 Multiply_Wxo_and_Xt_17: Matrix_Multiply_Prime
 PORT MAP(
          CLK => CLK,
          Matrix_1 => Wxo,
          Matrix_2 => X_ttemp,
          Matrix_res => Wxo_Xttemp);
 
 Add_Who_Ht1_and_Wxo_Xt_18 : Matrix_add
 PORT MAP(
          Matrix_1 => Who_Ht1,
          Matrix_2 => Wxo_Xt,
          Matrix_res => Who_Ht1_Wxo_Xttemp);
 
 
 Add_Who_Ht1_Wxo_Xt_and_bo_19: Matrix_add
 PORT MAP(
          Matrix_1 => Who_Ht1_Wxo_Xt,
          Matrix_2 => bo,
          Matrix_res => Who_Ht1_Wxo_Xt_botemp);
 
Tanh_Who_Ht1_Wxo_Xt_bo_20: Matrix_Sigmoid
PORT MAP(
         Matrix_In => Who_Ht1_Wxo_Xt_bo,
         Matrix_Out => O_t_temp);           
----------------------------------------------------------------------------------------------------------------------------------  
----------------------------------------------------------- C(t) -----------------------------------------------------------------
 Multiply_Ft_and_Ct1_21: Matrix_Multiply_Elementwise
 PORT MAP(
           Matrix_1 => F_t,
           Matrix_2 => C_t1temp,
           Matrix_res => Ft_Ct1_temp);
 
 Multiply_it_and_Ctildet_22: Matrix_Multiply_Elementwise
 PORT MAP(
          Matrix_1 => i_t,
          Matrix_2 => C_tilde_t,
          Matrix_res => it_Ctildet_temp);
 
 Add_Ft_Ct1_and_it_Ctildet_23 : Matrix_add
 PORT MAP(
          Matrix_1 => Ft_Ct1,
          Matrix_2 => it_Ctildet,
          Matrix_res => C_ttemp);
----------------------------------------------------------------------------------------------------------------------------------  

----------------------------------------------------------- H(t) -----------------------------------------------------------------
 Tanh_Ct_24: Matrix_Tanh
 PORT MAP(
           Matrix_In => C_ttemp,
           Matrix_Out => Ct_tanh);
 
 Multiply_Ot_and_Ct_Tanh_25: Matrix_Multiply_Elementwise
 PORT MAP(
          Matrix_1 => O_t_prime,
          Matrix_2 => Ct_tanh,
          Matrix_res => H_ttemp);
------------------------------------------------------------------------------------------------------------------------------------  
END Behavioral;
--------------------------------------------END OF ARCHITECTURE------------------------------------------------------------------------
