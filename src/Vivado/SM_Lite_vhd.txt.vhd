----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.10.2024 16:58:56
-- Design Name: 
-- Module Name: StateMachine - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


entity SM_Lite is
    Port (
    clk             : in    std_logic;                             -- reloj de 100Mhz
    nxt             : in    std_logic;
    rst             : in    std_logic;
    
    lite            : in    std_logic;                             -- flag de termino transferencia AXI-LITE
    full            : in    std_logic;                             -- flag de termino transferenica AXI-FULL
    
    run_a           : out   std_logic := '0';                             -- flag de inicio rutina de leds A
    run_b           : out   std_logic := '0';                             -- flag de inicio rutina de leds B
    run_c           : out   std_logic := '0';                             -- flag de inicio rutina de leds B
    run_d           : out   std_logic := '0';                             -- flag de inicio rutina de leds B


    don_a           : in    std_logic;                             -- flag de termino rutina de leds A
    don_b           : in    std_logic;                             -- flag de termino rutina de leds B
    
    move_a          : in    std_logic_vector (7 downto 0);                 -- jugada player A
    move_b          : in    std_logic_vector (7 downto 0);                 -- jugada player B
    
    flag            : out   std_logic_vector (3 downto 0) := (others=>'0');   -- flag de estado de la State-Machine
    
    addr_lite       : out   std_logic_vector (2 downto 0) := (others=>'0');   -- address de RAM-AXI-LITE (Buffers RGB)
    addr_full       : out   std_logic_vector (2 downto 0) := (others=>'0')    -- address de RAM-AXI-FULL (rutina de luces)
    );
end SM_Lite;

----------------------------------------------------------------------------------
-- COMPONENT BEHAVORIAL DESCRIPTION HERE:
-- STATE 0:     state of AXI-Transcations
--              waitng for AXI-Transactions done
--              go STATE1 with:     (en_lite & en_full)

-- STATE 1:     state of first leds show
--              show the first leds bus from ATG-FULL-RAM 32'b
--              en_a: comes from LED_DRIVER, when it ends a leds show. it alert the end of led show
--              go STATE2:          (en_a)

-- STATE 2:     selection menu mode
--              in first version, we only have PvP hard mode
--              in futures versions, we add PvP easy mode/ PvE easy mode/ Pve hard mode
--              go STATE3:          (nxt)

-- STATE 3:     state of select first player choice
--              show in RGB, the color of the choice
--              change choice with left and right buttons   (need a Controll Button IP_Core)
--              confirm selection with nxt button
--              go STATE4:          (nxt)

-- STATE 4:     state of select second player choice
--              show in RGB, the color of the choice
--              change choice with left and right buttons   (need a Controll Button IP_Core)
--              confirm selection with nxt button
--              go STATE5:          (nxt)

-- STATE 5:     state of second leds show
--              show the second leds bus from ATG-FULL-RAM 32'b
--              go SATE6 with:      (en_b)
--              en_b: comes from LED_DRIVER, when it ends a second leds show. it alert the end of led show

-- STATE 6:     state of show the winner player
--              use the COMPARE_ELEMENT_IPcore
--              show a led(3) or led(0) depending the winner player
--              first player (left led), second player (right led)
--              show the rgb chocie who won
--              go STATE1 with:     (nxt)

architecture Behavioral of SM_Lite is

-- CONSTANT DECLARATIONS HERE:
 constant red_state     : std_logic_vector(7 downto 0) := "00000001";
 constant green_state   : std_logic_vector(7 downto 0) := "00000010";
 constant blue_state    : std_logic_vector(7 downto 0) := "00000100";
 constant cian_state    : std_logic_vector(7 downto 0) := "00001000";
 constant purple_state  : std_logic_vector(7 downto 0) := "00010000";
 constant yellow_state  : std_logic_vector(7 downto 0) := "00100000";
 constant orange_state  : std_logic_vector(7 downto 0) := "01000000";
 
-- SIGNAL DECLARATIONS HERE:

signal prsn         : std_logic := nxt;
signal past         : std_logic := prsn;

signal state        : integer range 0 to 7 := 0;

signal led_en       : std_logic;
signal rgb_en       : std_logic;

signal play_a     : std_logic_vector(2 downto 0);
signal play_b     : std_logic_vector(2 downto 0);
 

