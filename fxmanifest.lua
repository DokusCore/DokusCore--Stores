--------------------------------------------------------------------------------
----------------------------------- DevDokus -----------------------------------
--------------------------------------------------------------------------------
description 'DokusSync -- General Stores'
author 'http://DokusCore.com'
fx_version "adamant"
games {"rdr3"}
version '2.1.2'
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
client_scripts {
  '@DokusCore/[ Core ]/[ System ]/[ Client ]/CBSystem.lua',
  '@DokusCore/[ Core ]/[ Client ]/[ Utilities ]/Natives.lua',
  '@DokusCore/[ Core ]/[ Client ]/[ Utilities ]/Functions.lua',
  '[ Core ]/[ Client ]/*.lua',
}
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
server_scripts { '[ Core ]/[ Server ]/*.lua' }
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
shared_script {
  '@DokusCore/[ Configs ]/[ Core ]/Core.lua',
  '@DokusCore/[ Configs ]/[ Modules ]/Stores.lua',
  '@DokusCore/[ Configs ]/[ Dialogs ]/Stores.lua',
  '@DokusCore/[ Core ]/[ System ]/[ Shared ]/CBSystem.lua'
}
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
ui_page 'UI/index.html'
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
files {
  'UI/fonts/*',
  'UI/*',
  'UI/images/*',
  'UI/images/items/*',
	'UI/index.html',
	'UI/design.css',
	'UI/script.js',
	'UI/assets/*'
}
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
