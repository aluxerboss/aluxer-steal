--[[
	Create By Aluxer
	Contract : [Discord : ALUXER#9951] 
	My Discord : https://discord.gg/Yp5gYAPEEX
]]

ESX = nil
local gunbug = false

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


RegisterServerEvent('aluxer:sell') 
AddEventHandler('aluxer:sell', function()
	local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local price = math.random(16,20)
    local cime = math.random(0,100)

    if not gunbug then
        gunbug = true
        xPlayer.addMoney(price)
        Wait(500)
        gunbug = false
    end

    if cime == 60 then
        if xPlayer.canCarryItem('steel', 1) then
            xPlayer.addInventoryItem('steel', 1)
        else
            TriggerClientEvent("pNotify:SendNotification", source, {
                text = 'กระเป๋า<span class="red-text"> เต็ม!</span> ',
                type = "success",
                timeout = 2500,
                layout = "bottomCenter",
                queue = "global"
            }) 
        end
    end
end)