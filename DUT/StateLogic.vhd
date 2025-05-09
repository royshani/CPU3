library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
--------------------------------------------------------------
entity StateLogic is
  generic( StateLength : integer := 5 );  -- 2^5 bits to describe states
  port(
    clk, ena, rst         : in  std_logic;                   
    ALU_cflag             : in  std_logic;
    i_ALUFN               : in  std_logic_vector(3 downto 0);
    o_currentstate        : out std_logic_vector(StateLength-1 downto 0)
  );
end StateLogic;
--------------------------------------------------------------
architecture StateArch of StateLogic is

  signal current_state, next_state : std_logic_vector(StateLength-1 downto 0);

  -- bit-vector names for each state
  constant ST_IDLE         : std_logic_vector(StateLength-1 downto 0) := "00000";  --  0: reset / idle
  constant ST_FETCH        : std_logic_vector(StateLength-1 downto 0) := "00001";  --  1: fetch instruction
  constant ST_RT           : std_logic_vector(StateLength-1 downto 0) := "00010";  --  2: RT operands fetched
  constant ST_JMP          : std_logic_vector(StateLength-1 downto 0) := "00011";  --  3: jump execution
  constant ST_JC           : std_logic_vector(StateLength-1 downto 0) := "00100";  --  4: conditional jump
  constant ST_MOVE         : std_logic_vector(StateLength-1 downto 0) := "00101";  --  5: move execution
  constant ST_LD_OR_ST     : std_logic_vector(StateLength-1 downto 0) := "00110";  --  6: load/store setup
  constant ST_DONE         : std_logic_vector(StateLength-1 downto 0) := "00111";  --  7: done (halt)
  constant ST_ADD          : std_logic_vector(StateLength-1 downto 0) := "01000";  --  8: ADD execution
  constant ST_SUB          : std_logic_vector(StateLength-1 downto 0) := "01001";  --  9: SUB execution
  constant ST_AND          : std_logic_vector(StateLength-1 downto 0) := "01010";  -- 10: AND execution
  constant ST_OR           : std_logic_vector(StateLength-1 downto 0) := "01011";  -- 11: OR execution
  constant ST_XOR          : std_logic_vector(StateLength-1 downto 0) := "01100";  -- 12: XOR execution
  constant ST_RT_FIN       : std_logic_vector(StateLength-1 downto 0) := "01101";  -- 13: RT finalization
  constant ST_LD_ST_LOGIC  : std_logic_vector(StateLength-1 downto 0) := "01110";  -- 14: load/store logic
  constant ST_ST1          : std_logic_vector(StateLength-1 downto 0) := "01111";  -- 15: store phase 1
  constant ST_ST2          : std_logic_vector(StateLength-1 downto 0) := "10000";  -- 16: store phase 2
  constant ST_LD1          : std_logic_vector(StateLength-1 downto 0) := "10001";  -- 17: load phase 1
  constant ST_LD2          : std_logic_vector(StateLength-1 downto 0) := "10010";  -- 18: load phase 2
  constant ST_DEC          : std_logic_vector(StateLength-1 downto 0) := "10011";  -- 19: decode

  -- integer codes for case statements
  constant IDLE            : integer := 0;
  constant FETCH           : integer := 1;
  constant RT              : integer := 2;
  constant JUMP            : integer := 3;
  constant JC              : integer := 4;
  constant MOVE            : integer := 5;
  constant LD_OR_ST        : integer := 6;
  constant DONE            : integer := 7;
  constant ADD             : integer := 8;
  constant SUB             : integer := 9;
  constant AND_OP          : integer := 10;
  constant OR_OP           : integer := 11;
  constant XOR_OP          : integer := 12;
  constant RT_FIN          : integer := 13;
  constant LD_ST_LOGIC     : integer := 14;
  constant ST1             : integer := 15;
  constant ST2             : integer := 16;
  constant LD1             : integer := 17;
  constant LD2             : integer := 18;
  constant DEC             : integer := 19;

  -- opcode names
  constant OP_ADD          : integer := 0;
  constant OP_SUB          : integer := 1;
  constant OP_AND          : integer := 2;
  constant OP_OR           : integer := 3;
  constant OP_XOR          : integer := 4;
  constant OP_JMP          : integer := 7;
  constant OP_JC           : integer := 8;
  constant OP_JNC          : integer := 9;
  constant OP_MOVE         : integer := 12;
  constant OP_LD           : integer := 13;
  constant OP_ST           : integer := 14;
  constant OP_DONE         : integer := 15;

