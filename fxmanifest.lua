fx_version 'adamant'
game 'gta5'

description 'Menu Personel fait par Allooww'

server_scripts {
    "server/main.lua",
}

client_scripts {
    "src/RMenu.lua",
    "src/menu/RageUI.lua",
    "src/menu/Menu.lua",
    "src/menu/MenuController.lua",
    "src/components/*.lua",
    "src/menu/elements/*.lua",
    "src/menu/items/*.lua",
    "src/menu/panels/*.lua",
    "src/menu/panels/*.lua",
    "src/menu/windows/*.lua",
}

client_scripts {
	'@es_extended/locale.lua',
	'client/main.lua',
	'config.lua',
}

-- Ⓒ Allooww | Si vous avez des questions : https://discord.gg/WAQbzUJQU8