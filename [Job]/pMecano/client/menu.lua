ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

function LoadAnimDict(dict)
	if not HasAnimDictLoaded(dict) then
		RequestAnimDict(dict)

		while not HasAnimDictLoaded(dict) do
			Citizen.Wait(1)
		end
	end
end

local PlayerData = {}
local NPCOnJob = false

local performanceactivation = true
local diagnostiqueactivation = true

local vehicles = {}
local selectVeh = nil
local vehProps = nil

local fait = false
local faitt = false
local encours = true

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

local statsVeh = {{
    mod = 'modEngine',
    label = "Moteur"
}, {
    mod = 'modTransmission',
    label = "Transmission"
}, {
    mod = 'modBrakes',
    label = "Frein"
}, {
    mod = 'modSuspension',
    label = "Suspension"
}}

local AnnonceList = {
    "~g~Ouverture~s~",
    "~r~Fermeture~s~",
    "~b~Personnaliser~s~"
}

local AnnonceListIndex = 1

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)  
	PlayerData.job = job  
	Citizen.Wait(5000) 
end)

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

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)


RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)


function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    blockinput = true
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
        Wait(0)
    end 
        
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        blockinput = false
        return result
    else
        Wait(500)
        blockinput = false
        return nil
    end
end

----------------------------------------------------------------------
-----------------------------Mission Code-----------------------------
----------------------------------------------------------------------
local NPCOnJob = false
local CurrentlyTowedVehicle, Blips, NPCOnJob, NPCTargetTowable, NPCTargetTowableZone = nil, {}, false, nil, nil
function StartNPCJob()
	NPCOnJob = true

	NPCTargetTowableZone = SelectRandomTowable()
	local zone       = Config.Zones[NPCTargetTowableZone]

	Blips['NPCTargetTowableZone'] = AddBlipForCoord(zone.Pos.x,  zone.Pos.y,  zone.Pos.z)
	SetBlipRoute(Blips['NPCTargetTowableZone'], true)

    ESX.ShowAdvancedNotification('Benny\'s Motor Works', '~y~Notification',"Rendez-vous à la ~y~position GPS~s~ afin de ~y~dépanner le véhicule~s~", 'CHAR_CARSITE3', 1)
end

