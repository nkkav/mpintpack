
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;
use WORK.mpint.all;

entity gmpfact is
end gmpfact;

architecture tb_arch of gmpfact is
  -- Constant declarations
  constant CLK_PERIOD : time := 10 ns;
begin

  TEST: process
    variable bufline : LINE;
    variable n : UINT32;
    variable x, prod : MP_INT;
  begin
    prod := mpz_set_ui(1);
    n := 20;
    wait for CLK_PERIOD;
    for i in 1 to n loop 
      x := mpz_set_ui(i);
      wait for CLK_PERIOD;
      prod := mpz_mul(prod, x);
      assert false 
        report "fact(" & integer'IMAGE(i) & ") = " & mpz_get_str(prod)
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
