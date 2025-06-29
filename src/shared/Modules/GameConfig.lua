local Config = {}
-- 106523725468780 - anime girl huzz 
Config.Rarities = {
    Common = { Color = Color3.fromRGB(150, 150, 150) },
    Uncommon = { Color = Color3.fromRGB(50, 200, 50) },
    Rare = { Color = Color3.fromRGB(50, 100, 255) },
    Epic = { Color = Color3.fromRGB(150, 50, 255) },
    Legendary = { Color = Color3.fromRGB(255, 150, 50) },
    Mythical = { Color = Color3.fromRGB(255, 50, 150) },
    Celestial = { Color = Color3.fromRGB(0, 255, 255) },
    Divine = { Color = Color3.fromRGB(255, 255, 100) },
    Transcendent = { Color = Color3.fromRGB(255, 100, 255) },
    Ethereal = { Color = Color3.fromRGB(220, 220, 255) },
    Quantum = { Color = Color3.fromRGB(50, 20, 80) },
    Godly = { Color = Color3.fromRGB(255, 215, 0) },
    
    -- Ultra-Premium Limited Rarities
    Limited = { Color = Color3.fromRGB(255, 20, 147) },      -- Deep Pink - For classic limiteds
    Vintage = { Color = Color3.fromRGB(184, 134, 11) },     -- Antique Gold - For vintage items
    Exclusive = { Color = Color3.fromRGB(138, 43, 226) },   -- Blue Violet - For exclusive limiteds
    Ultimate = { Color = Color3.fromRGB(255, 0, 0) },       -- Pure Red - For ultimate limiteds
    Dominus = { Color = Color3.fromRGB(0, 0, 0) },          -- Pure Black - For Dominus items only
    BRAINROT = { Color = Color3.fromRGB(180, 0, 255) },     -- Purple-pink for brainrot meme rarity
}

