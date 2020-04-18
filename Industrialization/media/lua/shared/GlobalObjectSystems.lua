

GlobalObjectSystems = {}

function GlobalObjectSystems.getSObjectSystems()
    local t = 
        {
            SPowerSourceSystem.instance,
            SMiningSystem.instance,
            SRefiningSystem.instance,
        }
    return t
end

function GlobalObjectSystems.getCObjectSystems()
    local t = 
        {
            CPowerSourceSystem.instance,
            CMiningSystem.instance,
            CRefiningSystem.instance,
        }
    return t
end

