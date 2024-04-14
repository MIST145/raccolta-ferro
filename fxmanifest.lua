fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

author 'peppegnegnect46'
description 'Raccolta di ferro'
discord 'https://discord.gg/TQwnckAKzS'
version '1.0.0'

client_scripts {
    'client/client.lua'
}

shared_scripts {
    'config.lua',
    '@ox_lib/init.lua'
}

server_scripts {
    'server/server.lua'
}

dependencies {
    'ox_target',
    'ox_lib'
}