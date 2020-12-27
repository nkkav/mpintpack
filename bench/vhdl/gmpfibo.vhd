library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;
use WORK.mpint.all;

entity gmpfibo is
end gmpfibo;

architecture tb_arch of gmpfibo is
  -- Constant declarations
  constant CLK_PERIOD : time := 10 ns;
begin

  TEST: process
    variable bufline : LINE;
    variable i, k, n : UINT32;
    variable f, f0, f1 : MP_INT;
  begin
    f0 := mpz_set_ui(0);
    f1 := mpz_set_ui(1);
    k := 2;
    n := 20;
    wait for CLK_PERIOD;
    loop
      k := k + 1;
      f := mpz_add(f1, f0);
      wait for CLK_PERIOD;
      f0 := mpz_set(f1);
      f1 := mpz_set(f);
      wait for CLK_PERIOD;
      assert false
        report "f =" & mpz_get_str(f)
        severity note; 
      exit when (k > n);
    end loop;
    wait for CLK_PERIOD;
    -- Automatic end of the current simulation.
    assert false
      report "End simulation time reached"
      severity failure;    
  end process TEST;
  
end tb_arch;
