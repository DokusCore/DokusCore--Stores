--------------------------------------------------------------------------------
---------------------------------- DokusCore -----------------------------------
--------------------------------------------------------------------------------
AliveNPCs = {}
InRange = false
MenuOpen = false
MenuPage = nil
PromptShop = nil
Location = nil
OpenShopGroup = GetRandomIntInRange(0, 0xffffff)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Spawn Store NPCs and Map Blips
--------------------------------------------------------------------------------
CreateThread(function()
  local Data = TSC('DokusCore:S:Core:DB:GetAll', { DB.Stores.GetAll })
  for k,v in pairs(Data) do
    local Coords = ConvertCoords(v.NPC)
    SpawnStoreNPC(v.Hash, Coords, v.Heading)
  end

  for k,v in pairs(Data) do
    local Coords = ConvertCoords(v.NPC)
    local blip = N_0x554d9d53f696d002(1664425300, Coords)
    SetBlipSprite(blip, 1475879922, 1)
		SetBlipScale(blip, 0.2)
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, v.Store..' Store')
  end
end)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Delete all NPCs when the resource stops
--------------------------------------------------------------------------------
AddEventHandler('onResourceStop', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then return end
  for k,v in pairs(AliveNPCs) do DeleteEntity(v) end
end)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Check Distance from the shops.
--------------------------------------------------------------------------------
Citizen.CreateThread(function()
  -- Wait(10000)
  OpenShop()
  DokusMenu.CreateMenu('StoreMenu', 'Store Menu', '')
  DokusMenu.SetSubTitle('StoreMenu', 'General Store')
  DokusMenu.CreateMenu('BuyPage', 'Buying Items')
  DokusMenu.SetSubTitle('BuyPage', 'General Store')
  DokusMenu.CreateMenu('SellPage', 'Selling Items')
  DokusMenu.SetSubTitle('SellPage', 'General Store')
  DokusMenu.CreateMenu('ManageMenu', 'Store Manager')
  DokusMenu.SetSubTitle('ManageMenu', 'Owner Menu')

  local Data = TSC('DokusCore:S:Core:DB:GetAll', { DB.Stores.GetAll })
  while true do Wait(1000)
    for k, v in pairs(Data) do
      local Coords = ConvertCoords(v.Coords)
      local IsClose = IsClose(Coords)
      if Location == nil and IsClose then Location = string.lower(v.Store) end
      if Location == string.lower(v.Store) then
        if not IsClose and InRange then InRange = false Location = nil OpenMenu = false MenuPage = nil end
        if IsClose and not InRange then Location = string.lower(v.Store) InRange = true
          TriggerEvent('DokusCore:Stores:C:StartScript')
        end
      end
    end
  end
end)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Check when backspace is used.
--------------------------------------------------------------------------------
RegisterNetEvent('DokusCore:Stores:C:BackCheck')
AddEventHandler('DokusCore:Stores:C:BackCheck', function()
  while MenuOpen do Wait(0)
    if IsControlJustPressed(0, _Keys['BACKSPACE']) then
        if MenuPage == 'StoreMenu' then DokusMenu.CloseMenu() MenuPage = nil MenuOpen = false
        elseif MenuPage == 'BuyPage' then DokusMenu.OpenMenu('StoreMenu') MenuPage = 'StoreMenu'
        elseif MenuPage == 'SellPage' then DokusMenu.OpenMenu('StoreMenu') MenuPage = 'StoreMenu'
        elseif MenuPage == 'ManageMenu' then DokusMenu.OpenMenu('StoreMenu') MenuPage = 'StoreMenu'
        end
      end
  end
end)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
local Warning = false
RegisterNetEvent('DokusCore:Stores:C:StartScript')
AddEventHandler('DokusCore:Stores:C:StartScript', function()
  while InRange do Wait(0)
    local ShopGroupName  = CreateVarString(10, 'LITERAL_STRING', "Shop")
    PromptSetActiveGroupThisFrame(OpenShopGroup, ShopGroupName)
    if PromptHasHoldModeCompleted(PromptShop) then
      DokusMenu.OpenMenu('StoreMenu')
      if not MenuOpen then
        MenuOpen = true MenuPage = 'StoreMenu'
        TriggerEvent('DokusCore:Stores:C:BackCheck')
        local User   = TSC('DokusCore:S:Core:GetCoreUserData')
        local Items  = TSC('DokusCore:S:Core:DB:GetAll', { DB.Items.GetAll })
        local Stores = TSC('DokusCore:S:Core:DB:GetAll', { DB.Stores.GetAll })
        local Stocks  = TSC('DokusCore:C:Core:DB:GetStore', { DB.Stores.GetStore, Location })[1][1]
        local Encode = json.decode(Stocks.Stock)

        while MenuOpen do Wait(0)
          local DokusPage = DokusMenu.IsMenuOpened
          if DokusPage('StoreMenu') then
            local BuyItem  = DokusMenu.Button('Buy Items')
            local SellItem = DokusMenu.Button('Sell Items')
            local Manager = DokusMenu.Button('Manage Store')
            if BuyItem then MenuPage = 'BuyPage' DokusMenu.OpenMenu('BuyPage') end
            if SellItem then MenuPage = 'SellPage' DokusMenu.OpenMenu('SellPage') end
            if Manager then MenuPage = 'ManageMenu' DokusMenu.OpenMenu('ManageMenu') end
          elseif DokusPage('BuyPage') then
            -- Set the store
            local Item, Store = false, nil
            for k,v in pairs(Stores) do if (string.lower(v.Store) == Location) then Store = Location end end
            -- Set the items of the store
            for k,v in pairs(Items) do
              local VT, SD, BW, TW = v.Valentine, v.Saint, v.Blackwater, v.Tumbleweed
              local RD, AR, ST = v.Rhodes, v.Armadillo, v.Strawberry

              if ((BW == 1) and Location == 'blackwater') then
                for i,p in pairs(Encode) do
                  local Button = DokusMenu.Button(v.Name, p.Stock.."               "..'$'..v.bPrice)
                  if Button then BuyCurrentItem(Store, User.Steam, User.CharID, v.Item, v.Name, v.Type, v.bPrice, v.Amount, v.Limit) end
                end
              end

              if ((VT == 1) and Location == 'valentine') then
                for i,p in pairs(Encode) do
                  if (v.Item == p.Item) then
                    local Button = DokusMenu.Button(v.Name, p.Stock.."               "..'$'..v.bPrice)
                    if Button then BuyCurrentItem(Store, User.Steam, User.CharID, v.Item, v.Name, v.Type, v.bPrice, v.Amount, v.Limit) end
                  end
                end
              end

              if ((SD == 1) and Location == 'saint denis') then
                for i,p in pairs(Encode) do
                  local Button = DokusMenu.Button(v.Name, p.Stock.."               "..'$'..v.bPrice)
                  if Button then BuyCurrentItem(Store, User.Steam, User.CharID, v.Item, v.Name, v.Type, v.bPrice, v.Amount, v.Limit) end
                end
              end

              if ((TW == 1) and Location == 'tumbleweed') then
                for i,p in pairs(Encode) do
                  local Button = DokusMenu.Button(v.Name, p.Stock.."               "..'$'..v.bPrice)
                  if Button then BuyCurrentItem(Store, User.Steam, User.CharID, v.Item, v.Name, v.Type, v.bPrice, v.Amount, v.Limit) end
                end
              end

              if ((RD == 1) and Location == 'rhodes') then
                for i,p in pairs(Encode) do
                  local Button = DokusMenu.Button(v.Name, p.Stock.."               "..'$'..v.bPrice)
                  if Button then BuyCurrentItem(Store, User.Steam, User.CharID, v.Item, v.Name, v.Type, v.bPrice, v.Amount, v.Limit) end
                end
              end

              if ((AR == 1) and Location == 'armadillo') then
                for i,p in pairs(Encode) do
                  local Button = DokusMenu.Button(v.Name, p.Stock.."               "..'$'..v.bPrice)
                  if Button then BuyCurrentItem(Store, User.Steam, User.CharID, v.Item, v.Name, v.Type, v.bPrice, v.Amount, v.Limit) end
                end
              end

              if ((ST == 1) and Location == 'strawberry') then
                for i,p in pairs(Encode) do
                  local Button = DokusMenu.Button(v.Name, p.Stock.."               "..'$'..v.bPrice)
                  if Button then BuyCurrentItem(Store, User.Steam, User.CharID, v.Item, v.Name, v.Type, v.bPrice, v.Amount, v.Limit) end
                end
              end
            end
          elseif DokusPage('SellPage') then
            -- Set the store
            local Item, Store = false, nil
            for k,v in pairs(Stores) do if (string.lower(v.Store) == Location) then Store = Location end end
            -- Set the items of the store
            for k,v in pairs(Items) do
              local VT, SD, BW, TW = v.Valentine, v.Saint, v.Blackwater, v.Tumbleweed
              local RD, AR, ST = v.Rhodes, v.Armadillo, v.Strawberry
              if ((BW == 1) and Location == 'blackwater') then
                local Button = DokusMenu.Button(v.Name, v.Amount.."               "..'$'..v.sPrice)
                if Button then SellCurrentItem(Store, User.Steam, User.CharID, v.Item, v.Name, v.Type, v.sPrice, v.Amount, v.Limit) end
              end

              if ((VT == 1) and Location == 'valentine') then
                local Button = DokusMenu.Button(v.Name, v.Amount.."               "..'$'..v.sPrice)
                if Button then SellCurrentItem(Store, User.Steam, User.CharID, v.Item, v.Name, v.Type, v.sPrice, v.Amount, v.Limit) end
              end

              if ((SD == 1) and Location == 'saint denis') then
                local Button = DokusMenu.Button(v.Name, v.Amount.."               "..'$'..v.sPrice)
                if Button then SellCurrentItem(Store, User.Steam, User.CharID, v.Item, v.Name, v.Type, v.sPrice, v.Amount, v.Limit) end
              end

              if ((TW == 1) and Location == 'tumbleweed') then
                local Button = DokusMenu.Button(v.Name, v.Amount.."               "..'$'..v.sPrice)
                if Button then SellCurrentItem(Store, User.Steam, User.CharID, v.Item, v.Name, v.Type, v.sPrice, v.Amount, v.Limit) end
              end

              if ((RD == 1) and Location == 'rhodes') then
                local Button = DokusMenu.Button(v.Name, v.Amount.."               "..'$'..v.sPrice)
                if Button then SellCurrentItem(Store, User.Steam, User.CharID, v.Item, v.Name, v.Type, v.sPrice, v.Amount, v.Limit) end
              end

              if ((AR == 1) and Location == 'armadillo') then
                local Button = DokusMenu.Button(v.Name, v.Amount.."               "..'$'..v.sPrice)
                if Button then SellCurrentItem(Store, User.Steam, User.CharID, v.Item, v.Name, v.Type, v.sPrice, v.Amount, v.Limit) end
              end

              if ((ST == 1) and Location == 'strawberry') then
                local Button = DokusMenu.Button(v.Name, v.Amount.."               "..'$'..v.sPrice)
                if Button then SellCurrentItem(Store, User.Steam, User.CharID, v.Item, v.Name, v.Type, v.sPrice, v.Amount, v.Limit) end
              end
            end
          elseif DokusPage('ManageMenu') then
            local Buy  = DokusMenu.Button('Buy Store')
            local Sell = DokusMenu.Button('Sell Store')
            local tOWner = DokusMenu.Button('Transer Ownership')
            local Stock = DokusMenu.Button('Manage Stock')

            if not Warning then
              Warning = true
              Note('These features are in the making, and will be released in a later version', 'TopRight', 5000)
            end
          end
          DokusMenu.Display()
        end
      end
    end
  end
end)
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
CreateThread(function() Wait(0)
  local Stocks = {}
  local Stores = TSC('DokusCore:S:Core:DB:GetAll', { DB.Stores.GetAll })
  for k,v in pairs(Stores) do
    if (v.Stock == nil) then
      local Items = TSC('DokusCore:S:Core:DB:GetAll', { DB.Items.GetAll })
      for i,p in pairs(Items) do table.insert(Stocks, { Item = p.Item, Stock = math.floor((p.sLimit / 2)), Limit = p.sLimit }) end
      local Encode = json.encode(Stocks)
      local Index = { DB.Stores.SetStock, Encode, v.Store }
      TSC('DokusCore:S:Core:DB:Stores:SetStock', Index)
    end
  end
end)






























--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
