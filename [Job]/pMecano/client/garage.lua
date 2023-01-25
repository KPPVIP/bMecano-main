Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(10)
    end
    while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
    end
    if ESX.IsPlayerLoaded() then

		ESX.PlayerData = ESX.GetPlayerData()

    end
end)

function starts(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

-- MENU FUNCTION --
local open = false 
local menu = RageUI.CreateMenu('Garage', 'Action')
menu.Closed = function()
  open = false
end

function GarageBenny()
     if open then 
         open = false
         RageUI.Visible(menu, false)
         return
     else
         open = true 
         RageUI.Visible(menu, true)
         CreateThread(function()
         while open do 
            RageUI.IsVisible(menu,function() 
              local vehicle =  GetClosestVehicle(GetEntityCoords(PlayerPedId()),5.0, 0, 70)
              local model = GetEntityModel(vehicle)
              local displaytext = GetDisplayNameFromVehicleModel(model)
              local text = GetLabelText(displaytext)

              if DoesEntityExist(vehicle) then
              RageUI.Button("Ranger : ~g~"..text, nil, {RightLabel = ""}, true, {
                onActive = function()
                  GetCloseVehi()
                end,
                onSelected = function()
                  DeleteEntity(vehicle)
                  ESX.ShowNotification('~g~Véhicule ranger !')
                end
                })	
              else
                RageUI.Separator('~r~Aucun véhicule à proximité')
              end
              RageUI.line(255,255,255,255)

                for k, v in pairs(Config.GarageVehicle) do
                RageUI.Button("Faire spawn un/une : "..v.Label, nil, {RightLabel = ""}, true, {
                onSelected = function()
                    if not ESX.Game.IsSpawnPointClear(vector3(v.spawnzone.x, v.spawnzone.y, v.spawnzone.z), 10.0) then
                        ESX.ShowNotification("~r~Point de spawn des véhicules trop encombrer !")
                        else
                        local model = GetHashKey(v.Spawnname)
                        RequestModel(model)
                        while not HasModelLoaded(model) do Wait(10) end
                        local vehiclebenny = CreateVehicle(model, v.spawnzone.x, v.spawnzone.y, v.spawnzone.z, v.headingspawn, true, false)
                        SetVehicleFixed(vehiclebenny)
                        SetVehicleDirtLevel(vehiclebenny, 0.0)
                        SetVehicleFuelLevel(vehiclebenny, 100.0)
                        SetVehRadioStation(vehiclebenny, 0)
                        ESX.ShowNotification('Vous venez de sortir un/une ~g~ '..GetLabelText(v.Spawnname))
                        RageUI.CloseAll()
                        open = false
                        end
                end
                })	
            end
            end)
          Wait(0)
         end
      end)
   end
end

Citizen.CreateThread(function()
  while true do
  local wait = 750
      if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' then
          for k in pairs(Config.garage) do
              local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
              local pos = Config.garage
              local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, pos[k].x, pos[k].y, pos[k].z)

              if dist <= Config.MarkerDistance and open == false then
                  wait = 0
                  if Config.use3Dtext == false then
                  DrawMarker(Config.MarkerType, pos[k].x, pos[k].y, pos[k].z, 0.0, 0.0, 0.0, 0.0,0.0,0.0, Config.MarkerSizeLargeur, Config.MarkerSizeEpaisseur, Config.MarkerSizeHauteur, Config.MarkerColorR, Config.MarkerColorG, Config.MarkerColorB, Config.MarkerOpacite, Config.MarkerSaute, true, p19, Config.MarkerTourne)  
                  end
                end

              if dist <= 1.0 then
                  wait = 0
                if Config.use3Dtext == false and open == false then
                  ESX.ShowHelpNotification("Appuyer sur ~INPUT_PICKUP~ pour ouvrir le garage") 
                end

                  if IsControlJustPressed(1,51) then
                    GarageBenny()
                  end
              end
          end
  end
  Citizen.Wait(wait)
  end
end)

local npc = {
	{hash="ig_benny", x = -200.76077270508, y = -1309.5847167969, z = 31.234971466064, a = 3.32451009750366},
}

Citizen.CreateThread(function()
	for _, garagebenny in pairs(npc) do
		local hash = GetHashKey(garagebenny.hash)
		while not HasModelLoaded(hash) do
		RequestModel(hash)
		Wait(20)
		end
		ped2 = CreatePed("PED_TYPE_CIVFEMALE", garagebenny.hash, garagebenny.x, garagebenny.y, garagebenny.z-0.92, garagebenny.a, false, true)
        TaskStartScenarioInPlace(ped2, 'WORLD_HUMAN_CLIPBOARD', 0, true)
		SetBlockingOfNonTemporaryEvents(ped2, true)
		FreezeEntityPosition(ped2, true)
		SetEntityInvincible(ped2, true)
        while true do
        if Config.use3Dtext == true and open == false then
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, garagebenny.x, garagebenny.y, garagebenny.z)
            if dist <= 1.0 then
            Draw3DText(garagebenny.x, garagebenny.y, garagebenny.z + 1.2, 0.290, '~r~[E]~s~ Ouvrir le garage')
            end
        end
        Citizen.Wait(1)
    end
	end
 end)  