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

-- MENU FUNCTION --

local open = false 
local menu = RageUI.CreateMenu('Vestaire', 'Action')
menu.Closed = function()
  open = false
end

function VersiaireBenny()
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

			
                RageUI.Button("Reprendre sa tenue de civil", nil, {RightLabel = "→→"}, true, {
                onSelected = function()
                  ExecuteCommand('e adjusttie')
                  exports.rprogress:Start('Chargement de la tenue...', 3000)
                  exports.rprogress:Stop()
                  ClearPedTasks(PlayerPedId())
                    ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin) 
                    TriggerEvent('skinchanger:loadSkin', skin) 
                  end)
                end
                })	

                RageUI.Separator("↓ ~y~Tenues de service ~s~↓")			
              for _,infos in pairs(Config.MecanoOutfit.clothes) do
                RageUI.Button(infos.label, nil, {RightLabel = "→→"}, ESX.PlayerData.job.grade >= infos.minimum_grade, {
                onSelected = function()
                  ExecuteCommand('e adjusttie')
                  exports.rprogress:Start('Chargement de la tenue...', 3000)
                  exports.rprogress:Stop()
                     skinapplication(infos)
                     ClearPedTasks(PlayerPedId())
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
          for k in pairs(Config.vestiaire) do
              local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
              local pos = Config.vestiaire
              local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, pos[k].x, pos[k].y, pos[k].z)

              if dist <= Config.MarkerDistance and open == false then
                  wait = 0
                  DrawMarker(Config.MarkerType, pos[k].x, pos[k].y, pos[k].z, 0.0, 0.0, 0.0, 0.0,0.0,0.0, Config.MarkerSizeLargeur, Config.MarkerSizeEpaisseur, Config.MarkerSizeHauteur, Config.MarkerColorR, Config.MarkerColorG, Config.MarkerColorB, Config.MarkerOpacite, Config.MarkerSaute, true, p19, Config.MarkerTourne)  
              end

              if dist <= 1.0 then
                  wait = 0
                  if Config.use3Dtext == true and open == false then
                    Draw3DText(pos[k].x, pos[k].y, pos[k].z + 0.2, 0.190, '~r~[E]~s~ Ouvrir le vestiaire')
                  elseif Config.use3Dtext == false and open == false then
                  ESX.ShowHelpNotification("Appuyer sur ~INPUT_PICKUP~ pour ouvrir le vestiaire") 
                end

                  if IsControlJustPressed(1,51) then
                    VersiaireBenny()
                  end
              end
          end
  end
  Citizen.Wait(wait)
  end
end)

function skinapplication(infos)
	TriggerEvent('skinchanger:getSkin', function(skin)
		local uniformObject
		if skin.sex == 0 then
			uniformObject = infos.variations.male
		else
			uniformObject = infos.variations.female
		end
		if uniformObject then
			TriggerEvent('skinchanger:loadClothes', skin, uniformObject)
		end

		infos.onEquip()
	end)
end