Config = {}

Config.ferroShop = true

Config.ferroShopPos = {
    {
        coords = {x = 1719.8920, y = 3694.9006, z = 34.4878, h = 99.6752},
        ped = 'a_m_m_business_01', 
        size = vec3(1, 1, 2),
        label = 'Manager',
        icon = 'fas fa-briefcase'
    },
}

Config.Blips = {
    {
        title = "Raccolta Ferro",
        colour = 60,
        id = 849,
        size = 0.9,
        x = 1719.8920,
        y = 3694.9006,
        z = 34.4878,
    },
}

Config.Items = {
    'ironore'
}

Config.RequiredItem = 'estrattore'

Config.Debug = true

Config.Timings = {
    ["Estrattore"] = math.random(4000, 5000),
    ["FerroRespawn"] = math.random(8000, 8500),
}

Config.ferroPositions = {
    vector4(1713.7229, 3694.0505, 34.5277, 293.4879),
    vector4(1710.3945, 3695.1445, 34.4891, 98.6446),
    vector4(1711.6024, 3697.8083, 34.4460, 4.0272),
    vector4(1714.2061, 3697.9707, 34.4585, 217.2248),
    vector4(1715.4595, 3689.5408, 34.6199, 308.4962)
}
