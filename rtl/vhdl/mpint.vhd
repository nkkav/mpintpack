library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.textio.all;


package mpint is

  -- Constant declarations
  constant MAXDIGITS : positive := 2047;
  constant RADIX     : positive :=  256;
  constant BASE      : positive :=    8;
  
  -- Type declarations
  subtype UINT8      is integer range 0 to 255;
  subtype UINT32     is integer range 0 to 2**31-1;
  type MP_INT_ARR    is array (MAXDIGITS downto 0) of uint8;
  type MP_SLV_ARR    is array (MAXDIGITS downto 0) of std_logic_vector(BASE-1 downto 0);
  type PP_INT        is array (1 downto 0) of uint8;
  type PP_SLV        is array (1 downto 0) of std_logic_vector(BASE-1 downto 0);
  
  -- Composite type declarations (records)
  type MP_INT is record
    data : MP_INT_ARR;
    size : integer;
  end record;
  type MP_SLV is record
    data : MP_SLV_ARR;
    size : integer;
  end record;

  function slv2chr (hex : std_logic_vector( 3 downto 0)) return CHARACTER;
 
  -- mpz_init
  procedure mpz_init (x : out MP_INT);
  procedure mpz_init (x : out MP_SLV);
  
  -- mpz_set_ui
  function mpz_set_ui (u : UINT32) return MP_INT;
  function mpz_set_ui (slv : std_logic_vector) return MP_INT;
  function mpz_set_ui (slv : std_logic_vector) return MP_SLV;
  
  -- mpz_set
  function mpz_set (x : MP_INT) return MP_INT;
  function mpz_set (x : MP_SLV) return MP_SLV;

  -- mpz_add
  function mpz_add    (x, y : MP_INT) return MP_INT;
  function mpz_add    (x, y : MP_SLV) return MP_SLV;
  
  -- mpz_add_ui
  function mpz_add_ui (x : MP_INT; y : UINT32) return MP_INT;
  function mpz_add_ui (x : MP_INT; y : std_logic_vector) return MP_INT;  
  function mpz_add_ui (x : MP_SLV; y : std_logic_vector) return MP_SLV;  

  -- mpz_sub
  function mpz_sub    (x, y : MP_INT) return MP_INT;
  function mpz_sub    (x, y : MP_SLV) return MP_SLV;
  
  -- mpz_sub_ui
  function mpz_sub_ui (x : MP_INT; y : UINT32) return MP_INT;
  function mpz_sub_ui (x : MP_INT; y : std_logic_vector) return MP_INT;  
  function mpz_sub_ui (x : MP_SLV; y : std_logic_vector) return MP_SLV;  
  
  -- mpz_mul
  function mpz_mul    (x, y : MP_INT) return MP_INT;
  function mpz_mul    (x, y : MP_SLV) return MP_SLV;
  
  -- mpz_mul_ui
  function mpz_mul_ui (x : MP_INT; y : UINT32) return MP_INT;
  function mpz_mul_ui (x : MP_INT; y : std_logic_vector) return MP_INT;
  function mpz_mul_ui (x : MP_SLV; y : std_logic_vector) return MP_SLV;  

  -- mpz_get_str
  function mpz_get_str (x : MP_INT) return string;
  function mpz_get_str (x : MP_SLV) return string;

  -- mpz_printh
  procedure mpz_printh (x : in MP_INT);
  procedure mpz_printh (x : in MP_SLV);
  
end package mpint;


