--
-- For more information on config.lua see the Project Configuration Guide at:
-- https://docs.coronalabs.com/guide/basics/configSettings
--

application =
{
	content =
	{
		width = 768,
		height = 1024, 
		scale = "zoomEven", --Options "letterbox"(Content can be clipped) and "zoomEven" (black border edge can be shown)
		fps = 60,
		
		--[[
		imageSuffix =
		{
			    ["@2x"] = 2,
			    ["@4x"] = 4,
		},
		--]]
	},
}