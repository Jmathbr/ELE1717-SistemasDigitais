library ieee ;
use ieee.std_logic_1164.all;

entity mde is
port (ck, rst, R_carry, R_Z: in std_logic ;
      OP: in std_logic_vector(3 downto 0);
      Rp_S, Rw_S, D_rd, D_wr, RF_s, RW_W_WR, RF_rp_rd, RF_rq_rd, ALU_S0, ALU_S1, ALU_S2, R_ld, PC_INC, PC_CLR, hlt_inc, JMP_LD : out std_logic );
end mde;

architecture logica of mde is

    type state_type is (INIT, BUSC, DEC, HLT, LDR, STR, MOV, ADD, SUB, SAND, SOR, SNOT, SXOR, CMP, JMP, JNC, JC, JNZ, JZ);
    signal estado: state_type;

begin
    process (ck, rst)
    begin
        if rst = '1' then
        estado <= INIT;
        elsif ( ck' event and ck = '1') then
            case estado is

                when INIT =>
                    estado <= BUSC;

                when BUSC =>
                    estado <= DEC;
                
                when DEC =>
                    if    OP = "0000" then estado <= HLT;
                    elsif OP = "0001" then estado <= LDR;
                    elsif OP = "0010" then estado <= STR; 
                    elsif OP = "0011" then estado <= MOV;
                    elsif OP = "0100" then estado <= ADD;
                    elsif OP = "0101" then estado <= SUB;
                    elsif OP = "0110" then estado <= SAND;
                    elsif OP = "0111" then estado <= SOR;
                    elsif OP = "1000" then estado <= SNOT;
                    elsif OP = "1001" then estado <= SXOR;
                    elsif OP = "1010" then estado <= CMP;
                    elsif OP = "1011" then estado <= JMP;
                    elsif OP = "1100" then estado <= JNC;
                    elsif OP = "1101" then estado <= JC;
                    elsif OP = "1110" then estado <= JNZ;
                    elsif OP = "1111" then estado <= JZ;
                    end if;
                
                when HLT =>
                    estado <= BUSC;

                when LDR =>
                    estado <= BUSC;

                when STR =>
                    estado <= BUSC;

                when MOV =>
                    estado <= BUSC;
                
                when ADD =>
                    estado <= BUSC;
                
                when SUB =>
                    estado <= BUSC;

                when SAND =>
                    estado <= BUSC;

                when SOR =>
                    estado <= BUSC;
                
                when SNOT =>
                    estado <= BUSC;
                
                when SXOR =>
                    estado <= BUSC;

                when CMP =>
                    estado <= BUSC;
                
                when JMP =>
                    estado <= BUSC;
                
                when JNC =>
                    if R_carry = '0' then estado <= JMP;
                    else estado <= BUSC;
                    end if;
                
                when JC =>
                    if R_carry = '1' then estado <= JMP;
                    else estado <= BUSC;
                    end if;
                
                when JNZ =>
                    if R_Z = '0' then estado <= JMP;
                    else estado <= BUSC;
                    end if;
                
                when JZ =>
                    if R_Z = '0' then estado <= JMP;
                    else estado <= BUSC;
                    end if;
        end case ;
    end if ;
end process ;

with estado select
    Rp_S <= '0' when INIT,
        '0' when BUSC,
        '0' when DEC,
        '0' when HLT, 
        '0' when LDR, 
        '1' when STR,
        '0' when MOV, 
        '0' when ADD, 
        '0' when SUB, 
        '0' when SAND,  
        '0' when SOR, 
        '0' when SNOT,  
        '0' when SXOR,  
        '0' when CMP, 
        '0' when JMP,  
        '0' when JNC, 
        '0' when JC, 
        '0' when JNZ,  
        '0' when JZ;

with estado select
    Rw_S <= '0' when INIT,
        '0' when BUSC,
        '0' when DEC,
        '0' when HLT, 
        '0' when LDR, 
        '0' when STR,
        '1' when MOV, 
        '0' when ADD, 
        '0' when SUB, 
        '0' when SAND,  
        '0' when SOR, 
        '0' when SNOT,  
        '0' when SXOR,  
        '0' when CMP, 
        '0' when JMP,  
        '0' when JNC, 
        '0' when JC, 
        '0' when JNZ,  
        '0' when JZ;

with estado select
    D_rd <= '0' when INIT,
        '0' when BUSC,
        '0' when DEC,
        '0' when HLT, 
        '1' when LDR, 
        '0' when STR,
        '0' when MOV, 
        '0' when ADD, 
        '0' when SUB, 
        '0' when SAND,  
        '0' when SOR, 
        '0' when SNOT,  
        '0' when SXOR,  
        '0' when CMP, 
        '0' when JMP,  
        '0' when JNC, 
        '0' when JC, 
        '0' when JNZ,  
        '0' when JZ;

with estado select
    D_wr <= '0' when INIT,
        '0' when BUSC,
        '0' when DEC,
        '0' when HLT, 
        '0' when LDR, 
        '1' when STR,
        '0' when MOV, 
        '0' when ADD, 
        '0' when SUB, 
        '0' when SAND,  
        '0' when SOR, 
        '0' when SNOT,  
        '0' when SXOR,  
        '0' when CMP, 
        '0' when JMP,  
        '0' when JNC, 
        '0' when JC, 
        '0' when JNZ,  
        '0' when JZ;

with estado select
    RF_S <= '0' when INIT,
        '0' when BUSC,
        '0' when DEC,
        '0' when HLT, 
        '1' when LDR, 
        '0' when STR,
        '0' when MOV, 
        '0' when ADD, 
        '0' when SUB, 
        '0' when SAND,  
        '0' when SOR, 
        '0' when SNOT,  
        '0' when SXOR,  
        '0' when CMP, 
        '0' when JMP,  
        '0' when JNC, 
        '0' when JC, 
        '0' when JNZ,  
        '0' when JZ;

with estado select
    RW_W_WR <= '0' when INIT,
        '0' when BUSC,
        '0' when DEC,
        '0' when HLT, 
        '1' when LDR, 
        '0' when STR,
        '1' when MOV, 
        '1' when ADD, 
        '1' when SUB, 
        '1' when SAND,  
        '1' when SOR, 
        '1' when SNOT,  
        '1' when SXOR,  
        '1' when CMP, 
        '0' when JMP,  
        '0' when JNC, 
        '0' when JC, 
        '0' when JNZ,  
        '0' when JZ;

with estado select
    RF_rp_rd <= '0' when INIT,
        '0' when BUSC,
        '0' when DEC,
        '0' when HLT, 
        '0' when LDR, 
        '1' when STR,
        '0' when MOV, 
        '1' when ADD, 
        '1' when SUB, 
        '1' when SAND,  
        '1' when SOR,
        '0' when SNOT,  
        '1' when SXOR,  
        '1' when CMP, 
        '0' when JMP,  
        '0' when JNC, 
        '0' when JC, 
        '0' when JNZ,  
        '0' when JZ;

with estado select
    RF_rq_rd <= '0' when INIT,
        '0' when BUSC,
        '0' when DEC,
        '0' when HLT, 
        '0' when LDR, 
        '0' when STR,
        '1' when MOV, 
        '1' when ADD, 
        '1' when SUB, 
        '1' when SAND,  
        '1' when SOR, 
        '1' when SNOT,  
        '1' when SXOR,  
        '1' when CMP, 
        '0' when JMP,  
        '0' when JNC, 
        '0' when JC, 
        '0' when JNZ,  
        '0' when JZ;

with estado select
    ALU_S0 <= '0' when INIT,
        '0' when BUSC,
        '0' when DEC,
        '0' when HLT, 
        '0' when LDR, 
        '0' when STR,
        '1' when MOV, 
        '0' when ADD, 
        '0' when SUB, 
        '0' when SAND,  
        '0' when SOR, 
        '1' when SNOT,  
        '1' when SXOR,  
        '1' when CMP, 
        '0' when JMP,  
        '0' when JNC, 
        '0' when JC, 
        '0' when JNZ,  
        '0' when JZ;

with estado select
    ALU_S1 <= '0' when INIT,
        '0' when BUSC,
        '0' when DEC,
        '0' when HLT, 
        '0' when LDR, 
        '0' when STR,
        '1' when MOV, 
        '0' when ADD, 
        '0' when SUB, 
        '1' when SAND,  
        '1' when SOR, 
        '0' when SNOT,  
        '0' when SXOR,  
        '1' when CMP, 
        '0' when JMP,  
        '0' when JNC, 
        '0' when JC, 
        '0' when JNZ,  
        '0' when JZ;
        
with estado select
    ALU_S2 <= '0' when INIT,
        '0' when BUSC,
        '0' when DEC,
        '0' when HLT, 
        '0' when LDR, 
        '0' when STR,
        '1' when MOV, 
        '0' when ADD, 
        '1' when SUB, 
        '0' when SAND,  
        '1' when SOR, 
        '0' when SNOT,  
        '1' when SXOR,  
        '0' when CMP, 
        '0' when JMP,  
        '0' when JNC, 
        '0' when JC, 
        '0' when JNZ,  
        '0' when JZ;

with estado select
    R_ld <= '0' when INIT,
        '0' when BUSC,
        '0' when DEC,
        '0' when HLT, 
        '0' when LDR, 
        '0' when STR,
        '0' when MOV, 
        '1' when ADD, 
        '1' when SUB, 
        '1' when SAND,  
        '1' when SOR, 
        '1' when SNOT,  
        '1' when SXOR,  
        '1' when CMP, 
        '0' when JMP,  
        '0' when JNC, 
        '0' when JC, 
        '0' when JNZ,  
        '0' when JZ;

with estado select
    PC_inc <= '0' when INIT,
        '1' when BUSC,
        '0' when DEC,
        '0' when HLT, 
        '0' when LDR, 
        '0' when STR,
        '0' when MOV, 
        '0' when ADD, 
        '0' when SUB, 
        '0' when SAND,  
        '0' when SOR, 
        '0' when SNOT,  
        '0' when SXOR,  
        '0' when CMP, 
        '0' when JMP,  
        '0' when JNC, 
        '0' when JC, 
        '0' when JNZ,  
        '0' when JZ;

with estado select    
    PC_CLR <= '1' when INIT,
        '0' when BUSC,
        '0' when DEC,
        '0' when HLT, 
        '0' when LDR, 
        '0' when STR,
        '0' when MOV, 
        '0' when ADD, 
        '0' when SUB, 
        '0' when SAND,  
        '0' when SOR, 
        '0' when SNOT,  
        '0' when SXOR,  
        '0' when CMP, 
        '0' when JMP,  
        '0' when JNC, 
        '0' when JC, 
        '0' when JNZ,  
        '0' when JZ;

with estado select    
    hlt_inc <= '0' when INIT,
        '0' when BUSC,
        '0' when DEC,
        '1' when HLT, 
        '0' when LDR, 
        '0' when STR,
        '0' when MOV, 
        '0' when ADD, 
        '0' when SUB, 
        '0' when SAND,  
        '0' when SOR, 
        '0' when SNOT,  
        '0' when SXOR,  
        '0' when CMP, 
        '0' when JMP,  
        '0' when JNC, 
        '0' when JC, 
        '0' when JNZ,  
        '0' when JZ;

with estado select
    JMP_LD <= '0' when INIT,
        '0' when BUSC,
        '0' when DEC,
        '0' when HLT, 
        '0' when LDR, 
        '0' when STR,
        '0' when MOV, 
        '0' when ADD, 
        '0' when SUB, 
        '0' when SAND,  
        '0' when SOR, 
        '0' when SNOT,  
        '0' when SXOR,  
        '0' when CMP, 
        '1' when JMP,  
        '0' when JNC, 
        '0' when JC, 
        '0' when JNZ,  
        '0' when JZ;
        
end logica ;