Config.Items = {
    -- Common UGC Items (R$ 10 - 50)
    ["Basic Cap"] = { 
        Rarity = "Common", 
        Value = 10, 
        AssetId = 12608560678,
        Type = "Hat",
        Description = "A simple cap perfect for everyday wear."
    },
    ["Plain T-Shirt"] = { 
        Rarity = "Common", 
        Value = 15, 
        AssetId = 15960290658,
        Type = "Shirt",
        Description = "A basic t-shirt in classic white."
    },
    ["Simple Pants"] = { 
        Rarity = "Common", 
        Value = 20, 
        AssetId = 12331810734,
        Type = "Pants",
        Description = "Comfortable everyday pants."
    },
    ["Basic Glasses"] = { 
        Rarity = "Common", 
        Value = 25, 
        AssetId = 12568844178,
        Type = "Face",
        Description = "Simple reading glasses for a smart look."
    },
    ["School Backpack"] = { 
        Rarity = "Common", 
        Value = 30, 
        AssetId = 15750709511,
        Type = "Back",
        Description = "A practical backpack for carrying your belongings."
    },
    ["White Sneakers"] = { 
        Rarity = "Common", 
        Value = 35, 
        AssetId = 13905362703,
        Type = "Shoes",
        Description = "Clean white sneakers for any occasion."
    },

    -- Uncommon UGC Items (R$ 50 - 250)
    ["Stylish Hat"] = { 
        Rarity = "Uncommon", 
        Value = 55, 
        AssetId = 95868078367137,
        Type = "Hat",
        Description = "A trendy hat that stands out from the crowd."
    },
    ["Cool Hoodie"] = { 
        Rarity = "Uncommon", 
        Value = 75, 
        AssetId = 14784743786,
        Type = "Shirt",
        Description = "A comfortable hoodie with a modern design."
    },
    ["Designer Jeans"] = { 
        Rarity = "Uncommon", 
        Value = 90, 
        AssetId = 93307791450624,
        Type = "Pants",
        Description = "Stylish jeans with premium denim fabric."
    },
    ["Sunglasses"] = { 
        Rarity = "Uncommon", 
        Value = 110, 
        AssetId = 15171164330,
        Type = "Face",
        Description = "Cool sunglasses that block out the haters."
    },
    ["Sports Watch"] = { 
        Rarity = "Uncommon", 
        Value = 150, 
        AssetId = 15713273681,
        Type = "Front",
        Description = "A digital sports watch for tracking your activities."
    },
    ["Leather Jacket"] = { 
        Rarity = "Uncommon", 
        Value = 200, 
        AssetId = 7192549218,
        Type = "Shirt",
        Description = "A classic leather jacket that never goes out of style."
    },

    -- Rare UGC Items (R$ 250 - 1,000)
    ["Gaming Headset"] = { 
        Rarity = "Rare", 
        Value = 260, 
        AssetId = 6097845436,
        Type = "Hat",
        Description = "Professional gaming headset with crystal clear audio."
    },
    ["Neon Jacket"] = { 
        Rarity = "Rare", 
        Value = 350, 
        AssetId = 14971476921,
        Type = "Shirt",
        Description = "A futuristic jacket that glows with neon colors."
    },
    ["Cargo Pants"] = { 
        Rarity = "Rare", 
        Value = 450, 
        AssetId = 18522156233,
        Type = "Pants",
        Description = "Tactical cargo pants with multiple pockets."
    },
    ["VR Goggles"] = { 
        Rarity = "Rare", 
        Value = 600, 
        AssetId = 11989097369,
        Type = "Face",
        Description = "Virtual reality goggles that transport you to other worlds."
    },
    ["Holographic Visor"] = { 
        Rarity = "Rare", 
        Value = 800, 
        AssetId = 5618036089,
        Type = "Hat",
        Description = "A high-tech visor with holographic display capabilities."
    },
    ["Jetpack"] = { 
        Rarity = "Rare", 
        Value = 1000, 
        AssetId = 5768738455,
        Type = "Back",
        Description = "A personal jetpack for aerial adventures."
    },

    -- Epic UGC Items (R$ 1,000 - 5,000)
    ["Crown"] = { 
        Rarity = "Epic", 
        Value = 1200, 
        AssetId = 14943768260,
        Type = "Hat",
        Description = "A royal crown fit for a king or queen."
    },
    ["Dragon Robe"] = { 
        Rarity = "Epic", 
        Value = 1800, 
        AssetId = 82347235066957,
        Type = "Shirt",
        Description = "An ancient robe adorned with dragon motifs."
    },
    ["Knight Armor"] = { 
        Rarity = "Epic", 
        Value = 2500, 
        AssetId = 14458547725,
        Type = "Shirt",
        Description = "Medieval knight armor forged from the finest steel."
    },
    ["Angel Wings"] = { 
        Rarity = "Epic", 
        Value = 3500, 
        AssetId = 135727710186452,
        Type = "Back",
        Description = "Ethereal wings that grant the appearance of divine grace."
    },
    ["Wizard Hat"] = { 
        Rarity = "Epic", 
        Value = 4200, 
        AssetId = 17187373352,
        Type = "Hat",
        Description = "A mystical hat imbued with ancient magical powers."
    },
    ["Power Gauntlet"] = { 
        Rarity = "Epic", 
        Value = 5000, 
        AssetId = 90027970393139,
        Type = "Front",
        Description = "A gauntlet that channels incredible energy."
    },

    -- Legendary UGC Items (R$ 5,000 - 25,000)
    ["Diamond Crown"] = { 
        Rarity = "Legendary", 
        Value = 6000, 
        AssetId = 14815863631,
        Type = "Hat",
        Description = "A crown encrusted with the finest diamonds."
    },
    ["Phoenix Wings"] = { 
        Rarity = "Legendary", 
        Value = 8500, 
        AssetId = 126032464353482,
        Type = "Back",
        Description = "Wings of the legendary phoenix, said to grant rebirth."
    },
    ["Void Cloak"] = { 
        Rarity = "Legendary", 
        Value = 12000, 
        AssetId = 101396490083754,
        Type = "Shirt",
        Description = "A cloak woven from the fabric of space itself."
    },
    ["Time Boots"] = { 
        Rarity = "Legendary", 
        Value = 16000, 
        AssetId = 18426584193,
        Type = "Shoes",
        Description = "Boots that allow the wearer to manipulate time."
    },
    ["Crystal Sword"] = { 
        Rarity = "Legendary", 
        Value = 20000, 
        AssetId = 14751422959,
        Type = "Front",
        Description = "A blade forged from pure crystal energy."
    },
    ["Celestial Armor"] = { 
        Rarity = "Legendary", 
        Value = 25000, 
        AssetId = 82943442611683,
        Type = "Shirt",
        Description = "Armor blessed by celestial beings."
    },

    -- Mythical UGC Items (R$ 25,000 - 100,000)
    ["God's Halo"] = { 
        Rarity = "Mythical", 
        Value = 30000, 
        AssetId = 18780268549,
        Type = "Hat",
        Description = "A divine halo that radiates holy light."
    },
    ["Reality Gloves"] = { 
        Rarity = "Mythical", 
        Value = 45000, 
        AssetId = 15435394705,
        Type = "Front",
        Description = "Gloves that can bend reality to the wearer's will."
    },
    ["Infinity Cloak"] = { 
        Rarity = "Mythical", 
        Value = 65000, 
        AssetId = 10552660662,
        Type = "Shirt",
        Description = "A cloak that extends beyond the boundaries of existence."
    },
    ["Cosmic Crown"] = { 
        Rarity = "Mythical", 
        Value = 80000, 
        AssetId = 14971249131,
        Type = "Hat",
        Description = "A crown forged from the heart of a dying star."
    },
    ["Singularity Staff"] = { 
        Rarity = "Mythical", 
        Value = 100000, 
        AssetId = 89383395698855,
        Type = "Front",
        Description = "A staff that contains the power of a black hole."
    },

    -- Celestial UGC Items (R$ 100,000 - 500,000)
    ["Galaxy Wings"] = { 
        Rarity = "Celestial", 
        Value = 120000, 
        AssetId = 18746999284,
        Type = "Back",
        Description = "Wings that sparkle with the light of a thousand stars."
    },
    ["Nebula Armor"] = { 
        Rarity = "Celestial", 
        Value = 180000, 
        AssetId = 71453601384352,
        Type = "Shirt",
        Description = "Armor forged from the dust of distant nebulae."
    },
    ["Stardust Pauldrons"] = { 
        Rarity = "Celestial", 
        Value = 250000, 
        AssetId = 17799345182,
        Type = "Shoulders",
        Description = "Shoulder guards made from compressed stardust."
    },
    ["Supernova Helmet"] = { 
        Rarity = "Celestial", 
        Value = 350000, 
        AssetId = 17662144185,
        Type = "Hat",
        Description = "A helmet that burns with the intensity of a supernova."
    },
    ["Black Hole Blade"] = { 
        Rarity = "Celestial", 
        Value = 500000, 
        AssetId = 111367840820187,
        Type = "Front",
        Description = "A weapon that devours light itself."
    },
    
    -- Divine UGC Items (R$ 500,000 - 2,500,000)
    ["Aura of the Gods"] = { 
        Rarity = "Divine", 
        Value = 600000, 
        AssetId = 131802293344145,
        Type = "Shirt",
        Description = "An aura that marks the wearer as divine."
    },
    ["Creator's Cape"] = { 
        Rarity = "Divine", 
        Value = 850000, 
        AssetId = 112619410096862,
        Type = "Back",
        Description = "The cape worn by the creator of worlds."
    },
    ["Dominus Astra"] = { 
        Rarity = "Divine", 
        Value = 1800000, 
        AssetId = 162067148,
        Type = "Hat",
        Description = "The crown of the stellar emperor."
    },
    ["Valkyrie of the Metaverse"] = { 
        Rarity = "Divine", 
        Value = 2500000, 
        AssetId = 16166647111,
        Type = "Shirt",
        Description = "Armor worn by the guardian of digital realms."
    },

    -- Transcendent UGC Items (R$ 5,000,000 - 25,000,000)
    ["Rift Walker's Scythe"] = { 
        Rarity = "Transcendent", 
        Value = 5000000, 
        AssetId = 82818827434214,
        Type = "Front",
        Description = "A scythe that can cut through the fabric of reality."
    },
    ["Chronomancer's Crown"] = { 
        Rarity = "Transcendent", 
        Value = 8000000, 
        AssetId = 116875747342075,
        Type = "Hat",
        Description = "A crown that grants mastery over time itself."
    },
    ["Echoes of the Void"] = { 
        Rarity = "Transcendent", 
        Value = 12000000, 
        AssetId = 18528865852,
        Type = "Shirt",
        Description = "Clothing that resonates with the emptiness between worlds."
    },
    ["Heart of a Dying Star"] = { 
        Rarity = "Transcendent", 
        Value = 18000000, 
        AssetId = 122518448724885,
        Type = "Front",
        Description = "The crystallized heart of a star in its final moments."
    },
    ["Singularity Wings"] = { 
        Rarity = "Transcendent", 
        Value = 25000000, 
        AssetId = 15099368793,
        Type = "Back",
        Description = "Wings forged from the event horizon itself."
    },

    -- Ethereal UGC Items (R$ 30,000,000 - 150,000,000)
    ["The First Omen"] = { 
        Rarity = "Ethereal", 
        Value = 10000000, 
        AssetId = 132480258038179,
        Type = "Hat",
        Description = "The first sign of the coming digital apocalypse."
    },
    ["Crown of the Silent King"] = { 
        Rarity = "Ethereal", 
        Value = 13000000, 
        AssetId = 146083020,
        Type = "Hat",
        Description = "A crown that speaks without words."
    },
    ["Aetherium Blade"] = { 
        Rarity = "Ethereal", 
        Value = 16000000, 
        AssetId = 86216026118611,
        Type = "Front",
        Description = "A blade forged from pure aetherium energy."
    },
    ["Mantle of the Architect"] = { 
        Rarity = "Ethereal", 
        Value = 22000000, 
        AssetId = 95824173117693,
        Type = "Shirt",
        Description = "The mantle worn by the architect of existence."
    },
    ["The Unseen Hand"] = { 
        Rarity = "Ethereal", 
        Value = 35000000, 
        AssetId = 12725518393,
        Type = "Front",
        Description = "A hand that shapes destiny from the shadows."
    },

    -- Quantum UGC Items (R$ 200,000,000 - 1,000,000,000)
    ["Fragment of Creation"] = { 
        Rarity = "Quantum", 
        Value = 60000000, 
        AssetId = 8782356060,
        Type = "Front",
        Description = "A fragment from the moment of universal creation."
    },
    ["The Final Shape"] = { 
        Rarity = "Quantum", 
        Value = 350000000, 
        AssetId = 93566247282147,
        Type = "Shirt",
        Description = "The ultimate form that all things aspire to become."
    },
    ["Event Horizon"] = { 
        Rarity = "Quantum", 
        Value = 500000000, 
        AssetId = 13241957708,
        Type = "Back",
        Description = "The boundary beyond which nothing can return."
    },
    ["Wings of Doom"] = { 
        Rarity = "Quantum", 
        Value = 500000000, 
        AssetId = 132275193556412,
        Type = "Back",
        Description = "Wings that grant the power of the void."
    },
    ["Glimpse of Infinity"] = { 
        Rarity = "Quantum", 
        Value = 750000000, 
        AssetId = 16580998098,
        Type = "Face",
        Description = "A view into the endless expanse of possibility."
    },
    ["The Robloxian"] = { 
        Rarity = "Quantum", 
        Value = 1000000000, 
        AssetId = 17720934054,
        Type = "Hat",
        Description = "The ultimate expression of what it means to be Robloxian."
    },

    -- Limited Items (Authentic Roblox Catalog Limiteds) - Ultra-Premium Rarities
    ["Red Banded Top Hat"] = { 
        Rarity = "Limited", 
        Value = 50000000, 
        AssetId = 2972302,
        Type = "Hat",
        Description = "An elegant top hat with a distinguished red band."
    },
    ["Sparkle Time Fedora"] = { 
        Rarity = "Limited", 
        Value = 100000000, 
        AssetId = 1285307,
        Type = "Hat",
        Description = "A dazzling fedora that sparkles with limited edition magic."
    },
    ["ROBLOX Visor"] = { 
        Rarity = "Vintage", 
        Value = 200000000, 
        AssetId = 607700713,
        Type = "Hat",
        Description = "The iconic ROBLOX visor from the golden age."
    },
    ["Workclock Headphones"] = { 
        Rarity = "Vintage", 
        Value = 300000000, 
        AssetId = 172309919,
        Type = "Hat",
        Description = "Vintage headphones from the early days of Roblox."
    },
    ["Clockwork's Shades"] = { 
        Rarity = "Vintage", 
        Value = 500000000, 
        AssetId = 11748356,
        Type = "Hat",
        Description = "The legendary shades worn by Clockwork himself."
    },
    ["Brighteyes' Bloxy Cola Hat"] = { 
        Rarity = "Exclusive", 
        Value = 750000000, 
        AssetId = 24114402,
        Type = "Hat",
        Description = "Brighteyes' exclusive Bloxy Cola promotional hat."
    },
    ["Green Bow Tie"] = { 
        Rarity = "Exclusive", 
        Value = 1000000000, 
        AssetId = 1031429,
        Type = "Hat",
        Description = "A sophisticated green bow tie of limited availability."
    },
    ["Kleos Aphthiton"] = { 
        Rarity = "Exclusive", 
        Value = 1500000000, 
        AssetId = 1365767,
        Type = "Hat",
        Description = "Eternal glory incarnate in headwear form."
    },
    ["Adurite Antlers"] = { 
        Rarity = "Ultimate", 
        Value = 2000000000, 
        AssetId = 162066057,
        Type = "Hat",
        Description = "Mystical antlers forged from pure adurite."
    },
    ["Dominus Empyreus"] = { 
        Rarity = "Dominus", 
        Value = 3000000000, 
        AssetId = 21070012,
        Type = "Hat",
        Description = "The legendary golden Dominus of the heavens."
    },
    ["Dominus Messor"] = { 
        Rarity = "Dominus", 
        Value = 5000000000, 
        AssetId = 64444871,
        Type = "Hat",
        Description = "The harvester Dominus that reaps souls."
    },
    ["Dominus Frigidus"] = { 
        Rarity = "Dominus", 
        Value = 7500000000, 
        AssetId = 48545806,
        Type = "Hat",
        Description = "An icy cold Dominus of unparalleled rarity."
    },
    ["Dominus Vespertilio"] = { 
        Rarity = "Dominus", 
        Value = 10000000000, 
        AssetId = 96103379,
        Type = "Hat",
        Description = "The bat-winged Dominus of eternal night."
    },
    ["Dominus Infernus"] = { 
        Rarity = "Dominus", 
        Value = 15000000000, 
        AssetId = 31101391,
        Type = "Hat",
        Description = "The infernal Dominus wreathed in hellfire."
    },
    ["Dominus Aureus"] = { 
        Rarity = "Dominus", 
        Value = 25000000000, 
        AssetId = 138932314,
        Type = "Hat",
        Description = "The golden Dominus forged from pure aurum."
    },
    ["Tung Tung Soldiers"] = {
        Rarity = "BRAINROT",
        Value = 100000000000, -- 100B (Loss)
        AssetId = 119552849311628,
        Type = "Hat",
        Description = "The legendary TUNG TUNG SOLDIERS march on!"
    },
    ["Kanye"] = {
        Rarity = "BRAINROT",
        Value = 200000000000, -- 200B (Loss)
        AssetId = 95838284964747,
        Type = "Hat",
        Description = "A mysterious Kanye artifact from another universe."
    },
    ["Bombardiro Crocodilo"] = {
        Rarity = "BRAINROT",
        Value = 300000000000, -- 300B (Loss)
        AssetId = 82573291743526,
        Type = "Hat",
        Description = "The croc that bombards with tralalero tralala energy."
    },
    ["Tralalero Tralala"] = {
        Rarity = "BRAINROT",
        Value = 400000000000, -- 400B (Loss)
        AssetId = 126595809028493,
        Type = "Hat",
        Description = "The sound of the brainrot. TRALALELO TRALALA!"
    },
    ["TaTa Sahur"] = {
        Rarity = "BRAINROT",
        Value = 600000000000, -- 600B (Win)
        AssetId = 120782162269962,
        Type = "Hat",
        Description = "TaTa Sahur: The meme, the legend."
    },
    ["Chimpanzini Bananini"] = {
        Rarity = "BRAINROT",
        Value = 1000000000000, -- 1T (Win)
        AssetId = 116419829790643,
        Type = "Hat",
        Description = "The rare Chimpanzini Bananini, only for the brainrotted."
    },
    ["Two Monkey Standing In Back Meme Funny Animal"] = {
        Rarity = "BRAINROT",
        Value = 2000000000000, -- 2T (Jackpot)
        AssetId = 101829766673768,
        Type = "Hat",
        Description = "Two monkeys, infinite brainrot."
    },
    ["Capuchino Assassino"] = {
        Rarity = "BRAINROT",
        Value = 150000000000, -- 150B (Loss)
        AssetId = 81371421522107,
        Type = "Hat",
        Description = "The most dangerous cappuccino."
    },
    ["Lirili Larila"] = {
        Rarity = "BRAINROT",
        Value = 500000000000, -- 250B (Loss)
        AssetId = 106643331897210,
        Type = "Hat",
        Description = "Lirili Larila, the sound of brainrot intensifies."
    },
}

