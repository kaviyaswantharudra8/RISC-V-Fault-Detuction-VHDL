library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity PC is
    Port (
        clk, rst, fi : in STD_LOGIC;
        din : in STD_LOGIC_VECTOR(31 downto 0);
        dout : out STD_LOGIC_VECTOR(31 downto 0)
    );
end PC;

architecture rtl of PC is
begin
    process(clk, rst)
    begin
        if rst = '1' then
            dout <= (others => '0');
        elsif rising_edge(clk) then
            if fi = '1' then
                dout <= x"DEADBEEF";
            else
                dout <= din;
            end if;
        end if;
    end process;
end rtl;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity IM is
    Port (
        addr : in STD_LOGIC_VECTOR(31 downto 0);
        fi : in STD_LOGIC;
        dout : out STD_LOGIC_VECTOR(31 downto 0)
    );
end IM;

architecture rtl of IM is
    type rom_t is array (0 to 15) of STD_LOGIC_VECTOR(31 downto 0);

    constant rom : rom_t := (
        0 => x"00500093",
        1 => x"00A00113",
        2 => x"002081B3",
        3 => x"00302023",
        4 => x"00002203",
        others => x"00000013"
    );
begin
    process(addr, fi)
        variable i : integer;
    begin
        i := to_integer(unsigned(addr(5 downto 2)));

        if fi = '1' then
            dout <= x"FFFFFFFF";
        elsif i >= 0 and i < 16 then
            dout <= rom(i);
        else
            dout <= x"00000013";
        end if;
    end process;
end rtl;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RF is
    Port (
        clk, rst, we, fi : in STD_LOGIC;
        rs1, rs2, rd : in STD_LOGIC_VECTOR(4 downto 0);
        wd : in STD_LOGIC_VECTOR(31 downto 0);
        d1, d2 : out STD_LOGIC_VECTOR(31 downto 0)
    );
end RF;

architecture rtl of RF is
    type reg_t is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    signal r : reg_t := (others => (others => '0'));
begin

    process(rs1, rs2, r, fi)
    begin
        if fi = '1' then
            d1 <= x"BAD0BAD0";
            d2 <= x"BAD0BAD0";
        else
            if rs1 = "00000" then
                d1 <= (others => '0');
            else
                d1 <= r(to_integer(unsigned(rs1)));
            end if;

            if rs2 = "00000" then
                d2 <= (others => '0');
            else
                d2 <= r(to_integer(unsigned(rs2)));
            end if;
        end if;
    end process;

    process(clk, rst)
    begin
        if rst = '1' then
            for i in 0 to 31 loop
                r(i) <= (others => '0');
            end loop;
        elsif rising_edge(clk) then
            if we = '1' and rd /= "00000" then
                r(to_integer(unsigned(rd))) <= wd;
            end if;
        end if;
    end process;

end rtl;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity IMM is
    Port (
        ins : in STD_LOGIC_VECTOR(31 downto 0);
        imm : out STD_LOGIC_VECTOR(31 downto 0)
    );
end IMM;

architecture rtl of IMM is
begin
    process(ins)
    begin
        case ins(6 downto 0) is

            when "0010011" =>
                imm <= std_logic_vector(
                    resize(signed(ins(31 downto 20)), 32)
                );

            when "0000011" =>
                imm <= std_logic_vector(
                    resize(signed(ins(31 downto 20)), 32)
                );

            when "0100011" =>
                imm <= std_logic_vector(
                    resize(
                        signed(ins(31 downto 25) & ins(11 downto 7)),
                        32
                    )
                );

            when others =>
                imm <= (others => '0');

        end case;
    end process;
end rtl;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALU is
    Port (
        a, b : in STD_LOGIC_VECTOR(31 downto 0);
        op : in STD_LOGIC_VECTOR(2 downto 0);
        fi : in STD_LOGIC;
        y : out STD_LOGIC_VECTOR(31 downto 0);
        z : out STD_LOGIC
    );
end ALU;

architecture rtl of ALU is
begin
    process(a, b, op, fi)
        variable t : STD_LOGIC_VECTOR(31 downto 0);
    begin

        case op is
            when "000" =>
                t := std_logic_vector(signed(a) + signed(b));

            when "001" =>
                t := std_logic_vector(signed(a) - signed(b));

            when "010" =>
                t := a and b;

            when "011" =>
                t := a or b;

            when "100" =>
                t := a xor b;

            when others =>
                t := (others => '0');
        end case;

        if fi = '1' then
            y <= x"0BADD00D";
            z <= '0';
        else
            y <= t;

            if t = x"00000000" then
                z <= '1';
            else
                z <= '0';
            end if;
        end if;

    end process;
end rtl;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ALUCTRL is
    Port (
        aluop : in STD_LOGIC_VECTOR(1 downto 0);
        f3 : in STD_LOGIC_VECTOR(2 downto 0);
        f7 : in STD_LOGIC;
        fi : in STD_LOGIC;
        op : out STD_LOGIC_VECTOR(2 downto 0)
    );
end ALUCTRL;

architecture rtl of ALUCTRL is
begin
    process(aluop, f3, f7, fi)
    begin

        if fi = '1' then
            op <= "111";
        else
            case aluop is

                when "00" =>
                    op <= "000";

                when "01" =>
                    op <= "001";

                when "10" =>
                    case f3 is

                        when "000" =>
                            if f7 = '1' then
                                op <= "001";
                            else
                                op <= "000";
                            end if;

                        when "111" =>
                            op <= "010";

                        when "110" =>
                            op <= "011";

                        when "100" =>
                            op <= "100";

                        when others =>
                            op <= "000";

                    end case;

                when others =>
                    op <= "000";

            end case;
        end if;

    end process;
