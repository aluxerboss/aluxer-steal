--[[
	Create By Aluxer
	Contract : [Discord : ALUXER#9951] 
	My Discord : https://discord.gg/Yp5gYAPEEX
]]

local hasAlreadyEnteredMarker, currentActionData = false, {}
local lastZone, currentAction, currentActionMsg

local IsPickingUp = false
local pick = false

ESX = nil

local PlayerData = {}
local clothjob = false
local buggy = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	Citizen.Wait(5000)
	PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
	Citizen.Wait(5000)
end)


AddEventHandler('aluxer-steal:hasEnteredMarker', function(zone)
	currentAction     = 'aluxer-steal'
	currentActionMsg  = 'press ~INPUT_CONTEXT~ to open ~y~Steal Job'
	currentActionData = {}
end)

AddEventHandler('aluxer-steal:hasExitedMarker', function(zone)
	ESX.UI.Menu.CloseAll()
	currentAction = nil
end)

function ClothSteal()
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'cloth_confirm',
		{
			title = 'เปลี่ยนชุดทำงาน',
			align = 'top-left',
			elements = {
				{label = 'ชุดทำงาน', value = 'clothejob'},
				{label = 'ใส่ชุดปกติ', value = 'recloth'}
			}
		}, function(data, menu)
			menu.close()

			if data.current.value == 'clothejob' then
				if not clothjob then
					if ESX.PlayerData.job.name == 'unemployed' then
						clothjob = true
						TriggerEvent('aluxer:job',true)
						TriggerEvent('skinchanger:getSkin', function(skin)
							local playerPed = PlayerPedId()
							local lib_un, anim_un = 'mp_safehouseshower@male@', 'male_shower_undress_&_turn_on_water' 
							ESX.Streaming.RequestAnimDict(lib_un, function()
								local co = GetEntityCoords(playerPed)
								local he = GetEntityHeading(playerPed)
							
								TaskPlayAnimAdvanced(playerPed, lib_un, anim_un, co.x, co.y, co.z, 0, 0, he, 8.0, 1.0, -1, 0, 0.4, 0, 0)
								Citizen.Wait(1000)
								ClearPedTasks(playerPed)

								if skin.sex == 0 then
									local clothesSkin = {
										['tshirt_1'] = 59, ['tshirt_2'] = 1,
										['torso_1'] = 56, ['torso_2'] = 0,
										['arms'] = 52, ['arms_2'] = 0,
										['pants_1'] = 36, ['pants_2'] = 0,
										['helmet_1'] = 0,  ['helmet_2'] = 0,
										['shoes_1'] = 27, ['shoes_2'] = 0
										}
									TriggerEvent('skinchanger:loadClothes', skin, clothesSkin)
								else
									local clothesSkin = {
										['tshirt_1'] = 36, ['tshirt_2'] = 1,
										['torso_1'] = 49, ['torso_2'] = 0,
										['arms'] = 46, ['arms_2'] = 0,
										['pants_1'] = 35, ['pants_2'] = 0,
										['helmet_1'] = 0,  ['helmet_2'] = 0,
										['shoes_1'] = 52, ['shoes_2'] = 0
										}
									TriggerEvent('skinchanger:loadClothes', skin, clothesSkin)
								end
							end)
						end)
					else
						TriggerEvent("pNotify:SendNotification", {
							text = 'คุณทำ<strong class="red-text"> อาชีพที่ดี </strong>อยู่แล้ว',
							type = "error",
							timeout = 3000,
							layout = "bottomCenter",
							queue = "global"
						})
					end
				else
					TriggerEvent("pNotify:SendNotification", {
						text = 'คุณ<strong class="red-text"> ใส่ชุดทำงาน </strong>อยู่แล้ว',
						type = "error",
						timeout = 3000,
						layout = "bottomCenter",
						queue = "global"
					})
				end
			elseif data.current.value == 'recloth' then
				if clothjob then
					clothjob = false
					TriggerEvent('aluxer:job',false)
					ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
						local playerPed = PlayerPedId()
						local lib, anim = 'mp_safehouseshower@male@', 'male_shower_towel_dry_to_get_dressed'
							ESX.Streaming.RequestAnimDict(lib, function()
								local co = GetEntityCoords(playerPed)
								local he = GetEntityHeading(playerPed)

								TaskPlayAnimAdvanced(playerPed, lib, anim, co.x, co.y, co.z, 0, 0, he, 8.0, 1.0, -1, 0, 0.5, 0, 0)

								Citizen.Wait(2000)
								ClearPedTasks(playerPed)
							end)
						TriggerEvent('skinchanger:loadSkin', skin)
					end)
				else
					TriggerEvent("pNotify:SendNotification", {
                        text = 'คุณ<strong class="red-text"> ไม่ได้ใส่ชุดทำงาน </strong>',
                        type = "error",
                        timeout = 3000,
                        layout = "bottomCenter",
                        queue = "global"
                    })
				end
			end

			currentAction     = 'aluxer-steal'
			currentActionMsg  = 'press ~INPUT_CONTEXT~ to open ~y~Steal Job'
			currentActionData = {}
		end, function(data, menu)
			menu.close()
			currentAction     = 'aluxer-steal'
			currentActionMsg  = 'press ~INPUT_CONTEXT~ to open ~y~Steal Job'
			currentActionData = {}
		end)
