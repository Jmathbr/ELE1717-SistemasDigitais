entity DEMUX1x16 is
    port(en: in bit;
        S: in bit_vector(3 downto 0);
        O: out bit_vector(15 downto 0));
end DEMUX1x16;
 
architecture hardware of DEMUX1x16 is
 
begin
 
    O(0)  <= en  and (not S(3) and not S(2) and not S(1) and not S(0));
    O(1)  <= en  and (not S(3) and not S(2) and not S(1) and     S(0));
    O(2)  <= en  and (not S(3) and not S(2) and     S(1) and not S(0));
    O(3)  <= en  and (not S(3) and not S(2) and     S(1) and     S(0));
    O(4)  <= en  and (not S(3) and     S(2) and not S(1) and not S(0));
    O(5)  <= en  and (not S(3) and     S(2) and not S(1) and     S(0));
    O(6)  <= en  and (not S(3) and     S(2) and     S(1) and not S(0));
    O(7)  <= en  and (not S(3) and     S(2) and     S(1) and     S(0));
    O(8)  <= en  and (    S(3) and not S(2) and not S(1) and not S(0));
    O(9)  <= en  and (    S(3) and not S(2) and not S(1) and     S(0));
    O(10) <= en  and (    S(3) and not S(2) and     S(1) and not S(0));
    O(11) <= en  and (    S(3) and not S(2) and     S(1) and     S(0));
    O(12) <= en  and (    S(3) and     S(2) and not S(1) and not S(0));
    O(13) <= en  and (    S(3) and     S(2) and not S(1) and     S(0));
    O(14) <= en  and (    S(3) and     S(2) and     S(1) and not S(0));
    O(15) <= en  and (    S(3) and     S(2) and     S(1) and     S(0));
    
end hardware;


entity MUX16x1 is
    port(I0, I1, I2, I3, I4, I5, I6, I7, I8, I9, I10, I11, I12, I13, I14, I15, en: in BIT;
        S: in bit_vector(3 downto 0);
        O: out bit);
end MUX16x1;
 
architecture hardware of MUX16x1 is
 
begin
 
    O <= en and ((I0  and not S(3) and not S(2) and not S(1) and not S(0)) 
      or (I1  and not S(3) and not S(2) and not S(1) and     S(0)) 
      or (I2  and not S(3) and not S(2) and     S(1) and not S(0))
      or (I3  and not S(3) and not S(2) and     S(1) and     S(0)) 
      or (I4  and not S(3) and     S(2) and not S(1) and not S(0)) 
      or (I5  and not S(3) and     S(2) and not S(1) and     S(0))
      or (I6  and not S(3) and     S(2) and     S(1) and not S(0)) 
      or (I7  and not S(3) and     S(2) and     S(1) and     S(0)) 
      or (I8  and     S(3) and not S(2) and not S(1) and not S(0))
      or (I9  and     S(3) and not S(2) and not S(1) and     S(0)) 
      or (I10 and     S(3) and not S(2) and     S(1) and not S(0)) 
      or (I11 and     S(3) and not S(2) and     S(1) and     S(0))
      or (I12 and     S(3) and     S(2) and not S(1) and not S(0))
      or (I13 and     S(3) and     S(2) and not S(1) and     S(0))
      or (I14 and     S(3) and     S(2) and     S(1) and not S(0))
      or (I15 and     S(3) and     S(2) and     S(1) and     S(0)));
 
end hardware;

entity MUX16x1_8 is
    port(I0, I1, I2, I3, I4, I5, I6, I7, I8, I9, I10, I11, I12, I13, I14, I15: in BIT_VECTOR(7 DOWNTO 0);
        en: in bit;
        S: in bit_vector(3 downto 0);
        O: out BIT_VECTOR(7 DOWNTO 0));
end MUX16x1_8;
 
architecture hardware of MUX16x1_8 is
 
component MUX16x1 is
    port(I0, I1, I2, I3, I4, I5, I6, I7, I8, I9, I10, I11, I12, I13, I14, I15, en: in BIT;
        S: in bit_vector(3 downto 0);
        O: out bit);
end component;
 
