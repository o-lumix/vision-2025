RegisterServerEvent('codem-nargile:server:setAlreadyHaveHookah')
AddEventHandler('codem-nargile:server:setAlreadyHaveHookah', function(masa, toggle)
    Masalar[masa].alreadyHaveHookah = toggle
    TriggerClientEvent('codem-nargile:client:getConfig', -1,  Masalar)
end)

RegisterServerEvent('codem-nargile:server:setSessionStarted')
AddEventHandler('codem-nargile:server:setSessionStarted', function(masa, toggle)
    Masalar[masa].sessionActive = toggle
    TriggerClientEvent('codem-nargile:client:getConfig', -1,  Masalar)
end)

RegisterServerEvent('codem-nargile:server:syncHookahTable')
AddEventHandler('codem-nargile:server:syncHookahTable', function(nargileler)
    TriggerClientEvent('codem-nargile:client:setHookahs', -1, nargileler)
end)

RegisterServerEvent("hookah_smokes")
AddEventHandler("hookah_smokes", function(entity,x,y,z)
	TriggerClientEvent("c_hookah_smokes", -1, entity,x,y,z)
end)

RegisterServerEvent('codem-nargile:server:deleteMarpuc')
AddEventHandler('codem-nargile:server:deleteMarpuc', function(masa)
    TriggerClientEvent('codem-nargile:client:deleteMarpuc', -1, masa)
end)

RegisterServerEvent('codem-nargile:server:deleteNargile')
AddEventHandler('codem-nargile:server:deleteNargile', function(masa)
    TriggerClientEvent('codem-nargile:client:deleteNargile', -1, masa)
end)


RegisterServerEvent('codem-nargile:server:syncKoz')
AddEventHandler('codem-nargile:server:syncKoz', function(obj, amount)
    TriggerClientEvent('codem-nargile:client:syncKoz', -1, obj, amount)
end)