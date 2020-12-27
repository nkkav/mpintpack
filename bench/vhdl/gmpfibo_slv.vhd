library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;
use WORK.mpint.all;

entity gmpfibo_slv is
end gmpfibo_slv;

architecture tb_arch of gmpfibo_slv is
  -- Constant declarations
  constant CLK_PERIOD : time := 10 ns;
begin

  TEST: process
    variable bufline : LINE;
    variable i : UINT32;
    variable k, n : std_logic_vector(31 downto 0);
    variable f, f0, f1 : MP_SLV;
  begin
    f0 := mpz_set_ui(std_logic_vector(to_unsigned(0, 32)));
    f1 := mpz_set_ui(std_logic_vector(to_unsigned(1, 32)));
    k := std_logic_vector(to_unsigned(2, 32));
    n := std_logic_vector(to_unsigned(20, 32));
    wait for CLK_PERIOD;
    loop
      k := std_logic_vector(unsigned(k) + 1);
      f := mpz_add(f1, f0);
      wait for CLK_PERIOD;
      f0 := mpz_set(f1);
      f1 := mpz_set(f);
      wait for CLK_PERIOD;
      assert false
        report "f =" & mpz_get_str(f)
        severity note; 
      exit when (unsigned(k) > unsigned(n));
    end loop;
    wait for CLK_PERIOD;
    -- Automatic end of the current simulation.
    assert false
      report "End simulation time reached"
      severity failure;    
  end process TEST;
  
end tb_arch;