package body mpint is

  function slv2chr(hex : std_logic_vector(3 downto 0)) return CHARACTER is
    variable char : CHARACTER;
  begin
    case hex is
      when "0000" => char := '0'; 
      when "0001" => char := '1'; 
      when "0010" => char := '2'; 
      when "0011" => char := '3'; 
      when "0100" => char := '4'; 
      when "0101" => char := '5'; 
      when "0110" => char := '6'; 
      when "0111" => char := '7'; 
      when "1000" => char := '8'; 
      when "1001" => char := '9'; 
      when "1010" => char := 'A'; 
      when "1011" => char := 'B'; 
      when "1100" => char := 'C'; 
      when "1101" => char := 'D'; 
      when "1110" => char := 'E'; 
      when "1111" => char := 'F';
      when others => 
        assert false report "no hex character read" severity failure;
    end case;
    return (char);
  end slv2chr;

   -- mpz_init
  procedure mpz_init (x : out MP_INT) is
  begin
    x.data := (others => 0);
    x.size := 1;
  end procedure mpz_init;
  
  -- mpz_init
  procedure mpz_init (x : out MP_SLV) is
  begin
    x.data := (others => (others => '0'));
    x.size := 1;
  end procedure mpz_init;
  
   -- mpz_set_ui
  function mpz_set_ui (u : UINT32) return MP_INT is
    variable i     : integer;
    variable x     : UINT32;
    variable q     : UINT32;
    variable a     : MP_INT;
  begin
    a.data := (others => 0);
    i := 0;
    x := u;
    q := x / RADIX;
    a.data(i) := x - q * RADIX;
    while (q > 0) loop
      i := i + 1;
      x := q;
      q := x / RADIX;
      a.data(i) := x - q * RADIX;
    end loop;
    a.size := i + 1;
    return a;
  end function mpz_set_ui;

  -- mpz_set_ui
  function mpz_set_ui (slv : std_logic_vector) return MP_INT is
    variable u     : UINT32;  
    variable a     : MP_INT;
  begin
    u := to_integer(unsigned(slv));    
    a := mpz_set_ui(u);
    return a;
  end function mpz_set_ui;
  
  -- mpz_set_ui
  function mpz_set_ui (slv : std_logic_vector) return MP_SLV is
    variable u     : UINT32;
    variable x     : UINT32;
    variable q     : UINT32;    
    variable a     : MP_INT;
    variable m     : MP_SLV;
  begin
    a.data := (others => 0);
    m.data := (others => (others => '0'));
    u := to_integer(unsigned(slv));    
    a := mpz_set_ui(u);
    for i in 0 to a.size-1 loop
      m.data(i) := std_logic_vector(to_unsigned(a.data(i), BASE));
    end loop;
    m.size := a.size;
    return m;
  end function mpz_set_ui;

  -- mpz_set
  function mpz_set (x : MP_INT) return MP_INT is
    variable w     : MP_INT;
  begin
    w.data := (others => 0);
    for i in 0 to x.size-1 loop
      w.data(i) := x.data(i);
    end loop;
    w.size := x.size;
    return (w);
  end function mpz_set;

  -- mpz_set
  function mpz_set (x : MP_SLV) return MP_SLV is
    variable w     : MP_INT;
    variable a     : MP_INT;
    variable v     : MP_SLV;
  begin
    for i in 0 to x.size-1 loop
      a.data(i) := to_integer(unsigned(x.data(i)));
    end loop;
    a.size := x.size;
    --    
    w := mpz_set(a);
    --
    for i in 0 to w.size-1 loop
      v.data(i) := std_logic_vector(to_unsigned(w.data(i), BASE));
    end loop;
    v.size := w.size;
    return (v);
  end function mpz_set;
  
  -- mpz_add
  function mpz_add (x, y : MP_INT) return MP_INT is
    variable c     : UINT32;
    variable w     : MP_INT;
  begin
--    assert (x.size = y.size)
--      report "mpz_add: x.size must be equal to y.size"
--      severity failure;    
    w.data := (others => 0);
    c := 0;
    for i in 0 to x.size-1 loop
      w.data(i) := (x.data(i) + y.data(i) + c) mod RADIX;
      if ((x.data(i) + y.data(i) + c) < RADIX) then
        c := 0;
      else
        c := 1;
      end if;
    end loop;
    -- Normalization
    if (c = 0) then
      w.size := x.size;
    else
      w.size := x.size + 1;
      w.data(w.size-1) := c;
    end if;    
    return (w);
  end function mpz_add;

  -- mpz_add
  function mpz_add (x, y : MP_SLV) return MP_SLV is
    variable c     : UINT32;
    variable w     : MP_INT;
    variable a     : MP_INT;
    variable b     : MP_INT;
    variable v     : MP_SLV;
  begin
