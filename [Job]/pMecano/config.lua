Config = {

-----------------------------------------------------------------------
-------------------------Marker Configuration--------------------------
-----------------------------------------------------------------------
MarkerType = 22, -- Pour voir les différents type de marker: https://docs.fivem.net/docs/game-references/markers/
MarkerSizeLargeur = 0.2, -- Largeur du marker
MarkerSizeEpaisseur = 0.2, -- Épaisseur du marker
MarkerSizeHauteur = 0.2, -- Hauteur du marker
MarkerDistance = 6.0, -- Distane de visibiliter du marker (1.0 = 1 mètre)
MarkerColorR = 255, -- Voir pour les couleurs RGB: https://www.google.com/search?q=html+color+picker&rlz=1C1GCEA_enFR965FR965&oq=html+color+&aqs=chrome.2.69i59j0i131i433i512j0i512l5j69i60.3367j0j7&sourceid=chrome&ie=UTF-8
MarkerColorG = 0, -- Voir pour les couleurs RGB: https://www.google.com/search?q=html+color+picker&rlz=1C1GCEA_enFR965FR965&oq=html+color+&aqs=chrome.2.69i59j0i131i433i512j0i512l5j69i60.3367j0j7&sourceid=chrome&ie=UTF-8
MarkerColorB = 0, -- Voir pour les couleurs RGB: https://www.google.com/search?q=html+color+picker&rlz=1C1GCEA_enFR965FR965&oq=html+color+&aqs=chrome.2.69i59j0i131i433i512j0i512l5j69i60.3367j0j7&sourceid=chrome&ie=UTF-8
MarkerOpacite = 255, -- Opacité du marker (min: 0, max: 255)
MarkerSaute = false, -- Si le marker saute (true = oui, false = non)
MarkerTourne = true, -- Si le marker tourne (true = oui, false = non)


--------------------------------------------------------
-------------------------BLIPS--------------------------
--------------------------------------------------------
blipname = "Benny's Motor Work",
blipscale = 0.8, 
blipcolour = 5, 
blipsprite = 446, 
blipdisplay = 4, 
blipposition = vector3(-213.33702087402, -1326.0938720703, 30.906789779663),


----------------------------------------------------------------
-------------------------Configuration--------------------------
----------------------------------------------------------------
Text3DService = false, -- Activer ou non l'affichage du texte 3D qui affiche les statistiques du véhicule (Conseille : N'activer pas le diagnostique de Dégât si vous activer ceci, il deviendrait inutile)
use3Dtext = true, -- Activer ou non les 3D text (si désactiver = ShowHelpNotification)

UseBossMenu = true, -- Désactiver si vous utilisez un script autre que le esx_society
UseCoffreMenu = true, -- Si vous utilisez un coffre builder (Ps : J'en est créer un si vous le voulez héhé °-°)

diagnostiquemenu = true, -- Si vous voulez le menu diagnostique

MissionPnj = true, -- Si vous voulez les missions PNJ

WebhookService = "", -- Webhook prise de service et fin de service
WebhookCoffre = "", -- Webhook dépôt/retrait coffre

-------------------------------------------------------------------------
-------------------------Position Configuration--------------------------
-------------------------------------------------------------------------
vestiaire = {vector3(-213.76039123535,-1332.3093261719,23.142585754395)},
coffre = {vector3(-196.52070617676, -1315.0802001953, 31.089220046997)},
garage = {vector3(-200.82537841797, -1308.9290771484, 31.294128417969)},
boss = {vector3(-198.36763000488, -1340.7150878906, 34.899417877197)},
fabricationkit = {vector3(-196.54814147949, -1318.8675537109, 31.089227676392)},


-----------------------------------------------------------------------
-------------------------Garage Configuration--------------------------
-----------------------------------------------------------------------
GarageVehicle = {
    {Label = "Dépanneuse à plateau", Spawnname = "flatbed", spawnzone = vector3(-193.42640686035,-1305.8988037109,31.352931976318), headingspawn = 87.64408111572266},
    {Label = "Dépanneuse à cable", Spawnname = "towtruck", spawnzone = vector3(-193.42640686035,-1305.8988037109,31.352931976318), headingspawn = 87.64408111572266},
},



----------------------------------------------------------------------
-------------------------Tenue Configuration--------------------------
----------------------------------------------------------------------
MecanoOutfit = {
    clothes = {
                [1] = {
                    minimum_grade = 0,
                    label = "Tenue Service",
                    variations = {
                    male = {
                        ['tshirt_1'] = 15,  ['tshirt_2'] = 0,
                        ['torso_1'] = 66,   ['torso_2'] = 0,
                        ['decals_1'] = 0,   ['decals_2'] = 0,
                        ['arms'] = 38,
                        ['pants_1'] = 39,   ['pants_2'] = 0,
                        ['shoes_1'] = 25,   ['shoes_2'] = 0,
                    },
                    female = {
                        ['tshirt_1'] = 103,  ['tshirt_2'] = 0,
                        ['torso_1'] = 230,   ['torso_2'] = 0,
                        ['decals_1'] = 0,   ['decals_2'] = 0,
                        ['arms'] = 215,
                        ['pants_1'] = 30,   ['pants_2'] = 0,
                        ['shoes_1'] = 25,   ['shoes_2'] = 0,
                        ['helmet_1'] = 149,  ['helmet_2'] = 0,
                        ['chain_1'] = 0,    ['chain_2'] = 0,
                        ['mask_1'] = 185,  ['mask_2'] = 0,
                        ['bproof_1'] = 0,  ['bproof_2'] = 0,
                        ['ears_1'] = -1,     ['ears_2'] = 0,
                        ['bproof_1'] = 27,  ['bproof_2'] = 0,
                        ['glasses_1'] = 22
                   }
               },
                onEquip = function()
            end
         }
    }
},
}

