library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity rom256_16b is
port (
clk : in std_logic ;
addr : in std_logic_vector ( 7 downto 0);
data : out std_logic_vector (15 downto 0)
);
end rom256_16b;
architecture ckt of rom256_16b is
type memoria_rom is array (0 to 255) of std_logic_vector (15 downto 0);
signal ROM : memoria_rom := (0 => X"1000",
1 => X"1101",
2 => X"4201",
3 => X"2202",
4 => X"1303",
5 => X"1404",
6 => X"3004",
7 => X"6103",
8 => X"A312",
9 => X"1508",
10 => X"8605",
11 => X"4952",
12 => X"D004",
13 => X"6012",
14 => X"9312",
15 => X"7412",
16 => X"A512",
17 => X"5034",
18 => X"E000",
19 => X"F009",
20 => X"0000",
others => X"0000");
begin
process (clk) begin
if rising_edge(clk) then
data <= ROM(conv_integer(addr ));
end if;
end process ;
end ckt;
