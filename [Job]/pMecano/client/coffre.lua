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
all_items = {}
societyitem = {}
recherche = nil
rechercheactivation = false
local open = false 
local menu = RageUI.CreateMenu('Coffre', 'Action')
local depotitem = RageUI.CreateSubMenu(menu, 'Dépôt', 'Action')
local retraititem = RageUI.CreateSubMenu(menu, 'Retrait', 'Action')
menu.Closed = function()
  open = false
end

function CoffreBenny()
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

			
                RageUI.Button("Déposer un/des objet(s)", nil, {RightLabel = "→→"}, true, {
                onSelected = function()
                    getInventory()
                end
                }, depotitem)	

                RageUI.Button("Retirer un/des objet(s)", nil, {RightLabel = "→→"}, true, {
                    onSelected = function()
                        getStock()
                    end
                }, retraititem)	
            end)

            RageUI.IsVisible(depotitem, function()
            
                for k,v in pairs(all_items) do
                    RageUI.Button(v.label, nil, {RightLabel = "~g~x"..math.round(v.nb)}, true, {onSelected = function()
                        local count = KeyboardInput("~s~Quantité à déposer ?", '' , '', 80)
                        count = tonumber(count)
                        TriggerServerEvent("pawal:depotbenny",v.item, count, ESX.PlayerData.job.grade_label)
                        getInventory()
                    end});
                end
           end)

           RageUI.IsVisible(retraititem, function()
            RageUI.Button("Rechercher un item", nil, {RightLabel = "→→"}, true, {
                onSelected = function()
                    local itemrecherche = KeyboardInput("~s~Item rechercher ?", '' , '', 80)
                                if itemrecherche ~= "" and itemrecherche ~= nil then
                                recherche = itemrecherche
                                rechercheactivation = true
                                else
                                    ESX.ShowNotification('~r~Rercherche invalide !')
                         end
                end
            })

            if rechercheactivation == true then
                RageUI.Button("Supprimer la recherche", nil, {RightLabel = "→→"}, true, {
                    onSelected = function()
                      recherche = nil
                      rechercheactivation = false
                    end
                })
                RageUI.Separator('Item rechercher : ~g~'..recherche)
            end

            RageUI.line(255,255,255,255)

            for k,v in pairs(societyitem) do
                if recherche ~= nil then
                    if starts(v.label:lower(), recherche:lower()) then
                        RageUI.Button(v.label, nil, {RightLabel = "~g~x"..math.round(v.nb)}, true, {onSelected = function()
                            local count = KeyboardInput("~s~Quantité à retirer ?", '' , '', 80)
                            count = tonumber(count)
                            if count <= v.nb then
                                TriggerServerEvent("pawal:retraitbenny", v.item, count, ESX.PlayerData.job.grade_label)
                            else
                                ESX.ShowNotification("~r~Pas assez de stock de "..v.label.." pour pouvoir retirer le montant saisi")
                            end
                            getStock()
                        end});
                   end
               end
               if recherche == nil then
                RageUI.Button(v.label, nil, {RightLabel = "~g~x"..math.round(v.nb)}, true, {onSelected = function()
                    local count = KeyboardInput("~s~Quantité à retirer ?", '' , '', 80)
                    count = tonumber(count)
                    if count <= v.nb then
                        TriggerServerEvent("pawal:retraitbenny", v.item, count, ESX.PlayerData.job.grade_label)
                    else
						ESX.ShowNotification("~r~Pas assez de stock de "..v.label.." pour pouvoir retirer le montant saisi")
                    end
                    getStock()
                end});
            end
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
  if Config.UseCoffreMenu == true then
      if ESX.PlayerData.job and ESX.PlayerData.job.name == 'mechanic' then
          for k in pairs(Config.coffre) do
              local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
              local pos = Config.coffre
              local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, pos[k].x, pos[k].y, pos[k].z)

              if dist <= Config.MarkerDistance and open == false then
                  wait = 0
                  DrawMarker(Config.MarkerType, pos[k].x, pos[k].y, pos[k].z, 0.0, 0.0, 0.0, 0.0,0.0,0.0, Config.MarkerSizeLargeur, Config.MarkerSizeEpaisseur, Config.MarkerSizeHauteur, Config.MarkerColorR, Config.MarkerColorG, Config.MarkerColorB, Config.MarkerOpacite, Config.MarkerSaute, true, p19, Config.MarkerTourne)  
              end

              if dist <= 1.0 then
                  wait = 0
                  if Config.use3Dtext == true and open == false then
                    Draw3DText(pos[k].x, pos[k].y, pos[k].z + 0.2, 0.190, '~r~[E]~s~ Ouvrir le coffre')
                  elseif Config.use3Dtext == false and open == false then
                  ESX.ShowHelpNotification("Appuyer sur ~INPUT_PICKUP~ pour ouvrir le coffre") 
                end

                  if IsControlJustPressed(1,51) then
                    CoffreBenny()
                  end
              end
          end
        end
  end
  Citizen.Wait(wait)
  end
end)

function getInventory()
    ESX.TriggerServerCallback('pawal:bennyinventairejoueur', function(inventory)               
                
        all_items = inventory

    end)
end

function getStock()
    ESX.TriggerServerCallback('pawal:récupérationstockitemsociety', function(item)               
                
        societyitem = item
        
    end)
end