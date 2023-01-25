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
local fabrication = false
local menu = RageUI.CreateMenu('Fabrication kit', 'Action')
menu.Closed = function()
  open = false
end

function KitBenny()
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

                RageUI.Button("Fabriquer : Kit de réparation" , nil, {RightLabel = "→→"}, true , {
                    onSelected = function()
                        count = tonumber(count)
                        local playerPed = PlayerPedId()
                        fabrication = true
                        RageUI.CloseAll()
                        open = false
                        LancementCreationKit("reparation")
                     end
                 })

                 RageUI.Button("Fabriquer : Kit de nettoyage" , nil, {RightLabel = "→→"}, true , {
                    onSelected = function()
                        count = tonumber(count)
                        local playerPed = PlayerPedId()
                        fabrication = true
                        RageUI.CloseAll()
                        open = false
                        LancementCreationKit("nettoyage")
                   end
                 })

            end)
          Wait(0)
         end
      end)
   end
end

local recoltepossible = false
function CancelCreationKit()
    if recoltepossible then
        exports.rprogress:Stop()  
    	recoltepossible = false
        Wait(100)
        exports.rprogress:Stop()
        recoltepossible = false
        fabrication = false
    end
end

function LancementCreationKit(typekit)
    if not recoltepossible then
        recoltepossible = true
    while recoltepossible do     
        ExecuteCommand("e parkingmeter") 
        Citizen.Wait(100)
        exports.rprogress:Start('Fabrication en cours...', 2000)
        exports.rprogress:Stop()  
        if typekit == "reparation" then 
            TriggerServerEvent('pawal:creationkitrepa', 'fixkit', 1)
            ClearPedTasks(PlayerPedId())
           elseif typekit == "nettoyage" then
            TriggerServerEvent('pawal:creationkitnettoyage', 'nettoyagekit', 1)
            ClearPedTasks(PlayerPedId())
        end
    end
    else
        recoltepossible = false
    end
end



Citizen.CreateThread(function()
  while true do
  local wait = 750
      if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' then
        if not recoltepossible then
          for k in pairs(Config.fabricationkit) do
              local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
              local pos = Config.fabricationkit
              local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, pos[k].x, pos[k].y, pos[k].z)

              if dist <= Config.MarkerDistance and open == false then
                  wait = 0
                  if fabrication == false then
                  DrawMarker(Config.MarkerType, pos[k].x, pos[k].y, pos[k].z, 0.0, 0.0, 0.0, 0.0,0.0,0.0, Config.MarkerSizeLargeur, Config.MarkerSizeEpaisseur, Config.MarkerSizeHauteur, Config.MarkerColorR, Config.MarkerColorG, Config.MarkerColorB, Config.MarkerOpacite, Config.MarkerSaute, true, p19, Config.MarkerTourne)  
                  end
                end

              if dist <= 1.0 then
                  wait = 0
                  if fabrication == false then
                  if Config.use3Dtext == true and open == false then
                    Draw3DText(pos[k].x, pos[k].y, pos[k].z + 0.2, 0.190, '~r~[E]~s~ Ouvrir fabrication kit')
                  elseif Config.use3Dtext == false and open == false then
                  ESX.ShowHelpNotification("Appuyer sur ~INPUT_PICKUP~ pour ouvrir la fabrication kit") 
                end  
            end

                  if IsControlJustPressed(1,51) then
                    KitBenny()
                  end
              end
          end
        end
  end
  Citizen.Wait(wait)
  end
end)

Citizen.CreateThread(function()
    while true do
        if recoltepossible then
            ESX.ShowHelpNotification("Appuyer sur ~INPUT_CREATOR_LT~ pour stopper la fabrication") 
            if IsControlJustPressed(1,252) then
                CancelCreationKit()
            end
        end
      Citizen.Wait(1)
    end
  end)

         
RegisterNetEvent('pawal:utilisationkitreparation')
    AddEventHandler('pawal:utilisationkitreparation', function()
             local playerPed = PlayerPedId()
             local coords    = GetEntityCoords(playerPed)
         
             if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
                 local vehicle
         
                 if IsPedInAnyVehicle(playerPed, false) then
                     vehicle = GetVehiclePedIsIn(playerPed, false)
                 else
                     vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
                 end
         
                 if DoesEntityExist(vehicle) then
                     TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_BUM_BIN', 0, true)
                     Citizen.CreateThread(function()
                         Citizen.Wait(10000)
                         SetVehicleFixed(vehicle)
                         SetVehicleDeformationFixed(vehicle)
                         SetVehicleUndriveable(vehicle, false)
                         ClearPedTasksImmediately(playerPed)
                         ESX.ShowNotification('~g~Véhicule réparer')
               end)
         end
      end
end)

         
RegisterNetEvent('pawal:utilisationkitnettoyage')
    AddEventHandler('pawal:utilisationkitnettoyage', function()
             local playerPed = PlayerPedId()
             local coords    = GetEntityCoords(playerPed)
         
             if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, 5.0) then
                 local vehicle
         
                 if IsPedInAnyVehicle(playerPed, false) then
                     vehicle = GetVehiclePedIsIn(playerPed, false)
                 else
                     vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
                 end
         
                 if DoesEntityExist(vehicle) then
                    TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_MAID_CLEAN', 0, true)
                    Citizen.CreateThread(function()
                         Citizen.Wait(10000)
                         SetVehicleDirtLevel(vehicle, 0.0)
                         SetVehicleUndriveable(vehicle, false)
                         ClearPedTasksImmediately(playerPed)
                         ESX.ShowNotification('~g~Nettoyage terminer')
               end)
         end
      end
end)