end

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerCoords, isInMarker, currentZone, letSleep = GetEntityCoords(PlayerPedId()), false, nil, true

		for k,v in pairs(Config.Steal) do
			local distance = #(playerCoords - v)

			if distance < Config.DrawDistance then
				letSleep = false
				DrawMarker(Config.MarkerType, v, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, nil, nil, false)

				if distance < Config.MarkerSize.x then
					isInMarker, currentZone = true, k
				end
			end
		end

		if (isInMarker and not hasAlreadyEnteredMarker) or (isInMarker and lastZone ~= currentZone) then
			hasAlreadyEnteredMarker, lastZone = true, currentZone
			TriggerEvent('aluxer-steal:hasEnteredMarker', currentZone)
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('aluxer-steal:hasExitedMarker', lastZone)
		end

		if letSleep then
			Citizen.Wait(500)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if currentAction ~= nil then
			ESX.ShowHelpNotification(currentActionMsg)

			if IsControlJustReleased(0, 38) then
				if currentAction == 'aluxer-steal' then
					ClothSteal()
				end
				currentAction = nil
			end
		else
			Citizen.Wait(500)
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local letSleep = true
		
		if clothjob then
			letSleep = false
			if buggy then
				DisableControlAction(0,38,true)
			end
		else
			Citizen.Wait(500)
		end

		if letSleep then
		 Citizen.Wait(500)
		end
	end
end)

---เทรด อาชีพ
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)

		for k, v in pairs(Config.StealIn) do
			for i=1, #v.Pos, 1 do
				if GetDistanceBetweenCoords(coords, v.Pos[i], true) < 1.2 then
					nearbyID = true
				else
					nearbyID = false
				end
			end
		end

		if nearbyID and clothjob and IsPedOnFoot(playerPed) then

			if not IsPickingUp then
				ESX.ShowHelpNotification("press ~INPUT_CONTEXT~ to ~y~search~s~")
			end

			if IsControlJustReleased(0, 38) and not IsPickingUp then
				buggy = true
			if buggy then
				TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)
					exports['mythic_progbar']:Progress({
						name = "unique_action_name",
						duration = 2000,
						label = 'Doing Something',
						useWhileDead = true,
						canCancel = true,
						controlDisables = {
							disableMovement = true,
							disableCarMovement = true,
							disableMouse = false,
							disableCombat = true,
						},
					}, function(cancelled)
						if not cancelled then
							ClearPedTasks(playerPed)
							Wait(200)
							TriggerEvent('aluxer:putsteal')
							pick = true
							buggy = false
						else
							ClearPedTasks(playerPed)
							buggy = false
						end
					end)
				end
			end

		else
			Citizen.Wait(500)
		end
	end
end)

