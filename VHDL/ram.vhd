library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
entity ram256_8b is
port (
clk : in std_logic ;
we : in std_logic ;
addr : in std_logic_vector ( 7 downto 0);
datai : in std_logic_vector (7 downto 0);
datao : out std_logic_vector (7 downto 0)
);
end ram256_8b;


architecture ckt of ram256_8b is
type memoria_ram is array (0 to 255) of std_logic_vector (7 downto 0);
signal RAM : memoria_ram := (	0 => X"17",
				1 => X"08",
				2 => X"03",
				3 => X"13",
				4 => X"10",
				8 => X"26",
			   others => X"00");
begin
	process (clk) begin
	if rising_edge(clk) then
		if we = '1' then
			RAM(conv_integer(addr))<=datai;
		end if;
		datao <= RAM(conv_integer(addr ));
	end if;
end process ;
end ckt;
