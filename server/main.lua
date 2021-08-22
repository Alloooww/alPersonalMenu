ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('alPersonalMenu:WeaponAddAmmoToPedS')
AddEventHandler('alPersonalMenu:WeaponAddAmmoToPedS', function(plyId, value, quantity)
	if #(GetEntityCoords(source, false) - GetEntityCoords(plyId, false)) <= 3.0 then
		TriggerClientEvent('alPersonalMenu:WeaponAddAmmoToPedC', plyId, value, quantity)
	end
end)

ESX.RegisterServerCallback('alPersonalMenu:billing', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	local bills = {}

	MySQL.Async.fetchAll('SELECT * FROM billing WHERE identifier = @identifier', {
		['@identifier'] = xPlayer.identifier
	}, function(result)
		for i = 1, #result, 1 do
			table.insert(bills, {
				id = result[i].id,
				label = result[i].label,
				amount = result[i].amount
			})
		end

		cb(bills)
	end)
end)

-- Ⓒ Allooww | Si vous avez des questions : https://discord.gg/WAQbzUJQU8