-- COMPONENTS DECLARATIONS HERE:

begin

-- COMPONENTS PORT HERE:

-----------------------------------------------------------------
-- SEQUENTIAL USER CODE HERE:     

DINAMIC: process (clk, rst)

begin
    if (rst = '1') then
        past                <= nxt;
        state               <= 0;
        run_a               <= '0';
        run_b               <= '0';
        addr_lite           <= (others => '0');
        addr_full           <= (others => '0');
        
    elsif(rising_edge(clk)) then
    prsn                <= nxt;
    past                <= prsn;
    
    -------------------------------------------------------------
    -- STATE 0 transition
    if (state = 0) then
        addr_lite           <= (others => '0');
        addr_full           <= (others => '0');
        if (lite and full) = '1' then
            state <= state + 1;
            run_a       <= '1';             --rising_edge juego de luces 1
        end if; 
    end if;
    -------------------------------------------------------------
    -- STATE 1 transition
    if (state = 1) then
        addr_full           <= "001";
        if (don_a = '1') then
            run_a       <= '0';             --falling_edge jugo de luces 1
            state       <= state + 1;
        end if; 
    end if;
    -------------------------------------------------------------
    -- STATE 2 transition
    if (state = 2) then
        addr_full           <= "000";
        if (past = '0' and prsn = '1') then
            run_c       <= '1';             --rising_edge jugador 1 
            state       <= state + 1;
        end if; 
    end if;
    -------------------------------------------------------------
    -- STATE 3 transition
    if (state = 3) then
        addr_lite       <= play_a;
        if (past = '0' and prsn = '1') then
            run_c       <= '0';             --falling_edge jugador 1 
            run_d       <= '1';             --rising_edge jugador 2 
            state       <= state + 1;
        end if;
    end if;
    -------------------------------------------------------------
    -- STATE 4 transition
    if (state = 4) then
        addr_lite       <= play_b;
        if (past = '0' and prsn = '1') then
            state       <= state + 1;
            run_d       <= '0';             --falling_edge jugador 2 
            run_b       <= '1';             --rising_edge juego de luces 2
        end if;
    end if;
    -------------------------------------------------------------
    -- STATE 5 transition
    if (state = 5) then
        addr_lite       <= (others => '0');
        if (don_b = '1') then
            run_b       <= '0';             --falling_edge juego de luces 2
            state       <= state + 1;
        end if;  
    end if;
    -------------------------------------------------------------
    -- STATE 6 transition
    if (state = 6) then
        if (past = '0' and prsn = '1') then
            state       <= 1;
            run_a       <= '1';
        end if; 
    end if;
    
    -------------------------------------------------------------
    case move_a is
    when red_state      => play_a <= "001";
    when green_state    => play_a <= "010";
    when blue_state     => play_a <= "011";
    when cian_state     => play_a <= "100";
    when purple_state   => play_a <= "101";
    when yellow_state   => play_a <= "110";
    when orange_state   => play_a <= "111";
    when others         => play_a <= "000";
    end case;
    
    case move_b is
    when red_state      => play_b <= "001";
    when green_state    => play_b <= "010";
    when blue_state     => play_b <= "011";
    when cian_state     => play_b <= "100";
    when purple_state   => play_b <= "101";
    when yellow_state   => play_b <= "110";
    when orange_state   => play_b <= "111";
    when others         => play_b <= "000";
    end case;
    
    end if;
end process DINAMIC;

STATIC: process(clk)
    
begin

    
    -- STATE 0 
    if (state = 0) then
    
    end if;
    -- STATE 1
    if (state = 0) then
--        run_a           <= '1';
    end if;
    -- STATE 2
    if (state = 0) then
    
    end if;
    -- STATE 3
    if (state = 0) then
    
    end if;
    -- STATE 4
    if (state = 0) then
    
    end if;
    -- STATE 5
    if (state = 0) then
--        run_b           <= '1';
    end if;
    -- STATE 6
    if (state = 0) then
    
    end if;
end process STATIC;
                                                          
-----------------------------------------------------------------
-- LOGIC USER CODE HERE:

flag                <= std_logic_vector(TO_UNSIGNED(state, 4));

                                                                
end Behavioral;