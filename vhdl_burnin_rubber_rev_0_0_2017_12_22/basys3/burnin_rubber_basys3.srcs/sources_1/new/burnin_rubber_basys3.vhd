----------------------------------------------------------------------------------
-- Company: Red~Bote
-- Engineer: Red-Bote (Glenn Neidermeier)
-- 
-- Create Date: 12/15/2024 02:55:15 PM
-- Design Name: 
-- Module Name: burnin_rubber_basys3 - struct
-- Project Name: 
-- Target Devices: Basys 3
-- Tool Versions: 
-- Description: 
--  Top level for Burning Rubber by Dar on Basys 3
-- Dependencies: 
--   vhdl_burnin_rubber_rev_0_0_2017_12_22.zip
--   https://github.com/DECAfpga/Arcade_Galaga/blob/main/mist/scandoubler.v
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
entity burnin_rubber_basys3 is
    port (
        clk : in std_logic;

        vgaRed : out std_logic_vector (3 downto 0);
        vgaGreen : out std_logic_vector (3 downto 0);
        vgaBlue : out std_logic_vector (3 downto 0);
        H_sync : out std_logic;
        V_sync : out std_logic;

        sw : in std_logic_vector (15 downto 0);

        ps2_clk : in std_logic;
        ps2_dat : in std_logic;

        O_PMODAMP2_AIN : out std_logic;
        O_PMODAMP2_GAIN : out std_logic;
        O_PMODAMP2_SHUTD : out std_logic);

end burnin_rubber_basys3;

architecture struct of burnin_rubber_basys3 is

    signal clock_12 : std_logic;
    signal reset : std_logic;
    signal clock_6 : std_logic;
    signal r : std_logic_vector(2 downto 0);
    signal g : std_logic_vector(2 downto 0);
    signal b : std_logic_vector(1 downto 0);
    signal csync : std_logic;
    signal blankn : std_logic;

    signal hsync : std_logic;
    signal vsync : std_logic;

    signal vga_r : std_logic_vector(5 downto 0);
    signal vga_g : std_logic_vector(5 downto 0);
    signal vga_b : std_logic_vector(5 downto 0);

    signal vga_r_o : std_logic_vector(5 downto 0);
    signal vga_g_o : std_logic_vector(5 downto 0);
    signal vga_b_o : std_logic_vector(5 downto 0);

    signal audio : std_logic_vector(10 downto 0);
    signal pwm_accumulator : std_logic_vector(12 downto 0);
    signal kbd_intr : std_logic;
    signal kbd_scancode : std_logic_vector(7 downto 0);
    signal joyHBCPPFRLDU : std_logic_vector(9 downto 0);

    signal dbg_cpu_addr : std_logic_vector(15 downto 0);

    component clk_wiz_0
        port (
            -- Clock out ports
            clk_out1 : out std_logic;
            clk_out2 : out std_logic;
            -- Status and control signals
            reset : in std_logic;
            locked : out std_logic;
            -- Clock in ports
            clk_in1 : in std_logic
        );
    end component;

    component scandoubler
        port (
            clk_sys : in std_logic;
            scanlines : in std_logic_vector (1 downto 0);
            ce_x1 : in std_logic;
            ce_x2 : in std_logic;
            hs_in : in std_logic;
            vs_in : in std_logic;
            r_in : in std_logic_vector (5 downto 0);
            g_in : in std_logic_vector (5 downto 0);
            b_in : in std_logic_vector (5 downto 0);
            hs_out : out std_logic;
            vs_out : out std_logic;
            r_out : out std_logic_vector (5 downto 0);
            g_out : out std_logic_vector (5 downto 0);
            b_out : out std_logic_vector (5 downto 0)
        );
    end component;