function SelectRandomTowable()
	local index = GetRandomIntInRange(1,  #Config.Towables)

	for k,v in pairs(Config.Zones) do
		if v.Pos.x == Config.Towables[index].x and v.Pos.y == Config.Towables[index].y and v.Pos.z == Config.Towables[index].z then
			return k
		end
	end
end

function StopNPCJob(cancel)
	if Blips['NPCTargetTowableZone'] then
		RemoveBlip(Blips['NPCTargetTowableZone'])
		Blips['NPCTargetTowableZone'] = nil
	end

	if Blips['NPCDelivery'] then
		RemoveBlip(Blips['NPCDelivery'])
		Blips['NPCDelivery'] = nil
	end

	Config.Zones.VehicleDelivery.Type = -1

	NPCOnJob                = false
	NPCTargetTowable        = nil
	NPCTargetTowableZone    = nil
	NPCHasSpawnedTowable    = false
	NPCHasBeenNextToTowable = false

	if cancel then
        ESX.ShowAdvancedNotification('Benny\'s Motor Works', '~y~Notification',"~r~Vous venez de stopper la mission !", 'CHAR_CARSITE3', 1)
	else
		--TriggerServerEvent('esx_mechanicjob:onNPCJobCompleted')
	end
end

AddEventHandler('pawal:markeractivation', function(zone, station, part, partNum)
	if zone == 'NPCJobTargetTowable' then

	elseif zone =='VehicleDelivery' then
		NPCTargetDeleterZone = true
    end
end)

AddEventHandler('pawal:markerdesactivation', function(zone, station, part, partNum)
	if zone =='VehicleDelivery' then
		NPCTargetDeleterZone = false
    end
	CurrentAction = nil
end)


                

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)

		if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' then

			local coords      = GetEntityCoords(PlayerPedId())
			local isInMarker  = false
			local currentZone = nil

			for k,v in pairs(Config.Zones) do
				if(GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x) then
					isInMarker  = true
					currentZone = k
				end
			end

			if (isInMarker and not HasAlreadyEnteredMarker) or (isInMarker and LastZone ~= currentZone) then
				HasAlreadyEnteredMarker = true
				LastZone                = currentZone
				TriggerEvent('pawal:markeractivation', currentZone)
			end

			if not isInMarker and HasAlreadyEnteredMarker then
				HasAlreadyEnteredMarker = false
				TriggerEvent('pawal:markerdesactivation', LastZone)
			end

		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)

		if NPCTargetTowableZone and not NPCHasSpawnedTowable then
			local coords = GetEntityCoords(PlayerPedId())
			local zone   = Config.Zones[NPCTargetTowableZone]

			if GetDistanceBetweenCoords(coords, zone.Pos.x, zone.Pos.y, zone.Pos.z, true) < Config.NPCSpawnDistance then
				local model = Config.Vehicles[GetRandomIntInRange(1,  #Config.Vehicles)]

				ESX.Game.SpawnVehicle(model, zone.Pos, 0, function(vehicle)
					NPCTargetTowable = vehicle
                    SetVehicleEngineHealth(vehicle, 300)
				end)

				NPCHasSpawnedTowable = true
			end
		end

		if NPCTargetTowableZone and NPCHasSpawnedTowable and not NPCHasBeenNextToTowable then
			local coords = GetEntityCoords(PlayerPedId())
			local zone   = Config.Zones[NPCTargetTowableZone]

			if GetDistanceBetweenCoords(coords, zone.Pos.x, zone.Pos.y, zone.Pos.z, true) < Config.NPCNextToDistance then
                ESX.ShowAdvancedNotification('Benny\'s Motor Works', '~y~Notification',"Veuillez ~y~remorquer~s~ le véhicule", 'CHAR_CARSITE3', 1)
				NPCHasBeenNextToTowable = true
			end
		end
	end
end)

-------------------------------------------------------------------
-----------------------------Menu Code-----------------------------
-------------------------------------------------------------------
 
 local mainMenu = RageUI.CreateMenu("Benny's", "Action") 
 local MenuVehicule = RageUI.CreateSubMenu(mainMenu, "Benny's", "Action") 
 local MenuDiagnostique = RageUI.CreateSubMenu(mainMenu, "Benny's", "Action") 
 local communication = RageUI.CreateSubMenu(mainMenu, "Benny's", "Action")
 local performance = RageUI.CreateSubMenu(MenuDiagnostique, "Benny's", "Action")
 local diagnostique = RageUI.CreateSubMenu(MenuDiagnostique, "Benny's", "Action")

 local autorisation = false
 local open = false
 
 mainMenu.X = 0 
 mainMenu.Y = 0
 
 mainMenu.Closed = function() 
     open = false 
 end 

performance.Closed = function() 
    local playerPed = PlayerPedId()
    local coords    = GetEntityCoords(playerPed)
    local tablette = GetClosestObjectOfType(coords.x, coords.y, coords.z, 1.0, GetHashKey("prop_cs_tablet"), false)
    ClearPedTasks(playerPed)
    DeleteObject(tablette)    
end 
 
diagnostique.Closed = function() 
    local playerPed = PlayerPedId()
    local coords    = GetEntityCoords(playerPed)
    local tablette = GetClosestObjectOfType(coords.x, coords.y, coords.z, 1.0, GetHashKey("prop_cs_tablet"), false)
    ClearPedTasks(playerPed)
    DeleteObject(tablette)    
end 

 function menumechanic()
     if open then 
         open = false 
             RageUI.Visible(mainMenu, false) 
             return 
     else 
         open = true 
         local fait = false
             RageUI.Visible(mainMenu, true)
         Citizen.CreateThread(function()
             while open do 
                if RageUI.Visible(performance) or RageUI.Visible(diagnostique) or RageUI.Visible(MenuDiagnostique) then
                    if GetClosestVehicle(GetEntityCoords(PlayerPedId()),3.0, 0, 70) <= 4.0 then
                    ESX.ShowNotification('~r~Vous êtes trop loin du véhicule')
                    RageUI.Visible(mainMenu, true)
                end
            end
                 RageUI.IsVisible(mainMenu, function()
                    RageUI.Checkbox("Prendre son service Mécano", nil, serviceMecano, {}, {
                        onChecked = function(index, items)
                            serviceMecano = true
                            TriggerServerEvent('benny:prisedeservice')
                            TriggerServerEvent('pawal:PriseService', ESX.PlayerData.job.grade_label)
                            ESX.ShowAdvancedNotification('Benny\'s Motor Works', '~y~Notification', "~g~Vous avez pris votre service", 'CHAR_CARSITE3', 1)
                        end,
                        onUnChecked = function(index, items)
                            serviceMecano = false
                            if NPCOnJob == true then
                                StopNPCJob()
                            end
                            TriggerServerEvent('benny:prisedeservice')
                            TriggerServerEvent('pawal:FinService', ESX.PlayerData.job.grade_label)
                            ESX.ShowAdvancedNotification('Benny\'s Motor Works', '~y~Notification', "~r~Vous avez quitter votre service", 'CHAR_CARSITE3', 1)
                        end
                    })

                 if serviceMecano then
                         
                    local vehiclemission = GetVehiclePedIsIn(PlayerPedId(), false)
                    local model = GetEntityModel(vehiclemission)
                    local displaytext = GetDisplayNameFromVehicleModel(model)
            
                    if displaytext == "FLATBED" then
                       autorisation = true 
                       message = nil
                    else
                       autorisation = false 
                       message = "~r~Bloquer\n~s~Vous devez être à bord d'une Dépanneuse à plateau pour commencer une mission"
                    end

                    RageUI.line(255,255,255,255)

                    if Config.MissionPnj and NPCOnJob == true then
                        RageUI.Separator("En Mission : ~g~Oui~s~")
                        RageUI.Separator("Objectif : ~y~"..objectif.."~s~")
                        RageUI.line(255,255,255,255)
                        elseif Config.MissionPnj and NPCOnJob == false then
                        RageUI.Separator("En Mission : ~r~Non~s~")
                        RageUI.line(255,255,255,255)
                    end

                    RageUI.Button("Communication", nil, {RightLabel = "→→"}, true, {
                        onSelected = function()
                        end
                        }, communication)  

                       RageUI.Button("Intéraction Véhicule", nil, {RightLabel = "→→"}, true, {
                        onSelected = function()
                        end
                       }, MenuVehicule)

                if Config.MissionPnj == true then
                    if NPCOnJob == false then
                       RageUI.Button("Commencer une mission", message, {RightLabel = "→→"}, autorisation, {
                        onSelected = function()
                            NPCOnJob = true
                            objectif = "Récupérer le véhicule"
                            StartNPCJob()
                        end
                       })
                    elseif NPCOnJob == true then
                        RageUI.Button("Annuler la mission", nil, {RightLabel = "→→"}, true, {
                            onSelected = function()
                                NPCOnJob = false
                                StopNPCJob(true)
                            end
                        })
                    end
                end

                       if  GetClosestVehicle(GetEntityCoords(PlayerPedId()),3.0, 0, 70) <= 4.0 then
                        activation = false
                        messagediagno = "~r~Bloquer\n~s~Aucun véhicule à proximité"
                       else
                        activation = true
                        messagediagno = nil
                       end

                       if Config.diagnostiquemenu == true then
                       RageUI.Button("Caractéristique / Diagnostique Véhicule", messagediagno, {RightLabel = "→→"}, activation, {
                        onActive = function()
                            GetCloseVehi()

                        end,
                        onSelected = function()
                        end
                       }, MenuDiagnostique)
                    end

                       RageUI.Button("Facturation", nil, {RightLabel = "→→"}, true, {
                        onSelected = function()
                            local ClosestPlayer, distance = ESX.Game.GetClosestPlayer()
                            local AmountBill =  KeyboardInput("Montant", "", 100)
                            AmountBill = tonumber(AmountBill)
                            if ClosestPlayer ~= -1 and distance <= 3.0 then
                                if AmountBill ~= nil and type(AmountBill) == 'number' then
                                    TaskStartScenarioInPlace(PlayerPedId(), 'CODE_HUMAN_MEDIC_TIME_OF_DEATH', 0, true)
                                      Citizen.Wait(4000)
                                      ClearPedTasks(PlayerPedId())
                                        TriggerServerEvent('esx_billing:sendBill', GetPlayerServerId(ClosestPlayer), 'society_mechanic', 'Otto Mechanic', AmountBill)
                                        ESX.ShowNotification("~g~Vous avez envoyée une facture au montant de "..AmountBill.."$")
                                else
                                    ESX.ShowNotification("~r~Montant invalide")
                                end
                            else
                                ESX.ShowNotification("~r~Aucun joueur à proximité")
                            end
                        end
                        })   
                    end  
            end)

            RageUI.IsVisible(MenuVehicule, function()
                RageUI.Button("Faire une réparation", nil, {RightLabel = "→→"}, true, {
                    onActive = function()
                        GetCloseVehi()
                      end,
                    onSelected = function()
                        local playerPed = PlayerPedId()
			local vehicle   = ESX.Game.GetVehicleInDirection()
			local coords    = GetEntityCoords(playerPed)

			if IsPedSittingInAnyVehicle(playerPed) then
                ESX.ShowAdvancedNotification('Benny\'s Motor Works', '~y~Notification', "~r~Vous ne pouvez pas faire cette action depuis un véhicule", 'CHAR_CARSITE3', 1)
				return
			end

			if DoesEntityExist(vehicle) then
				isBusy = true
				TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_BUM_BIN', 0, true)
				Citizen.CreateThread(function()
                    exports.rprogress:Start('Réparation en cours...', 10000)
                    exports.rprogress:Stop()

					SetVehicleFixed(vehicle)
					SetVehicleDeformationFixed(vehicle)
					SetVehicleUndriveable(vehicle, false)
					SetVehicleEngineOn(vehicle, true, true)
					ClearPedTasksImmediately(playerPed)

                    ESX.ShowAdvancedNotification('Benny\'s Motor Works', '~y~Notification', "~g~Réparation du véhicule réussi", 'CHAR_CARSITE3', 1)
					isBusy = false
				end)
			else
                ESX.ShowAdvancedNotification('Benny\'s Motor Works', '~y~Notification', "~r~Aucun véhicule à proximité", 'CHAR_CARSITE3', 1)
			end
                    end
                   })

                   RageUI.Button("Faire un nettoyage", nil, {RightLabel = "→→"}, true, {
                    onActive = function()
                        GetCloseVehi()
                      end,
                    onSelected = function()
                            
                            local playerPed = PlayerPedId()
    
                            local vehicle   = ESX.Game.GetVehicleInDirection()
    
                            if IsPedSittingInAnyVehicle(playerPed) then
                                ESX.ShowNotification('~r~Vous ne pouvez pas faire cette action depuis un véhicule')
                                return
                            end
                        if DoesEntityExist(vehicle) then
                            TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_MAID_CLEAN', 0, true)
                            FreezeEntityPosition(playerPed, true)
                            exports.rprogress:Start('Nettoyage en cours...', 6000)
                            exports.rprogress:Stop()
                            ESX.ShowAdvancedNotification('Benny\'s Motor Works', '~y~Notification', "~g~Nettoyage réussi", 'CHAR_CARSITE3', 1)
                            SetVehicleDirtLevel(vehicle, 0.0)
                            FreezeEntityPosition(playerPed, false)
                            ClearPedTasks(playerPed)
    
                        else
                            ESX.ShowAdvancedNotification('Benny\'s Motor Works', '~y~Notification', "~r~Aucun véhicule à proximité", 'CHAR_CARSITE3', 1)
                        end
                    end                  
                 })

                    RageUI.Button("Remplir le réservoir", nil, {RightLabel = "→→"}, true, {
                        onActive = function()
                            GetCloseVehi()
                          end,
                        onSelected = function()
                            LoadAnimDict("timetable@gardener@filling_can")
                            
                            local playerPed = PlayerPedId()
    
                            local vehicle   = ESX.Game.GetVehicleInDirection()
    
                            if IsPedSittingInAnyVehicle(playerPed) then
                                ESX.ShowNotification('~r~Vous ne pouvez pas faire cette action depuis un véhicule')
                                return
                            end
                        if DoesEntityExist(vehicle) then
                            TaskPlayAnim(playerPed, "timetable@gardener@filling_can", "gar_ig_5_filling_can", 2.0, 8.0, -1, 50, 0, 0, 0, 0)
                            FreezeEntityPosition(playerPed, true)
                            exports.rprogress:Start('Plein en cours...', 6000)
                            exports.rprogress:Stop()
                            ESX.ShowAdvancedNotification('Benny\'s Motor Works', '~y~Notification', "~g~Plein du réservoir réussi", 'CHAR_CARSITE3', 1)
                            exports["LegacyFuel"]:SetFuel(vehicle, 100)
                            FreezeEntityPosition(playerPed, false)
                            ClearPedTasks(playerPed)
    
                        else
                            ESX.ShowAdvancedNotification('Benny\'s Motor Works', '~y~Notification', "~r~Aucun véhicule à proximité", 'CHAR_CARSITE3', 1)
                        end
                        end
                       })

                   RageUI.line(255,255,255,255)

                   RageUI.Button("Procédure de mise en fourrière", nil, {RightLabel = "→→"}, true, {
                    onActive = function()
                        GetCloseVehi()
                      end,
                    onSelected = function()
                        local playerPed = PlayerPedId()


			if IsPedSittingInAnyVehicle(playerPed) then
				local vehicle = GetVehiclePedIsIn(playerPed, false)

				if GetPedInVehicleSeat(vehicle, -1) == playerPed then
                TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TIME_OF_DEATH', 0, true)
                exports.rprogress:Start('Mise en fourrière en cours...', 9000)
                exports.rprogress:Stop()
                ClearPedTasks(playerPed)
                ESX.ShowAdvancedNotification('Benny\'s Motor Works', '~y~Notification', "~g~Véhicule mis en fourrière avec succès", 'CHAR_CARSITE3', 1)
                ESX.Game.DeleteVehicle(vehicle)
				else
					ESX.ShowAdvancedNotification('Benny\'s Motor Works', '~y~Notification', "~r~Vous devez être côté conducteur", 'CHAR_CARSITE3', 1)
				end
			else
				local vehicle = ESX.Game.GetVehicleInDirection()

				if DoesEntityExist(vehicle) then
                    TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TIME_OF_DEATH', 0, true)
                    exports.rprogress:Start('Mise en fourrière en cours...', 9000)
                    exports.rprogress:Stop()
                    ClearPedTasks(playerPed)
                    ESX.ShowAdvancedNotification('Benny\'s Motor Works', '~y~Notification', "~g~Véhicule mis en fourrière avec succès", 'CHAR_CARSITE3', 1)
					ESX.Game.DeleteVehicle(vehicle)
				else
					ESX.ShowAdvancedNotification('Benny\'s Motor Works', '~y~Notification', "~r~Aucun véhicule à proximité", 'CHAR_CARSITE3', 1)
				end
			end
                    end 
                })

                RageUI.Button("Crocheter le véhicule", nil, {RightLabel = "→→"}, true, {
                    onActive = function()
                        GetCloseVehi()
                      end,
                    onSelected = function()
                        local playerPed = PlayerPedId()
			local vehicle   = ESX.Game.GetVehicleInDirection()
			local coords    = GetEntityCoords(playerPed)

			if IsPedSittingInAnyVehicle(playerPed) then
				ESX.ShowAdvancedNotification('Benny\'s Motor Works', '~y~Notification', "~r~Vous ne pouvez pas faire cette action depuis un véhicule", 'CHAR_CARSITE3', 1)
				return
			end

			if DoesEntityExist(vehicle) then
				isBusy = true
				TaskStartScenarioInPlace(playerPed, 'WORLD_HUMAN_WELDING', 0, true)
				Citizen.CreateThread(function()
                    exports.rprogress:Start('Crochetage en cours...', 6000)
                    exports.rprogress:Stop()
					SetVehicleDoorsLocked(vehicle, 1)
					SetVehicleDoorsLockedForAllPlayers(vehicle, false)
					ClearPedTasksImmediately(playerPed)

					ESX.ShowAdvancedNotification('Benny\'s Motor Works', '~y~Notification', "~g~Crochetage réussi", 'CHAR_CARSITE3', 1)
					isBusy = false
				end)
			else
				ESX.ShowAdvancedNotification('Benny\'s Motor Works', '~y~Notification', "~r~Aucun véhicule à proximité", 'CHAR_CARSITE3', 1)
			end
                    end
                })

                RageUI.line(255,255,255,255)

                RageUI.Button("Mettre / Retirer le véhicule du plateau", "~b~Information\n~s~Vous devez d'abord monter dans votre dépanneuse à plateau", {RightLabel = "→→"}, encours, {
                    onActive = function()
                        GetCloseVehi()
                      end,
                    onSelected = function()
                local vehicledepannage =  GetClosestVehicle(GetEntityCoords(PlayerPedId()),5.0, 0, 70)
                local playerPed = PlayerPedId()
                local vehicle = GetVehiclePedIsIn(playerPed, true)
    
                local towmodel = GetHashKey('flatbed')
                local isVehicleTow = IsVehicleModel(vehicle, towmodel)
    
                if isVehicleTow then
    
                    if CurrentlyTowedVehicle == nil then
                        if DoesEntityExist(vehicledepannage) then
                            if not IsPedInAnyVehicle(playerPed, true) then
                                if vehicle ~= vehicledepannage then
                                    TaskStartScenarioInPlace(playerPed, 'CODE_HUMAN_MEDIC_TEND_TO_DEAD', 0, true)
                                    encours = false
                                    exports.rprogress:Start('Mise en place sur le plateau ...', 10000)
                                    exports.rprogress:Stop()
                                    encours = true
                                    ClearPedTasks(playerPed)
                                    AttachEntityToEntity(vehicledepannage, vehicle, 20, -0.5, -5.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
                                    CurrentlyTowedVehicle = vehicledepannage
                                    ESX.ShowAdvancedNotification('Benny\'s Motor Works', '~y~Notification', "~g~Mise sur le plateau réussi", 'CHAR_CARSITE3', 1)
    
                                    if NPCOnJob then
                                        if NPCTargetTowable == vehicledepannage then
                                            objectif = "Déposer le véhicule au garage"
                                            ESX.ShowAdvancedNotification('Benny\'s Motor Works', '~y~Notification', "Dés à présent, Déposer le ~y~véhicule au garage~s~", 'CHAR_CARSITE3', 1)
                                            Config.Zones.VehicleDelivery.Type = 1
    
                                            if Blips['NPCTargetTowableZone'] then
                                                RemoveBlip(Blips['NPCTargetTowableZone'])
                                                Blips['NPCTargetTowableZone'] = nil
                                            end
    
                                            Blips['NPCDelivery'] = AddBlipForCoord(Config.Zones.VehicleDelivery.Pos.x, Config.Zones.VehicleDelivery.Pos.y, Config.Zones.VehicleDelivery.Pos.z)
                                            SetBlipRoute(Blips['NPCDelivery'], true)
                                        end
                                    end
                                else
                                    ESX.ShowAdvancedNotification('Benny\'s Motor Works', '~y~Notification', "~r~Vous ne pouvez pas attacher votre véhicule de dépannage", 'CHAR_CARSITE3', 1)
                                end
                            end
                        else
                            ESX.ShowAdvancedNotification('Benny\'s Motor Works', '~y~Notification', "~r~Aucun véhicule à proximité", 'CHAR_CARSITE3', 1)
                        end
                    else
                        AttachEntityToEntity(CurrentlyTowedVehicle, vehicle, 20, -0.5, -12.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)
                        DetachEntity(CurrentlyTowedVehicle, true, true)
                        
                        if NPCOnJob then
                            if NPCTargetDeleterZone then
    
                                if CurrentlyTowedVehicle == NPCTargetTowable then
                                    ESX.Game.DeleteVehicle(NPCTargetTowable)
                                    TriggerServerEvent('pawal:missionreussimayement')
                                    StopNPCJob()
                                    NPCTargetDeleterZone = false
                                else
                                    ESX.ShowNotification("Ce n'est pas le bon ~r~véhicule !", 'CHAR_CARSITE3')
                                end
    
                            else
                                ESX.ShowNotification("Vous n'etes pas au bon endroit ~h~pour faire cela !")
                            end
                        end
    
                        CurrentlyTowedVehicle = nil
                        ESX.ShowAdvancedNotification('Benny\'s Motor Works', '~y~Notification', "~g~Véhicule retirer du plateau", 'CHAR_CARSITE3', 1)
                    end
                else
                    ESX.ShowAdvancedNotification('Benny\'s Motor Works', '~y~Notification', "~r~Vous devez avoir un véhicule à plateau pour faire cela", 'CHAR_CARSITE3', 1)
                end
                    end
                })

            end)

            RageUI.IsVisible(communication, function()
                RageUI.Button("Demande Assistance", nil, {RightLabel = "→→"}, true, {
                    onSelected = function()
                        local playerPed = PlayerPedId()
                        local coords  = GetEntityCoords(playerPed)
                        TriggerServerEvent('pawal:renfort', coords)
                    end
                   })
                   RageUI.List("Annonce", AnnonceList, AnnonceListIndex, nil, {}, true, {
                    onListChange = function(i, Items)
                        if AnnonceListIndex ~= i then
                            AnnonceListIndex = i;
                        end
                    end,
                    onSelected = function(i, itm)
                        if i == 1 then
                            TriggerServerEvent('Ouvre:benny')
                        elseif i == 2 then
                            TriggerServerEvent('Ferme:benny')
                        elseif i == 3 then
                            local message = KeyboardInput("Texte de l'annonce", "", 100)
                            ExecuteCommand("meca " ..message)
                        end
                    end
                })
            end)

            RageUI.IsVisible(MenuDiagnostique, function()
                fait = false
                faitt = false
                local veh = GetClosestVehicle(GetEntityCoords(PlayerPedId()),3.0, 0, 70)
                local model = GetEntityModel(veh)
                local displaytext = GetDisplayNameFromVehicleModel(model)
                local text = GetLabelText(displaytext)
                RageUI.Separator('Modèle du véhicule : ~b~'..text)
                RageUI.Separator('Plaque : ~b~'..GetVehicleNumberPlateText(veh))
                RageUI.line(255,255,255,255)
                RageUI.Button("Performance", nil, {RightLabel = "→→"}, true, {
                    onSelected = function()
                        local veh, dst = ESX.Game.GetClosestVehicle(playerCoords)
                        if dst <= 2.5 then
                            vehProps = ESX.Game.GetVehicleProperties(veh)
                        end
                    end
                   },performance)
                RageUI.Button("Diagnostique", nil, {RightLabel = "→→"}, true, {
                    onSelected = function()
                    end
                   }, diagnostique)
            end)

            RageUI.IsVisible(performance, function()
                local veh = GetClosestVehicle(GetEntityCoords(PlayerPedId()),3.0, 0, 70)
                local model = GetEntityModel(veh)
                local displaytext = GetDisplayNameFromVehicleModel(model)
                local text = GetLabelText(displaytext)
                MaxSpeed = GetVehicleModelMaxSpeed(GetHashKey(model))*3.6
                Acceleration = GetVehicleModelAcceleration(GetHashKey(model))*3.6/220
                Braking = GetVehicleModelMaxBraking(GetHashKey(model))/2
                RageUI.Separator('Modèle du véhicule : ~b~'..text)
                RageUI.Separator('Plaque : ~b~'..GetVehicleNumberPlateText(veh))
                RageUI.line(255,255,255,255)
                if faitt == false then
                RageUI.Button("Vérifier les performances", nil, {RightLabel = "→→"}, performanceactivation, {
                    onSelected = function()
                        local playerPed = PlayerPedId()
                        ExecuteCommand('e tablet2')
                        performance.Closable = false
                        performanceactivation = false
                        exports.rprogress:Start('Vérification en cours...', 6000)
                        exports.rprogress:Stop()
                        performanceactivation = true
                        performance.Closable = true
                        faitt = true
                    end
                   })
                end
                if faitt == true then
                if not vehProps then
                    RageUI.Separator("Pas de vehicule à proximité")
                else
                    for kStatsVeh, vStatsVeh in pairs(statsVeh) do
                        RageUI.Separator(vStatsVeh.label .. ":  ~g~Stage " .. vehProps[vStatsVeh.mod] + 2)
                    end
                    RageUI.Separator("Turbo: " .. (vehProps["modTurbo"] and "~g~Installé" or "~r~Pas installé"))
                end
            end
            end)

            RageUI.IsVisible(diagnostique, function()
                local veh = GetClosestVehicle(GetEntityCoords(PlayerPedId()),3.0, 0, 70)
                local model = GetEntityModel(veh)
                local displaytext = GetDisplayNameFromVehicleModel(model)
                local text = GetLabelText(displaytext)
                RageUI.Separator('Modèle du véhicule : ~b~'..text)
                RageUI.Separator('Plaque : ~b~'..GetVehicleNumberPlateText(veh))
                RageUI.line(255,255,255,255)

                if fait == false then
                RageUI.Button("Lancer un diagnostique", nil, {RightLabel = "→→"}, diagnostiqueactivation, {
                    onSelected = function()
                        local playerPed = PlayerPedId()
                        diagnostiqueactivation = false
                        ExecuteCommand('e tablet2')
                        diagnostique.Closable = false
                        exports.rprogress:Start('Diagnostique en cours...', 6000)
                        exports.rprogress:Stop()
                        diagnostiqueactivation = true
                        diagnostique.Closable = true
                        fait = true
                    end
                   })
                end

                if fait == true then
                    RageUI.Separator('Etat du véhicule : ~g~'..Round(GetVehicleEngineHealth(veh)).."~s~ /1000")
                    RageUI.Separator("Essence : ~o~"..Round(GetVehicleFuelLevel(veh)).." L")
                    RageUI.line(255,255,255,255)
                    RageUI.Separator("↓ ~b~Résultat du diagnostique~s~ ↓")
                    if Round(GetVehicleEngineHealth(veh)) >= 700 then
                    RageUI.Separator("Véhicule en ~g~Bonne état")
                    elseif Round(GetVehicleEngineHealth(veh)) >= 400 then
                        RageUI.Separator("Véhicule en ~o~Assez bonne état")
                    elseif Round(GetVehicleEngineHealth(veh)) < 400 then
                        RageUI.Separator("Véhicule en ~r~Mauvaise état")
                 end
                end

            end)

        
             Wait(0)
             end
         end)
     end
 end
 
 -- MARKERS
 
 Keys.Register('F6', 'mécano', 'Ouvrir le menu mécano', function()
	if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' then
        if IsControlJustPressed(1,167) then
        menumechanic()
        end
	end
end)

RegisterNetEvent('pawal:onCarokit')
         AddEventHandler('pawal:onCarokit', function()
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
                         ClearPedTasksImmediately(playerPed)
                         ESX.ShowNotification(_U('body_repaired'))
                     end)
                 end
             end
         end)
         
         RegisterNetEvent('pawal:onFixkit')
         AddEventHandler('pawal:onFixkit', function()
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
                         Citizen.Wait(20000)
                         SetVehicleFixed(vehicle)
                         SetVehicleDeformationFixed(vehicle)
                         SetVehicleUndriveable(vehicle, false)
                         ClearPedTasksImmediately(playerPed)
                         ESX.ShowNotification(_U('veh_repaired'))
                     end)
                 end
             end
         end)


         
