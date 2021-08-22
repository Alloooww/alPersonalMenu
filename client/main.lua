ESX = nil



Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
	end

	ESX.PlayerData = ESX.GetPlayerData()

    AL.WeaponData = ESX.GetWeaponList()

	RefreshMoney()

	for i = 1, #AL.WeaponData, 1 do
		if AL.WeaponData[i].name == 'WEAPON_UNARMED' then
			AL.WeaponData[i] = nil
		else
			AL.WeaponData[i].hash = GetHashKey(AL.WeaponData[i].name)
		end
    end

	RMenu.Add('alPersonalMenu', 'alPersonalMenu:Main', RageUI.CreateMenu("Menu Personnel", "Menu Personnel"))
	RMenu.Add('alPersonalMenu', 'alPersonalMenu:Inventory', RageUI.CreateSubMenu(RMenu:Get('alPersonalMenu', 'alPersonalMenu:Main'), "Inventaire", "Gérer votre inventaire"))
	RMenu.Add('alPersonalMenu', 'alPersonalMenu:InventoryUse', RageUI.CreateSubMenu(RMenu:Get('alPersonalMenu', 'alPersonalMenu:Main'), "Inventaire", "Gérer votre inventaire"))
	RMenu.Add('alPersonalMenu', 'alPersonalMenu:InventoryWeapon', RageUI.CreateSubMenu(RMenu:Get('alPersonalMenu', 'alPersonalMenu:Main'), "Gestion Arme", "Gérer vos armes"))
	RMenu.Add('alPersonalMenu', 'alPersonalMenu:InventoryWeaponUse', RageUI.CreateSubMenu(RMenu:Get('alPersonalMenu', 'alPersonalMenu:Main'), "Gestion Arme", "Gérer vos armes"))
	RMenu.Add('alPersonalMenu', 'alPersonalMenu:Wallet', RageUI.CreateSubMenu(RMenu:Get('alPersonalMenu', 'alPersonalMenu:Main'), "Portefeuille", "Portefeuille"))
	RMenu.Add('alPersonalMenu', 'alPersonalMenu:Animations', RageUI.CreateSubMenu(RMenu:Get('alPersonalMenu', 'alPersonalMenu:Main'), "Gestions Animations", "Animations"))
	RMenu.Add('alPersonalMenu', 'alPersonalMenu:Vehicle', RageUI.CreateSubMenu(RMenu:Get('alPersonalMenu', 'alPersonalMenu:Main'), "Gestions Véhicule", "Véhicule"))
	RMenu.Add('alPersonalMenu', 'alPersonalMenu:Bills', RageUI.CreateSubMenu(RMenu:Get('alPersonalMenu', 'alPersonalMenu:Main'), "Factures", "Vos factures"))
	RMenu.Add('alPersonalMenu', 'alPersonalMenu:Info', RageUI.CreateSubMenu(RMenu:Get('alPersonalMenu', 'alPersonalMenu:Main'), "Informations", "Informations du serveur"))
	RMenu.Add('alPersonalMenu', 'alPersonalMenu:Settings', RageUI.CreateSubMenu(RMenu:Get('alPersonalMenu', 'alPersonalMenu:Main'), "Réglages", "Vos réglages"))
	RMenu.Add('alPersonalMenu', 'alPersonalMenu:SettingsPersoMenu', RageUI.CreateSubMenu(RMenu:Get('alPersonalMenu', 'alPersonalMenu:Main'), "Personalisation", "Personnaliser le menu"))
	RMenu.Add('alPersonalMenu', 'alPersonalMenu:SettingsPlayer', RageUI.CreateSubMenu(RMenu:Get('alPersonalMenu', 'alPersonalMenu:Main'), "Personnage", "Réglage du personnage"))
	RMenu.Add('alPersonalMenu', 'alPersonalMenu:SettingsVisual', RageUI.CreateSubMenu(RMenu:Get('alPersonalMenu', 'alPersonalMenu:Main'), "Visuel", "Réglage visuel"))
    RMenu:Get('alPersonalMenu', 'alPersonalMenu:Main'):SetSubtitle("Connecté en tant que : ~g~".. GetPlayerName(PlayerId()) .. '')
    RMenu:Get('alPersonalMenu', 'alPersonalMenu:Main').EnableMouse = false
	RMenu:Get('alPersonalMenu', 'alPersonalMenu:Main').Closed = function()

		A.alPersonalMenu = false
    end
