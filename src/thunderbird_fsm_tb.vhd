--+----------------------------------------------------------------------------
--| 
--| COPYRIGHT 2017 United States Air Force Academy All rights reserved.
--| 
--| United States Air Force Academy     __  _______ ___    _________ 
--| Dept of Electrical &               / / / / ___//   |  / ____/   |
--| Computer Engineering              / / / /\__ \/ /| | / /_  / /| |
--| 2354 Fairchild Drive Ste 2F6     / /_/ /___/ / ___ |/ __/ / ___ |
--| USAF Academy, CO 80840           \____//____/_/  |_/_/   /_/  |_|
--| 
--| ---------------------------------------------------------------------------
--|
--| FILENAME      : thunderbird_fsm_tb.vhd (TEST BENCH)
--| AUTHOR(S)     : Capt Phillip Warner
--| CREATED       : 03/2017
--| DESCRIPTION   : This file tests the thunderbird_fsm modules.
--|
--|
--+----------------------------------------------------------------------------
--|
--| REQUIRED FILES :
--|
--|    Libraries : ieee
--|    Packages  : std_logic_1164, numeric_std
--|    Files     : thunderbird_fsm_enumerated.vhd, thunderbird_fsm_binary.vhd, 
--|				   or thunderbird_fsm_onehot.vhd
--|
--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  
entity thunderbird_fsm_tb is
end thunderbird_fsm_tb;

architecture test_bench of thunderbird_fsm_tb is 
	
	component thunderbird_fsm is 
	  port(
        i_clk, i_reset  : in    std_logic;
        i_left, i_right : in    std_logic;
        o_lights_l      : out   std_logic_vector(2 downto 0);
        o_lights_r      : out   std_logic_vector(2 downto 0)    
	);
	end component thunderbird_fsm;

	-- test I/O signals
	-- inputs
	signal w_clk : std_logic := '0';
	signal w_reset: std_logic := '0';
	signal w_left : std_logic := '0';
	signal w_right : std_logic := '0';
	-- outputs
	signal w_lights_l : std_logic_vector(2 downto 0) := "000";
	signal w_lights_r : std_logic_vector(2 downto 0) := "000";
	
	-- constants
	constant k_clk_period : time := 10 ns;
	
begin
	-- PORT MAPS ----------------------------------------
	thunderbird_fsm_inst : thunderbird_fsm
	  port map(
        i_clk => w_clk,
        i_reset => w_reset,
        i_left => w_left,
        i_right => w_right,
        o_lights_l => w_lights_l,
        o_lights_r => w_lights_r
	); 

	-- PROCESSES ----------------------------------------	
    -- Clock process ------------------------------------
    clk_proc : process
	begin
		w_clk <= '0';
        wait for k_clk_period/2;
		w_clk <= '1';
		wait for k_clk_period/2;
	end process;
	
	-- Test Plan Process --------------------------------
	sim_proc: process
	begin
		-- test initial reset		
		w_reset <= '1';
		wait for k_clk_period*2;
		  assert (w_lights_l = "000" and w_lights_r = "000") report "bad reset at start" severity failure;
		w_reset <= '0';
		wait for k_clk_period;
		
		-- left blinker (single blink)
		w_left <= '1'; wait for k_clk_period;
		w_left <= '0';
		  assert w_lights_l = "001" report "bad 1st light on left" severity failure; wait for k_clk_period;
		  assert w_lights_l = "011" report "bad 2nd light on left" severity failure; wait for k_clk_period;
		  assert w_lights_l = "111" report "bad 3rd light on left" severity failure; wait for k_clk_period;
		  assert w_lights_l = "000" report "bad return to off on left" severity failure; wait for k_clk_period;
		
		-- left blinker (multiple blink)
		w_left <= '1'; wait for k_clk_period;
		  assert w_lights_l = "001" report "bad 1st light on left" severity failure; wait for k_clk_period;
		  assert w_lights_l = "011" report "bad 2nd light on left" severity failure; wait for k_clk_period;
		  assert w_lights_l = "111" report "bad 3rd light on left" severity failure; wait for k_clk_period;
		  assert w_lights_l = "000" report "bad return to off on left" severity failure; wait for k_clk_period;
		  --should return to off state and repeat turn signal pattern
		  assert w_lights_l = "001" report "bad 1st light on left" severity failure; wait for k_clk_period;
	   w_left <= '0';
		  assert w_lights_l = "011" report "bad 2nd light on left" severity failure; wait for k_clk_period;
		  assert w_lights_l = "111" report "bad 3rd light on left" severity failure; wait for k_clk_period;
		  assert w_lights_l = "000" report "bad return to off on left" severity failure; wait for k_clk_period;   
		  
        -- right blinker (single blink)
		w_right <= '1'; wait for k_clk_period;
		w_right <= '0';
		  assert w_lights_r = "001" report "bad 1st light on right" severity failure; wait for k_clk_period;
		  assert w_lights_r = "011" report "bad 2nd light on right" severity failure; wait for k_clk_period;
		  assert w_lights_r = "111" report "bad 3rd light on right" severity failure; wait for k_clk_period;
		  assert w_lights_r = "000" report "bad return to off on right" severity failure; wait for k_clk_period;
		
		-- right blinker (multiple blink)
		w_right <= '1'; wait for k_clk_period;
		  assert w_lights_r = "001" report "bad 1st light on right" severity failure; wait for k_clk_period;
		  assert w_lights_r = "011" report "bad 2nd light on right" severity failure; wait for k_clk_period;
		  assert w_lights_r = "111" report "bad 3rd light on right" severity failure; wait for k_clk_period;
		  assert w_lights_r = "000" report "bad return to off on right" severity failure; wait for k_clk_period;
		  --should return to off state and repeat turn signal pattern
		  assert w_lights_r = "001" report "bad 1st light on right" severity failure; wait for k_clk_period;
	   w_right <= '0';
		  assert w_lights_r = "011" report "bad 2nd light on right" severity failure; wait for k_clk_period;
		  assert w_lights_r = "111" report "bad 3rd light on right" severity failure; wait for k_clk_period;
		  assert w_lights_r = "000" report "bad return to off on right" severity failure; wait for k_clk_period;   		  
		  
		-- both left and right switch on...should blink all lights on and off (i.e. hazard lights)
		w_left <= '1'; w_right <= '1'; wait for k_clk_period;
          assert (w_lights_l = "111" and w_lights_r = "111") report "should blink all lights (hazard)" severity failure; wait for k_clk_period;
          assert (w_lights_l = "000" and w_lights_r = "000") report "should turn off all lights (hazard)" severity failure; wait for k_clk_period;
        w_left <= '0'; w_right <= '0';    
          assert (w_lights_l = "111" and w_lights_r = "111") report "should blink all lights (hazard)" severity failure; wait for k_clk_period;
          
        -- test reset in middle of turn pattern
        w_left <= '1'; wait for k_clk_period;
		w_left <= '0';
		  assert w_lights_l = "001" report "bad 1st light on left" severity failure; wait for k_clk_period;
        w_reset <= '1'; wait for k_clk_period;
          assert (w_lights_l = "000" and w_lights_r = "000") report "bad reset at start" severity failure;		
		
        wait;
    end process;
	
end test_bench;
