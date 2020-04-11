
-- ***********************************************************
-- **                    Hydromancerx                       **
-- ***********************************************************

require "Items/SuburbsDistributions"
require "Items/ItemPicker"
IndustrializationTextureLoader = {}

local spriteNames = {
	"Industrialization_AutoMiner_1.png",
}

local function maskLoad(path)
	local tex = getTexture(path);
	tex:createMask(tex:getData());
	return tex;
end

-- Graphics
IndustrializationTextureLoader.getSprites = function()
    for k, v in pairs(spriteNames) do
        maskLoad(v);
        maskLoad("media/textures/".. v);
    end
	print("IndustrializationTextureLoader: Textures and Sprites Loaded.");
end


--print("Industrialization: SuburbsDistributions added.");

--Events.OnPreMapLoad.Add(IndustrializationTextureLoader.getSprites);
--Events.OnGameBoot.Add(IndustrializationTextureLoader.getSprites);

