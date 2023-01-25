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
local menu = RageUI.CreateMenu('Gestion Entreprise', 'Action')
menu.Closed = function()
  open = false
end


function BossBenny()
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
			
                RageUI.Button("Accédez au gestion entreprise" , nil, {RightLabel = "→→"}, true , {
                    onSelected = function()
                        gestionboss()
                        RageUI.CloseAll()
                        open = false
                        
                    end
                 })

            end)
          Wait(0)
         end
      end)
   end
end

function gestionboss()
    TriggerEvent('esx_society:openBossMenu', 'mechanic', function(data, menu)
        menu.close()
    end, {wash = false})
end

Citizen.CreateThread(function()
  while true do
  local wait = 750
  if Config.UseBossMenu == true then
    if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' and ESX.PlayerData.job.grade_name == "boss" then
          for k in pairs(Config.boss) do
              local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
              local pos = Config.boss
              local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, pos[k].x, pos[k].y, pos[k].z)

              if dist <= Config.MarkerDistance and open == false then
                  wait = 0
                  DrawMarker(Config.MarkerType, pos[k].x, pos[k].y, pos[k].z, 0.0, 0.0, 0.0, 0.0,0.0,0.0, Config.MarkerSizeLargeur, Config.MarkerSizeEpaisseur, Config.MarkerSizeHauteur, Config.MarkerColorR, Config.MarkerColorG, Config.MarkerColorB, Config.MarkerOpacite, Config.MarkerSaute, true, p19, Config.MarkerTourne)  
                end

              if dist <= 1.0 then
                  wait = 0
                  if Config.use3Dtext == true and open == false then
                    Draw3DText(pos[k].x, pos[k].y, pos[k].z + 0.2, 0.190, '~r~[E]~s~ Ouvrir gestion entreprise')
                  elseif Config.use3Dtext == false and open == false then
                  ESX.ShowHelpNotification("Appuyer sur ~INPUT_PICKUP~ pour ouvrir la gestion entreprise") 
                end  

                  if IsControlJustPressed(1,51) then
                    BossBenny()
                  end
              end
          end
  end
end
  Citizen.Wait(wait)
  end
end)