begin
 
    BIT0:  MUX16x1 port map (I0(0),  I1(0),  I2(0),  I3(0),  I4(0),  I5(0),  I6(0),  I7(0),  I8(0),  I9(0),  I10(0),  I11(0),  I12(0),  I13(0),  I14(0),  I15(0), en, S, O(0));
    BIT1:  MUX16x1 port map (I0(1),  I1(1),  I2(1),  I3(1),  I4(1),  I5(1),  I6(1),  I7(1),  I8(1),  I9(1),  I10(1),  I11(1),  I12(1),  I13(1),  I14(1),  I15(1), en, S, O(1));
    BIT2:  MUX16x1 port map (I0(2),  I1(2),  I2(2),  I3(2),  I4(2),  I5(2),  I6(2),  I7(2),  I8(2),  I9(2),  I10(2),  I11(2),  I12(2),  I13(2),  I14(2),  I15(2), en, S, O(2));
    BIT3:  MUX16x1 port map (I0(3),  I1(3),  I2(3),  I3(3),  I4(3),  I5(3),  I6(3),  I7(3),  I8(3),  I9(3),  I10(3),  I11(3),  I12(3),  I13(3),  I14(3),  I15(3), en, S, O(3));
    BIT4:  MUX16x1 port map (I0(4),  I1(4),  I2(4),  I3(4),  I4(4),  I5(4),  I6(4),  I7(4),  I8(4),  I9(4),  I10(4),  I11(4),  I12(4),  I13(4),  I14(4),  I15(4), en, S, O(4));
    BIT5:  MUX16x1 port map (I0(5),  I1(5),  I2(5),  I3(5),  I4(5),  I5(5),  I6(5),  I7(5),  I8(5),  I9(5),  I10(5),  I11(5),  I12(5),  I13(5),  I14(5),  I15(5), en, S, O(5));
    BIT6:  MUX16x1 port map (I0(6),  I1(6),  I2(6),  I3(6),  I4(6),  I5(6),  I6(6),  I7(6),  I8(6),  I9(6),  I10(6),  I11(6),  I12(6),  I13(6),  I14(6),  I15(6), en, S, O(6));
    BIT7:  MUX16x1 port map (I0(7),  I1(7),  I2(7),  I3(7),  I4(7),  I5(7),  I6(7),  I7(7),  I8(7),  I9(7),  I10(7),  I11(7),  I12(7),  I13(7),  I14(7),  I15(7), en, S, O(7));
    
end hardware;

entity MUX2x1 is
    port(A, B, S: in bit;
            C: out bit);
end MUX2x1;
 
architecture hardware of MUX2x1 is
 
begin
 
    C <= (A and (not S)) or (B and S);
end hardware;

entity FFD is
    port (D, R, clk: in bit;
            Q, NQ: out bit);    
end FFD;
    
architecture hardware of FFD is
 
signal QS: bit;
 
begin
    process(CLK, R)
    begin
        if R = '1' then QS <= '0';
        elsif clk = '1' and clk'event then QS <= D;
        end if;
    end process;
 
    Q <= QS;
    NQ <= not(QS);
 
end hardware;


entity REGISTER8BITS is
    port( I: in bit_vector(7 downto 0);
            ld, clr, clk: in bit; 
            O: out bit_vector(7 downto 0));
end REGISTER8BITS;
 
architecture hardware of REGISTER8BITs is
 
component FFD is
    port (D, R, clk: in bit; 
            Q, NQ: out bit);    
end component;
 
component MUX2x1 is
    port(A, B, S: in bit;
            C: out bit);
end component;
 
signal D, Q, NQ: bit_vector(7 downto 0);
 
begin
    -- mux para habilitar a carga do registrador
    MUX0:  MUX2x1 port map(Q(0),  I(0),  ld, D(0));
    MUX1:  MUX2x1 port map(Q(1),  I(1),  ld, D(1));
    MUX2:  MUX2x1 port map(Q(2),  I(2),  ld, D(2));
    MUX3:  MUX2x1 port map(Q(3),  I(3),  ld, D(3));
    MUX4:  MUX2x1 port map(Q(4),  I(4),  ld, D(4));
    MUX5:  MUX2x1 port map(Q(5),  I(5),  ld, D(5));
    MUX6:  MUX2x1 port map(Q(6),  I(6),  ld, D(6));
    MUX7:  MUX2x1 port map(Q(7),  I(7),  ld, D(7));

    FF0:  FFD port map(D(0), clr, clk, Q(0),  NQ(0));
    FF1:  FFD port map(D(1), clr, clk, Q(1),  NQ(1));
    FF2:  FFD port map(D(2), clr, clk, Q(2),  NQ(2));
    FF3:  FFD port map(D(3), clr, clk, Q(3),  NQ(3));
    FF4:  FFD port map(D(4), clr, clk, Q(4),  NQ(4));
    FF5:  FFD port map(D(5), clr, clk, Q(5),  NQ(5));
    FF6:  FFD port map(D(6), clr, clk, Q(6),  NQ(6));
    FF7:  FFD port map(D(7), clr, clk, Q(7),  NQ(7));

    -- saida
    O <= Q;
 
