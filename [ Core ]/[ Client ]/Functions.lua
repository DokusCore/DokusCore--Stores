--------------------------------------------------------------------------------
---------------------------------- DokusCore -----------------------------------
--------------------------------------------------------------------------------
function Note(txt, pos, time)
  TriggerEvent("pNotify:SendNotification", {
    text = "<height='40' width='40' style='float:left; margin-bottom:10px; margin-left:20px;' />"..txt,
    type = "success", timeout = time, layout = pos, queue = "right"
  })
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function SpawnStoreNPC(_, Coords, Heading)
  local _ = GetHashKey(_)
  while not HasModelLoaded(_) do RequestModel(_) Wait(1) end
  local StoreNPCs = Citizen.InvokeNative(0xD49F9B0955C367DE, _, Coords, Heading, 0, 0, 0, Citizen.ResultAsInteger())
  table.insert(AliveNPCs, StoreNPCs)
  Citizen.InvokeNative(0x1794B4FCC84D812F, StoreNPCs, 1) -- SetEntityVisible
  Citizen.InvokeNative(0x0DF7692B1D9E7BA7, StoreNPCs, 255, false) -- SetEntityAlpha
  Citizen.InvokeNative(0x283978A15512B2FE, StoreNPCs, true) -- SetRandomOutfitVariation
  Citizen.InvokeNative(0x7D9EFB7AD6B19754, StoreNPCs, true) -- FreezeEntityPosition
  Citizen.InvokeNative(0xDC19C288082E586E, StoreNPCs, 1, 1) --SetEntityAsMissionEntity
  Citizen.InvokeNative(0x919BE13EED931959, StoreNPCs, - 1) -- TaskStandStill
  Citizen.InvokeNative(0xC80A74AC829DDD92, StoreNPCs, _) -- SET_PED_RELATIONSHIP_GROUP_HASH
  Citizen.InvokeNative(0x4AD96EF928BD4F9A, StoreNPCs) -- SetModelAsNoLongerNeeded
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function OpenShop()
  Citizen.CreateThread(function()
    local str = "Browse"
    PromptShop = PromptRegisterBegin()
    PromptSetControlAction(PromptShop, _Keys['LALT'])
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(PromptShop, str)
    PromptSetEnabled(PromptShop, true)
    PromptSetVisible(PromptShop, true)
    PromptSetHoldMode(PromptShop, true)
    PromptSetGroup(PromptShop, OpenShopGroup)
    PromptRegisterEnd(PromptShop)
  end)
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function Distance(Coords)
  local Ped = PlayerPedId()
  local pCoords = GetEntityCoords(Ped)
  local Dist = Vdist(pCoords, Coords)
  return Dist
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function IsClose(Coords)
  local Ped = PlayerPedId()
  local pCoords = GetEntityCoords(Ped)
  local Dist = Vdist(pCoords, Coords)
  if (Dist <= 1.5) then return true else return false end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function BuyCurrentItem(Shop, Steam, CharID, Item, Name, Type, Price, Amount, Limit)
  -- Check if item is in stock
  local Stocks = {}
  local Stores = TSC('DokusCore:S:Core:DB:GetAll', {DB.Stores.GetAll})[1]
  local Decode = json.decode(Stores.Stock)
  local IsItem, xItem, xStock, xLimit = false, 0, 0, 0
  for k, v in pairs(Decode) do
    if (v.Item ~= Item) then table.insert(Stocks, v) end
    if (v.Item == Item) then IsItem, xItem, xStock, xLimit = true, v.Item, v.Stock, v.Limit end
  end

  if ((tonumber(xStock) - Amount) > 0) then
    local Type = string.lower(Type)
    local Index = { Item, Amount, nil }
    TSC('DokusCore:S:Core:DB:AddInventoryItem', {Steam, CharID, Type, Index})
    LetUserPay(Steam, CharID, Price)

    -- Set the new stock
    table.insert(Stocks, { Item = Item, Stock = (xStock - Amount), Limit = xLimit })
    local Encode = json.encode(Stocks)
    local Index = { DB.Stores.SetStock, Encode, Shop }
    TSC('DokusCore:S:Core:DB:Stores:SetStock', Index)
    Stocks = {}
  else
    Note(Name.." is currently out of stock! We are unable to sell this item at this time.", 'TopRight', 5000)
  end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function SellCurrentItem(Shop, Steam, CharID, Item, Name, Type, Price, Amount, Limit)
  local Stocks, HasItem = {}, false
  local Stores = TSC('DokusCore:S:Core:DB:GetAll', {DB.Stores.GetAll})
  local Invent = TSC('DokusCore:S:Core:DB:GetInventory', {Steam, CharID})
  local IsItem, xItem, xStock, xLimit = false, 0, 0, 0

  -- Stop the user if he or she does not have this item.
  for k,v in pairs(Invent) do if (v.Item == Item) then HasItem = true end end
  if not HasItem then Note("You've no item like this to sell!", 'TopRight', 5000) return end

  for k, v in pairs(Stores) do
    if (string.lower(v.Store) == Shop) then
      local Decode = json.decode(v.Stock)

      for k, v in pairs(Decode) do
        if (v.Item ~= Item) then table.insert(Stocks, v) end
        if (v.Item == Item) then
          IsItem, xItem, xStock, xLimit = true, v.Item, v.Stock, v.Limit
        end
      end
    end
  end

  -- Add new item to stock if not existing
  if (xItem == 0) then
    local Data = TSC('DokusCore:S:Core:DB:GetAll', {DB.Items.GetAll})
    for k, v in pairs(Data) do
      local sLimit = v.sLimit
      if (v.Item == Item) then
        -- Remove the item from the inventory
        local Index = { Item, Amount, Steam, CharID }
        TSC('DokusCore:S:Core:DB:DelInventoryItem', Index)
        PayTheUser(Steam, CharID, Price) -- Pay the user
        -- Update the stores stock for this item
        table.insert(Stocks, { Item = Item, Stock = Amount, Limit = sLimit })
        local Encode = json.encode(Stocks)
        local Index = { DB.Stores.SetStock, Encode, Shop }
        TSC('DokusCore:S:Core:DB:Stores:SetStock', Index)
        Stocks = {}
        return
      end
    end
  end

  -- Check if there is room in the stock
  if ((xStock + Amount) <= xLimit) then
    -- Remove the item from the inventory
    local Index = { Item, Amount, Steam, CharID }
    TSC('DokusCore:S:Core:DB:DelInventoryItem', Index)
    PayTheUser(Steam, CharID, Price) -- Pay the user
    -- Update the stores stock for this item
    table.insert(Stocks, { Item = Item, Stock = (xStock + Amount), Limit = xLimit })
    local Encode = json.encode(Stocks)
    local Index = { DB.Stores.SetStock, Encode, Shop }
    TSC('DokusCore:S:Core:DB:Stores:SetStock', Index)
    Stocks = {}
  else
    -- Refuse
    Note("Our stock is full, we can't hold anymore ".. Name, 'TopRight', 5000)
  end

