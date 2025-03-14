-- -- Tous les objets utilisés par la grue, y compris les conteneurs qu'elle peut ramasser
-- CraneObjects = {
--     ['frame'] = {
--         model = 'prop_dock_rtg_ld',
--         coords = { x = -47.290, y = -2415.690, z = 5.18 }
--     },
--     ['cabin'] = {
--         model = 'p_dock_rtg_ld_cab',
--         position = { x = -0.1, y = 0.0, z = 18.0 },
--         attachTo = 'frame'
--     },
--     ['lifter-cables1'] = {
--         model = 'p_dock_crane_cabl_s',
--         position = { x = 0.1, y = 1.0, z = -5.5 },
--         rotation = { x = 0.0, y = 0.0, z = 90.0 },
--         attachTo = 'cabin'
--     },
--     ['lifter-cables2'] = {
--         model = 'p_dock_crane_cabl_s',
--         position = { x = 0.0, y = 0.0, z = 0.0 },
--         rotation = { x = 0.0, y = 0.0, z = 90.0 },
--         attachTo = 'lifter-cables1'
--     },
--     ['lifter-cables3'] = {
--         model = 'p_dock_crane_cabl_s',
--         position = { x = 0.0, y = 0.0, z = 0.0 },
--         rotation = { x = 0.0, y = 0.0, z = 90.0 },
--         attachTo = 'lifter-cables2'
--     },
--     ['lifter-cables4'] = {
--         model = 'p_dock_crane_cabl_s',
--         position = { x = 0.0, y = 0.0, z = 0.0 },
--         rotation = { x = 0.0, y = 0.0, z = 90.0 },
--         attachTo = 'lifter-cables3'
--     },
--     ['lifter-cables5'] = {
--         model = 'p_dock_crane_cabl_s',
--         position = { x = 0.0, y = 0.0, z = 0.0 },
--         rotation = { x = 0.0, y = 0.0, z = 90.0 },
--         attachTo = 'lifter-cables4'
--     },
--     ['lifter-cables6'] = {
--         model = 'p_dock_crane_cabl_s',
--         position = { x = 0.0, y = 0.0, z = 0.0 },
--         rotation = { x = 0.0, y = 0.0, z = 90.0 },
--         attachTo = 'lifter-cables5'
--     },
--     ['lifter'] = {
--         model = 'p_dock_crane_sld_s',
--         position = { x = 0.0, y = 0.0, z = -8.3 },
--         rotation = { x = 0.0, y = 0.0, z = 90.0 },
--         attachTo = 'lifter-cables6'
--     },
--     ['wheel'] = {
--         model = 'p_dock_rtg_ld_wheel',
--         positions = {
--             leftFront = {
--                 [2] = { x = -5, y = -9.02, z = 0.65 },
--                 [1] = { x = -3.58, y = -9.02, z = 0.65 }
--             },
--             leftBack = {
--                 [2] = { x = 3.3, y = -9.02, z = 0.65 },
--                 [1] = { x = 4.7, y = -9.02, z = 0.65 }
--             },
--             rightFront = {
--                 [2] = { x = -5, y = 9.46, z = 0.65 },
--                 [1] = { x = -3.58, y = 9.46, z = 0.65 }
--             },
--             rightBack = {
--                 [2] = { x = 3.3, y = 9.46, z = 0.65 },
--                 [1] = { x = 4.7, y = 9.46, z = 0.65 }
--             }
--         },
--         attachTo = 'frame'
--     },
--     containers = {
--         ['container-red'] = { model = 'prop_container_01a' },
--         ['container-bilgeco-blue'] = { model = 'prop_container_01c' },
--         ['container-jetsam'] = { model = 'prop_container_01d' },
--         ['container-bilgeco-green'] = { model = 'prop_container_01e' },
--         ['container-krapea'] = { model = 'prop_container_01b' },
--         ['container-postop'] = { model = 'prop_container_01h' },
--         ['container-gopostal'] = { model = 'prop_container_01g' },
--         ['container-landocorp'] = { model = 'prop_container_01f' }
--     }
-- }

-- CranecreatedObjects = {}

-- currentCable = 1