-----------------------------------------------------------------------
-------------------------Mission Configuration-------------------------
-----------------------------------------------------------------------
Config.NPCSpawnDistance           = 500.0  --(Spawn Distance)
Config.NPCNextToDistance          = 25.0
Config.NPCJobEarnings             = { min = 15, max = 40 } --(Payement Tarif (Mission))

Config.Zones = { 
    VehicleDelivery = {   --(configuration zone de dépôt des véhicules dépanner)
		Pos   = {x = -163.10093688965, y = -1305.8044433594, z = 31.352502822876},
		Size  = { x = 20.0, y = 20.0, z = 3.0 },
		Color = { r = 204, g = 204, b = 0 },
		Type  = -1
	}													
}

Config.Towables = { --(configuration zone de spawn des véhicule à dépanner)
	vector3(-2480.9, -212.0, 17.4),
	vector3(-2723.4, 13.2, 15.1),
	vector3(-3169.6, 976.2, 15.0),
	vector3(-3139.8, 1078.7, 20.2),
	vector3(-1656.9, -246.2, 54.5),
	vector3(-1586.7, -647.6, 29.4),
	vector3(-1036.1, -491.1, 36.2),
	vector3(-1029.2, -475.5, 36.4),
	vector3(75.2, 164.9, 104.7),
	vector3(-534.6, -756.7, 31.6),
	vector3(487.2, -30.8, 88.9),
	vector3(-772.2, -1281.8, 4.6),
	vector3(-663.8, -1207.0, 10.2),
	vector3(719.1, -767.8, 24.9),
	vector3(-971.0, -2410.4, 13.3),
	vector3(-1067.5, -2571.4, 13.2),
	vector3(-619.2, -2207.3, 5.6),
	vector3(1192.1, -1336.9, 35.1),
	vector3(-432.8, -2166.1, 9.9),
	vector3(-451.8, -2269.3, 7.2),
	vector3(939.3, -2197.5, 30.5),
	vector3(-556.1, -1794.7, 22.0),
	vector3(591.7, -2628.2, 5.6),
	vector3(1654.5, -2535.8, 74.5),
	vector3(1642.6, -2413.3, 93.1),
	vector3(1371.3, -2549.5, 47.6),
	vector3(383.8, -1652.9, 37.3),
	vector3(27.2, -1030.9, 29.4),
	vector3(229.3, -365.9, 43.8),
	vector3(-85.8, -51.7, 61.1),
	vector3(-4.6, -670.3, 31.9),
	vector3(-111.9, 92.0, 71.1),
	vector3(-314.3, -698.2, 32.5),
	vector3(-366.9, 115.5, 65.6),
	vector3(-592.1, 138.2, 60.1),
	vector3(-1613.9, 18.8, 61.8),
	vector3(-1709.8, 55.1, 65.7),
	vector3(-521.9, -266.8, 34.9),
	vector3(-451.1, -333.5, 34.0),
	vector3(322.4, -1900.5, 25.8)
}

Config.Vehicles = { -- (configuration des voitures à dépanner)
	'adder',
	'asea',
	'asterope',
	'banshee',
	'buffalo',
	'sultan',
	'baller3'
}


for k,v in ipairs(Config.Towables) do
	Config.Zones['Towable' .. k] = {
		Pos   = v,
		Size  = { x = 1.5, y = 1.5, z = 1.0 },
		Color = { r = 204, g = 204, b = 0 },
		Type  = -1
	}
end

