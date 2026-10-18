fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'jvl_textui'
author 'JVL MediaCode'
description 'JVL TextUI - Interaction prompts in JVL Steel Blue (standalone, auto multi-language)'
version '2.0.0'

shared_scripts {
    'config.lua',
    'locales/*.lua',
}
client_script 'client.lua'

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/jvl-steel-blue.css',
    'web/style.css',
    'web/script.js',
    'sounds/*.ogg',
}