--    assert (x.size = y.size)
--      report "mpz_add: x.size must be equal to y.size"
--      severity failure;    
    for i in 0 to x.size-1 loop
      a.data(i) := to_integer(unsigned(x.data(i)));
    end loop;
    a.size := x.size;
    for i in 0 to y.size-1 loop
      b.data(i) := to_integer(unsigned(y.data(i)));
    end loop;
    b.size := y.size;
    --    
    w := mpz_add(a, b);
    --
    for i in 0 to x.size-1 loop
      v.data(i) := std_logic_vector(to_unsigned(w.data(i), BASE));
    end loop;
    v.size := w.size;
    return (v);
  end function mpz_add;

  -- mpz_add_ui
  function mpz_add_ui (x : MP_INT; y : UINT32) return MP_INT is
    variable b     : MP_INT;
    variable w     : MP_INT;    
  begin
    b := mpz_set_ui(y);
    w := mpz_add(x, b);
    return (w);
  end function mpz_add_ui;

  -- mpz_add_ui
  function mpz_add_ui (x : MP_INT; y : std_logic_vector) return MP_INT is
    variable b     : MP_INT;
    variable w     : MP_INT;
  begin
    b := mpz_set_ui(y);
    w := mpz_add(x, b);
    return (w);
  end function mpz_add_ui;
  
  -- mpz_add_ui
  function mpz_add_ui (x : MP_SLV; y : std_logic_vector) return MP_SLV is
    variable b     : MP_SLV;
    variable v     : MP_SLV;
  begin
    b := mpz_set_ui(y);
    v := mpz_add(x, b);
    return (v);
  end function mpz_add_ui;

  -- mpz_sub
  function mpz_sub (x, y : MP_INT) return MP_INT is
    variable c     : integer;
    variable w     : MP_INT;
    variable t     : MP_INT;
    variable v     : MP_INT;
  begin
