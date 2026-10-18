--[[
    JVL TextUI - configuration
    Interaction prompts ("[E] Open the garage") in JVL Steel Blue.
    API modeled on ox_lib's lib.showTextUI. Standalone: no framework and no other resource required.
]]

Config = {}

-- ══════════════════════════════════════════════════════════════════
-- 1. LANGUAGE
-- ══════════════════════════════════════════════════════════════════
-- 'auto' = the language each player has in GTA V (Settings > Language).
-- Or force one: 'es' | 'en' | 'fr' | 'de' | 'pt'
Config.Locale = 'auto'
Config.FallbackLocale = 'en' -- Used when the player's language has no file in locales/

-- ══════════════════════════════════════════════════════════════════
-- 2. POSITION
-- ══════════════════════════════════════════════════════════════════
-- 'left-center' | 'right-center' | 'top-center' | 'bottom-center'
-- 'top-left' | 'top-right' | 'bottom-left' | 'bottom-right' | 'center'
Config.DefaultPosition = 'left-center'
Config.PlayersCanMove = true -- /textui position <name> saves a personal position per player

Config.Margins = {
    side = 24,   -- px from the left / right edge
    top = 4,     -- % from the top edge
    bottom = 6,  -- % from the bottom edge
}

-- ══════════════════════════════════════════════════════════════════
-- 3. LOOK (JVL Steel Blue; change only if you need another accent)
-- ══════════════════════════════════════════════════════════════════
Config.Style = {
    background = 'translucent', -- 'translucent' (see-through to the right) | 'solid'
    accent = '#38bdf8',         -- Left bar, icon and glow
    accentBar = true,           -- Colored bar on the left edge
    lightLine = true,           -- Steel light line on the top edge
    glow = true,                -- Blue glow under the card
    borderWidth = 2,            -- px
    radius = 11,                -- px
    minWidth = 180,             -- px
    maxWidth = 420,             -- px
    padding = { 10, 16, 10, 10 }, -- px: top, right, bottom, left
    font = 'Poppins',
    fontSize = 13.5,            -- px
    fontWeight = 500,
    textColor = '#eef3f9',
    uppercase = false,
}

-- Keys written as [E], [H], [ALT]... are drawn as key caps.
Config.KeyCaps = {
    enabled = true,
    style = 'silver', -- 'silver' (JVL default) | 'blue' | 'outline'
}

Config.Icon = {
    enabled = true,
    default = 'fa-solid fa-hand-pointer', -- Font Awesome class used when the caller sends none
    size = 32,                            -- px box
    color = nil,                          -- nil = accent color
    animation = nil,                      -- nil | 'spin' | 'beat' | 'fade' | 'bounce' | 'shake' | 'beatFade'
}

Config.Animation = {
    type = 'slide',  -- 'slide' | 'fade' | 'scale' | 'none'
    duration = 220,  -- ms
}

-- ══════════════════════════════════════════════════════════════════
-- 4. BEHAVIOUR
-- ══════════════════════════════════════════════════════════════════
-- The same text shown again while it is visible is ignored (no sound / animation spam in zones).
Config.PreventRepeat = true

Config.Sounds = {
    enabled = true,
    volume = 0.35,      -- 0.0 - 1.0
    show = 'show.ogg',  -- sounds/ folder (false = no sound)
    hide = 'hide.ogg',
    cooldown = 300,     -- ms between sounds
}

-- /textui test | hide | position <name> | lang
Config.Command = 'textui'