begin
  o_currentstate <= current_state;

  ----------------------------------------------------------------------------
  -- combinational next-state logic
  NextStateMachine: PROCESS (ena, rst, current_state, next_state)
    variable current_state_var : integer range 0 to 31;
    variable opcode_var        : integer range 0 to 15;
  BEGIN
    -- convert vector inputs to integers for case statements
    current_state_var := conv_integer(current_state);
    opcode_var        := conv_integer(i_ALUFN);

    if rst = '1' then
      -- asynchronous reset: go to idle
      next_state <= ST_IDLE;

    elsif ena = '1' then
      -- main FSM transition
      case current_state_var is

        when FETCH =>
          -- fetch done → decode
          next_state <= ST_DEC;

        when RT =>
          -- RT operands fetched → dispatch ALU function
          case opcode_var is
            when OP_ADD    => next_state <= ST_ADD;
            when OP_SUB    => next_state <= ST_SUB;
            when OP_AND    => next_state <= ST_AND;
            when OP_OR     => next_state <= ST_OR;
            when OP_XOR    => next_state <= ST_XOR;
            when others    => next_state <= ST_FETCH;
          end case;

        when LD_OR_ST =>
          -- load/store setup → go into load/store logic
          next_state <= ST_LD_ST_LOGIC;

        when DONE =>
          -- halt state remains done
          next_state <= ST_DONE;

        when ADD | SUB | AND_OP | OR_OP | XOR_OP =>
          -- ALU exec complete → RT finalization
          next_state <= ST_RT_FIN;

        when LD_ST_LOGIC =>
          -- after load/store logic, decide store vs load phases
          case opcode_var is
            when OP_LD   => next_state <= ST_LD1;
            when OP_ST   => next_state <= ST_ST1;
            when others  => next_state <= ST_FETCH;
          end case;

        when ST1 =>
          -- store phase 1 → store phase 2
          next_state <= ST_ST2;

        when LD1 =>
          -- load phase 1 → load phase 2
          next_state <= ST_LD2;

        when DEC =>
          -- decode → dispatch to micro‐ops or memory ops
          case opcode_var is
            when OP_JMP                => next_state <= ST_JMP;
            when OP_JC  | OP_JNC       => next_state <= ST_JC;
            when OP_MOVE               => next_state <= ST_MOVE;
            when OP_LD   | OP_ST       => next_state <= ST_LD_OR_ST;
            when OP_DONE               => next_state <= ST_DONE;
            when OP_ADD  | OP_SUB
              | OP_AND  | OP_OR
              | OP_XOR                 => next_state <= ST_RT;
            when others                => next_state <= ST_FETCH;
          end case;

        when others =>
          -- any undefined or self‐looping state → go back to fetch
          next_state <= ST_FETCH;
      end case;

    else
      -- hold current state when enable=0
      next_state <= current_state;
    end if;
  END PROCESS NextStateMachine;

  ----------------------------------------------------------------------------
  -- synchronous state register (clocked) with gated enable
  next_st_register: PROCESS (clk, next_state)
  BEGIN
    if rst = '1' then
      current_state <= ST_IDLE;
    elsif ena = '1' then
      if rising_edge(clk) then
        current_state <= next_state;
      end if;
    end if;
  END PROCESS next_st_register;

end StateArch;
