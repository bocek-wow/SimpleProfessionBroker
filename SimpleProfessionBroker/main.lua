local addonName = ...

local playerName = UnitName("player")
local config = {}
local menu = {}
local defaultProfession = {}
local f = CreateFrame("Frame", addonName, UIParent, "UIDropDownMenuTemplate")

function PrintTable (tt, indent, done)
    done = done or {}
    indent = indent or 0
    if type(tt) == "table" then
      local sb = {}
      for key, value in pairs (tt) do
        table.insert(sb, string.rep (" ", indent)) -- indent it
        if type (value) == "table" and not done [value] then
          done [value] = true
          table.insert(sb, key .. " = {\n");
          table.insert(sb, PrintTable (value, indent + 2, done))
          table.insert(sb, string.rep (" ", indent)) -- indent it
          table.insert(sb, "}\n");
        elseif "number" == type(key) then
          table.insert(sb, string.format("\"%s\"\n", tostring(value)))
        else
          table.insert(sb, string.format(
              "%s = \"%s\"\n", tostring (key), tostring(value)))
         end
      end
      return table.concat(sb)
    else
      return tt .. "\n"
    end
end

function TableToString(tbl)
    if "nil" == type(tbl) then
        return tostring(nil)
    elseif "table" == type(tbl) then
        return PrintTable(tbl)
    elseif "string" == type(tbl) then
        return tbl
    else
        return tostring(tbl)
    end
end

local function OpenProfession(skillName, skillLine)
    if skillName == "Archaeology" then
        CastSpellByName(skillName)
    else
        if C_TradeSkillUI.GetTradeSkillLine() ~= nil then
            C_TradeSkillUI.CloseTradeSkill()
        else
            C_TradeSkillUI.OpenTradeSkill(skillLine)
        end
    end
end

local function SetDefaultProfession(profession)
    defaultProfession = profession
    config[playerName] = profession
end

local function UpdateBroker(skillName, icon)
    f.broker.text = skillName
    f.broker.icon = icon
end

local function BrokerOnEnter(frame)
    local showBelow = select(2, frame:GetCenter()) > UIParent:GetHeight() / 2
    local a1 = (showBelow and "TOP") or "BOTTOM"
    local a2 = (showBelow and "BOTTOM") or "TOP"

    UIDropDownMenu_SetAnchor(f, 0, 0, a1, frame, a2)
    EasyMenu(menu, f, nil, nil, nil, "MENU")
end

local function BrokerOnClick()
    OpenProfession(defaultProfession.name, defaultProfession.skillLine)
    UpdateBroker(defaultProfession.name, defaultProfession.icon)
    SetDefaultProfession(defaultProfession)
end

f.broker = LibStub("LibDataBroker-1.1"):NewDataObject(addonName, {
	type = "data source",
	text = "placeholder",
    icon = "",
    OnEnter = BrokerOnEnter,
    OnClick = BrokerOnClick
})

local function GetPlayerProfessions()
    local professionInfo = {}
    local professions = {GetProfessions()}

    for i, id in pairs(professions) do
        local name, icon, _, _, _, _, skillLine = GetProfessionInfo(id)
        local profession = {}
        profession["name"] = name
        profession["icon"] = icon
        profession["skillLine"] = skillLine
        professionInfo[i] = profession
    end

    return professionInfo
end

local function BrokerMenuOnClick(profession)
    OpenProfession(profession.name, profession.skillLine)
    UpdateBroker(profession.name, profession.icon)
    SetDefaultProfession(profession)
end

f:SetScript("OnEvent", function()
    SimpleProfessionBrokerDB = SimpleProfessionBrokerDB or {}
    config = SimpleProfessionBrokerDB

    local professionInfo = GetPlayerProfessions()

    menu[1] = {text = "Professions", isTitle = true, notCheckable = true}
    for i, profession in pairs(professionInfo) do
        local menuList = {icon = profession.icon, text = profession.name, func = function() BrokerMenuOnClick(profession) end, notCheckable = true}
        menu[i+1] = menuList
    end

    if config[playerName] ~= nil then
        local profession = config[playerName]
        UpdateBroker(profession.name, profession.icon)
        SetDefaultProfession(profession)
    else
        local profession = professionInfo[1]
        UpdateBroker(profession.name, profession.icon)
        SetDefaultProfession(profession)
    end
end)
f:RegisterEvent("ADDON_LOADED")