function Draw3DText(x, y, z, scl_factor, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local p = GetGameplayCamCoords()
    local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, x, y, z, 1)
    local scale = (1 / distance) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov * scl_factor
    if onScreen then
        SetTextScale(0.0, scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end


         Citizen.CreateThread(function() 
            while true do
                local player = GetPlayerPed(-1)
                local vehicle = GetClosestVehicle(GetEntityCoords(PlayerPedId()),3.0, 0, 70)
                local vCoords = GetEntityCoords(vehicle)
                if serviceMecano and not IsPedSittingInAnyVehicle(PlayerPedId()) and DoesEntityExist(vehicle) and Config.Text3DService == true then
                    Draw3DText(vCoords.x, vCoords.y, vCoords.z + 1.2, 0.3, 'Etat Véhicule : ~b~'..Round(GetVehicleEngineHealth(vehicle))..'~s~/1000')
                    Draw3DText(vCoords.x, vCoords.y, vCoords.z + 1.1, 0.3, 'Essence : ~g~'..Round(GetVehicleFuelLevel(vehicle))..'L')
                end 
                Citizen.Wait(0)
            end
        end)

         function GetCloseVehi()
            local player = GetPlayerPed(-1)
            local vehicle = GetClosestVehicle(GetEntityCoords(PlayerPedId()),3.0, 0, 70)
            local vCoords = GetEntityCoords(vehicle)
            DrawMarker(2, vCoords.x, vCoords.y, vCoords.z + 1.6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.5, 0.5, 0.5, 0, 125, 255, 85, 1, 1, 2, 1, nil, nil, 0)
        end

        RegisterNetEvent('pawal:setBlip')
        AddEventHandler('pawal:setBlip', function(coords)
            PlaySoundFrontend(-1, "Start_Squelch", "CB_RADIO_SFX", 1)
            PlaySoundFrontend(-1, "OOB_Start", "GTAO_FM_Events_Soundset", 1)
            ESX.ShowAdvancedNotification('Benny\'s Motor Works', '~y~Demande d\'Assistance', 'Un Agent du ~y~Benny\'s~s~ demande une ~y~assistance supplémentaire~s~.\n[~y~Voir GPS~s~]', 'CHAR_CARSITE3', 1)
            Wait(1000)
            PlaySoundFrontend(-1, "End_Squelch", "CB_RADIO_SFX", 1)
            local blipId = AddBlipForCoord(coords)
            SetBlipSprite(blipId, 161)
            SetBlipScale(blipId, 1.2)
            SetBlipColour(blipId, 5)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString('[~y~Benny\'s~s~] Demande Assistance')
            EndTextCommandSetBlipName(blipId)
            Wait(80 * 1000)
            RemoveBlip(blipId)
        end)

Citizen.CreateThread(function()
     local BENNYBLIP = AddBlipForCoord(Config.blipposition)

      SetBlipSprite(BENNYBLIP, Config.blipsprite)
      SetBlipColour(BENNYBLIP, Config.blipcolour)
      SetBlipScale(BENNYBLIP, Config.blipscale)
      SetBlipAsShortRange(BENNYBLIP, true)
      BeginTextCommandSetBlipName('STRING')
      AddTextComponentSubstringPlayerName(Config.blipname) 
      EndTextCommandSetBlipName(BENNYBLIP)

end)