--    assert (x.size = y.size)
--      report "mpz_sub: x.size must be equal to y.size"
--      severity failure;    
    w.data := (others => 0);
    c := 0;
    for i in 0 to x.size-1 loop
      w.data(i) := (x.data(i) - y.data(i) + c) mod RADIX;
      if ((x.data(i) - y.data(i) + c) < RADIX) then
        c := 0;
      else
        c := -1;
      end if;
    end loop;
    w.size := x.size;
    --
    if (c = 0) then
      return (w);
    elsif (c = -1) then
      t.data := (others => 0);
      c := 0;
      for i in 0 to x.size-1 loop
        v.data(i) := (t.data(i) - w.data(i) + c) mod RADIX;
        if ((t.data(i) - w.data(i) + c) < RADIX) then
          c := 0;
        else
          c := -1;
        end if;
      end loop;
      v.size := w.size;
      return (t);
    end if;
  end function mpz_sub;

  -- mpz_sub
  function mpz_sub (x, y : MP_SLV) return MP_SLV is
    variable c     : UINT32;
    variable w     : MP_INT;
    variable a     : MP_INT;
    variable b     : MP_INT;
    variable v     : MP_SLV;
  begin
    assert (x.size = y.size)
      report "mpz_sub: x.size must be equal to y.size"
      severity failure;    
    for i in 0 to x.size-1 loop
      a.data(i) := to_integer(unsigned(x.data(i)));
    end loop;
    a.size := x.size;
    for i in 0 to y.size-1 loop
      b.data(i) := to_integer(unsigned(y.data(i)));
    end loop;
    b.size := y.size;
    --    
    w := mpz_sub(a, b);
    --
    for i in 0 to x.size-1 loop
      v.data(i) := std_logic_vector(to_unsigned(w.data(i), BASE));
    end loop;
    v.size := w.size;
    return (v);
  end function mpz_sub;

  -- mpz_sub_ui
  function mpz_sub_ui (x : MP_INT; y : UINT32) return MP_INT is
    variable b     : MP_INT;
    variable w     : MP_INT;    
  begin
    b := mpz_set_ui(y);
    w := mpz_sub(x, b);
    return (w);
  end function mpz_sub_ui;

  -- mpz_sub_ui
  function mpz_sub_ui (x : MP_INT; y : std_logic_vector) return MP_INT is
    variable b     : MP_INT;
    variable w     : MP_INT;
  begin
    b := mpz_set_ui(y);
    w := mpz_sub(x, b);
    return (w);
  end function mpz_sub_ui;

  -- mpz_sub_ui
  function mpz_sub_ui (x : MP_SLV; y : std_logic_vector) return MP_SLV is
    variable b     : MP_SLV;
    variable v     : MP_SLV;
  begin
    b := mpz_set_ui(y);
    v := mpz_sub(x, b);
    return (v);
  end function mpz_sub_ui;
  
  -- mpz_mul
  function mpz_mul (x, y : MP_INT) return MP_INT is
    variable ii    : integer;
    variable c     : UINT32;
    variable w     : MP_INT;
    variable uv    : PP_INT;
    variable t     : integer;
    variable t_slv : std_logic_vector(2*BASE-1 downto 0);
  begin
    for i in 0 to (x.size + y.size - 1) loop
      w.data(i) := 0;
    end loop;
    for i in 0 to y.size-1 loop
      c := 0;
      for j in 0 to x.size-1 loop
        -- temporary result (up to 16 bits for radix-256)
        t := w.data(i+j) + x.data(j) * y.data(i) + c;
        t_slv := std_logic_vector(to_unsigned(t, 2*BASE));
        uv(1) := to_integer(unsigned(t_slv(2*BASE-1 downto BASE)));
        uv(0) := to_integer(unsigned(t_slv(  BASE-1 downto    0)));
        w.data(i+j) := uv(0);
        c := uv(1);
      end loop;
      w.data(i+x.size) := uv(1);
    end loop;  
    w.size := x.size + y.size;
    --
    -- Normalization
    ii := w.size - 1;
    while (ii > 0) loop
      if (w.data(ii) = 0) then
        ii := ii - 1;
      else
        exit;
      end if;
    end loop;
    w.size := ii + 1;
    return (w);
  end function mpz_mul;
      
  -- mpz_mul
  function mpz_mul (x, y : MP_SLV) return MP_SLV is
    variable c     : UINT32;
    variable w     : MP_INT;
    variable a     : MP_INT;
    variable b     : MP_INT;
    variable v     : MP_SLV;
  begin
    for i in 0 to x.size-1 loop
      a.data(i) := to_integer(unsigned(x.data(i)));
    end loop;
    a.size := x.size;
    for i in 0 to y.size-1 loop
      b.data(i) := to_integer(unsigned(y.data(i)));
    end loop;
    b.size := y.size;
    --    
    w := mpz_mul(a, b);
    --
    for i in 0 to w.size-1 loop
      v.data(i) := std_logic_vector(to_unsigned(w.data(i), BASE));
    end loop;
    v.size := w.size;
    return (v);
  end function mpz_mul;

  -- mpz_mul_ui
  function mpz_mul_ui (x : MP_INT; y : UINT32) return MP_INT is
    variable b     : MP_INT;
    variable w     : MP_INT;    
  begin
    b := mpz_set_ui(y);
    w := mpz_mul(x, b);
    return (w);
  end function mpz_mul_ui;
  
  -- mpz_mul_ui
  function mpz_mul_ui (x : MP_INT; y : std_logic_vector) return MP_INT is
    variable b     : MP_INT;
    variable w     : MP_INT;
  begin
    b := mpz_set_ui(y);
    w := mpz_mul(x, b);
    return (w);
  end function mpz_mul_ui;  

  -- mpz_mul_ui
  function mpz_mul_ui (x : MP_SLV; y : std_logic_vector) return MP_SLV is
    variable b     : MP_SLV;
    variable v     : MP_SLV;
  begin
    b := mpz_set_ui(y);
    v := mpz_mul(x, b);
    return (v);
  end function mpz_mul_ui;
  
  -- mpz_get_str
  function mpz_get_str (x : MP_INT) return string is
    variable j     : integer;
    variable k     : integer;
    variable s     : string(0 to 2*x.size-1);
    variable t     : std_logic_vector(BASE-1 downto 0);
    variable u     : std_logic_vector(3 downto 0);
  begin
    s := (others => '0');
    u := (others => '0');
    k := 0;
    for i in x.size-1 downto 0 loop
      t := std_logic_vector(to_unsigned(x.data(i), BASE));
      j := BASE/4-1;
      while (j >= 0) loop
        u := t(4*(j+1)-1 downto 4*j);
        j := j - 1;
        s(k) := slv2chr(u);
        k := k + 1;
      end loop;        
    end loop;
    return (s);
  end function mpz_get_str;

  -- mpz_get_str
  function mpz_get_str (x : MP_SLV) return string is
    variable s     : string(0 to 2*x.size-1);
    variable a     : MP_INT;    
  begin
    for i in 0 to x.size-1 loop
      a.data(i) := to_integer(unsigned(x.data(i)));
    end loop;
    a.size := x.size;
    --    
    s := mpz_get_str(a);
    --
    return (s);
  end function mpz_get_str;
  
  -- mpz_printh
  procedure mpz_printh (x : in MP_INT) is
  begin
    assert false 
      report "(MP_INT) " & mpz_get_str(x)
      severity note;
  end procedure mpz_printh;
  
  -- mpz_printh
  procedure mpz_printh (x : in MP_SLV) is
  begin
    assert false 
      report "(MP_SLV) " & mpz_get_str(x)
      severity note;
  end procedure mpz_printh;
        
end package body mpint;