end hardware;

entity BANCO_REG is
    port(w_data: in bit_vector(7 downto 0); 
            RW_W_WR, RF_Rp_RD, RF_Rq_RD: in bit; 
            RW_W_ADDR, RF_Rp_ADDR, RF_Rq_ADDR: in bit_vector(3 downto 0); 
            clr, clk: in bit;
            rp_data, rq_data: out bit_vector(7 downto 0)); 
end BANCO_REG;
 
architecture hardware of BANCO_REG is
 
component REGISTER8BITS is
    port( I: in bit_vector(7 downto 0);
        ld, clr, clk: in bit;
        O: out bit_vector(7 downto 0));
end component;
 
component MUX16x1_8 is
    port(I0, I1, I2, I3, I4, I5, I6, I7, I8, I9, I10, I11, I12, I13, I14, I15: in BIT_VECTOR(7 DOWNTO 0);
        en: in bit;
        S: in bit_vector(3 downto 0);
        O: out BIT_VECTOR(7 DOWNTO 0));
end component;
 
component DEMUX1x16 is
    port(en: in bit;
        S: in bit_vector(3 downto 0);
        O: out bit_vector(15 downto 0));
end component;
 
signal out_demux: bit_vector (15 downto 0);
signal r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15: bit_vector(7 downto 0);
 
begin
    -- demux para selecionar o registrador de escrita
    SELECIONA_REG: DEMUX1x16 port map(RW_W_WR, RW_W_ADDR, out_demux);
 
    -- registradores (so ira guardar no registrador correspondente a saida do demux anterior)
    DEFINE_REG0:  REGISTER8BITS port map(w_data, out_demux(0),  clr, clk, r0);
    DEFINE_REG1:  REGISTER8BITS port map(w_data, out_demux(1),  clr, clk, r1);
    DEFINE_REG2:  REGISTER8BITS port map(w_data, out_demux(2),  clr, clk, r2);
    DEFINE_REG3:  REGISTER8BITS port map(w_data, out_demux(3),  clr, clk, r3);
    DEFINE_REG4:  REGISTER8BITS port map(w_data, out_demux(4),  clr, clk, r4);
    DEFINE_REG5:  REGISTER8BITS port map(w_data, out_demux(5),  clr, clk, r5);
    DEFINE_REG6:  REGISTER8BITS port map(w_data, out_demux(6),  clr, clk, r6);
    DEFINE_REG7:  REGISTER8BITS port map(w_data, out_demux(7),  clr, clk, r7);
    DEFINE_REG8:  REGISTER8BITS port map(w_data, out_demux(8),  clr, clk, r8);
    DEFINE_REG9:  REGISTER8BITS port map(w_data, out_demux(9),  clr, clk, r9);
    DEFINE_REG10: REGISTER8BITS port map(w_data, out_demux(10), clr, clk, r10);
    DEFINE_REG11: REGISTER8BITS port map(w_data, out_demux(11), clr, clk, r11);
    DEFINE_REG12: REGISTER8BITS port map(w_data, out_demux(12), clr, clk, r12);
    DEFINE_REG13: REGISTER8BITS port map(w_data, out_demux(13), clr, clk, r13);
    DEFINE_REG14: REGISTER8BITS port map(w_data, out_demux(14), clr, clk, r14);
    DEFINE_REG15: REGISTER8BITS port map(w_data, out_demux(15), clr, clk, r15);
 
    --seleciona os registradores que devem ser lidos (rq e rp)
    leitura_rp: MUX16x1_8 port map(r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, RF_Rp_RD, RF_Rp_ADDR, rp_data);
    leitura_rq: MUX16x1_8 port map(r0, r1, r2, r3, r4, r5, r6, r7, r8, r9, r10, r11, r12, r13, r14, r15, RF_Rq_RD, RF_Rq_ADDR, rq_data);
 
end hardware;


