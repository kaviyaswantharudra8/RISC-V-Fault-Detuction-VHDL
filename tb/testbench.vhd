library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_CPU is
end tb_CPU;

architecture sim of tb_CPU is

    signal clk, rst, fi : STD_LOGIC := '0';
    signal result : STD_LOGIC_VECTOR(31 downto 0);

    signal run : boolean := true;

begin

    UUT: entity work.CPU
        port map(
            clk,
            rst,
            fi,
            result
        );

    clk_gen: process
    begin
        while run loop

            clk <= '0';
            wait for 5 ns;

            clk <= '1';
            wait for 5 ns;

        end loop;

        wait;
    end process;


    stim: process
    begin

        rst <= '1';
        fi <= '0';

        wait for 15 ns;

        rst <= '0';

        wait for 30 ns;

        fi <= '1';

        wait for 20 ns;

        fi <= '0';

        wait for 20 ns;

        rst <= '1';

        wait for 10 ns;

        rst <= '0';

        wait for 30 ns;

        run <= false;

        wait;

    end process;

end sim;
