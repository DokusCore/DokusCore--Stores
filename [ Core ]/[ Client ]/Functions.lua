--------------------------------------------------------------------------------
----------------------------------- DevDokus -----------------------------------
--------------------------------------------------------------------------------
----------------------- I feel a disturbance in the force ----------------------
--------------------------------------------------------------------------------
function FrameReady()
  local Data = TCTCC('DokuCore:Sync:Get:CoreData')
  return Data.FrameReady
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function UserInGame()
  local Data = TCTCC('DokusCore:Sync:Get:UserData')
  return Data.UserInGame
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function NREntryErr() Notify("You've not inserted a number, but inserted text or nothing!!") end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function Open(Type) TriggerEvent('DokusCore:Stores:OpenStore', Type) end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function SetInArea()
  print("Player Entered the Area")
  InArea = true
  TriggerEvent('DokusCore:Stores:CheckDistStore')
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function SetOutArea()
  print("Player Left the Area")
  InArea, Loc = false, nil
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function SetInStore()
  print("Player Entered the Store Area")
  InStore = true
  TriggerEvent('DokusCore:Stores:CheckDistNPC')
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function SetOutStore()
  print("Player Left the Store Area")
  InStore = false
  Array = {}
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function SetNearNPC()
  print("Player is near the npc")
  NearNPC = true
  TriggerEvent('DokusCore:Stores:ShowPrompt')
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function SetFarNPC()
  print("Player Left the npc")
  NearNPC = false
  StoreInUse = false
  Prompt, PromptGroup = nil, GetRandomIntInRange(0, 0xffffff)
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function PromptKey(Lang)
  CreateThread(function()
    local str = 'Buy'
    Prompt_Buy = PromptRegisterBegin()
    PromptSetControlAction(Prompt_Buy, _Keys['E'])
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(Prompt_Buy, str)
    PromptSetEnabled(Prompt_BuyPrompt_Buy, true)
    PromptSetVisible(Prompt_Buy, true)
    PromptSetHoldMode(Prompt_Buy, true)
    PromptSetGroup(Prompt_Buy, PromptGroup)
    PromptRegisterEnd(Prompt_Buy)

    local str = 'Sell'
    Prompt_Sell = PromptRegisterBegin()
    PromptSetControlAction(Prompt_Sell, _Keys['F'])
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(Prompt_Sell, str)
    PromptSetEnabled(Prompt_Sell, true)
    PromptSetVisible(Prompt_Sell, true)
    PromptSetHoldMode(Prompt_Sell, true)
    PromptSetGroup(Prompt_Sell, PromptGroup)
    PromptRegisterEnd(Prompt_Sell)

    local str = 'Manage'
    Prompt_Manage = PromptRegisterBegin()
    PromptSetControlAction(Prompt_Manage, _Keys['X'])
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(Prompt_Manage, str)
    PromptSetEnabled(Prompt_Manage, true)
    PromptSetVisible(Prompt_Manage, true)
    PromptSetHoldMode(Prompt_Manage, true)
    PromptSetGroup(Prompt_Manage, PromptGroup)
    PromptRegisterEnd(Prompt_Manage)
  end)
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function ResetStore()
  Radar(true)
  ShowCores(true)
  SetNuiFocus(false, false)
  NearNPC = false
  StoreInUse = false
  Prompt = nil
  PromptGroup = GetRandomIntInRange(0, 0xffffff)
  Array_Inv, Array_Store = {}, {}
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function CloseStore() SetNuiFocus(false, false) end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function IndexItemDataStore()
  local Data = TSC('DokusCore:Core:DBGet:Stores', { 'All' })
  if (Data.Result == nil) then return end
  for k,v in pairs(Data.Result) do
    table.insert(Array_Store, {
      Item = v.Item,
      Name = v.Name,
      Type = v.Type,
      Desc = v.Description,
      Buy  = v.Buy
    })
  end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function IndexItemDataInv()
  local Data  = TSC('DokusCore:Core:DBGet:Inventory', { 'User', 'All', { SteamID, CharID } })
  local Items = TSC('DokusCore:Core:DBGet:Stores', { 'All' }).Result
  if (Data.Result == nil) then return end
  for k,i in pairs(Data.Result) do
    for o,s in pairs(Items) do
      if (Low(i.Item) == Low(s.Item)) then
        table.insert(Array_Inv, {
          Item = i.Item,
          Name = s.Name,
          Type = s.Type,
          Desc = s.Description,
          Sell = s.Sell
        })
      end
    end
  end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function InsertInvItem(Item, Amount)
  TriggerServerEvent('DokusCore:Core:DBIns:Inventory', { 'User', 'InsertItem', { SteamID, CharID, 'Consumable', Item, Amount } })
  Message('Buy', Item, Amount)
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function AddInvItem(Item, Amount, Data)
  TriggerServerEvent('DokusCore:Core:DBSet:Inventory', { 'User', 'AddItem', { SteamID, CharID, Item, Amount, Data[1].Amount } })
  Message('Buy', Item, Amount)
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function DelInvItem(Item, Amount, Data)
  TriggerServerEvent('DokusCore:Core:DBDel:Inventory', { 'User', 'Item', { SteamID, CharID, Item } })
  Message('Sell', Item, Amount)
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function SetInvItem(Item, Amount, Data)
  TriggerServerEvent('DokusCore:Core:DBSet:Inventory', { 'User', 'RemoveItem', { SteamID, CharID, Item, Amount, Data } })
  Message('Sell', Item, Amount)
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function IndexAllData()
  Array_Inv, Array_Store = {}, {}
  IndexItemDataStore()
  IndexItemDataInv()
end

function OpenStore() IndexAllData() end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function OpenStoreBuy()
  StoreInUse = true
  Array_Inv, Array_Store = {}, {}
  IndexAllData()
  TriggerEvent('DokusCore:Stores:OpenStore', 'Buy')
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function OpenStoreSell()
  Array_Inv, Array_Store = {}, {}
  IndexAllData()
  StoreInUse = true
  TriggerEvent('DokusCore:Stores:OpenStore', 'Sell')
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
function Message(Type, Item, Amount)
  if (Type == 'NotEnough') then Notify("You do not have this much in your inventory!") end
  if (Type == 'InDev') then Notify('This Option is in developement!') Wait(5000) end
  if (Type == 'NoMinNumber') then Notify("You can not use negative numbers!") end
  if (Type == 'Buy') then Notify("You've bought "..Amount.." "..Item.."'s") end
  if (Type == 'Sell') then Notify("You've sold "..Amount.." "..Item.."'s") end
  if (Type == 'NoBuyMoney') then Notify("You've not enough money to buys this / these amount of items!") end
end
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------










--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