end rtl;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity DM is
    Port (
        clk, rst, mw, mr, fi : in STD_LOGIC;
        addr, wd : in STD_LOGIC_VECTOR(31 downto 0);
        rd : out STD_LOGIC_VECTOR(31 downto 0)
    );
end DM;

architecture rtl of DM is
    type ram_t is array (0 to 31) of STD_LOGIC_VECTOR(31 downto 0);
    signal ram : ram_t := (others => (others => '0'));
begin

    process(clk, rst)
    begin
        if rst = '1' then
            for i in 0 to 31 loop
                ram(i) <= (others => '0');
            end loop;

        elsif rising_edge(clk) then
            if mw = '1' then
                ram(to_integer(unsigned(addr(6 downto 2)))) <= wd;
            end if;
        end if;
    end process;

    process(addr, mr, ram, fi)
    begin
        if fi = '1' then
            rd <= x"DEADDEAD";
        elsif mr = '1' then
            rd <= ram(to_integer(unsigned(addr(6 downto 2))));
        else
            rd <= (others => '0');
        end if;
    end process;

end rtl;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CU is
    Port (
        op : in STD_LOGIC_VECTOR(6 downto 0);
        fi : in STD_LOGIC;
        asrc, mtr, we, mr, mw, br : out STD_LOGIC;
        aluop : out STD_LOGIC_VECTOR(1 downto 0)
    );
end CU;

architecture rtl of CU is
begin
    process(op, fi)
    begin

        asrc <= '0';
        mtr <= '0';
        we <= '0';
        mr <= '0';
        mw <= '0';
        br <= '0';
        aluop <= "00";

        if fi = '1' then

            asrc <= '1';
            mtr <= '1';
            we <= '1';
            mr <= '1';
            mw <= '1';
            br <= '1';
            aluop <= "11";

        else

            case op is

                when "0110011" =>
                    we <= '1';
                    aluop <= "10";

                when "0010011" =>
                    asrc <= '1';
                    we <= '1';
                    aluop <= "00";

                when "0000011" =>
                    asrc <= '1';
                    mtr <= '1';
                    we <= '1';
                    mr <= '1';
                    aluop <= "00";

                when "0100011" =>
                    asrc <= '1';
                    mw <= '1';
                    aluop <= "00";

                when "1100011" =>
                    br <= '1';
                    aluop <= "01";

                when others =>
                    null;

            end case;

        end if;

    end process;
end rtl;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MUX is
    Port (
        a, b : in STD_LOGIC_VECTOR(31 downto 0);
        s, fi : in STD_LOGIC;
        y : out STD_LOGIC_VECTOR(31 downto 0)
    );
end MUX;

architecture rtl of MUX is
begin
    process(a, b, s, fi)
    begin

        if fi = '1' then
            y <= x"EEEEEEEE";
        elsif s = '0' then
            y <= a;
        else
            y <= b;
        end if;

    end process;
end rtl;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity CPU is
    Port (
        clk, rst, fi : in STD_LOGIC;
        result : out STD_LOGIC_VECTOR(31 downto 0)
    );
end CPU;

architecture rtl of CPU is

    signal pc, npc, ins : STD_LOGIC_VECTOR(31 downto 0);

    signal d1, d2 : STD_LOGIC_VECTOR(31 downto 0);
    signal imm : STD_LOGIC_VECTOR(31 downto 0);

    signal alu_b : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_y : STD_LOGIC_VECTOR(31 downto 0);

    signal mem_d : STD_LOGIC_VECTOR(31 downto 0);
    signal wb_d : STD_LOGIC_VECTOR(31 downto 0);

    signal asrc, mtr, we, mr, mw, br : STD_LOGIC;

    signal aluop : STD_LOGIC_VECTOR(1 downto 0);
    signal alu_ctrl : STD_LOGIC_VECTOR(2 downto 0);

    signal z : STD_LOGIC;

begin

    U1: entity work.PC
        port map(
            clk,
            rst,
            fi,
            npc,
            pc
        );

    U2: entity work.IM
        port map(
            pc,
            fi,
            ins
        );

    U3: entity work.CU
        port map(
            ins(6 downto 0),
            fi,
            asrc,
            mtr,
            we,
            mr,
            mw,
            br,
            aluop
        );

    U4: entity work.IMM
        port map(
            ins,
            imm
        );

    U5: entity work.RF
        port map(
            clk,
            rst,
            we,
            fi,
            ins(19 downto 15),
            ins(24 downto 20),
            ins(11 downto 7),
            wb_d,
            d1,
            d2
        );

    U6: entity work.MUX
        port map(
            d2,
            imm,
            asrc,
            fi,
            alu_b
        );

    U7: entity work.ALUCTRL
        port map(
            aluop,
            ins(14 downto 12),
            ins(30),
            fi,
            alu_ctrl
        );

    U8: entity work.ALU
        port map(
            d1,
            alu_b,
            alu_ctrl,
            fi,
            alu_y,
            z
        );

    U9: entity work.DM
        port map(
            clk,
            rst,
            mw,
            mr,
            fi,
            alu_y,
            d2,
            mem_d
        );

    U10: entity work.MUX
        port map(
            alu_y,
            mem_d,
            mtr,
            fi,
            wb_d
        );

    result <= alu_y;

    npc <= std_logic_vector(unsigned(pc) + 4)
           when rst = '0'
           else x"00000000";

end rtl;
