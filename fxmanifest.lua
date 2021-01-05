--[[
	Create By Aluxer
	Contract : [Discord : ALUXER#9951] 
	My Discord : https://discord.gg/Yp5gYAPEEX
]]

fx_version 'adamant'

game 'gta5'

description 'Aluxer Steal Job'

version '1.0.0'

client_scripts {
    "config.lua",
    "client.lua"
}

server_scripts {
    "@mysql-async/lib/MySQL.lua",
    "config.lua",
    "server.lua"
}