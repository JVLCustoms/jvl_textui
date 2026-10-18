--[[
    JVL TextUI - client
    exports.jvl_textui:Show(text, options)   options = { position, icon, iconColor, iconAnimation, duration }
    exports.jvl_textui:Hide()
    exports.jvl_textui:IsOpen()              -> boolean, text
    exports.jvl_textui:GetLocale()           -> 'es' | 'en' | ...

    `text` can be a string or a table of translations: { es = '[E] Abrir', en = '[E] Open' }.
    The one matching the player's language is shown (Config.Locale = 'auto').
]]

local isOpen, currentText = false, nil
local showId = 0 -- increases on every show, cancels old auto-hide timers

local positions = {
    ['left-center'] = true, ['right-center'] = true, ['top-center'] = true, ['bottom-center'] = true,
    ['top-left'] = true, ['top-right'] = true, ['bottom-left'] = true, ['bottom-right'] = true, ['center'] = true,
}

-- ---------------------------------------------------------------------
-- Language (GTA V language of the player -> locales/<code>.lua)
-- ---------------------------------------------------------------------

-- GetCurrentLanguage(): 0 en, 1 fr, 2 de, 3 it, 4 es, 5 pt-BR, 6 pl, 7 ru, 8 ko, 9 zh-TW, 10 ja, 11 es-MX, 12 zh-CN
local gameLanguages = { [0] = 'en', 'fr', 'de', 'it', 'es', 'pt', 'pl', 'ru', 'ko', 'zh', 'ja', 'es', 'zh' }

local function detectLocale()
    local wanted = Config.Locale
    if wanted == 'auto' then wanted = gameLanguages[GetCurrentLanguage()] or Config.FallbackLocale end
    if Locales[wanted] then return wanted end
    return Locales[Config.FallbackLocale] and Config.FallbackLocale or 'en'
end

local locale = detectLocale()

local function L(key, ...)
    local text = (Locales[locale] and Locales[locale][key]) or (Locales.en and Locales.en[key]) or key
    if select('#', ...) > 0 then return text:format(...) end
    return text
end

--- Picks the right translation when the caller sends a table of texts.
local function translate(text)
    if type(text) ~= 'table' then return text end
    return text[locale] or text[Config.FallbackLocale] or text.en or select(2, next(text))
end

-- ---------------------------------------------------------------------
-- NUI setup (style from config.lua as CSS variables)
-- ---------------------------------------------------------------------

local position = GetResourceKvpString('position')
if not Config.PlayersCanMove or not positions[position or ''] then position = Config.DefaultPosition end

local nuiReady = false

local function sendSetup()
    SendNUIMessage({
        action = 'setup',
        style = Config.Style,
        margins = Config.Margins,
        keyCaps = Config.KeyCaps,
        icon = Config.Icon,
        animation = Config.Animation,
    })
    nuiReady = true
end

CreateThread(function()
    Wait(500) -- let the NUI page load
    sendSetup()
end)

local function sound(kind)
    local s = Config.Sounds
    if not s.enabled or not s[kind] then return nil end
    return { file = s[kind], volume = s.volume, cooldown = s.cooldown }
end

-- ---------------------------------------------------------------------
-- Show / hide
-- ---------------------------------------------------------------------

local function hide()
    if not isOpen then return end
    isOpen, currentText = false, nil
    showId = showId + 1
    SendNUIMessage({ action = 'hide', sound = sound('hide') })
end

---@param text string|table Text, or { es = '...', en = '...' }
---@param options? table { position, icon, iconColor, iconAnimation, duration } or a duration in ms
local function show(text, options)
    text = translate(text)
    if type(text) ~= 'string' or text == '' then return end
    if type(options) == 'number' then options = { duration = options } end
    options = type(options) == 'table' and options or {}
    if not nuiReady then sendSetup() end

    if Config.PreventRepeat and isOpen and text == currentText then return end
    local wasOpen = isOpen
    isOpen, currentText = true, text
    showId = showId + 1
    local id = showId

    local icon = false
    if Config.Icon.enabled then
        icon = options.icon
        if icon == nil then icon = Config.Icon.default end
    end

    SendNUIMessage({
        action = 'show',
        text = text,
        icon = icon or false,
        iconColor = options.iconColor or Config.Icon.color,
        iconAnimation = options.iconAnimation or Config.Icon.animation,
        position = positions[options.position or ''] and options.position or position,
        sound = not wasOpen and sound('show') or nil,
    })

    local duration = tonumber(options.duration)
    if duration and duration > 0 then
        SetTimeout(duration, function()
            if showId == id then hide() end
        end)
    end
end

local function setPosition(name)
    if not positions[name or ''] then return false end
    position = name
    SetResourceKvp('position', name)
    if isOpen then SendNUIMessage({ action = 'position', position = name }) end
    return name
end

exports('Show', show)
exports('Hide', hide)
exports('IsOpen', function() return isOpen, currentText end)
exports('GetLocale', function() return locale end)
-- ox_lib style names
exports('showTextUI', show)
exports('hideTextUI', hide)
exports('isTextUIOpen', function() return isOpen, currentText end)

RegisterNetEvent('jvl_textui:show', show) -- also usable from the server
RegisterNetEvent('jvl_textui:hide', hide)

-- ---------------------------------------------------------------------
-- Command
-- ---------------------------------------------------------------------

RegisterCommand(Config.Command, function(_, args)
    local action = args[1]
    if action == 'test' then
        show(L('test'), { duration = 5000 })
    elseif action == 'hide' then
        hide()
    elseif action == 'lang' then
        print(L('language', locale))
    elseif action == 'position' then
        if not Config.PlayersCanMove then return print(L('position_locked')) end
        local name = setPosition(args[2])
        print(name and L('position_changed', name) or L('invalid', tostring(args[2])))
        if name then
            hide()
            show(L('test'), { duration = 3000 })
        end
    else
        print(L('usage'))
    end
end, false)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then isOpen = false end
end)