end)

A = {
    alPersonalMenu = false,
}

AL= {
    ItemSelected = {},
    ItemSelected2 = {},
    WeaponData = {},
    Menu = false,
    Ped = PlayerPedId(),
    bank = nil,
    sale = nil,
    map = true,
    billing = {},
    visual = false,
    visual3 = false,
    visual5 = false,
}

AL.V = {
    VehPed = GetVehiclePedIsIn(AL.Ped, false),
    Get = GetVehiclePedIsUsing(AL.Ped),
    agauche = false,
    argauche = false,
    adroite = false,
    ardroite = false,
    capot = false,
    test = false
}

local ragdolling = false


function RefreshMoney()
	if ESX.PlayerData.job ~= nil and ESX.PlayerData.job.grade_name == 'boss' then
		ESX.TriggerServerCallback('esx_society:getSocietyMoney', function(money)
			societymoney = ESX.Math.GroupDigits(money)
		end, ESX.PlayerData.job.name)
	end
end

function ShowAboveRadarMessage(msg, flash, saveToBrief, hudColorIndex)
    if saveToBrief == nil then saveToBrief = true end
    AddTextEntry('notif', msg)
    BeginTextCommandThefeedPost('notif')
    if hudColorIndex then ThefeedNextPostBackgroundColor(hudColorIndex) end
    EndTextCommandThefeedPostTicker(flash or false, saveToBrief)
end

function CheckQuantity(number)
  number = tonumber(number)

  if type(number) == 'number' then
    number = ESX.Math.Round(number)

    if number > 0 then
      return true, number
    end
  end

  return false, number
end

function KeyboardInput(entryTitle, textEntry, inputText, maxLength)
    AddTextEntry(entryTitle, textEntry)
    DisplayOnscreenKeyboard(1, entryTitle, '', inputText, '', '', '', maxLength)
  
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
      Citizen.Wait(0)
    end
  
    if UpdateOnscreenKeyboard() ~= 2 then
      local result = GetOnscreenKeyboardResult()
      Citizen.Wait(500)
      return result
    else
      Citizen.Wait(500)
      return nil
    end
  end