end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function LetUserPay(Steam, CharID, Price)
  local Balance = 0
  local source = source
  local Bank = TSC('DokusCore:S:Core:DB:GetViaSteamAndCharID', {DB.Banks.Get, Steam, CharID})
  local Money, BankMoney = Bank[1].Money, Bank[1].BankMoney
  Balance = (tonumber(Money) - Price)
  local Index = { DB.Banks.SetMoney, 'Money', Balance, Steam, CharID }
  local Bank = TSC('DokusCore:S:Core:DB:UpdateViaSteamAndCharID', Index)
  local sID = TSC('DokusCore:S:Core:GetUserServerID')
  TriggerEvent('DokusCore:C:Core:Hud:Update', {Balance, BankMoney, CharID, sID})
  Note("You've bought an item", 'TopRight', 5000)
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function PayTheUser(Steam, CharID, Price)
  local Balance = 0
  local source = source
  local Bank = TSC('DokusCore:S:Core:DB:GetViaSteamAndCharID', {DB.Banks.Get, Steam, CharID})
  local Money, BankMoney = Bank[1].Money, Bank[1].BankMoney
  Balance = (tonumber(Money) + Price)
  local Index = { DB.Banks.SetMoney, 'Money', Balance, Steam, CharID }
  local Bank = TSC('DokusCore:S:Core:DB:UpdateViaSteamAndCharID', Index)
  local sID = TSC('DokusCore:S:Core:GetUserServerID')
  TriggerEvent('DokusCore:C:Core:Hud:Update', {Balance, BankMoney, CharID, sID})
  Note("You've sold an item", 'TopRight', 5000)
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function SplitString(s, d)
  result = {};
  for match in (s..d):gmatch("(.-)"..d) do table.insert(result, match); end
  return result;
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function ConvertToCoords(string)
  local Data = string.gsub(string, "{", "")
  local Data = string.gsub(Data, "}", "")
  local Data = string.gsub(Data, ",", "")
  return Data
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function ConvertCoords(Coords)
  local Data = ConvertToCoords(Coords)
  local Data = SplitString(Data, " ")
  local x, y, z = tonumber(Data[1]), tonumber(Data[2]), tonumber(Data[3])
  local Coords = vector3(x, y, z)
  return Coords
end



--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
