--------------------------------------------------------------------------------
----------------------------------- DevDokus -----------------------------------
--------------------------------------------------------------------------------
description 'DokusCore Stores'
author 'http://DokusCore.com'
fx_version "adamant"
games {"rdr3"}
version '1.0.0 BETA'
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
client_scripts { '[ Core ]/[ Client ]/*.lua' }
server_scripts { '@mysql-async/lib/MySQL.lua', '[ Core ]/[ Server ]/*.lua' }
shared_script {
  'Config.lua',
  '@DokusCore/Config.lua',
  '@DokusCore/[ Core ]/[ System ]/Callbacks.lua',
  '@DokusCore/[ Core ]/[ Server ]/[ Data ]/DBTables.lua',
  '@DokusCore/[ Core ]/[ System ]/Shared.lua',
  '@DokusCore/[ Core ]/[ System ]/[ Dependencies ]/DokusMenu.lua',
}
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