RegisterNetEvent('es:activateMoney')
AddEventHandler('es:activateMoney', function(money)
	  ESX.PlayerData.money = money
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RegisterNetEvent('esx:setAccountMoney')
AddEventHandler('esx:setAccountMoney', function(account)
	for i=1, #ESX.PlayerData.accounts, 1 do
		if ESX.PlayerData.accounts[i].name == account.name then
			ESX.PlayerData.accounts[i] = account
			break
		end
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  ESX.PlayerData = xPlayer
end)

RegisterNetEvent('alPersonalMenu:WeaponAddAmmoToPedC') -- weapon
AddEventHandler('alPersonalMenu:WeaponAddAmmoToPedC', function(value, quantity)
  local weaponHash = GetHashKey(value)

    if HasPedGotWeapon(PlayerPed, weaponHash, false) and value ~= 'WEAPON_UNARMED' then
        AddAmmoToPed(PlayerPed, value, quantity)
    end
end)



function notificationmenu(msg)
    local mugshot, mugshotStr = ESX.Game.GetPedMugshot(PlayerPedId())
    ESX.ShowAdvancedNotification('Menu personnel', 'Informations', 'La couleur de votre menu à été ~g~sauvegardée', mugshotStr, 8)
    UnregisterPedheadshot(mugshot)
end

function notificationmenusave(msg)
    local mugshot, mugshotStr = ESX.Game.GetPedMugshot(PlayerPedId())
    ESX.ShowAdvancedNotification('Menu personnel', 'Informations', 'Votre personnage à été ~g~sauvegardée', mugshotStr, 8)
    UnregisterPedheadshot(mugshot)
end

function notificationmenuid(msg)
    local mugshot, mugshotStr = ESX.Game.GetPedMugshot(PlayerPedId())
    ESX.ShowAdvancedNotification('Menu personnel', 'Informations', 'Votre ID est le :~g~ '.. GetPlayerServerId(PlayerId()), mugshotStr, 8)
    UnregisterPedheadshot(mugshot)
end

local menuColor = {66, 173, 245}
Citizen.CreateThread(function()
    Wait(1000)
    menuColor[1] = GetResourceKvpInt("menuR")
    menuColor[2] = GetResourceKvpInt("menuG")
    menuColor[3] = GetResourceKvpInt("menuB")
    ReloadColor()
end)

local AllMenuToChange = nil
function ReloadColor()
    Citizen.CreateThread(function()
        if AllMenuToChange == nil then
            AllMenuToChange = {}
            for Name, Menu in pairs(RMenu['alPersonalMenu']) do
                if Menu.Menu.Sprite.Dictionary == "commonmenu" then
                    table.insert(AllMenuToChange, Name)
                end
            end
        end
        for k,v in pairs(AllMenuToChange) do
            RMenu:Get('alPersonalMenu', v):SetRectangleBanner(menuColor[1], menuColor[2], menuColor[3], 255)
        end
    end)
end

function openalPersonalMenu()
    if A.alPersonalMenu then
        A.alPersonalMenu = false
    else
        A.alPersonalMenu = true
        RageUI.Visible(RMenu:Get('alPersonalMenu', 'alPersonalMenu:Main'), true)

        Citizen.CreateThread(function()
			while A.alPersonalMenu do
				RageUI.IsVisible(RMenu:Get('alPersonalMenu', 'alPersonalMenu:Main'), true, true, true, function()
				RageUI.ButtonWithStyle("Inventaire", nil, {RightLabel = "→→"},true, function()
				end, RMenu:Get('alPersonalMenu', 'alPersonalMenu:Inventory'))

				RageUI.ButtonWithStyle("Portefeuille", nil, {RightLabel = "→→"},true, function()
				end, RMenu:Get('alPersonalMenu', 'alPersonalMenu:Wallet'))

				RageUI.ButtonWithStyle("Factures", nil, {RightLabel = "→→"},true, function()
				end, RMenu:Get('alPersonalMenu', 'alPersonalMenu:Bills'))

				RageUI.ButtonWithStyle("Animations",nil, {RightLabel = "→→"}, true, function(Hovered, Active, Selected)
					if Selected then
					TriggerEvent("dp:RecieveMenu")
					RageUI.CloseAll()
					end
				end)

				RageUI.ButtonWithStyle("Infos", nil, {RightLabel = "→→"},true, function()
				end, RMenu:Get('alPersonalMenu', 'alPersonalMenu:Info'))

				RageUI.ButtonWithStyle("Réglages", nil, {RightLabel = "→→"},true, function()
				end, RMenu:Get('alPersonalMenu', 'alPersonalMenu:Settings'))

				if IsPedSittingInAnyVehicle(AL.Ped) then
				 	RageUI.ButtonWithStyle("Géstion du Véhicule", nil, {RightLabel = "→→"},true, function()
					end, RMenu:Get('alPersonalMenu', 'alPersonalMenu:Vehicle'))
				end
			
			end)


		RageUI.IsVisible(RMenu:Get('alPersonalMenu', 'alPersonalMenu:Bills'), true, true, true, function()

			if #AL.billing == 0 then
				RageUI.ButtonWithStyle("Aucune facture", nil, { RightLabel = "→" }, true, function(Hovered, Active, Selected)
					if (Selected) then
					end
				end)
			end
				
			for i = 1, #AL.billing, 1 do
			RageUI.ButtonWithStyle(AL.billing[i].label, nil, {RightLabel = '[~b~$' .. ESX.Math.GroupDigits(AL.billing[i].amount.."~s~] →")}, true, function(Hovered,Active,Selected)
				if Selected then
						ESX.TriggerServerCallback('esx_billing:payBill', function()
						ESX.TriggerServerCallback('VInventory:billing', function(bills) AL.billing = bills end)
								end)
							end
						end)
					end
			  --  end)
		end, function()
		end)

		RageUI.IsVisible(RMenu:Get('alPersonalMenu', 'alPersonalMenu:Info'), true, true, true, function()

			RageUI.Separator("IP du serveur          127.0.0.1")

			RageUI.Separator("↓   ↓   ↓")

			RageUI.Separator("Discord du serveur          discord.gg/ntm")

		end, function()
		end)

		RageUI.IsVisible(RMenu:Get('alPersonalMenu', 'alPersonalMenu:Settings'), true, true, true, function()

			RageUI.ButtonWithStyle("Personnalisation du menu", nil, {RightLabel = "→→"},true, function()
			end, RMenu:Get('alPersonalMenu', 'alPersonalMenu:SettingsPersoMenu'))

			RageUI.ButtonWithStyle("Réglages du personnage", nil, {RightLabel = "→→"},true, function()
			end, RMenu:Get('alPersonalMenu', 'alPersonalMenu:SettingsPlayer'))

			RageUI.ButtonWithStyle("Réglages visuel", nil, {RightLabel = "→→"},true, function()
			end, RMenu:Get('alPersonalMenu', 'alPersonalMenu:SettingsVisual'))

		end, function()
		end)

		RageUI.IsVisible(RMenu:Get('alPersonalMenu', 'alPersonalMenu:Vehicle'), true, true, true, function()
			RageUI.Separator("Plaque d'immatriculation : ~r~"..GetVehicleNumberPlateText(AL.V.VehPed).."")
	
			RageUI.ButtonWithStyle("~g~Allumer~s~ / ~r~Eteindre~s~ votre moteur", nil, {RightBadge = RageUI.BadgeStyle.Car}, true, function(Hovered,Active,Selected) 
				if Selected then
					if GetIsVehicleEngineRunning(AL.V.VehPed) then
							SetVehicleEngineOn(AL.V.VehPed, false, false, true)
							SetVehicleUndriveable(AL.V.VehPed, true)
					elseif not GetIsVehicleEngineRunning(AL.V.VehPed) then
							SetVehicleEngineOn(AL.V.VehPed, true, false, true)
							SetVehicleUndriveable(AL.V.VehPed, false)
					end
				end
			end)

			RageUI.ButtonWithStyle("Ouvrir / Fermer Avant Gauche", nil, {RightLabel = "→"}, true, function(Hovered,Active,Selected)
				if Selected then
						SetVehicleDoorOpen(AL.V.VehPed, 0, AL.V.agauche)
							AL.V.agauche = not AL.V.agauche
						end
					end)

			RageUI.ButtonWithStyle("Ouvrir / Fermer Avant Droite", nil, {RightLabel = "→"}, true, function(Hovered,Active,Selected)
				if Selected then
					if not AL.V.adroite then
						AL.V.adroite = true
						SetVehicleDoorOpen(AL.V.VehPed, 1, false, false)
					elseif AL.V.adroite then
						AL.V.adroite = false
						SetVehicleDoorShut(AL.V.VehPed, 1, false, false)
						end
					end
				end)

			RageUI.ButtonWithStyle("Ouvrir / Fermer Arrière Gauche", nil, {RightLabel = "→"}, true, function(Hovered,Active,Selected)
				if Selected then
					if not AL.V.argauche then
						AL.V.argauche = true
						SetVehicleDoorOpen(AL.V.VehPed, 2, false, false)
					elseif AL.V.argauche then
						AL.V.argauche = false
						SetVehicleDoorShut(AL.V.VehPed, 2, false, false)
						end
					end
				end)

			RageUI.ButtonWithStyle("Ouvrir / Fermer Arrière Droite", nil, {RightLabel = "→"}, true, function(Hovered,Active,Selected)
				if Selected then
					if not AL.V.ardroite then
						AL.V.ardroite = true
						SetVehicleDoorOpen(AL.V.VehPed, 3, false, false)
					elseif AL.V.ardroite then
						AL.V.ardroite = false
						SetVehicleDoorShut(AL.V.VehPed, 3, false, false)
						end
					end
				end)

				RageUI.ButtonWithStyle("Ouvrir / Fermer Capot", nil, {RightLabel = "→"}, true, function(Hovered,Active,Selected) 
					if Selected then
						if not AL.V.capot then
							AL.V.capot = true
							SetVehicleDoorOpen(AL.V.VehPed, 4, false, false)
						elseif AL.V.capot then
							AL.V.capot = false
							SetVehicleDoorShut(AL.V.VehPed, 4, false, false)
							end
						end
				end)


		end, function()
		end)

		RageUI.IsVisible(RMenu:Get('alPersonalMenu', 'alPersonalMenu:InventoryWeapon'), true, true, true, function()

			RageUI.Separator("~r~Vos armes")

			ESX.PlayerData = ESX.GetPlayerData()
                    for i = 1, #AL.WeaponData, 1 do
                        if HasPedGotWeapon(AL.Ped, AL.WeaponData[i].hash, false) then
                            local ammo = GetAmmoInPedWeapon(AL.Ped, AL.WeaponData[i].hash)
            
                            RageUI.ButtonWithStyle('[~r~' ..ammo.. '~s~] ~b~- ~s~' ..AL.WeaponData[i].label, nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
                                if (Selected) then
                                    AL.ItemSelected = AL.WeaponData[i]
                                end
                            end,RMenu:Get('alPersonalMenu', 'alPersonalMenu:InventoryWeaponUse'))
                        end
                    end
		end, function()
		end)

		RageUI.IsVisible(RMenu:Get('alPersonalMenu', 'alPersonalMenu:InventoryWeaponUse'), true, true, true, function() 
			RageUI.ButtonWithStyle('~b~Donner~w~ des munitions', nil, {RightBadge = RageUI.BadgeStyle.Ammo}, true, function(Hovered, Active, Selected)
				if (Selected) then
					local post, quantity = CheckQuantity(KeyboardInput('Nombre de munitions', '180'), '', 8)

					if post then
						local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

						if closestDistance ~= -1 and closestDistance <= 3 then
							local closestPed = GetPlayerPed(closestPlayer)
							local pPed = GetPlayerPed(-1)
							local coords = GetEntityCoords(pPed)
							local x,y,z = table.unpack(coords)
							DrawMarker(2, x, y, z+1.5, 0, 0, 0, 180.0,nil,nil, 0.5, 0.5, 0.5, 0, 0, 255, 120, true, true, p19, true)

							if IsPedOnFoot(closestPed) then
								local ammo = GetAmmoInPedWeapon(AL.Ped, AL.ItemSelected.hash)

								if ammo > 0 then
									if quantity <= ammo and quantity >= 0 then
										local finalAmmo = math.floor(ammo - quantity)
										SetPedAmmo(AL.Ped, AL.ItemSelected.name, finalAmmo)

										TriggerServerEvent('alPersonalMenu:WeaponAddAmmoToPedS', GetPlayerServerId(closestPlayer), AL.ItemSelected.name, quantity)
										ShowAboveRadarMessage('Vous avez donné x%s munitions à %s', quantity, GetPlayerName(closestPlayer))
										--RageUI.CloseAll()
									else
										ShowAboveRadarMessage('Vous ne possédez pas autant de munitions')
									end
								else
									ShowAboveRadarMessage("Vous n'avez pas de munition")
								end
							else
								ShowAboveRadarMessage('Vous ne pouvez pas donner des munitions dans un ~~r~véhicule~s~', AL.ItemSelected.label)
							end
						else
							ShowAboveRadarMessage('Aucun joueur ~r~proche~s~ !')
						end
					else
						ShowAboveRadarMessage('Nombre de munition ~r~invalid')
					end
				end
			end)
			
			RageUI.ButtonWithStyle("~r~Jeter~w~ l'arme", nil, {RightBadge = RageUI.BadgeStyle.Gun}, true, function(Hovered, Active, Selected)
				if Selected then
					if IsPedOnFoot(AL.Ped) then
						TriggerServerEvent('esx:removeInventoryItem', 'item_weapon', AL.ItemSelected.name)
						--RageUI.CloseAll()
					else
						ShowAboveRadarMessage("~r~Impossible~s~ de jeter l'armes dans un véhicule", AL.ItemSelected.label)
					end
				end
			end)

			if HasPedGotWeapon(AL.Ped, AL.ItemSelected.hash, false) then
				RageUI.ButtonWithStyle("~b~Donner~w~ l'arme", nil, {RightBadge = RageUI.BadgeStyle.Gun}, true, function(Hovered, Active, Selected)
					if Selected then
						local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

					if closestDistance ~= -1 and closestDistance <= 3 then
						local closestPed = GetPlayerPed(closestPlayer)
						local pPed = GetPlayerPed(-1)
						local coords = GetEntityCoords(pPed)
						local x,y,z = table.unpack(coords)
						DrawMarker(2, x, y, z+1.5, 0, 0, 0, 180.0,nil,nil, 0.5, 0.5, 0.5, 0, 0, 255, 120, true, true, p19, true)

						if IsPedOnFoot(closestPed) then
							local ammo = GetAmmoInPedWeapon(AL.Ped, AL.ItemSelected.hash)
							TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_weapon', AL.ItemSelected.name, ammo)
							--seAll()
						else
							ShowAboveRadarMessage('~r~Impossible~s~ de donner une arme dans un véhicule', AL.ItemSelected.label)
						end
					else
						ShowAboveRadarMessage('Aucun joueur ~r~proche !')
					end
				end
			end)
		end
		end,function()
		end)

		RageUI.IsVisible(RMenu:Get('alPersonalMenu', 'alPersonalMenu:SettingsPersoMenu'), true, true, true, function()
			local self = RMenu:Get('alPersonalMenu', 'alPersonalMenu:SettingsPersoMenu')
            self.EnableMouse = true

			RageUI.Separator("~r~Personnalise la couleur du menu")

			RageUI.Progress("Rouge", menuColor[1], 255, nil, true, true,function(Hovered, Active, Selected,Color)
				menuColor[1] = Color
				ReloadColor()
			end)
		
			RageUI.Progress("Vert", menuColor[2], 255, nil, true, true,function(Hovered, Active, Selected,Color)
				menuColor[2] = Color
				ReloadColor()
			end)
		
			RageUI.Progress("Bleu", menuColor[3], 255, nil, true, true,function(Hovered, Active, Selected,Color)
				menuColor[3] = Color
				ReloadColor()
			end)

			RageUI.ButtonWithStyle("Sauvegarder la couleur", nil, { RightBadge = RageUI.BadgeStyle.Tick }, true, function(Hovered, Active, Selected)
				if Selected then
					SetResourceKvpInt("menuR", menuColor[1])
					SetResourceKvpInt("menuG", menuColor[2])
					SetResourceKvpInt("menuB", menuColor[3])
					ReloadColor()
					notificationmenu()
					PlaySoundFrontend(-1, "HACKING_SUCCESS", 0, 1)
				end
			end)
		end, function()
		end)

		RageUI.IsVisible(RMenu:Get('alPersonalMenu', 'alPersonalMenu:SettingsVisual'), true, true, true, function()

			RageUI.Separator("~r~Réglage visuel")

			RageUI.Checkbox("Vue & lumières améliorées", description, AL.visual, {}, function(Hovered, Selected, Active, Checked) 
				if Selected then 
					AL.visual = Checked
					if Checked then
						SetTimecycleModifier('tunnel')
					else
						SetTimecycleModifier('')
					end
				end 
			end)

			RageUI.Checkbox("Noir & blancs", description, AL.visual3, {}, function(Hovered, Selected, Active, Checked) 
				if Selected then 
					AL.visual3 = Checked
					if Checked then
						SetTimecycleModifier('rply_saturation_neg')
					else
						SetTimecycleModifier('')
					end
				end 
			end)

			RageUI.Checkbox("Vue optimisée", description, AL.visual5, {}, function(Hovered, Selected, Active, Checked) 
				if Selected then 
					AL.visual5 = Checked
					if Checked then
						SetTimecycleModifier('yell_tunnel_nodirect')
					else
						SetTimecycleModifier('')
					end
				end 
			end)

		end, function()
		end)

		RageUI.IsVisible(RMenu:Get('alPersonalMenu', 'alPersonalMenu:SettingsPlayer'), true, true, true, function()

			RageUI.Separator("~r~Réglage du personnage")
			
			RageUI.Checkbox("Activer / Désactiver la map", description, AL.map,{},function(Hovered,Ative,Selected,Checked)
				if Selected then
					AL.map = Checked
					if Checked then
						DisplayRadar(true)
					else
						DisplayRadar(false)
					end
				end
			end)

			RageUI.ButtonWithStyle("S'endormir", description, {RightLabel = ""}, true, function(Hovered, Active, Selected) 
				if (Selected) then
					ragdolling = not ragdolling
					while ragdolling do
					 Wait(0)
					local myPed = GetPlayerPed(-1)
					SetPedToRagdoll(myPed, 1000, 1000, 0, 0, 0, 0)
					ResetPedRagdollTimer(myPed)
					AddTextEntry(GetCurrentResourceName(), ('Appuyez sur ~INPUT_JUMP~ pour vous ~g~réveiller'))
					DisplayHelpTextThisFrame(GetCurrentResourceName(), false)
					ResetPedRagdollTimer(myPed)
					if IsControlJustPressed(0, 22) then 
					break
				end
			end
			end
			end)

			RageUI.ButtonWithStyle("Savoir votre ID", nil, { RightLabel = "" },true, function(_,_,Selected)
				if (Selected) then
					notificationmenuid()
					PlaySoundFrontend(-1, "HACKING_SUCCESS", 0, 1)

				end
			end)

			RageUI.ButtonWithStyle("Sauvegarder votre personnage", nil, { RightBadge = RageUI.BadgeStyle.Tick }, true, function(Hovered, Active, Selected)
				if Selected then
					TriggerEvent('esx_skin:requestSaveSkin', source)
					Citizen.Wait(500)
					notificationmenusave()
					PlaySoundFrontend(-1, "HACKING_SUCCESS", 0, 1)
				end
			end)
		end, function()
		end)

		RageUI.IsVisible(RMenu:Get('alPersonalMenu', 'alPersonalMenu:InventoryUse'), true, true, true, function()
                    
			RageUI.ButtonWithStyle("~g~Utiliser~w~ l'item", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
				if (Selected) then
				   -- local NumerItems = KeyboardInput("Combiens d'items voulez-vous utiliser ?", "", 3)
				 if AL.ItemSelected.usable then
					 TriggerServerEvent('esx:useItem', AL.ItemSelected.name)
					else
						ShowAboveRadarMessage('l\'item n\'est pas utilisable', AL.ItemSelected.label)
						end
					end
				end) 

				RageUI.ButtonWithStyle("~b~Donner~w~ l'item", nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected)
					if (Selected) then
						local sonner,quantity = CheckQuantity(KeyboardInput("Nombres d'items que vous voulez donner", '', '', 100))
						local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
						local pPed = GetPlayerPed(-1)
						local coords = GetEntityCoords(pPed)
						local x,y,z = table.unpack(coords)
						DrawMarker(2, x, y, z+1.5, 0, 0, 0, 180.0,nil,nil, 0.5, 0.5, 0.5, 0, 0, 255, 120, true, true, p19, true)
	
						if sonner then
							if closestDistance ~= -1 and closestDistance <= 3 then
								local closestPed = GetPlayerPed(closestPlayer)
	
								if IsPedOnFoot(closestPed) then
										TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_standard', AL.ItemSelected.name, quantity)
										--RageUI.CloseAll()
									else
										ShowAboveRadarMessage("~∑~ Nombres d'items invalid !")
									end
								--else
									--ShowAboveRadarMessage("~∑~ Tu ne peux pas donner d'items dans un véhicule !", AL.ItemSelected.label
							else
								ShowAboveRadarMessage("∑ Aucun joueur ~r~Proche~n~ !")
								end
							end
						end
					end)

				RageUI.ButtonWithStyle("~r~Jeter ~w~l'item", nil, {RightBadge = RageUI.BadgeStyle.Alert}, true, function(Hovered, Active, Selected)
					if (Selected) then
						if AL.ItemSelected.canRemove then
							local post,quantity = CheckQuantity(KeyboardInput("Nombres d'items que vous voulez jeter", '', '', 100))
							if post then
								if not IsPedSittingInAnyVehicle(PlayerPed) then
									TriggerServerEvent('esx:removeInventoryItem', 'item_standard', AL.ItemSelected.name, quantity)
									--RageUI.CloseAll()
								end
							end
						end
					end
				end)
				end,function()
			end)

			RageUI.IsVisible(RMenu:Get('alPersonalMenu', 'alPersonalMenu:Wallet'), true, true, true, function() 

				RageUI.Separator("~r~Votre portefeuille ")

				RageUI.ButtonWithStyle("~b~Donner~s~ de l'argent liquide" , nil, {RightLabel = "→"}, true, function(Hovered,Active,Selected)
					if Selected then
						local black, quantity = CheckQuantity(KeyboardInput("Somme d'argent que vous voulez donner", '', '', 1000))
							if black then
								local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()

						if closestDistance ~= -1 and closestDistance <= 3 then
							local closestPed = GetPlayerPed(closestPlayer)

							if not IsPedSittingInAnyVehicle(closestPed) then
								TriggerServerEvent('esx:giveInventoryItem', GetPlayerServerId(closestPlayer), 'item_money', ESX.PlayerData.money, quantity)
								--RageUI.CloseAll()
							else
							   ShowAboveRadarMessage(_U('Vous ne pouvez pas donner ', 'de l\'argent dans un véhicles'))
							end
						else
						   ShowAboveRadarMessage('Aucun joueur proche !')
						end
					else
					   ShowAboveRadarMessage('Somme invalid')
					end
				end
			end)

			RageUI.ButtonWithStyle("~r~Jeter~s~ de l'argent liquide", nil, {RightBadge = RageUI.BadgeStyle.Alert}, true, function(Hovered, Active, Selected)
				if Selected then
					local black, quantity = CheckQuantity(KeyboardInput("Somme d'argent que vous voulez jeter", '', '', 1000))
					if black then
						if not IsPedSittingInAnyVehicle(PlayerPed) then
							TriggerServerEvent('esx:removeInventoryItem', 'item_money', ESX.PlayerData.money, quantity)
							--RageUI.CloseAll()
								else
								   ShowAboveRadarMessage('Vous pouvez pas jeter', 'de l\'argent')
									end
								else
								   ShowAboveRadarMessage('Somme Invalid')
								end
							end
			end)
			
			RageUI.ButtonWithStyle("Votre métier", nil, {RightLabel = "~r~"..ESX.PlayerData.job.label .. " - " .. ESX.PlayerData.job.grade_label .."~s~"}, true, function(Hovered, Active, Selected)
				if Selected then
				end
			end)

			RageUI.ButtonWithStyle("Votre Argent", nil, {RightLabel = "~g~" .. ESX.PlayerData.money .. "$~s~"}, true, function(Hovered, Active, Selected)
				if Selected then
				end
			end)

		end)

		RageUI.IsVisible(RMenu:Get('alPersonalMenu', 'alPersonalMenu:Inventory'), true, true, true, function()

			RageUI.ButtonWithStyle("Gérer vos armes", nil, {RightLabel = "→→"},true, function()
			end, RMenu:Get('alPersonalMenu', 'alPersonalMenu:InventoryWeapon'))

			RageUI.Separator("~r~Votre inventaire")


			ESX.PlayerData = ESX.GetPlayerData()
                    for i = 1, #ESX.PlayerData.inventory do
                        if ESX.PlayerData.inventory[i].count > 0 then
                            RageUI.ButtonWithStyle('[~g~' ..ESX.PlayerData.inventory[i].count.. '~s~] ~b~- ~s~' ..ESX.PlayerData.inventory[i].label, nil, {RightLabel = "→"}, true, function(Hovered, Active, Selected) 
                                if (Selected) then 
                                    AL.ItemSelected = ESX.PlayerData.inventory[i]
                                    end 
                                end, RMenu:Get('alPersonalMenu', 'alPersonalMenu:InventoryUse'))
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
        Citizen.Wait(0)
		if IsControlJustPressed(0,166) then
			openalPersonalMenu() 
            RageUI.IsVisible(RMenu:Get('alPersonalMenu', 'alPersonalMenu:Main'), not RageUI.IsVisible(RMenu:Get('alPersonalMenu', 'alPersonalMenu:Main')))
        end
    end
end)

-- Ⓒ Allooww | Si vous avez des questions : https://discord.gg/WAQbzUJQU8