-- -- Assurez-vous que chaque modèle a été demandé
-- for type, data in pairs(CraneObjects) do
--     if type == 'containers' then
--         for _, container in pairs(data) do
--             local model = container.model
--             if not HasModelLoaded(model) and IsModelInCdimage(model) then
--                 RequestModel(model)
--             end
--         end
--     else
--         local model = data.model
--         if not HasModelLoaded(model) and IsModelInCdimage(model) then
--             RequestModel(model)
--         end
--     end
-- end

-- local function placeCrane()
--     for type, data in pairs(CraneObjects) do
--         local model = GetHashKey(data.model)
--         if data.coords then
--             CranecreatedObjects[type] = CreateObject(model, data.coords.x, data.coords.y, data.coords.z, false, false, false)
--             if data.heading then
--                 SetEntityHeading(CranecreatedObjects[type], data.heading)
--             end
--         elseif data.positions then
--             for group, positions in pairs(data.positions) do
--                 for num, position in pairs(positions) do
--                     local objKey = string.format('%s-%s-%d', type, group, num)
--                     CranecreatedObjects[objKey] = CreateObject(model, CraneObjects.frame.coords.x, CraneObjects.frame.coords.y, CraneObjects.frame.coords.z, false, false, false)
--                     AttachEntityToEntity(
--                         CranecreatedObjects[objKey],
--                         CranecreatedObjects[data.attachTo],
--                         0,
--                         position.x,
--                         position.y,
--                         position.z,
--                         0.0,
--                         0.0,
--                         0.0,
--                         false,
--                         false,
--                         true,
--                         false,
--                         0,
--                         false
--                     )
--                 end
--             end
--         elseif data.position then
--             local collision = true
--             CranecreatedObjects[type] = CreateObject(model, CraneObjects.frame.coords.x, CraneObjects.frame.coords.y, CraneObjects.frame.coords.z + 15.5, 1.0, false, false)
--             AttachEntityToEntity(
--                 CranecreatedObjects[type],
--                 CranecreatedObjects[data.attachTo],
--                 0,
--                 data.position.x,
--                 data.position.y,
--                 data.position.z,
--                 data.rotation and data.rotation.x or 0.0,
--                 data.rotation and data.rotation.y or 0.0,
--                 data.rotation and data.rotation.z or 0.0,
--                 false,
--                 false,
--                 collision,
--                 false,
--                 0,
--                 false
--             )
--         end
--     end
-- end

-- local function placeContainers()
--     local containerSpawn = {
--         x = { -52.990, -66.80324, -80.80324, -94.80324 },
--         y = { -2420.99, -2418.29, -2415.59, -2412.92, -2410.22 },
--         z = { 5, 7.82, 10.64 },
--         heading = 90.0
--     }

--     local containerPlacements = {
--         { {}, {}, {}, {} },
--         { {}, {}, {}, {} },
--         { {}, {}, {}, {} }
--     }

--     local containerList = {}
--     for containerType, container in pairs(CraneObjects.containers) do
--         containerList[#containerList + 1] = {
--             type = containerType,
--             model = container.model
--         }
--     end

--     for i = 1, 18 + #containerPlacements do
--         local container = containerList[math.random(1, #containerList)]
--         local foundPlacement = false
--         local containerCoords

--         while not foundPlacement do
--             local xIndex = math.random(1, #containerSpawn.x)
--             local yIndex = math.random(1, #containerSpawn.y)
--             local zIndex = math.random(1, #containerSpawn.z)

--             if not containerPlacements[zIndex][xIndex][yIndex] then
--                 foundPlacement = true
--                 containerPlacements[zIndex][xIndex][yIndex] = true

--                 containerCoords = {
--                     x = containerSpawn.x[xIndex],
--                     y = containerSpawn.y[yIndex],
--                     z = containerSpawn.z[zIndex],
--                     heading = containerSpawn.heading
--                 }
--             end
--         end

--         RequestModel(container.model)
--         while not HasModelLoaded(container.model) do
--             Wait(0)
--         end

--         local containerObj = CreateObject(
--             GetHashKey(container.model),
--             containerCoords.x,
--             containerCoords.y,
--             containerCoords.z,
--             false,
--             false,
--             false
--         )
--         SetEntityHeading(containerObj, containerCoords.heading)
--         SetEntityRotation(containerObj, 0.0, 0.0, containerCoords.heading, 2, false)
--         FreezeEntityPosition(containerObj, true)
--     end
-- end

-- placeCrane()
-- Wait(4000)
-- placeContainers()