RegisterNetEvent('aluxer:putsteal')
AddEventHandler('aluxer:putsteal',function(source)
	IsPickingUp = true
	local ad = "anim@heists@box_carry@"
	loadAnimDict(ad)
	TaskPlayAnim(PlayerPedId(), ad, "idle", 3.0, -8, -1, 63, 0, 0, 0, 0)
	local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
	local szn = math.random(1,3)
	if szn == 1 then
		bagModel = 'prop_car_door_01'
		bagspawned = CreateObject(GetHashKey(bagModel), x, y, z+0.2,  true,  true, true)
		AttachEntityToEntity(bagspawned, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 60309), 0.025, 0.00, 0.355, -75.0, 470.0, 0.0, true, true, false, true, 1, true)
		Citizen.Wait(10000)
	elseif szn == 2 then
		bagModel = 'prop_car_seat'
		bagspawned = CreateObject(GetHashKey(bagModel), x, y, z+0.2,  true,  true, true)
		AttachEntityToEntity(bagspawned, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 60309), 0.025, 0.00, 0.355, -045.0, 480.0, 0.0, true, true, false, true, 1, true)
		Citizen.Wait(10000)
	else	
		bagModel = 'prop_rub_tyre_01'
		bagspawned = CreateObject(GetHashKey(bagModel), x, y, z,  true,  true, true)
		AttachEntityToEntity(bagspawned, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 60309), 0.025, 0.11, 0.255, -145.0, 290.0, 0.0, true, true, false, true, 1, true)
		Citizen.Wait(10000)
	end
end)

RegisterNetEvent('aluxer:sendsteal')
AddEventHandler('aluxer:sendsteal', function()
	DetachEntity(bagspawned, 1, 1)
	DeleteObject(bagspawned)
	IsPickingUp = false
	ClearPedSecondaryTask(PlayerPedId())
	FreezeEntityPosition(PlayerPedId(), false)
	TriggerServerEvent('aluxer:sell')
	pick = false
end)

function loadAnimDict(dict)
	while (not HasAnimDictLoaded(dict)) do
		RequestAnimDict(dict)
		Citizen.Wait(5)
	end
end

-- thread ส่งของ
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)

		if GetDistanceBetweenCoords(coords, -419.63, -1674.8, 19.02, true) < 2.5 then
			nearbyID = true
		else
			nearbyID = false
		end


		if nearbyID and clothjob and IsPedOnFoot(playerPed) then

			if pick then
				ESX.ShowHelpNotification("press ~INPUT_CONTEXT~ to ~y~packing~s~")
			end

			if IsControlJustReleased(0, 38) and pick then
				exports['mythic_progbar']:Progress({
					name = "unique_action_name",
					duration = 2000,
					label = 'Packing',
					useWhileDead = true,
					canCancel = false,
					controlDisables = {
						disableMovement = true,
						disableCarMovement = true,
						disableMouse = false,
						disableCombat = true,
					},
				}, function(cancelled)
					if not cancelled then
						TriggerEvent('aluxer:sendsteal')
					else

					end
				end)
			end

		else
			Citizen.Wait(500)
		end
	end
end)

function CreateBlipCircle(coords, text, radius, color, sprite)
	local blip = AddBlipForRadius(coords, radius)

	SetBlipHighDetail(blip, true)
	SetBlipColour(blip, 1)
	SetBlipAlpha (blip, 128)


	blip = AddBlipForCoord(coords)

	SetBlipHighDetail(blip, true)
	SetBlipSprite (blip, sprite)
	SetBlipScale  (blip, 0.6)
	SetBlipColour (blip, color)
	SetBlipAsShortRange(blip, true)

	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(text)
	EndTextCommandSetBlipName(blip)
end

Citizen.CreateThread(function()
	for k,zone in pairs(Config.CircleZones) do
		CreateBlipCircle(zone.coords, zone.name, zone.radius, zone.color, zone.sprite)
	end
end)

Citizen.CreateThread(function()
	local model = 's_m_m_dockwork_01'
	RequestModel(GetHashKey(model))
	while not HasModelLoaded(GetHashKey(model)) do
		Wait(155)
	end

	local ped =  CreatePed(4, GetHashKey(model), -428.53, -1728.24, 18.79, 69.5, false, true)
	TaskStartScenarioInPlace(ped, 'CODE_HUMAN_CROSS_ROAD_WAIT', 0, true)
	FreezeEntityPosition(ped, true)
	SetEntityInvincible(ped, true)
	SetBlockingOfNonTemporaryEvents(ped, true)
end)