
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;
use WORK.mpint.all;

entity gmpfact_slv is
end gmpfact_slv;

architecture tb_arch of gmpfact_slv is
  -- Constant declarations
  constant CLK_PERIOD : time := 10 ns;
begin

  TEST: process
    variable bufline : LINE;
    variable i : UINT32;
    variable n : std_logic_vector(31 downto 0);
    variable x, prod : MP_SLV;
  begin
    prod := mpz_set_ui(std_logic_vector(to_unsigned(1, 32)));
    n := std_logic_vector(to_unsigned(20, 32));
    wait for CLK_PERIOD;
    for i in 1 to to_integer(unsigned(n)) loop 
      x := mpz_set_ui(std_logic_vector(to_unsigned(i, 32)));
      wait for CLK_PERIOD;
      prod := mpz_mul(prod, x);
      assert false 
        report "fact2(" & integer'IMAGE(i) & ") = " & mpz_get_str(prod)
        severity note;
      wait for CLK_PERIOD;
    end loop;
    --
    wait for CLK_PERIOD;
    -- Automatic end of the current simulation.
    assert false
      report "End simulation time reached"
      severity failure;    
  end process TEST;
  
end tb_arch;