begin

    reset <= '0'; -- not reset_n;

    -- tv15Khz_mode <= '0'; -- sw();

    clocks : clk_wiz_0
    port map(
        -- Clock out ports
        clk_out1 => clock_12,
        clk_out2 => open, -- clock_6,
        -- Status and control signals
        reset => reset,
        locked => open, -- pll_locked
        -- Clock in ports
        clk_in1 => clk
    );

    -- get 6M from 12M clock
    process (reset, clock_12)
    begin
        if reset = '1' then
            clock_6 <= '0';
        else
            if rising_edge(clock_12) then
                clock_6 <= not clock_6;
            end if;
        end if;
    end process;

    -- burnin rubber
    burnin_rubber : entity work.burnin_rubber
        port map(
            clock_12 => clock_12,
            reset => reset,

            -- tv15Khz_mode => tv15Khz_mode,
            video_r => r,
            video_g => g,
            video_b => b,
            video_csync => csync,
            video_blankn => blankn,
            video_hs => hsync, -- not tested
            video_vs => vsync, -- not tested
            audio_out => audio,

            start2 => joyHBCPPFRLDU(6),
            start1 => joyHBCPPFRLDU(5),
            coin1 => joyHBCPPFRLDU(7),

            fire1 => joyHBCPPFRLDU(4),
            right1 => joyHBCPPFRLDU(3),
            left1 => joyHBCPPFRLDU(2),
            down1 => joyHBCPPFRLDU(1),
            up1 => joyHBCPPFRLDU(0),

            fire2 => joyHBCPPFRLDU(4),
            right2 => joyHBCPPFRLDU(3),
            left2 => joyHBCPPFRLDU(2),
            down2 => joyHBCPPFRLDU(1),
            up2 => joyHBCPPFRLDU(0),

            dbg_cpu_addr => dbg_cpu_addr
        );

    -- adapt video to 4bits/color only
    vga_r <= r & "000" when blankn = '1' else "000000";
    vga_g <= g & "000" when blankn = '1' else "000000";
    vga_b <= b & "0000" when blankn = '1' else "000000";

    -- synchro composite/ synchro horizontale
    --vga_hs <= csync;
    -- vga_hs <= csync when tv15Khz_mode = '1' else hsync;
    -- commutation rapide / synchro verticale
    --vga_vs <= '1';
    -- vga_vs <= '1'   when tv15Khz_mode = '1' else vsync;

    -- vga scandoubler
    scandoubler_inst : scandoubler
    port map(
        clk_sys => clock_12,
        scanlines => "01", --(00-none 01-25% 10-50% 11-75%)
        ce_x1 => clock_6,
        ce_x2 => '1',
        hs_in => hsync,
        vs_in => vsync,
        r_in => vga_r,
        g_in => vga_g,
        b_in => vga_b,
        hs_out => H_sync,
        vs_out => V_sync,
        r_out => vga_r_o,
        g_out => vga_g_o,
        b_out => vga_b_o
    );

    vgaRed <= vga_r_o(5 downto 2);
    vgaGreen <= vga_g_o(5 downto 2);
    vgaBlue <= vga_b_o(5 downto 2);

    -- get scancode from keyboard

    keyboard : entity work.io_ps2_keyboard
        port map(
            clk => clock_12, -- use same clock as main core
            kbd_clk => ps2_clk,
            kbd_dat => ps2_dat,
            interrupt => kbd_intr,
            scancode => kbd_scancode
        );

    -- translate scancode to joystick
    joystick : entity work.kbd_joystick
        port map(
            clk => clock_12, -- use same clock as main core
            kbdint => kbd_intr,
            kbdscancode => std_logic_vector(kbd_scancode),
            joyHBCPPFRLDU => joyHBCPPFRLDU,
            keys_HUA => open --keys_HUA
        );

    -- pwm sound output

    process (clock_12) -- use same clock as pooyan_sound_board
    begin
        if rising_edge(clock_12) then
            pwm_accumulator <= std_logic_vector(unsigned('0' & pwm_accumulator(11 downto 0)) + unsigned(audio & "00"));
        end if;
    end process;

    --pwm_audio_out_l <= pwm_accumulator(12);
    --pwm_audio_out_r <= pwm_accumulator(12); 

    -- active-low shutdown pin
    O_PMODAMP2_SHUTD <= sw(14);
    -- gain pin is driven high there is a 6 dB gain, low is a 12 dB gain 
    O_PMODAMP2_GAIN <= sw(15);

    O_PMODAMP2_AIN <= pwm_accumulator(12);

end struct;
