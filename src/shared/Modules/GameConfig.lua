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
    Limited = { Color = Color3.fromRGB(255, 20, 147) },     -- Deep Pink - For classic limiteds
    Vintage = { Color = Color3.fromRGB(184, 134, 11) },     -- Antique Gold - For vintage items
    Exclusive = { Color = Color3.fromRGB(138, 43, 226) },   -- Blue Violet - For exclusive limiteds
    Ultimate = { Color = Color3.fromRGB(255, 0, 0) },       -- Pure Red - For ultimate limiteds
    Dominus = { Color = Color3.fromRGB(0, 0, 0) },          -- Pure Black - For Dominus items
    BRAINROT = { Color = Color3.fromRGB(180, 0, 255) },     -- Purple-pink for brainrot meme rarity
    Huzz = { Color = Color3.fromRGB(255, 182, 193) },       -- Pink for huzz items
    EightBit = { Color = Color3.fromRGB(255, 165, 0) },     -- Orange for 8-Bit items
    Anime = { Color = Color3.fromRGB(255, 105, 180) },      -- Hot pink for anime items
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
    ["Girl Companion"] = {
        Rarity = "Huzz",
        Value = 1000000000000, -- 1T (loss)
        AssetId = 78040751853297,
        Type = "Hat",
        Description = "A loyal anime girl companion."
    },
    ["Cat Girl Companion"] = {
        Rarity = "Huzz",
        Value = 1200000000000, -- 1.2T (loss)
        AssetId = 96175704117932,
        Type = "Hat",
        Description = "A cute cat girl companion."
    },
    ["Goth Girl Companion"] = {
        Rarity = "Huzz",
        Value = 1500000000000, -- 1.5T (loss)
        AssetId = 72315510542194,
        Type = "Hat",
        Description = "A mysterious goth girl companion."
    },
    ["Cute Girl Companion"] = {
        Rarity = "Huzz",
        Value = 2000000000000, -- 2T (loss)
        AssetId = 76983254345484,
        Type = "Hat",
        Description = "A cute anime girl companion."
    },
    ["Furry Anime Girl Waifu"] = {
        Rarity = "Huzz",
        Value = 2500000000000, -- 2.5T (even)
        AssetId = 94263375860746,
        Type = "Hat",
        Description = "A furry anime girl waifu."
    },
    ["Wizard Girl Companion"] = {
        Rarity = "Huzz",
        Value = 4000000000000, -- 5T (win)
        AssetId = 133759958641927,
        Type = "Hat",
        Description = "A magical wizard girl companion."
    },
    ["Cat Maid Girl Companion"] = {
        Rarity = "Huzz",
        Value = 6000000000000, -- 7.5T (win)
        AssetId = 92407941953530,
        Type = "Hat",
        Description = "A cat maid girl companion."
    },
    ["Astolfo Companion"] = {
        Rarity = "Huzz",
        Value = 8000000000000, -- 10T (jackpot)
        AssetId = 87610936807356,
        Type = "Hat",
        Description = "Astolfo, the legendary companion."
    },
    
    -- 8-Bit Items (Special Pixel-Themed Collection)
    ["Black 8-Bit Wings"] = { 
        Rarity = "EightBit", 
        Value = 300000000000000, -- 300T
        AssetId = 17422376123,
        Type = "Back",
        Description = "Pixelated wings with a dark, mysterious aura."
    },
    ["8-Bit Roblox Coin"] = { 
        Rarity = "EightBit", 
        Value = 150000000000000, -- 150T
        AssetId = 10159622004,
        Type = "Front",
        Description = "A classic Roblox coin in 8-bit pixel art style."
    },
    ["Damaged Pixel Heart Meme HP"] = { 
        Rarity = "EightBit", 
        Value = 100000000000000, -- 100T
        AssetId = 16258039952,
        Type = "Front",
        Description = "A damaged pixel heart meme that's seen better days."
    },
    ["8-Bit Royal Crown"] = { 
        Rarity = "EightBit", 
        Value = 800000000000000, -- 800T
        AssetId = 10159600649,
        Type = "Hat",
        Description = "A royal crown rendered in beautiful 8-bit pixel art."
    },
    ["8-Bit Snowboard Goggles"] = { 
        Rarity = "EightBit", 
        Value = 60000000000000, -- 60T
        AssetId = 583136875,
        Type = "Face",
        Description = "Cool snowboard goggles with an 8-bit aesthetic."
    },
    ["8-Bit Dominus Infernus"] = { 
        Rarity = "EightBit", 
        Value = 2000000000000000000, -- 2Q
        AssetId = 17232200909,
        Type = "Hat",
        Description = "The legendary Dominus Infernus in 8-bit pixel form."
    },
    ["8-Bit Extra Life"] = { 
        Rarity = "EightBit", 
        Value = 200000000000000, -- 200T
        AssetId = 10159606132,
        Type = "Front",
        Description = "An extra life power-up in classic 8-bit style."
    },
    ["8-Bit Helmet"] = { 
        Rarity = "EightBit", 
        Value = 80000000000000, -- 80T
        AssetId = 17176601857,
        Type = "Hat",
        Description = "A protective helmet with retro 8-bit graphics."
    },
    ["8-Bit Immortal Sword Venoms Byte"] = { 
        Rarity = "EightBit", 
        Value = 500000000000000, -- 500T
        AssetId = 4390848511,
        Type = "Front",
        Description = "An immortal sword with venomous properties in 8-bit style."
    },
    ["Pixel Pistol"] = { 
        Rarity = "EightBit", 
        Value = 120000000000000, -- 120T
        AssetId = 84619076952401,
        Type = "Front",
        Description = "A pixelated pistol for the retro gamer aesthetic."
    },
    ["Horn Pixel Red"] = { 
        Rarity = "EightBit", 
        Value = 50000000000000, -- 50T
        AssetId = 72213798637315,
        Type = "Hat",
        Description = "A red pixel horn that adds a touch of retro charm."
    },

    -- Anime Plush Items (Special Anime-Themed Collection)
    ["Kurumi Plush"] = { 
        Rarity = "Anime", 
        Value = 100000000000000, -- 100T
        AssetId = 80286655940144,
        Type = "Hat",
        Description = "A cute Kurumi plush from Date A Live."
    },
    ["Kaguya Plush"] = { 
        Rarity = "Anime", 
        Value = 120000000000000, -- 120T
        AssetId = 120979169980923,
        Type = "Hat",
        Description = "A lovely Kaguya plush from Kaguya-sama."
    },
    ["Esdeath Chibi"] = { 
        Rarity = "Anime", 
        Value = 150000000000000, -- 150T
        AssetId = 103619451636916,
        Type = "Hat",
        Description = "A fierce Esdeath chibi from Akame ga Kill."
    },
    ["Tohsaka Plush"] = { 
        Rarity = "Anime", 
        Value = 180000000000000, -- 180T
        AssetId = 101759867782685,
        Type = "Hat",
        Description = "A magical Tohsaka plush from Fate series."
    },
    ["Toga Plush"] = { 
        Rarity = "Anime", 
        Value = 200000000000000, -- 200T
        AssetId = 118298586003684,
        Type = "Hat",
        Description = "A mischievous Toga plush from My Hero Academia."
    },
    ["Eren Plush"] = { 
        Rarity = "Anime", 
        Value = 250000000000000, -- 250T
        AssetId = 85860750818215,
        Type = "Hat",
        Description = "A determined Eren plush from Attack on Titan."
    },
    ["Rikka Plush"] = { 
        Rarity = "Anime", 
        Value = 300000000000000, -- 300T
        AssetId = 140546431532941,
        Type = "Hat",
        Description = "A chuunibyou Rikka plush from Chuunibyou."
    },
    ["Otonose Kanade Plush"] = { 
        Rarity = "Anime", 
        Value = 350000000000000, -- 350T
        AssetId = 81978788112291,
        Type = "Hat",
        Description = "A musical Kanade plush from Bocchi the Rock."
    },
    ["Ichigo Plush"] = { 
        Rarity = "Anime", 
        Value = 400000000000000, -- 400T
        AssetId = 90697073846805,
        Type = "Hat",
        Description = "A soul reaper Ichigo plush from Bleach."
    },
    ["Yumeko Plush"] = { 
        Rarity = "Anime", 
        Value = 450000000000000, -- 450T
        AssetId = 138458406285335,
        Type = "Hat",
        Description = "A gambling Yumeko plush from Kakegurui."
    },
    ["Nino Plush"] = { 
        Rarity = "Anime", 
        Value = 500000000000000, -- 500T
        AssetId = 111992428705947,
        Type = "Hat",
        Description = "A tsundere Nino plush from Quintessential Quintuplets."
    },
    ["Karane Plush"] = { 
        Rarity = "Anime", 
        Value = 600000000000000, -- 600T
        AssetId = 83039184707965,
        Type = "Hat",
        Description = "A shy Karane plush from 100 Girlfriends."
    },
    ["Futaba Plush"] = { 
        Rarity = "Anime", 
        Value = 700000000000000, -- 700T
        AssetId = 81446708266860,
        Type = "Hat",
        Description = "A hacker Futaba plush from Persona 5."
    },
    ["Marin Plush"] = { 
        Rarity = "Anime", 
        Value = 800000000000000, -- 800T
        AssetId = 98964265478838,
        Type = "Hat",
        Description = "A cosplay Marin plush from My Dress-Up Darling."
    },
    ["Akame Plush"] = { 
        Rarity = "Anime", 
        Value = 900000000000000, -- 900T
        AssetId = 100919375769067,
        Type = "Hat",
        Description = "A deadly Akame plush from Akame ga Kill."
    },
    ["Draken Plush"] = { 
        Rarity = "Anime", 
        Value = 1000000000000000, -- 1Qa
        AssetId = 118432867259524,
        Type = "Hat",
        Description = "A tough Draken plush from Tokyo Revengers."
    },
    ["2B Plush"] = { 
        Rarity = "Anime", 
        Value = 1200000000000000, -- 1.2Qa
        AssetId = 123571220493920,
        Type = "Hat",
        Description = "A beautiful 2B plush from NieR: Automata."
    },
    ["Kanae Plush"] = { 
        Rarity = "Anime", 
        Value = 1500000000000000, -- 1.5Qa
        AssetId = 131679242236794,
        Type = "Hat",
        Description = "A demon Kanae plush from Demon Slayer."
    },
    ["Kirito Plush"] = { 
        Rarity = "Anime", 
        Value = 1800000000000000, -- 1.8Qa
        AssetId = 127859451705974,
        Type = "Hat",
        Description = "A swordsman Kirito plush from Sword Art Online."
    },
    ["Shinobu Plush"] = { 
        Rarity = "Anime", 
        Value = 2000000000000000, -- 2Qa
        AssetId = 135124570654797,
        Type = "Hat",
        Description = "A vampire Shinobu plush from Monogatari."
    },
    ["Rukia Plush"] = { 
        Rarity = "Anime", 
        Value = 2500000000000000, -- 2.5Qa
        AssetId = 121551978558798,
        Type = "Hat",
        Description = "A noble Rukia plush from Bleach."
    },
    ["Tomori Plush"] = { 
        Rarity = "Anime", 
        Value = 3000000000000000, -- 3Qa
        AssetId = 74332967658986,
        Type = "Hat",
        Description = "A mysterious Tomori plush from Charlotte."
    },
    ["Evergarden Plush"] = { 
        Rarity = "Anime", 
        Value = 3500000000000000, -- 3.5Qa
        AssetId = 134668098666301,
        Type = "Hat",
        Description = "A graceful Violet plush from Violet Evergarden."
    },
    ["Hange Plush"] = { 
        Rarity = "Anime", 
        Value = 4000000000000000, -- 4Qa
        AssetId = 88445953503719,
        Type = "Hat",
        Description = "A curious Hange plush from Attack on Titan."
    },
    ["Nico Plush"] = { 
        Rarity = "Anime", 
        Value = 4500000000000000, -- 4.5Qa
        AssetId = 112979422108886,
        Type = "Hat",
        Description = "A cute Nico plush from Love Live."
    },
    ["Zero Two Plush"] = { 
        Rarity = "Anime", 
        Value = 5000000000000000, -- 5Qa
        AssetId = 77393117608031,
        Type = "Hat",
        Description = "A darling Zero Two plush from Darling in the Franxx."
    },
    ["Miku Nakano Plush"] = { 
        Rarity = "Anime", 
        Value = 6000000000000000, -- 6Qa
        AssetId = 114534510268326,
        Type = "Hat",
        Description = "A perfect Miku plush from Quintessential Quintuplets."
    },
    ["Lucy Plush"] = { 
        Rarity = "Anime", 
        Value = 7000000000000000, -- 7Qa
        AssetId = 139414524076855,
        Type = "Hat",
        Description = "A powerful Lucy plush from Fairy Tail."
    },
    ["Albedo Plush"] = { 
        Rarity = "Anime", 
        Value = 8000000000000000, -- 8Qa
        AssetId = 112939317392211,
        Type = "Hat",
        Description = "A devoted Albedo plush from Overlord."
    },
    ["Aqua Plush"] = { 
        Rarity = "Anime", 
        Value = 10000000000000000, -- 10Qa
        AssetId = 96637948387504,
        Type = "Hat",
        Description = "A goddess Aqua plush from Konosuba."
    },
    ["Mikasa Plush"] = { 
        Rarity = "Anime", 
        Value = 12000000000000000, -- 12Qa
        AssetId = 106783515664964,
        Type = "Hat",
        Description = "A loyal Mikasa plush from Attack on Titan."
    },
    ["Kurisu Plush"] = { 
        Rarity = "Anime", 
        Value = 15000000000000000, -- 15Qa
        AssetId = 133801904347240,
        Type = "Hat",
        Description = "A brilliant Kurisu plush from Steins;Gate."
    },
    ["Asuna Plush"] = { 
        Rarity = "Anime", 
        Value = 20000000000000000, -- 20Qa
        AssetId = 129248523610728,
        Type = "Hat",
        Description = "A knight Asuna plush from Sword Art Online."
    },
    ["Akutagawa Plush"] = { 
        Rarity = "Anime", 
        Value = 25000000000000000, -- 25Qa
        AssetId = 76226993735264,
        Type = "Hat",
        Description = "A fierce Akutagawa plush from Bungou Stray Dogs."
    },
    ["Nami Plush"] = { 
        Rarity = "Anime", 
        Value = 30000000000000000, -- 30Qa
        AssetId = 111939218743250,
        Type = "Hat",
        Description = "A navigator Nami plush from One Piece."
    },
    ["Saber Plush"] = { 
        Rarity = "Anime", 
        Value = 40000000000000000, -- 40Qa
        AssetId = 117822785453025,
        Type = "Hat",
        Description = "A noble Saber plush from Fate series."
    },
    ["Akeno Plush"] = { 
        Rarity = "Anime", 
        Value = 50000000000000000, -- 50Qa
        AssetId = 106506199081272,
        Type = "Hat",
        Description = "A seductive Akeno plush from High School DxD."
    },
    ["Power Plush"] = { 
        Rarity = "Anime", 
        Value = 60000000000000000, -- 60Qa
        AssetId = 108215437308239,
        Type = "Hat",
        Description = "A chaotic Power plush from Chainsaw Man."
    },
    ["Charlotte Plush"] = { 
        Rarity = "Anime", 
        Value = 80000000000000000, -- 80Qa
        AssetId = 86290424847412,
        Type = "Hat",
        Description = "A royal Charlotte plush from Charlotte."
    },
    ["Mai Sakurajima Plush"] = { 
        Rarity = "Anime", 
        Value = 100000000000000000, -- 100Qa
        AssetId = 116882525443631,
        Type = "Hat",
        Description = "A bunny girl Mai plush from Rascal Does Not Dream."
    },
    ["Ikaros Plush"] = { 
        Rarity = "Anime", 
        Value = 120000000000000000, -- 120Qa
        AssetId = 117371961086739,
        Type = "Hat",
        Description = "An angel Ikaros plush from Heaven's Lost Property."
    },
    ["Rias Gremory Plush"] = { 
        Rarity = "Anime", 
        Value = 150000000000000000, -- 150Qa
        AssetId = 140115303968413,
        Type = "Hat",
        Description = "A devil Rias plush from High School DxD."
    },
    ["Tsukishima Plush"] = { 
        Rarity = "Anime", 
        Value = 200000000000000000, -- 200Qa
        AssetId = 113611288168080,
        Type = "Hat",
        Description = "A cool Tsukishima plush from Haikyuu."
    },
    ["Reinhard Plush"] = { 
        Rarity = "Anime", 
        Value = 250000000000000000, -- 250Qa
        AssetId = 106991499877861,
        Type = "Hat",
        Description = "A knight Reinhard plush from Re:Zero."
    },
    ["Megumin Plush"] = { 
        Rarity = "Anime", 
        Value = 300000000000000000, -- 300Qa
        AssetId = 134436186351410,
        Type = "Hat",
        Description = "An explosion Megumin plush from Konosuba."
    },
    ["Nezuko Plush"] = { 
        Rarity = "Anime", 
        Value = 400000000000000000, -- 400Qa
        AssetId = 135862774225312,
        Type = "Hat",
        Description = "A demon Nezuko plush from Demon Slayer."
    },
    ["Makima Plush"] = { 
        Rarity = "Anime", 
        Value = 500000000000000000, -- 500Qa
        AssetId = 138437178030970,
        Type = "Hat",
        Description = "A devil Makima plush from Chainsaw Man."
    },
    ["Alexis Ness Plush"] = { 
        Rarity = "Anime", 
        Value = 600000000000000000, -- 600Qa
        AssetId = 121875727921857,
        Type = "Hat",
        Description = "A striker Alexis plush from Blue Lock."
    },
    ["Naruto Plush"] = { 
        Rarity = "Anime", 
        Value = 800000000000000000, -- 800Qa
        AssetId = 87105547120327,
        Type = "Hat",
        Description = "A ninja Naruto plush from Naruto."
    },
    ["Itoshi Sae Shoulder Chibi"] = { 
        Rarity = "Dominus", 
        Value = 1000000000000000000, -- 1Sx
        AssetId = 100064571606612,
        Type = "Hat",
        Description = "A striker Sae chibi from Blue Lock."
    },
    ["Luffy Plush"] = { 
        Rarity = "Anime", 
        Value = 1200000000000000000, -- 1.2Sx
        AssetId = 132866616405682,
        Type = "Hat",
        Description = "A pirate Luffy plush from One Piece."
    },
    ["Otoya Plush"] = { 
        Rarity = "Anime", 
        Value = 1500000000000000000, -- 1.5Sx
        AssetId = 116479106249234,
        Type = "Hat",
        Description = "A striker Otoya plush from Blue Lock."
    },
    ["Subaru Plush"] = { 
        Rarity = "Anime", 
        Value = 2000000000000000000, -- 2Sx
        AssetId = 94039272668891,
        Type = "Hat",
        Description = "A knight Subaru plush from Re:Zero."
    },
    ["Kagamine Rin Plush"] = { 
        Rarity = "Anime", 
        Value = 2500000000000000000, -- 2.5Sx
        AssetId = 80794130821345,
        Type = "Hat",
        Description = "A vocaloid Rin plush from Vocaloid."
    },
    ["Kagamine Len Plush"] = { 
        Rarity = "Anime", 
        Value = 3000000000000000000, -- 3Sx
        AssetId = 118186259403601,
        Type = "Hat",
        Description = "A vocaloid Len plush from Vocaloid."
    },
    ["Rem Chibi"] = { 
        Rarity = "Anime", 
        Value = 4000000000000000000, -- 4Sx
        AssetId = 85174694435262,
        Type = "Hat",
        Description = "A maid Rem chibi from Re:Zero."
    },
    ["Don Lorenzo Plush"] = { 
        Rarity = "Anime", 
        Value = 5000000000000000000, -- 5Sx
        AssetId = 97382518239088,
        Type = "Hat",
        Description = "A striker Lorenzo plush from Blue Lock."
    },
    ["Echidna Plush"] = { 
        Rarity = "Anime", 
        Value = 6000000000000000000, -- 6Sx
        AssetId = 99547520919606,
        Type = "Hat",
        Description = "A witch Echidna plush from Re:Zero."
    },
    ["Dante Plush"] = { 
        Rarity = "Anime", 
        Value = 8000000000000000000, -- 8Sx
        AssetId = 135675612917976,
        Type = "Hat",
        Description = "A devil Dante plush from Devil May Cry."
    },
    ["Uraraka Plush"] = { 
        Rarity = "Anime", 
        Value = 10000000000000000000, -- 10Sx
        AssetId = 128072588223691,
        Type = "Hat",
        Description = "A hero Uraraka plush from My Hero Academia."
    },
    ["Gojo Plush"] = { 
        Rarity = "Anime", 
        Value = 12000000000000000000000, -- 12Sx
        AssetId = 89007870290707,
        Type = "Hat",
        Description = "A sorcerer Gojo plush from Jujutsu Kaisen."
    },
    ["Miku Plush"] = { 
        Rarity = "Anime", 
        Value = 15000000000000000000000, -- 15Sx
        AssetId = 78288675005637,
        Type = "Hat",
        Description = "A vocaloid Miku plush from Vocaloid."
    },
    ["Kaiser Chibi"] = { 
        Rarity = "Anime", 
        Value = 20000000000000000000000, -- 20Sx
        AssetId = 136219287434270,
        Type = "Hat",
        Description = "A striker Kaiser chibi from Blue Lock."
    },
    ["Giyu Plush"] = { 
        Rarity = "Anime", 
        Value = 25000000000000000000000, -- 25Sx
        AssetId = 139516404833966,
        Type = "Hat",
        Description = "A hashira Giyu plush from Demon Slayer."
    },
    ["Teto Plush"] = { 
        Rarity = "Anime", 
        Value = 30000000000000000000000, -- 30Sx
        AssetId = 86926556400311,
        Type = "Hat",
        Description = "A vocaloid Teto plush from Vocaloid."
    },
    ["Kaiser Plush"] = { 
        Rarity = "Anime", 
        Value = 40000000000000000000000, -- 40Sx
        AssetId = 122129429181475,
        Type = "Hat",
        Description = "A striker Kaiser plush from Blue Lock."
    },
    ["Sukuna Plush"] = { 
        Rarity = "Anime", 
        Value = 50000000000000000000000, -- 50Sx
        AssetId = 133755205863725,
        Type = "Hat",
        Description = "A curse Sukuna plush from Jujutsu Kaisen."
    },
    ["Chigiri Plush"] = { 
        Rarity = "Anime", 
        Value = 60000000000000000000000, -- 60Sx
        AssetId = 129045042928256,
        Type = "Hat",
        Description = "A striker Chigiri plush from Blue Lock."
    },
    ["Kurona Plush"] = { 
        Rarity = "Anime", 
        Value = 80000000000000000000000, -- 80Sx
        AssetId = 98141693243477,
        Type = "Hat",
        Description = "A striker Kurona plush from Blue Lock."
    },
    ["Karasu Plush"] = { 
        Rarity = "Anime", 
        Value = 100000000000000000000000, -- 100Sx
        AssetId = 99248596109473,
        Type = "Hat",
        Description = "A striker Karasu plush from Blue Lock."
    },
    ["Beatrice Plush"] = { 
        Rarity = "Anime", 
        Value = 120000000000000000000000, -- 120Sx
        AssetId = 139238325031143,
        Type = "Hat",
        Description = "A spirit Beatrice plush from Re:Zero."
    },
    ["Otto Suwen Plush"] = { 
        Rarity = "Anime", 
        Value = 150000000000000000000000, -- 150Sx
        AssetId = 130421400224973,
        Type = "Hat",
        Description = "A knight Otto plush from Re:Zero."
    },
    ["Haruka Sakura Chibi"] = { 
        Rarity = "Anime", 
        Value = 200000000000000000000000, -- 200Sx
        AssetId = 118071099328414,
        Type = "Hat",
        Description = "A striker Haruka chibi from Blue Lock."
    },
    ["Bachira Plush"] = { 
        Rarity = "Anime", 
        Value = 250000000000000000000000, -- 250Sx
        AssetId = 139101954409068,
        Type = "Hat",
        Description = "A striker Bachira plush from Blue Lock."
    },
    ["Aryu Plush"] = { 
        Rarity = "Anime", 
        Value = 300000000000000000000000, -- 300Sx
        AssetId = 96832710486020,
        Type = "Hat",
        Description = "A striker Aryu plush from Blue Lock."
    },
    ["Alya Plush"] = { 
        Rarity = "Anime", 
        Value = 400000000000000000000000, -- 400Sx
        AssetId = 72528561297702,
        Type = "Hat",
        Description = "A striker Alya plush from Blue Lock."
    },
    ["Shinra Plush"] = { 
        Rarity = "Anime", 
        Value = 500000000000000000000000, -- 500Sx
        AssetId = 129245864936890,
        Type = "Hat",
        Description = "A fire force Shinra plush from Fire Force."
    },
    ["Rem Plush"] = { 
        Rarity = "Anime", 
        Value = 600000000000000000000000, -- 600Sx
        AssetId = 79044888298199,
        Type = "Hat",
        Description = "A maid Rem plush from Re:Zero."
    },
    ["Ram Plush"] = { 
        Rarity = "Anime", 
        Value = 800000000000000000000000, -- 800Sx
        AssetId = 100253924404063,
        Type = "Hat",
        Description = "A maid Ram plush from Re:Zero."
    },
    ["Mikey Chibi"] = { 
        Rarity = "Dominus", 
        Value = 1000000000000000000000000, -- 1Sp
        AssetId = 82490225667712,
        Type = "Hat",
        Description = "A gangster Mikey chibi from Tokyo Revengers."
    },
    ["Ego Plush"] = { 
        Rarity = "Dominus", 
        Value = 1200000000000000000000000, -- 1.2Sp
        AssetId = 110790114285745,
        Type = "Hat",
        Description = "A striker Ego plush from Blue Lock."
    },
    ["Nezuko Chibi"] = { 
        Rarity = "Dominus", 
        Value = 1500000000000000000000000, -- 1.5Sp
        AssetId = 117674505316276,
        Type = "Hat",
        Description = "A demon Nezuko chibi from Demon Slayer."
    },
    ["Yuta Chibi"] = { 
        Rarity = "Dominus", 
        Value = 2000000000000000000000000, -- 2Sp
        AssetId = 137886852149361,
        Type = "Hat",
        Description = "A sorcerer Yuta chibi from Jujutsu Kaisen."
    },
    ["Emilia Plush"] = { 
        Rarity = "Dominus", 
        Value = 2500000000000000000000000, -- 2.5Sp
        AssetId = 104808461282373,
        Type = "Hat",
        Description = "A half-elf Emilia plush from Re:Zero."
    },
    ["Toji Fushiguro Chibi"] = { 
        Rarity = "Dominus", 
        Value = 3000000000000000000000000, -- 3Sp
        AssetId = 80433151922305,
        Type = "Hat",
        Description = "A sorcerer Toji chibi from Jujutsu Kaisen."
    },
    ["Garou Plush"] = { 
        Rarity = "Dominus", 
        Value = 4000000000000000000000000, -- 4Sp
        AssetId = 93433945370816,
        Type = "Hat",
        Description = "A hero hunter Garou plush from One Punch Man."
    },
    ["Akashi Chibi"] = { 
        Rarity = "Dominus", 
        Value = 5000000000000000000000000, -- 5Sp
        AssetId = 102007362205931,
        Type = "Hat",
        Description = "A captain Akashi chibi from Kuroko's Basketball."
    },
    ["Alexis Ness Chibi"] = { 
        Rarity = "Dominus", 
        Value = 6000000000000000000000000, -- 6Sp
        AssetId = 133837204653747,
        Type = "Hat",
        Description = "A striker Alexis chibi from Blue Lock."
    },
    ["Shidou Ryusei Plush"] = { 
        Rarity = "Dominus", 
        Value = 8000000000000000000000000, -- 8Sp
        AssetId = 71831354211141,
        Type = "Hat",
        Description = "A striker Shidou plush from Blue Lock."
    },
    ["Deku Chibi"] = { 
        Rarity = "Dominus", 
        Value = 10000000000000000000000000, -- 10Sp
        AssetId = 73953876478108,
        Type = "Hat",
        Description = "A hero Deku chibi from My Hero Academia."
    },
    ["Nishinoya Chibi"] = { 
        Rarity = "Dominus", 
        Value = 12000000000000000000000000, -- 12Sp
        AssetId = 70520201064929,
        Type = "Hat",
        Description = "A libero Nishinoya chibi from Haikyuu."
    },
    ["Megumi Chibi"] = { 
        Rarity = "Dominus", 
        Value = 15000000000000000000000000, -- 15Sp
        AssetId = 78047132632240,
        Type = "Hat",
        Description = "A sorcerer Megumi chibi from Jujutsu Kaisen."
    },
    ["Mitsuri Chibi"] = { 
        Rarity = "Dominus", 
        Value = 20000000000000000000000000, -- 20Sp
        AssetId = 86591833840472,
        Type = "Hat",
        Description = "A hashira Mitsuri chibi from Demon Slayer."
    },
    ["Tanjiro Chibi"] = { 
        Rarity = "Dominus", 
        Value = 25000000000000000000000000, -- 25Sp
        AssetId = 89137342503648,
        Type = "Hat",
        Description = "A demon slayer Tanjiro chibi from Demon Slayer."
    },
    ["Sanemi Chibi"] = { 
        Rarity = "Dominus", 
        Value = 30000000000000000000000000, -- 30Sp
        AssetId = 134640182204961,
        Type = "Hat",
        Description = "A hashira Sanemi chibi from Demon Slayer."
    },
    ["Sae Itoshi Plush"] = { 
        Rarity = "Dominus", 
        Value = 40000000000000000000000000, -- 40Sp
        AssetId = 95433557675398,
        Type = "Hat",
        Description = "A striker Sae plush from Blue Lock."
    },
    ["Isagi Chibi"] = { 
        Rarity = "Dominus", 
        Value = 50000000000000000000000000, -- 50Sp
        AssetId = 74114087443816,
        Type = "Hat",
        Description = "A striker Isagi chibi from Blue Lock."
    },
    ["Itadori Yuji Chibi"] = { 
        Rarity = "Dominus", 
        Value = 60000000000000000000000000, -- 60Sp
        AssetId = 136322471735141,
        Type = "Hat",
        Description = "A sorcerer Yuji chibi from Jujutsu Kaisen."
    },
    ["Bakugo Chibi"] = { 
        Rarity = "Dominus", 
        Value = 80000000000000000000000000, -- 80Sp
        AssetId = 108029167681721,
        Type = "Hat",
        Description = "A hero Bakugo chibi from My Hero Academia."
    },
    ["Bachira Chibi"] = { 
        Rarity = "Dominus", 
        Value = 100000000000000000000000000, -- 100Sp
        AssetId = 137719282020891,
        Type = "Hat",
        Description = "A striker Bachira chibi from Blue Lock."
    },
    ["Gojo Plush"] = { 
        Rarity = "Dominus", 
        Value = 120000000000000000000000000, -- 120Sp
        AssetId = 128493642736861,
        Type = "Hat",
        Description = "A sorcerer Gojo plush from Jujutsu Kaisen."
    },
    ["Zhongli Chibi"] = { 
        Rarity = "Dominus", 
        Value = 150000000000000000000000000, -- 150Sp
        AssetId = 135265524224498,
        Type = "Hat",
        Description = "An archon Zhongli chibi from Genshin Impact."
    },
    ["Itoshi Rin Chibi"] = { 
        Rarity = "Dominus", 
        Value = 200000000000000000000000000, -- 200Sp
        AssetId = 78091137335159,
        Type = "Hat",
        Description = "A striker Rin chibi from Blue Lock."
    },
    ["Sukuna Chibi"] = { 
        Rarity = "Dominus", 
        Value = 250000000000000000000000000, -- 250Sp
        AssetId = 70451661745817,
        Type = "Hat",
        Description = "A curse Sukuna chibi from Jujutsu Kaisen."
    },
    ["Choso Chibi"] = { 
        Rarity = "Dominus", 
        Value = 300000000000000000000000000, -- 300Sp
        AssetId = 136941804656549,
        Type = "Hat",
        Description = "A curse Choso chibi from Jujutsu Kaisen."
    },
    ["Reo Figure"] = { 
        Rarity = "Dominus", 
        Value = 400000000000000000000000000, -- 400Sp
        AssetId = 121200396959101,
        Type = "Hat",
        Description = "A striker Reo figure from Blue Lock."
    },
    ["Shidou Ryusei Figure"] = { 
        Rarity = "Dominus", 
        Value = 500000000000000000000000000, -- 500Sp
        AssetId = 111546688912355,
        Type = "Hat",
        Description = "A striker Shidou figure from Blue Lock."
    },
    ["Nagi Chibi"] = { 
        Rarity = "Dominus", 
        Value = 600000000000000000000000000, -- 600Sp
        AssetId = 134994248940255,
        Type = "Hat",
        Description = "A striker Nagi chibi from Blue Lock."
    },
    ["Sae Itoshi Chibi"] = { 
        Rarity = "Dominus", 
        Value = 800000000000000000000000000, -- 800Sp
        AssetId = 135563773581205,
        Type = "Hat",
        Description = "A striker Sae chibi from Blue Lock."
    },
    ["Sung Jinwoo Plush"] = { 
        Rarity = "Dominus", 
        Value = 1000000000000000000000000000, -- 1Oc
        AssetId = 133407688592895,
        Type = "Hat",
        Description = "A shadow monarch Jinwoo plush from Solo Leveling."
    },
    ["Geto Suguru Chibi"] = { 
        Rarity = "Dominus", 
        Value = 1200000000000000000000000000, -- 1.2Oc
        AssetId = 99694464261427,
        Type = "Hat",
        Description = "A sorcerer Geto chibi from Jujutsu Kaisen."
    },
    ["Rin Itoshi Plush"] = { 
        Rarity = "Dominus", 
        Value = 1500000000000000000000000000, -- 1.5Oc
        AssetId = 74093008941153,
        Type = "Hat",
        Description = "A striker Rin plush from Blue Lock."
    },
    ["Shoei Barou Plush"] = { 
        Rarity = "Dominus", 
        Value = 2000000000000000000000000000, -- 2Oc
        AssetId = 126767561558603,
        Type = "Hat",
        Description = "A striker Barou plush from Blue Lock."
    },
    ["Reo Plush"] = { 
        Rarity = "Dominus", 
        Value = 2500000000000000000000000000, -- 2.5Oc
        AssetId = 126199792991856,
        Type = "Hat",
        Description = "A striker Reo plush from Blue Lock."
    },
    ["Isagi Plush"] = { 
        Rarity = "Dominus", 
        Value = 3000000000000000000000000000, -- 3Oc
        AssetId = 122116904983686,
        Type = "Hat",
        Description = "A striker Isagi plush from Blue Lock."
    },
    ["Nagi Plush"] = { 
        Rarity = "Dominus", 
        Value = 4000000000000000000000000000, -- 4Oc
        AssetId = 121346350308698,
        Type = "Hat",
        Description = "A striker Nagi plush from Blue Lock."
    },
    ["Rimuru Plush"] = { 
        Rarity = "Dominus", 
        Value = 5000000000000000000000000000, -- 5Oc
        AssetId = 106378184060806,
        Type = "Hat",
        Description = "A slime Rimuru plush from That Time I Got Reincarnated as a Slime."
    },
    ["Okarun Plush"] = { 
        Rarity = "Dominus", 
        Value = 6000000000000000000000000000, -- 6Oc
        AssetId = 101714484536746,
        Type = "Hat",
        Description = "A ghost Okarun plush from Dandadan."
    },
    ["Momo Ayase Plush"] = { 
        Rarity = "Dominus", 
        Value = 8000000000000000000000000000, -- 8Oc
        AssetId = 84247659713026,
        Type = "Hat",
        Description = "A heroine Momo plush from Oregairu."
    },
    ["Hatsune Miku Keychain"] = { 
        Rarity = "Dominus", 
        Value = 10000000000000000000000000000, -- 10Oc
        AssetId = 72876356353513,
        Type = "Hat",
        Description = "A vocaloid Miku keychain from Vocaloid."
    },
    ["Miku"] = { 
        Rarity = "Dominus", 
        Value = 12000000000000000000000000000, -- 12Oc
        AssetId = 98505265332855,
        Type = "Hat",
        Description = "A vocaloid Miku from Vocaloid."
    },
    ["Satoru Gojo Chibi"] = { 
        Rarity = "Dominus", 
        Value = 15000000000000000000000000000, -- 15Oc
        AssetId = 110356026493646,
        Type = "Hat",
        Description = "A sorcerer Gojo chibi from Jujutsu Kaisen."
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
            ["Knight Armor"] = 19,      -- 2500 value (loss)
            ["Angel Wings"] = 3,        -- 3500 value (win)
            ["Wizard Hat"] = 1.5,       -- 4200 value (win)
            ["Phoenix Wings"] = 1,      -- 5000 value (win)
            ["Diamond Crown"] = 0.5,    -- 6000 value (jackpot)
        },
    },
    ["CelestialCrate"] = {
        Name = "🌌 Celestial Crate",
        Price = 15000,
        Rewards = {
            ["Void Cloak"] = 75,        -- 12000 value (loss)
            ["Time Boots"] = 19.5,        -- 16000 value (win)
            ["Crystal Sword"] = 3,      -- 20000 value (win)
            ["Celestial Armor"] = 1.5,  -- 25000 value (win)
            ["God's Halo"] = 0.5,       -- 30000 value (jackpot)
            ["Reality Gloves"] = 0.5,   -- 45000 value (jackpot)
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
    ["HuzzCrate"] = {
        Name = "💖 Huzz Crate",
        Price = 2500000000000,
        Rewards = {
            ["Girl Companion"] = 25,         -- 1T (loss)
            ["Cat Girl Companion"] = 19,     -- 1.2T (loss)
            ["Goth Girl Companion"] = 15,    -- 1.5T (loss)
            ["Cute Girl Companion"] = 15,    -- 2T (loss)
            ["Furry Anime Girl Waifu"] = 10,  -- 2.5T (even)
            ["Wizard Girl Companion"] = 10,   -- 5T (win)
            ["Cat Maid Girl Companion"] = 5, -- 7.5T (win)
            ["Astolfo Companion"] = 1,       -- 10T (jackpot)
        },
    },
    ["EightBitCrate"] = {
        Name = "🎮 8-Bit Crate",
        Price = 100000000000000, -- 100 trillion
        Rewards = {
            ["Horn Pixel Red"] = 40,                    -- 50T value (loss)
            ["8-Bit Snowboard Goggles"] = 25,           -- 60T value (loss)
            ["8-Bit Helmet"] = 15,                      -- 80T value (loss)
            ["Damaged Pixel Heart Meme HP"] = 8,        -- 100T value (break-even)
            ["Pixel Pistol"] = 5,                       -- 120T value (win)
            ["8-Bit Roblox Coin"] = 3,                  -- 150T value (win)
            ["8-Bit Extra Life"] = 2,                   -- 200T value (win)
            ["Black 8-Bit Wings"] = 1,                  -- 300T value (win)
            ["8-Bit Immortal Sword Venoms Byte"] = 0.5, -- 500T value (win)
            ["8-Bit Royal Crown"] = 0.3,                -- 800T value (win)
            ["8-Bit Dominus Infernus"] = 0.2,           -- 2Q value (jackpot)
        },
    },
    ["AnimePlushCrate"] = {
        Name = "🎀 Anime Plush Crate",
        Price = 1000000000000000, -- 1Q
        Rewards = {
            -- Losses (≈80%)
            ["Kurumi Plush"] = 18,
            ["Kaguya Plush"] = 15,
            ["Esdeath Chibi"] = 12,
            ["Tohsaka Plush"] = 10,
            ["Toga Plush"] = 8,
            ["Eren Plush"] = 6,
            ["Rikka Plush"] = 4.5,
            ["Otonose Kanade Plush"] = 3.5,
            ["Ichigo Plush"] = 3.5,
            ["Yumeko Plush"] = 2.5,
            ["Nino Plush"] = 2.5,
            ["Karane Plush"] = 2,
            ["Futaba Plush"] = 1.5,
            ["Marin Plush"] = 1.5,
            ["Akame Plush"] = 1,
        
            -- Break-even (5%)
            ["Draken Plush"] = 5,
        
            -- Wins (≈14.99999999999%)
        
            -- Low–Mid Wins (9.5%)
            ["Tomori Plush"] = 0.8,
            ["Evergarden Plush"] = 0.7,
            ["Hange Plush"] = 0.6,
            ["Nico Plush"] = 0.5,
            ["Zero Two Plush"] = 0.4,
            ["Miku Nakano Plush"] = 0.3,
            ["Lucy Plush"] = 0.25,
            ["Albedo Plush"] = 0.2,
            ["Aqua Plush"] = 0.15,
            ["Mikasa Plush"] = 0.12,
            ["Kurisu Plush"] = 0.1,
            ["Asuna Plush"] = 0.08,
        
            -- Big Wins (0.3%)
            ["Akutagawa Plush"] = 0.02,
            ["Nami Plush"] = 0.015,
            ["Saber Plush"] = 0.012,
            ["Akeno Plush"] = 0.01,
            ["Power Plush"] = 0.008,
            ["Charlotte Plush"] = 0.006,
            ["Ikaros Plush"] = 0.005,
            ["Rias Gremory Plush"] = 0.004,
            ["Tsukishima Plush"] = 0.003,
            ["Reinhard Plush"] = 0.0025,
            ["Megumin Plush"] = 0.002,
            ["Nezuko Plush"] = 0.0015,
            ["Makima Plush"] = 0.001,
        
            -- Ultra Rare (0.02%)
            ["Alexis Ness Plush"] = 0.0008,
            ["Naruto Plush"] = 0.0006,
            ["Itoshi Sae Shoulder Chibi"] = 0.0005,
            ["Luffy Plush"] = 0.0004,
            ["Otoya Plush"] = 0.0003,
            ["Subaru Plush"] = 0.00025,
            ["Kagamine Rin Plush"] = 0.0002,
            ["Kagamine Len Plush"] = 0.00015,
            ["Rem Chibi"] = 0.00012,
            ["Don Lorenzo Plush"] = 0.0001,
            ["Echidna Plush"] = 0.00008,
            ["Dante Plush"] = 0.00006,
            ["Uraraka Plush"] = 0.00005,
            ["Gojo Plush"] = 0.00004,
            ["Miku Plush"] = 0.00003,
            ["Kaiser Chibi"] = 0.000025,
            ["Giyu Plush"] = 0.00002,
            ["Teto Plush"] = 0.000015,
            ["Kaiser Plush"] = 0.000012,
            ["Sukuna Plush"] = 0.00001,
        
            -- Mythic+ (0.005%)
            ["Chigiri Plush"] = 0.000008,
            ["Kurona Plush"] = 0.000006,
            ["Karasu Plush"] = 0.000005,
            ["Beatrice Plush"] = 0.000004,
            ["Otto Suwen Plush"] = 0.000003,
            ["Haruka Sakura Chibi"] = 0.000002,
            ["Bachira Plush"] = 0.0000015,
            ["Aryu Plush"] = 0.0000012,
            ["Alya Plush"] = 0.000001,
            ["Shinra Plush"] = 0.0000008,
            ["Rem Plush"] = 0.0000006,
            ["Ram Plush"] = 0.0000004,
            ["Mikey Chibi"] = 0.0000003,
            ["Ego Plush"] = 0.0000002,
            ["Nezuko Chibi"] = 0.00000015,
            ["Yuta Chibi"] = 0.0000001,
        
            -- Jackpot-Tier (0.0005%)
            ["Emilia Plush"] = 0.00000008,
            ["Toji Fushiguro Chibi"] = 0.00000006,
            ["Garou Plush"] = 0.00000005,
            ["Akashi Chibi"] = 0.00000004,
            ["Alexis Ness Chibi"] = 0.00000003,
            ["Shidou Ryusei Plush"] = 0.00000002,
            ["Deku Chibi"] = 0.000000015,
            ["Nishinoya Chibi"] = 0.000000012,
            ["Megumi Chibi"] = 0.00000001,
        
            -- Ultimate Jackpot (0.00000000001%)
            ["Mai Sakurajima Plush"] = 0.00000000001
        },        
    },
}

-- Rebirth System Configuration
	Config.Rebirths = {
        [1] = {
            Name = "First Rebirth",
            Requirements = {
                Money = 50000,
                Items = {
                    {Name = "Cool Hoodie", Amount = 5},
                    {Name = "Designer Jeans", Amount = 3}
                }
            },
            Rewards = {
                LuckBonus = 10, -- 10% luck increase
                UnlockedCrates = {"LegendaryCrate"}
            },
            ResetMoney = 500,
            ClearInventory = true
        },
    
        [2] = {
            Name = "Second Rebirth",
            Requirements = {
                Money = 100000,
                Items = {
                    {Name = "Crown", Amount = 1},
                    {Name = "VR Goggles", Amount = 2}
                }
            },
            Rewards = {
                LuckBonus = 10, -- 10% luck increase (20% total)
                UnlockedCrates = {"MythicalCrate"}
            },
            ResetMoney = 500,
            ClearInventory = true
        },
    
        [3] = {
            Name = "Third Rebirth",
            Requirements = {
                Money = 500000,
                Items = {
                    {Name = "Diamond Crown", Amount = 1},
                    {Name = "Phoenix Wings", Amount = 1}
                }
            },
            Rewards = {
                LuckBonus = 10, -- 10% luck increase (30% total)
                UnlockedCrates = {"CelestialCrate"}
            },
            ResetMoney = 500,
            ClearInventory = true
        },
    
        [4] = {
            Name = "Fourth Rebirth",
            Requirements = {
                Money = 2000000,
                Items = {
                    {Name = "God's Halo", Amount = 1},
                    {Name = "Reality Gloves", Amount = 1}
                }
            },
            Rewards = {
                LuckBonus = 10, -- 10% luck increase (40% total)
                UnlockedCrates = {"DivineCrate"}
            },
            ResetMoney = 500
        },
    
        [5] = {
            Name = "Fifth Rebirth",
            Requirements = {
                Money = 10000000,
                Items = {
                    {Name = "Singularity Staff", Amount = 1},
                    {Name = "Cosmic Crown", Amount = 1}
                }
            },
            Rewards = {
                LuckBonus = 10, -- 10% luck increase (50% total)
                UnlockedCrates = {"TranscendentCrate"}
            },
            ResetMoney = 500,
            ClearInventory = false
        },
    
        [6] = {
            Name = "Sixth Rebirth",
            Requirements = {
                Money = 50000000,
                Items = {
                    {Name = "Aura of the Gods", Amount = 1},
                    {Name = "Black Hole Blade", Amount = 1}
                }
            },
            Rewards = {
                LuckBonus = 10, -- 10% luck increase (60% total)
                UnlockedCrates = {"EtherealCrate"}
            },
            ResetMoney = 500,
            ClearInventory = false
        },
    
        [7] = {
            Name = "Seventh Rebirth",
            Requirements = {
                Money = 100000000,
                Items = {
                    {Name = "Chronomancer's Crown", Amount = 1},
                    {Name = "Rift Walker's Scythe", Amount = 1}
                }
            },
            Rewards = {
                LuckBonus = 10, -- 10% luck increase (70% total)
                UnlockedCrates = {"QuantumCrate"}
            },
            ResetMoney = 500,
            ClearInventory = false
        },
    
        [8] = {
            Name = "Eighth Rebirth",
            Requirements = {
                Money = 500000000,
                Items = {
                    {Name = "Mantle of the Architect", Amount = 1},
                    {Name = "Fragment of Creation", Amount = 1}
                }
            },
            Rewards = {
                LuckBonus = 10, -- 10% luck increase (80% total)
                UnlockedCrates = {"LimitedCrate"}
            },
            ResetMoney = 500,
            ClearInventory = false
        },
    
        [9] = {
            Name = "Ninth Rebirth",
            Requirements = {
                Money = 2000000000,
                Items = {
                    {Name = "Clockwork's Shades", Amount = 1},
                    {Name = "Brighteyes' Bloxy Cola Hat", Amount = 1}
                }
            },
            Rewards = {
                LuckBonus = 10, -- 10% luck increase (90% total)
                UnlockedCrates = {"DominusCrate"}
            }
        },
    
        [10] = {
            Name = "Tenth Rebirth",
            Requirements = {
                Money = 10000000000,
                Items = {
                    {Name = "Dominus Empyreus", Amount = 1},
                    {Name = "Dominus Messor", Amount = 1}
                }
            },
            Rewards = {
                LuckBonus = 10, -- 10% luck increase (100% total)
                UnlockedCrates = {"BrainrotCrate"}
            }
        },
    
        [11] = {
            Name = "Eleventh Rebirth",
            Requirements = {
                Money = 25000000000,
                Items = {
                    {Name = "Tung Tung Soldiers", Amount = 1},
                    {Name = "Kanye", Amount = 1}
                }
            },
            Rewards = {
                LuckBonus = 10, -- 10% luck increase (110% total)
                UnlockedCrates = {"HuzzCrate"}
            }
        },
    
        [12] = {
            Name = "Twelfth Rebirth",
            Requirements = {
                Money = 50000000000,
                Items = {
                    {Name = "Girl Companion", Amount = 1},
                    {Name = "Goth Girl Companion", Amount = 1}
                }
            },
            Rewards = {
                LuckBonus = 10, -- 10% luck increase (120% total)
                UnlockedCrates = {"EightBitCrate"}
            }
        },
    
        [13] = {
            Name = "Thirteenth Rebirth",
            Requirements = {
                Money = 100000000000,
                Items = {
                    {Name = "Black 8-Bit Wings", Amount = 1},
                    {Name = "8-Bit Roblox Coin", Amount = 1}
                }
            },
            Rewards = {
                LuckBonus = 10, -- 10% luck increase (130% total)
                UnlockedCrates = {"AnimePlushCrate"}
            }
        },
    }

-- Default rebirth settings
Config.RebirthDefaults = {
	StartingRebirth = 0,
	MaxRebirths = 20,
	BaseLuck = 1.0 -- Base luck multiplier
}

-- Currency settings
Config.Currency = {
    Name = "R$",
    StartingAmount = 500,
}

Config.GamepassWhitelist = {
    1885690426, -- Nosowge
    -- 1261216760, -- Das_F1sHy312
    -- 2300668379, -- Trynocs
    -- 813591741, -- Nickkarto
}

Config.AutoEnchanterGamepassId = 1288782058 -- 99R$
Config.AutoOpenGamepassId = 1290860985 -- 99R$
Config.AutoSellGamepassId = 1296259225 -- 99R$
Config.InfiniteStorageGamepassId = 1291387177 -- 49R$

Config.ExtraLuckyGamepassId = 1293308405 -- Extra Lucky (+25%) 129R$
Config.UltraLuckyGamepassId = 1294534907 -- ULTRA Lucky (+40%) 199R$

-- Area System Configuration
Config.Areas = {
    [1] = { 
        Name = "Area 1", 
        RebirthsRequired = 2, 
        Position = Vector3.new(0, 5, 0),
        Description = "The starting area for new players"
    },
    [2] = { 
        Name = "Area 2", 
        RebirthsRequired = 4, 
        Position = Vector3.new(100, 5, 0),
        Description = "Requires 4 rebirths to access"
    },
    [3] = { 
        Name = "Area 3", 
        RebirthsRequired = 6, 
        Position = Vector3.new(200, 5, 0),
        Description = "Requires 6 rebirths to access"
    },
    [4] = { 
        Name = "Area 4", 
        RebirthsRequired = 8, 
        Position = Vector3.new(300, 5, 0),
        Description = "Requires 8 rebirths to access"
    },
    [5] = { 
        Name = "Area 5", 
        RebirthsRequired = 10, 
        Position = Vector3.new(400, 5, 0),
        Description = "Requires 10 rebirths to access"
    },
}

return Config