Config.Mutations = {
    ["Shiny"] = { Chance = 8, ValueMultiplier = 1.2, Color = Color3.fromRGB(255, 255, 100) },
    ["Glowing"] = { Chance = 4, ValueMultiplier = 1.5, Color = Color3.fromRGB(100, 255, 255) },
    ["Rainbow"] = { Chance = 2, ValueMultiplier = 2, Color = Color3.fromRGB(255, 100, 255) },
    ["Corrupted"] = { Chance = 0.8, ValueMultiplier = 3, Color = Color3.fromRGB(100, 0, 100) },
    ["Stellar"] = { Chance = 0.2, ValueMultiplier = 5, Color = Color3.fromRGB(200, 200, 255) },
    ["Quantum"] = { Chance = 0.05, ValueMultiplier = 10, Color = Color3.fromRGB(50, 20, 80) },
    ["Unknown"] = { Chance = 0.01, ValueMultiplier = 25, Color = Color3.fromRGB(0, 0, 0) },
}

Config.Boxes = {
    ["StarterCrate"] = {
        Name = "📦 Starter Crate",
        Price = 20,
        Rewards = {
            ["Basic Cap"] = 75,      -- 10 value (loss)
            ["Plain T-Shirt"] = 20,  -- 15 value (loss but better)
            ["Basic Glasses"] = 3,   -- 25 value (win)
            ["School Backpack"] = 2, -- 30 value (jackpot)
        },
    },
    ["PremiumCrate"] = {
        Name = "⭐ Premium Crate",
        Price = 100,
        Rewards = {
            ["Cool Hoodie"] = 75,       -- 75 value (loss)
            ["Designer Jeans"] = 20,    -- 90 value (loss but close)
            ["Sunglasses"] = 3,         -- 110 value (win)
            ["Sports Watch"] = 1.5,     -- 150 value (win)
            ["Gaming Headset"] = 0.5,   -- 260 value (jackpot)
        },
    },
    ["LegendaryCrate"] = {
        Name = "🌟 Legendary Crate",
        Price = 600,
        Rewards = {
            ["Neon Jacket"] = 75,           -- 350 value (loss)
            ["Cargo Pants"] = 20,           -- 450 value (loss)
            ["VR Goggles"] = 3,             -- 600 value (break-even)
            ["Holographic Visor"] = 1.5,    -- 800 value (win)
            ["Crown"] = 0.5,                -- 1200 value (jackpot)
        },
    },
    ["MythicalCrate"] = {
        Name = "🐉 Mythical Crate",
        Price = 3000,
        Rewards = {
            ["Dragon Robe"] = 75,       -- 1800 value (loss)
            ["Knight Armor"] = 20,      -- 2500 value (loss)
            ["Angel Wings"] = 3,        -- 3500 value (win)
            ["Wizard Hat"] = 1.5,       -- 4200 value (win)
            ["Diamond Crown"] = 0.5,    -- 6000 value (jackpot)
        },
    },
    ["CelestialCrate"] = {
        Name = "🌌 Celestial Crate",
        Price = 15000,
        Rewards = {
            ["Void Cloak"] = 75,        -- 12000 value (loss)
            ["Time Boots"] = 20,        -- 16000 value (win)
            ["Crystal Sword"] = 3,      -- 20000 value (win)
            ["Celestial Armor"] = 1.5,  -- 25000 value (win)
            ["God's Halo"] = 0.5,       -- 30000 value (jackpot)
        },
    },
    ["DivineCrate"] = {
        Name = "👑 Divine Crate",
        Price = 80000,
        Rewards = {
            ["Infinity Cloak"] = 75,    -- 65000 value (loss)
            ["Cosmic Crown"] = 20,      -- 80000 value (break-even)
            ["Singularity Staff"] = 3,  -- 100000 value (win)
            ["Galaxy Wings"] = 1.5,     -- 120000 value (win)
            ["Nebula Armor"] = 0.5,     -- 180000 value (jackpot)
        },
    },
    ["TranscendentCrate"] = {
        Name = "✨ Transcendent Crate",
        Price = 400000,
        Rewards = {
            ["Stardust Pauldrons"] = 75,    -- 250000 value (loss)
            ["Supernova Helmet"] = 20,      -- 350000 value (loss)
            ["Black Hole Blade"] = 3,       -- 500000 value (win)
            ["Aura of the Gods"] = 1.5,     -- 600000 value (win)
            ["Creator's Cape"] = 0.5,       -- 850000 value (jackpot)
        },
    },
    ["EtherealCrate"] = {
        Name = "💫 Ethereal Crate",
        Price = 2500000,
        Rewards = {
            ["Dominus Astra"] = 75,            -- 1800000 value (loss)
            ["Valkyrie of the Metaverse"] = 20, -- 2500000 value (break-even)
            ["Rift Walker's Scythe"] = 3,     -- 5000000 value (win)
            ["Chronomancer's Crown"] = 1.5,   -- 8000000 value (win)
            ["Echoes of the Void"] = 0.5,     -- 12000000 value (jackpot)
        },
    },
    ["QuantumCrate"] = {
        Name = "⚛️ Quantum Crate",
        Price = 20000000,
        Rewards = {
            ["The First Omen"] = 75,            -- 10000000 value (loss)
            ["Crown of the Silent King"] = 15,  -- 13000000 value (loss)
            ["Aetherium Blade"] = 8,            -- 16000000 value (win)
            ["Mantle of the Architect"] = 1.5,  -- 22000000 value (win)
            ["Fragment of Creation"] = 0.5,     -- 60000000 value (jackpot)
        },
    },
    ["LimitedCrate"] = {
        Name = "🏆 Limited Crate",
        Price = 500000000,
        Rewards = {
            ["Red Banded Top Hat"] = 25,                -- 50,000,000 value (loss)
            ["Sparkle Time Fedora"] = 15,               -- 100,000,000 value (loss)
            ["ROBLOX Visor"] = 15,                       -- 200,000,000 value (loss)
            ["Workclock Headphones"] = 15,             -- 300,000,000 value (loss)
            ["Clockwork's Shades"] = 15,               -- 500,000,000 value (break-even)
            ["Brighteyes' Bloxy Cola Hat"] = 5,      -- 750,000,000 value (win)
            ["Green Bow Tie"] = 6,                   -- 1,000,000,000 value (win)
            ["Kleos Aphthiton"] = 3.5,                 -- 1,500,000,000 value (jackpot)
            ["Adurite Antlers"] = 0.5,                 -- 2,000,000,000 value (jackpot)
        },
    },
    ["DominusCrate"] = {
        Name = "👑 Dominus Crate",
        Price = 10000000000,
        Rewards = {
            ["Dominus Empyreus"] = 50,            -- 3,000,000,000 value (loss)
            ["Dominus Messor"] = 25,              -- 5,000,000,000 value (loss)
            ["Dominus Frigidus"] = 10,            -- 7,500,000,000 value (loss)
            ["Dominus Vespertilio"] = 10,          -- 10,000,000,000 value (break-even)
            ["Dominus Infernus"] = 3.5,            -- 15,000,000,000 value (win)
            ["Dominus Aureus"] = 1.5,              -- 25,000,000,000 value (jackpot)
        },
    },
    ["BrainrotCrate"] = {
        Name = "🧠 Brainrot Crate",
        Price = 500000000000,
        Rewards = {
            ["Tung Tung Soldiers"] = 30, -- 100B (Loss)
            ["Kanye"] = 20, -- 200B (Loss)
            ["Bombardiro Crocodilo"] = 12, -- 300B (Loss)
            ["Tralalero Tralala"] = 10, -- 400B (Loss)
            ["Capuchino Assassino"] = 10, -- 150B (Loss)
            ["Lirili Larila"] = 8, -- 500B (even)
            ["TaTa Sahur"] = 6, -- 600B (Win)
            ["Chimpanzini Bananini"] = 3, -- 1T (Win)
            ["Two Monkey Standing In Back Meme Funny Animal"] = 1 -- 2T (Jackpot)
        },
    },
    ["FreeCrate"] = {
        Name = "🎁 Free Crate",
        Price = 0,
        Cooldown = 60,
        Rewards = {
            ["Basic Cap"] = 75,         -- 10 value
            ["Plain T-Shirt"] = 20,     -- 15 value
            ["Simple Pants"] = 4,       -- 20 value
            ["Basic Glasses"] = 1,      -- 25 value
        },
    },
}

-- Currency settings
Config.Currency = {
    Name = "R$",
    StartingAmount = 500,
}

return Config