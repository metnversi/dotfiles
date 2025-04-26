local wezterm = require("wezterm")
local config = {}
config.colors = require("cyberdream")
config.font = wezterm.font_with_fallback({
	{ family = "Iosevka Nerd Font", weight = "Light" }, -- Thin, ExtraLight, DemiLight, Light, Book, Medium,...
	{ family = "Iosevka Nerd Font Mono", weight = "ExtraLight" },
})
config.font_size = 18
config.anti_alias_custom_block_glyphs = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = true
config.window_decorations = "INTEGRATED_BUTTONS|RESIZE"
config.native_macos_fullscreen_mode = true
config.window_padding = { top = "0.2cell" }
config.mouse_bindings = {
	-- Cmd-click will open the link under the mouse cursor
	{
		event = { Up = { streak = 1, button = "Left" } },
		mods = "SUPER",
		action = wezterm.action.OpenLinkAtMouseCursor,
	},
}
config.keys = {
	{ mods = "OPT", key = "LeftArrow", action = wezterm.action.SendKey({ mods = "ALT", key = "b" }) },
	{ mods = "OPT", key = "RightArrow", action = wezterm.action.SendKey({ mods = "ALT", key = "f" }) },
	{ mods = "CMD", key = "LeftArrow", action = wezterm.action.SendKey({ mods = "CTRL", key = "a" }) },
	{ mods = "CMD", key = "RightArrow", action = wezterm.action.SendKey({ mods = "CTRL", key = "e" }) },
	{ mods = "CMD", key = "Backspace", action = wezterm.action.SendKey({ mods = "CTRL", key = "u" }) },
}
config.background = {
	{
		source = {
			--File = "/home/rose/Pictures/e7/harshetti.png",
			File = "/home/rose/Pictures/bg.png",
		},
		hsb = { brightness = 0.030 },
	},
}
--config.default_prog = { "/usr/bin/zsh", "-l" }
config.bypass_mouse_reporting_modifiers = "SHIFT"
--config.log_level = "ERROR"
config.debug_key_events = true
config.window_background_opacity = 0.8
-- config.macos_window_background_blur = 50
config.front_end = "WebGpu"
config.audible_bell = "Disabled"
return config
