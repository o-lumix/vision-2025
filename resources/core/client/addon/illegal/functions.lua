function PlayAlarm(id, url, vol, pos, distance)
    local mathr = math.random(1111,9999)
    xSound:PlayUrlPos(id, url, vol or 0.1, pos or GetEntityCoords(PlayerPedId()))
    xSound:Distance(id, distance + 0.01)
    xSound:destroyOnFinish(id, false)
end

function HackAnimation(ignoreminigame)
    local HasReceivedResponse = nil
    local plyPed = PlayerPedId()
    local plyPos = GetEntityCoords(plyPed)
    local animDict = "anim@heists@ornate_bank@hack"
    local props = "hei_prop_hst_laptop"

    RequestAnimDict(animDict)
    RequestModel(props)

    while not HasAnimDictLoaded(animDict) or not HasModelLoaded(props) do
        Citizen.Wait(10)
    end

    local targetPosition, targetRotation = vec3(plyPos.x, plyPos.y, plyPos.z+0.8), GetEntityRotation(plyPed)
    
    local animPos = GetAnimInitialOffsetPosition(animDict, "hack_loop", targetPosition, targetRotation, 0, 2)
    
    local laptop = CreateObject(GetHashKey(props), targetPosition, 1, 1, 0)
    NetworkAddEntityToSynchronisedScene(laptop, netScene, animDict, "hack_enter_laptop", 4.0, -8.0, 1)
    
    local netScene = NetworkCreateSynchronisedScene(targetPosition - vector3(0.0, 0.0, 0.4), targetRotation, 2, false, false, 1065353216, 0, 1.3)
    NetworkAddPedToSynchronisedScene(plyPed, netScene, animDict, "hack_loop", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(laptop, netScene, animDict, "hack_loop_laptop", 4.0, -8.0, 1)

    NetworkStartSynchronisedScene(netScene)
    Citizen.Wait(5000)
    
    if not ignoreminigame then
        TriggerEvent("datacrack:start", 4.5, function(output)
            if output == true then
                HasReceivedResponse = true
            else
                returHasReceivedResponse = false
            end
            setUsingComputer(false)
            NetworkStopSynchronisedScene(netScene)
        end)
    else
        HasReceivedResponse = true
    end
    DeleteEntity(laptop)
    while HasReceivedResponse == nil do 
        Wait(1)
    end
    return HasReceivedResponse
end


useCrochet = false
local crochetObj = nil

function DeleteCrochet()
    crochetObj:delete()
    useCrochet = false
end

RegisterNetEvent("core:useCrochet", function()
    useCrochet = not useCrochet
    if useCrochet then
        crochetObj = entity:CreateObject("prop_tool_screwdvr03", p:pos())
        AttachEntityToEntity(crochetObj:getEntityId(), p:ped(),GetEntityBoneIndexByName(p:ped(), "IK_R_Hand"), 0.1, 0.13,0.0, 90.0, 120.0, -20.0, false, false, false, false, 0.0, true)
        if CanAccessAction('Cambriolage') then
            HideAllPropertiesForCrochet()
        end
    else
        exports['vNotif']:createNotification({
            type = 'JAUNE',
            -- duration = 5, -- In seconds, default:  4
            content = "Vous avez ranger votre crochet"
        })
        if CanAccessAction('Cambriolage') then
            ShowAllPropertiesForCrochet()
        end
        crochetObj:delete()
    end
    while useCrochet do 
        Wait(1)
		for k, v in pairs(GetVehicles()) do
            if v and DoesEntityExist(v) then 
                if GetEntitySpeed(v) < 1.2 then
                    if GetDistanceBetweenCoords(GetEntityCoords(PlayerPedId()), GetEntityCoords(v)) < 2.6 then 
                        Bulle.create("veh" .. v,GetEntityCoords(v) + vector3(0.0, 0.0, 1.3),"bulleCrocheter",true)
                        if not useCrochet then 
                            Bulle.remove("veh" .. v)
                        end
                        if IsControlJustPressed(0, 38) then 
                            Bulle.remove("veh" .. v)
                            TriggerEvent("core:hookVehicle")
                            crochetObj:delete()
                            useCrochet = false
                            break
                        end
                    else
                        Bulle.remove("veh" .. v)
                    end
                else
                    Bulle.remove("veh" .. v)
                end
            end
        end
    end
    crochetObj:delete()
end)

function ShowAllPropertiesForCrochet()
    for k,v in pairs(AllPropBulles) do 
        Bulle.show(v.id)
        Bulle.remove("cambu " .. v.id)
    end
    Bulle.remove("cambuEntree")
end

function HideAllPropertiesForCrochet()
    for k,v in pairs(AllPropBulles) do 
        Bulle.hide(v.id)
        zone.addZone(
            "cambu " .. v.id,
            vector3(v.x, v.y, v.z),
            "~INPUT_CONTEXT~ Accéder à la propriété",
            function()
                if useCrochet then
                    TriggerEvent("core:UseCrocket")
                end
            end,
            false,
            50,             -- Id / type du marker
            0.6,                -- La taille
            { 51, 204, 255 },   -- RGB
            170,                 -- Alpha
            1.5,
            true,
            "bulleCambrioler"
        )
    end
end

function HideAllCambu()
    for k,v in pairs(AllPropBulles) do 
        Bulle.hide("cambu " .. v.id)
    end
end

function HideAllCambuForEnter(pos)
    for k,v in pairs(AllPropBulles) do 
        Bulle.hide("cambu " .. v.id)
    end
    zone.addZone(
        "cambuEntree",
        pos,
        "~INPUT_CONTEXT~ Accéder à la propriété",
        function()
        end,
        false,
        50,             -- Id / type du marker
        0.6,                -- La taille
        { 51, 204, 255 },   -- RGB
        170,                 -- Alpha
        1.5,
        true,
        "bulleEntrer"
    )
end

Drilling = {}

Drilling.DisabledControls = {30,31,32,33,34,35}

Drilling.Start = function(callback, ParticleCoords)
  if not Drilling.Active then
    Drilling.Active = true
    Drilling.Init()
    Drilling.Update(callback, ParticleCoords)
  end
end

local function ScalePopFloat(scaleform,method,val)
    PushScaleformMovieFunction(scaleform,method)
    PushScaleformMovieFunctionParameterFloat(val)
    PopScaleformMovieFunctionVoid()
end

Drilling.Init = function()
  if Drilling.Scaleform then
    SetScaleformMovieAsNoLongerNeeded(Drilling.Scaleform)
  end

  Drilling.Scaleform = RequestScaleformMovie("DRILLING")
  while not HasScaleformMovieLoaded(Drilling.Scaleform) do Wait(0) end
  
  Drilling.DrillSpeed = 0.0
  Drilling.DrillPos   = 0.0
  Drilling.DrillTemp  = 0.0
  Drilling.HoleDepth  = 0.0
  

  ScalePopFloat(Drilling.Scaleform,"SET_SPEED",           0.0)
  ScalePopFloat(Drilling.Scaleform,"SET_DRILL_POSITION",  0.0)
  ScalePopFloat(Drilling.Scaleform,"SET_TEMPERATURE",     0.0)
  ScalePopFloat(Drilling.Scaleform,"SET_HOLE_DEPTH",      0.0)
end

Drilling.Update = function(callback, ParticleCoords)
    print("ParticleCoords", ParticleCoords)
    RequestNamedPtfxAsset("core")
    UseParticleFxAssetNextCall("core")
    while not HasNamedPtfxAssetLoaded("core") do
        Wait(1)
    end
    while Drilling.Active do
        Drilling.Draw()
        Drilling.DisableControls()
        Drilling.HandleControls(ParticleCoords)
        Wait(0)
    end
    callback(Drilling.Result)
end

Drilling.Draw = function()
  DrawScaleformMovieFullscreen(Drilling.Scaleform,255,255,255,255,255)
end

Drilling.HandleControls = function(ParticleCoords)
    local last_pos = Drilling.DrillPos
    if IsControlJustPressed(0,172) then
        Drilling.DrillPos = math.min(1.0,Drilling.DrillPos + 0.01)
        UseParticleFxAssetNextCall("core")
        StopParticleFxLooped(Drilling.Particle, 0)
        RemoveParticleFx(Drilling.Particle, 0)
        Drilling.Particle = StartParticleFxLoopedAtCoord("ent_brk_sparking_wires", ParticleCoords, 90.0, 0.0, 0.0, 1.0, 0, 0, 0)
    elseif IsControlPressed(0,172) then
        Drilling.DrillPos = math.min(1.0,Drilling.DrillPos + (0.1 * GetFrameTime() / (math.max(0.1,Drilling.DrillTemp) * 10)))
        UseParticleFxAssetNextCall("core")
        StopParticleFxLooped(Drilling.Particle, 0)
        RemoveParticleFx(Drilling.Particle, 0)
        Drilling.Particle = StartParticleFxLoopedAtCoord("ent_brk_sparking_wires", ParticleCoords, 90.0, 0.0, 0.0, 1.0, 0, 0, 0)
    elseif IsControlJustPressed(0,173) then
        Drilling.DrillPos = math.max(0.0,Drilling.DrillPos - 0.01)
        StopParticleFxLooped(Drilling.Particle, 0)
        RemoveParticleFx(Drilling.Particle, 0)
    elseif IsControlPressed(0,173) then
        Drilling.DrillPos = math.max(0.0,Drilling.DrillPos - (0.1 * GetFrameTime()))
        StopParticleFxLooped(Drilling.Particle, 0)
        RemoveParticleFx(Drilling.Particle, 0)
    end

    local last_speed = Drilling.DrillSpeed
    if IsControlJustPressed(0,175) then
        Drilling.DrillSpeed = math.min(1.0,Drilling.DrillSpeed + 0.05)
    elseif IsControlPressed(0,175) then
        Drilling.DrillSpeed = math.min(1.0,Drilling.DrillSpeed + (0.5 * GetFrameTime()))
    elseif IsControlJustPressed(0,174) then
        Drilling.DrillSpeed = math.max(0.0,Drilling.DrillSpeed - 0.05)
    elseif IsControlPressed(0,174) then
        Drilling.DrillSpeed = math.max(0.0,Drilling.DrillSpeed - (0.5 * GetFrameTime()))
    end

    local last_temp = Drilling.DrillTemp
    if last_pos < Drilling.DrillPos then
        if Drilling.DrillSpeed > 0.4 then
        Drilling.DrillTemp = math.min(1.0,Drilling.DrillTemp + ((0.05 * GetFrameTime()) *  (Drilling.DrillSpeed * 10)))
        ScalePopFloat(Drilling.Scaleform,"SET_DRILL_POSITION",Drilling.DrillPos)
        else
        if Drilling.DrillPos < 0.1 or Drilling.DrillPos < Drilling.HoleDepth then
            ScalePopFloat(Drilling.Scaleform,"SET_DRILL_POSITION",Drilling.DrillPos)
        else
            Drilling.DrillPos = last_pos
            Drilling.DrillTemp = math.min(1.0,Drilling.DrillTemp + (0.01 * GetFrameTime()))
        end
        end
    else
        if Drilling.DrillPos < Drilling.HoleDepth then
        Drilling.DrillTemp = math.max(0.0,Drilling.DrillTemp - ( (0.05 * GetFrameTime()) *  math.max(0.005,(Drilling.DrillSpeed * 10) /2)) )
        end

        if Drilling.DrillPos ~= Drilling.HoleDepth then
        ScalePopFloat(Drilling.Scaleform,"SET_DRILL_POSITION",Drilling.DrillPos)
        end
    end

    if last_speed ~= Drilling.DrillSpeed then
        ScalePopFloat(Drilling.Scaleform,"SET_SPEED",Drilling.DrillSpeed)
    end

    if last_temp ~= Drilling.DrillTemp then    
        ScalePopFloat(Drilling.Scaleform,"SET_TEMPERATURE",Drilling.DrillTemp)
    end

    if Drilling.DrillTemp >= 1.0 then
        Drilling.Result = false
        Drilling.Active = false
    elseif Drilling.DrillPos >= 1.0 then
        Drilling.Result = true
        Drilling.Active = false
    end

    Drilling.HoleDepth = (Drilling.DrillPos > Drilling.HoleDepth and Drilling.DrillPos or Drilling.HoleDepth)
end

Drilling.DisableControls = function()
  for _,control in ipairs(Drilling.DisabledControls) do
    DisableControlAction(0,control,true)
  end
end

Drilling.EnableControls = function()
  for _,control in ipairs(Drilling.DisabledControls) do
    DisableControlAction(0,control,true)
  end
end

AddEventHandler("Drilling:Start",Drilling.Start)

RegisterNetEvent("Drilling:Stop")
AddEventHandler("Drilling:Stop", function()
  Drilling.Result = false
  Drilling.Active = false
end)


local menu = RageUI.CreateMenu("Particules", "Pas synchro")

local Particles = {
    'bul_gravel_heli',
    'ent_dst_concrete_large',
    'bul_wood_splinter',
    'fire_wrecked_plane_cockpit',
    'wheel_fric_water',
    'proj_flare_trail',
    'exp_grd_grenade_lod',
    'ent_amb_fbi_cinder',
    'muz_smoking_barrel_minigun',
    'ent_dst_gen_gobstop',
    'ent_dst_inflate_ball',
    'water_splash_ped_wade',
    'exp_grd_plane_post',
    'ent_ray_paleto_gas_flames',
    'eject_stungun',
    'ent_amb_wind_grass_dir',
    'ent_amb_steam_pipe_lgt',
    'ped_underwater_disturb_dirt',
    'water_boat_wash',
    'water_splash_obj_in',
    'blood_stab',
    'ent_brk_metal_frag',
    'bul_water_heli',
    'ent_sht_oil',
    'bul_decal_water_heli',
    'ent_sht_water_tower',
    'env_snow_flakes',
    'bul_hay',
    'trail_splash_oil',
    'bul_sand_loose_heli',
    'ent_sht_beer_barrel',
    'veh_sub_crush',
    'ent_anim_paparazzi_flash',
    'veh_vent_heli_anh',
    'exp_grd_petrol_pump',
    'ent_ray_meth_fires',
    'veh_exhaust_hidden',
    'exp_air_molotov',
    'ent_anim_snot_blow',
    'water_amph_car_rev',
    'mel_carmetal',
    'bul_concrete',
    'ent_anim_cig_exhale_mth_car',
    'exp_air_rpg_lod',
    'veh_trailer_petrol_spray',
    'water_amph_quad_bow',
    'env_smoke_fbi',
    'water_splash_vehicle',
    'blood_shark_attack',
    'ent_dst_wood_chunky',
    'td_blood_shotgun',
    'exp_grd_grenade_smoke',
    'ent_dst_elec_fire_sp',
    'ped_foot_decal_oil',
    'fire_wrecked_train',
    'exp_hydrant',
    'ent_amb_wind_leaves',
    'ent_amb_wind_litter_swirl',
    'wheel_fric_hard_dusty_Bike',
    'ent_amb_tap_drip',
    'exp_air_grenade_lod',
    'water_splash_sub_wade',
    'ped_foot_decal_mud',
    'water_splash_plane_in',
    'ent_amb_trev1_trailer_sp_s',
    'td_blood_throat',
    'blood_melee_punch',
    'wheel_fric_sandWet_Bike',
    'ent_dst_polystyrene',
    'exp_air_molotov_lod',
    'blood_exit',
    'eject_minigun',
    'wheel_fric_grass',
    'fire_wheel_bike',
    'fire_petroltank_car',
    'ent_amb_water_splash_wide',
    'veh_backfire',
    'weap_hvy_turbulance_water',
    'ent_amb_leaves_pine',
    'ent_amb_fountain_double',
    'ent_amb_exhaust_thin',
    'ent_dst_inflate_ring',
    'eject_auto',
    'bang_concrete',
    'ent_amb_wind_leaves_dir',
    'ent_amb_rapid_dir_splash_wide',
    'fire_petroltank_car_bullet',
    'muz_pistol_silencer',
    'ent_sht_gloopy_liquid',
    'ent_sht_petrol',
    'ent_ray_ch2_farm_resi_dble',
    'blood_chopper',
    'ent_amb_elec_crackle',
    'ent_dst_gen_paper',
    'ent_ray_train_water_wash',
    'ent_sht_flame',
    'ent_anim_cig_exhale_nse',
    'exp_grd_plane_sp',
    'veh_vent_rc',
    'veh_vent_heli_skylift',
    'ent_amb_fbi_smoulder_lg',
    'ent_amb_fbi_fire_beam',
    'ent_sht_bush_foliage',
    'ped_foot_woodchips',
    'ent_dst_sweet_boxes',
    'ped_foot_sand_deep',
    'ped_foot_gravel',
    'ent_dst_cig_packets',
    'ent_amb_wind_litter_dust_dir',
    'ent_dst_wood_splinter',
    'bul_gravel',
    'water_amph_prop',
    'ent_brk_concrete',
    'ent_sht_steam',
    'ent_amb_steam_prison',
    'water_splash_plane_trail',
    'ent_amb_water_drips_spawned',
    'veh_exhaust_heli_misfire',
    'wheel_fric_sand_LOD',
    'exp_air_rpg_plane',
    'water_jetski_bow1',
    'proj_missile_trail',
    'fire_petroltank_heli',
    'exp_grd_plane',
    'ent_amb_water_drips_lg',
    'ent_amb_smoke_gaswork',
    'proj_flare_fuse_fp',
    'ent_amb_smoke_chicken',
    'water_jetski_entry2',
    'bang_mud',
    'exp_air_rpg_plane_sp',
    'water_boat_entry',
    'fire_petrol_one',
    'ent_amb_cold_air_floor',
    'ent_col_tree_oranges',
    'ent_amb_fbi_smoke_land_lt',
    'ent_anim_cig_smoke',
    'ent_amb_fbi_fire_door',
    'fire_petroltank_truck',
    'veh_vent_heli_frogger',
    'ent_amb_wind_litter_dir',
    'bul_stungun_metal',
    'veh_respray_smoke',
    'ent_amb_foundry_molten_pour',
    'blood_stab_uw',
    'veh_downwash',
    'water_amph_quad_rev',
    'ent_brk_sparking_wires',
    'water_amph_car_bow',
    'veh_panel_open_car',
    'ent_amb_fountain_rodeo',
    'wheel_spin_gravel',
    'ent_amb_fbi_smoke_linger_hvy',
    'ent_amb_torch_fire',
    'ent_anim_leaf_blower',
    'ent_ray_shipwreck_oil',
    'sp_petrolcan_splash',
    'ped_parachute_open',
    'ent_amb_trop_fish_swarm_angel',
    'ent_anim_street_sweep',
    'wheel_fric_grass_bike',
    'water_boat_rev',
    'ent_ray_shipwreck_bubbles',
    'bang_wood',
    'proj_tank_trail',
    'bul_glass',
    'water_splash_bike_wade',
    'ent_amb_wind_hay',
    'glass_smash',
    'ent_amb_tnl_bubbles_sml',
    'ent_amb_sprinkler_crop',
    'fire_wrecked_tank',
    'ent_ray_pro1_water_drip',
    'lens_bug_dirt',
    'liquid_splash_oil',
    'ent_amb_smoke_scrap',
    'blood_animal_maul',
    'bang_blood',
    'ent_amb_water_roof_drips_thin',
    'ent_ray_ch2_farm_fire_u_l',
    'ent_amb_wind_litter_dust',
    'ent_brk_gate_smoke',
    'ent_amb_fbi_smoke_door_med',
    'veh_prop_sub',
    'bul_mud_heli',
    'bul_cardboard',
    'bul_carmetal_heli',
    'ped_foot_dirt_dry',
    'fire_petroltank_plane',
    'ent_col_rocks',
    'muz_assault_rifle',
    'water_splash_veh_out',
    'weap_veh_turbulance_sand',
    'ent_amb_wind_rand_litter',
    'ent_dst_gen_water_spray',
    'ent_amb_butterflys_swarm',
    'ent_amb_steam_vent_open_lgt',
    'veh_vent_heli_cargobob',
    'veh_light_red',
    'water_boat_bow',
    'env_interior_dusty',
    'ent_amb_rapid_area_spray_hvy',
    'bul_decal_oil',
    'trail_splash_blood',
    'ent_amb_jazuzzi',
    'ped_underwater_disturb_sand',
    'ent_dst_gen_food',
    'water_boat_prop',
    'ent_anim_dusty_hands',
    'exp_grd_tankshell_lod',
    'ent_amb_foundry_fogball',
    'bul_glass_mini',
    'veh_exhaust_heli_skylift',
    'veh_panel_shut_car',
    'fire_wrecked_heli_cockpit',
    'ent_amb_fbi_fire_drip',
    'bul_plastic',
    'bul_dirt_heli',
    'ent_amb_beach_campfire',
    'water_splash_obj_trail',
    'exp_grd_sticky_sp',
    'veh_panel_shut_truck',
    'ent_ray_finale_vault_haze',
    'ent_amb_trop_fish_swarm_col',
    'water_amph_car_entry',
    'bullet_tracer_railgun',
    'ped_blood_pool_water',
    'weap_hvy_turbulance_dirt',
    'fire_wrecked_car',
    'veh_plane_eject',
    'ent_ray_prologue_elec_crackle',
    'exp_grd_petrol_pump_sp',
    'ent_amb_tnl_bubbles_lge',
    'td_blood_stab',
    'exp_sht_flame',
    'ent_ray_heli_aprtmnt_water',
    'veh_exhaust_heli',
    'muz_stungun',
    'ent_ray_fam3_dust_motes',
    'wheel_fric_sandWet_Tank',
    'wheel_decal_slush',
    'ent_amb_steam',
    'ent_amb_rapid_rock_drips',
    'env_wind_debris_countryside',
    'blood_armour_heavy',
    'water_splash_ped_out',
    'ent_dst_rubbish',
    'ent_amb_fbi_falling_debris_sp',
    'muz_hunter',
    'veh_exhaust_plane_start',
    'muz_buzzard',
    'veh_air_turbulance_dirt',
    'wheel_decal_water_Bike_Deep',
    'ent_dst_glass_bottles',
    'fire_petrol_two',
    'wheel_spin_mud',
    'env_cloud',
    'exp_grd_boat_lod',
    'bul_glass_shotgun',
    'water_jetski_prop',
    'env_dust_motes_int_recycle',
    'ent_amb_sewer_drips_lg',
    'ent_amb_smoke_foundry',
    'env_dust_devil_urban_sma',
    'bul_rubber_dust',
    'exp_grd_plane_lod',
    'ent_brk_wood_splinter',
    'lens_rain',
    'veh_downwash_sand',
    'wheel_decal_petrol_Bike',
    'ent_amb_falling_palm_leaves',
    'lens_noir',
    'exp_grd_boat_sp',
    'ent_ray_finale1_fire',
    'scrape_plastic',
    'ent_anim_welder',
    'ent_anim_weed_smoke',
    'water_splash_bike_out',
    'veh_exhaust_spacecraft',
    'veh_exhaust_heli_cargobob_misfire',
    'ent_brk_steam_burst',
    'env_gunsmoke',
    'veh_prop_submersible',
    'exp_extinguisher',
    'water_boat_entry2',
    'veh_exhaust_plane',
    'water_boat_Tropic_bow',
    'water_splash_ped_in',
    'bul_leaves',
    'ent_amb_fbi_smoke_fogball',
    'liquid_splash_blood',
    'weap_veh_turbulance_default',
    'lens_smoke',
    'env_wind_debris',
    'lens_blaze',
    'exp_air_blimp2_sp',
    'env_dust_devil_urban_lrg',
    'exp_water',
    'ent_ray_finale_vault_sparks',
    'weap_hvy_turbulance_default',
    'ent_amb_steam_pipe_hvy',
    'bul_mud',
    'ent_amb_fire_ring',
    'ent_ray_pro1_water_splash_spawn',
    'ent_amb_drain_splash',
    'ent_amb_exhaust_thick',
    'exp_grd_molotov_lod',
    'ent_amb_sprinkler_golf',
    'ent_brk_tree_trunk_bark',
    'ent_amb_rapid_dir_splash_light',
    'ent_amb_barrel_fire',
    'ped_foot_water',
    'eject_auto_fp',
    'bul_foam',
    'water_splash_ped_bubbles',
    'ent_col_bush_leaves',
    'exp_grd_rpg_post',
    'fire_map_quick',
    'blood_mist',
    'ped_foot_dusty',
    'ent_amb_trop_fish_swarm_lil',
    'wtr_rocks_wall_splash',
    'wheel_fric_sand',
    'shotgun_water',
    'bul_concrete_heli',
    'water_boat_dinghy_bow_mounted',
    'ent_amb_fbi_fire_wall_lg',
    'ent_amb_foundry_dust',
    'scrape_metal',
    'exp_hydrant_decals_sp',
    'exp_grd_boat_spawn',
    'ent_amb_sewer_drips_med',
    'fire_petrol_script',
    'ent_amb_stoner_vent_smoke',
    'muz_alternate_star_fp',
    'wheel_spin_leaves',
    'ent_anim_bm_water_scp',
    'ent_sht_molten_liquid',
    'bul_concrete_minigun',
    'exp_bird_crap',
    'ent_amb_dust_motes',
    'ent_sht_paint_cans',
    'veh_light_amber',
    'ent_dst_paint_cans',
    'veh_downwash_foliage',
    'exp_grd_train',
    'weap_veh_turbulance_foliage',
    'liquid_splash_gloopy',
    'exp_air_blimp_sp',
    'env_interior_chickenfarm',
    'exp_sht_steam',
    'ent_amb_falling_leaves_m',
    'veh_plane_damage',
    'blood_nose',
    'muz_smoking_barrel',
    'scrape_mud',
    'water_boat_Suntrap_bow',
    'ent_sht_water',
    'ent_ray_heli_aprtmnt_l_fire',
    'fire_wrecked_truck_vent',
    'proj_missile_underwater',
    'ent_col_palm_leaves',
    'wheel_spin_water_deep',
    'wheel_spin_blood',
    'ent_dst_gen_liquid_burst',
    'ent_dst_wood_planks',
    'ent_amb_steam_vent_round',
    'ent_brk_tree_leaves',
    'scrape_veg',
    'ent_amb_moths_swarm',
    'exp_air_rpg_plane_lod',
    'wheel_fric_gravel',
    'td_blood_hatchet',
    'ent_amb_peeing',
    'bul_decal_blood',
    'exp_air_rpg_sp',
    'wheel_decal_water_Bike',
    'bul_grass',
    'ent_sht_cactus',
    'blood_entry_head_sniper',
    'weap_veh_turbulance_dirt',
    'veh_oil_slick',
    'ped_scrape_sand_underwater',
    'ped_foot_decal_water',
    'lens_snow',
    'td_blood_hatchet_back',
    'ent_amb_sprinkler_city_sml',
    'ent_amb_insect_plane',
    'water_boat_jetmax_bow',
    'exp_grd_flare',
    'wheel_fric_hard',
    'proj_flare_fuse',
    'muz_pistol_fp',
    'veh_exhaust_heli_cargobob',
    'bul_wood_splinter_heli',
    'ent_amb_sewer_drips_spawned_lg',
    'ent_ray_heli_aprtmnt_s_fire',
    'ent_amb_rapid_area_spray',
    'wheel_fric_water_Bike',
    'sp_fbi_fire_drip_trails',
    'ent_ray_ch2_farm_fire_dble',
    'veh_vent_boat',
    'exp_grd_molotov',
    'veh_exhaust_titan',
    'ent_amb_fbi_smoulder_sm',
    'ent_dst_gen_plastic_cont',
    'exp_grd_vehicle_lod',
    'wheel_spin_grass',
    'lens_water_run',
    'ent_dst_office_paper',
    'wheel_fric_leaves_Bike',
    'ent_amb_wind_grass',
    'liquid_splash_petrol',
    'veh_train_sparks',
    'ent_dst_gen_cardboard',
    'water_splash_whale_wade',
    'ent_amb_sparking_wires',
    'scrape_sand_underwater',
    'ent_dst_plant_leaves',
    'ent_brk_lamppost_base',
    'ent_amb_waterfall_splash_p',
    'liquid_splash_pee',
    'wheel_fric_gravel_LOD',
    'muz_smoking_barrel_shotgun',
    'bul_paper',
    'muz_rpg',
    'ped_foot_gravel_deep',
    'bul_brick',
    'mel_concrete',
    'ent_ray_heli_aprtmnt_embers',
    'bul_glass_tv',
    'wheel_decal_mud',
    'liquid_splash_paint',
    'ent_amb_fbi_light_door',
    'muz_smoking_barrel_fp',
    'veh_exhaust_start_bike',
    'water_splash_veh_in',
    'fire_wrecked_plane',
    'ent_ray_tanker_petrol_spray',
    'ent_amb_wind_hay_dir',
    'ent_amb_candle_flame',
    'muz_assault_rifle_fp',
    'ped_foot_chickenfarm',
    'exp_grd_grenade',
    'ent_amb_wfall_splash_sml',
    'exp_grd_vehicle_spawn',
    'ent_dst_electrical',
    'bul_carmetal',
    'veh_slipstream',
    'exp_grd_boat',
    'ent_amb_leaves_oak_g',
    'wheel_fric_hard_dusty_Tank',
    'water_jetski_bow1_mounted',
    'veh_vent_plane_duster',
    'fire_wrecked_truck',
    'ent_amb_wind_tree_leaves',
    'water_cannon_jet',
    'ent_ray_ch2_farm_smoke_dble',
    'ent_ray_heli_aprtmnt_exp',
    'env_dust_devil_rural_sma',
    'ent_dst_concrete',
    'ent_ray_heli_aprtmnt_sprk_wrs',
    'env_wind_debris_city',
    'ent_sht_blood',
    'exp_grd_propane',
    'veh_vent_plane_lazer',
    'fire_wrecked_bike',
    'veh_panel_shut_tank',
    'water_boat_exit',
    'bang_sand_underwater',
    'ent_sht_paper_bails',
    'ent_amb_smoke_general',
    'blood_entry_shotgun',
    'ent_dst_upholstery',
    'veh_exhaust_velum',
    'ent_amb_elec_crackle_sp',
    '_fog_plane',
    'exp_grd_sticky_lod',
    'blood_entry_sniper',
    'wheel_decal_mud_Bike',
    'fire_object',
    'proj_disturb_dust',
    'bullet_shotgun_tracer',
    'ent_ray_ch2_farm_fire_l_l_l',
    'ent_amb_foundry_heat_haze',
    'ent_dst_donuts',
    'wheel_fric_sandWet_LOD',
    'water_splash_sub_in',
    'veh_wind_litter_dir',
    'ent_amb_cig_smoke_linger',
    'ent_dst_hobo_trolley',
    'shark_underwater_trails',
    'ent_anim_pneumatic_drill',
    'ped_breath_water',
    'bul_chickenfarm',
    'proj_grenade_trail',
    'exp_grd_vehicle_post',
    'weap_hvy_turbulance_sand',
    'ent_col_electrical',
    'veh_exhaust_vulkan',
    'veh_plane_propeller_destroy',
    'scr_fbi_falling_dust',
    'proj_grenade_smoke',
    'scr_agency3b_sprinkler_off',
    'ent_brk_blood',
    'exp_grd_bzgas_smoke',
    'ent_sht_petrol_fire',
    'ent_amb_water_drips_spawned_lg',
    'ent_amb_abattoir_saw_blood',
    'bul_decal_water',
    'veh_exhaust_truck_rig',
    'ent_amb_snow_mist_upper',
    'wheel_decal_water_Tank',
    'ent_amb_fbi_falling_debris',
    'ent_dst_elec_fire',
    'env_dust_motes_int_hvy',
    'exp_grd_petrol_pump_spawn',
    'fire_wrecked_car_vent',
    'water_splash_shark_wade',
    'veh_panel_shut_feltzer2010',
    'wheel_fric_gravel_Bike',
    'ent_dst_newspaper',
    'ent_brk_wood_planks',
    'mel_glass',
    'blood_headshot',
    'ent_dst_wet_sand',
    'blood_throat',
    'fire_wrecked_boat',
    'trail_splash_water',
    'ent_anim_bm_water_mist',
    'ent_amb_fly_zapped_spawned',
    'exp_grd_rpg_sp',
    'env_bar_haze',
    'exp_grd_sticky',
    'veh_petrol_leak_bullet',
    'sp_ent_sparking_wires',
    'exp_grd_gas_can',
    'ent_amb_sewer_drips_spawned',
    'ent_amb_sprinkler_city',
    'water_splash_sub_out',
    'ent_amb_fbi_smoke_ramp_lt',
    'veh_exhaust_tug',
    'glass_windscreen',
    'ent_dst_elec_crackle',
    'proj_molotov_flame_fp',
    'eject_heli_gun',
    'ent_sht_extinguisher',
    'ent_amb_stoner_dust_drop',
    'ent_anim_gardener_plant',
    'wheel_fric_hard_tank',
    'veh_panel_open_carHK',
    'water_splash_animal_wade',
    'fire_wheel',
    'veh_light_red_trail',
    'ent_amb_falling_cherry_bloss',
    'ped_foot_decal_petrol',
    'ent_dst_inflatable',
    'bang_carmetal',
    'wtr_sea_pole_splash',
    'bang_blood_car',
    'ent_amb_vent_haze_sm',
    'water_splash_ped',
    'ent_amb_int_fireplace_sml',
    'muz_tank',
    'ent_amb_pro_elec_fires',
    'wheel_decal_oil_Bike',
    'veh_wingtip',
    'ent_sht_cardboard',
    'exp_grd_vehicle_sp',
    'proj_laser_player',
    'ent_amb_river_splash_gen',
    'exp_grd_tankshell',
    'ent_amb_foundry_steam',
    'water_jetski_rev',
    'ped_parachute_trail',
    'env_interior_foundry',
    'ent_amb_water_drips_med',
    'rim_fric_hard',
    'wheel_fric_grass_LOD',
    'ent_brk_coins',
    'ent_amb_rapid_dir_spray',
    'veh_sub_dive',
    'ent_amb_fbi_fire_fogball',
    'ent_anim_animal_graze',
    'exp_air_blimp',
    'muz_minigun_alt',
    'ent_amb_stoner_falling_wchips',
    'wheel_decal_water_deep',
    'exp_grd_rpg_plane_sp',
    'veh_exhaust_truck',
    'blood_mist_prop',
    'env_wind_debris_woodland',
    'bullet_tracer_jet',
    'ent_amb_leaves_ficus_g',
    'veh_overturned_exhaust',
    'blood_entry',
    'eject_shotgun',
    'muz_alternate_star',
    'sp_fire_trail_heli',
    'ent_brk_uprooted',
    'ent_amb_foundry_steam_spawn',
    'ent_amb_int_waterfall_splash',
    'exp_grd_barrel',
    'exp_grd_vehicle',
    'ent_amb_wind_litter',
    'muz_shotgun',
    'ent_ray_heli_aprtmnt_h_fire',
    'veh_downwash_dirt',
    'water_jetski_exit',
    'exp_grd_rpg_lod',
    'weap_petrol_can',
    'fire_ped_smoulder',
    'ent_amb_fly_zapped',
    'veh_air_debris',
    'ent_sht_dust',
    'veh_panel_open_truck',
    'ent_amb_fbi_fire_dub_door',
    'wheel_fric_sand_Bike',
    'wheel_fric_leaves',
    'env_dust_devil_rural_lrg',
    'bullet_tracer',
    'ent_dst_chick_carcass',
    'ent_amb_sewer_drips_sm',
    'wheel_burnout',
    'scrape_sand',
    'ent_amb_cockroach_swarm',
    'ent_amb_generator_smoke',
    'muz_laser',
    'env_gunsmoke_paper_factory',
    'veh_vent_heli',
    'ent_amb_river_mist_gen',
    'ent_amb_insect_swarm',
    'bul_tarmac_heli',
    'muz_smoking_barrel_rocket',
    'ent_amb_fire_gaswork',
    'ent_amb_cluckb_steam',
    'water_amph_quad_entry',
    'ent_col_tree_leaves',
    'ent_amb_stoner_woodchip_drop',
    'water_splash_veh_trail',
    'ent_dst_inflate_ball_clr',
    'exp_grd_gren_sp',
    'wheel_fric_leaves_Tank',
    'weap_extinguisher',
    'env_wind_debris_desert',
    'ent_brk_banknotes',
    'ent_amb_fountain_mansion2',
    'ent_amb_stoner_rubble_drop',
    'ped_foot_bushes',
    'ent_amb_sol1_plane_wreck',
    'wheel_fric_mud_Bike',
    'veh_wheel_burst',
    'fire_vehicle',
    'ent_anim_cig_exhale_mth',
    'ped_water_drips',
    'ent_ray_paleto_gas_plume_amb_L',
    'eject_pistol',
    'glass_side_window_PC',
    'water_splash_plane_wade',
    'ent_amb_cockroaches',
    'ped_bang_sand_underwater',
    'veh_exhaust_plane_misfire',
    'ent_dst_pineapple',
    'ped_foot_water_puddle',
    'ent_amb_bubble_stream',
    'ped_wade_mud',
    'ent_dst_metal_frag',
    'water_splash_bicycle_out',
    'ent_amb_fbi_live_wires',
    'veh_air_turbulance_sand',
    'eject_shotgun_fp',
    'exp_grd_plane_spawn',
    'mp_parachute_smoke',
    '_fog_foundry',
    'ent_dst_mail',
    'weap_hvy_turbulance_foliage',
    'ent_amb_abattoir_carcass',
    'ent_anim_hen_flee',
    'ent_col_falling_snow',
    'exp_sht_extinguisher',
    'ent_dst_crispbags',
    'wheel_spin_sand',
    'water_boat_LOD',
    'ent_sht_beer_containers',
    'veh_exhaust_start',
    'ent_amb_wfall_splash_lg',
    'ent_amb_fbi_smoke_creep',
    'bang_metal',
    'fire_ped_limb',
    'water_amph_quad_bow_mounted',
    'ent_amb_water_drips_dam_med',
    'veh_air_turbulance_foliage',
    'ent_amb_trop_fish_swarm',
    'ent_ray_heli_aprtmnt_s_fire_sq',
    'ent_anim_cig_exhale_nse_car',
    'veh_exhaust_misfire',
    'bullet_tracer_mg',
    'wheel_fric_gravel_Tank',
    'ent_amb_fbi_smoke_door_lt',
    'proj_molotov_trail',
    'veh_vent_plane',
    'veh_light_clear',
    'scrape_dirt_dry',
    'ent_amb_fbi_smoke_land_hvy',
    'fire_wrecked_rc',
    'wheel_decal_petrol',
    'ent_ray_paleto_gas_plume_amb',
    'water_cannon_spray',
    'ent_amb_cold_air_vent',
    'bul_stungun',
    'wheel_decal_sand_deep',
    'blood_mouth',
    'veh_exhaust_cuban800',
    'proj_laser_enemy',
    'water_splash_plane_out',
    'ent_amb_wfall_splash_med',
    'ent_amb_falling_leaves_l',
    'fire_wrecked_heli',
    'ent_brk_cactus',
    'liquid_splash_water',
    'bang_dirt_dry',
    'proj_rpg_trail',
    'water_heli_blades',
    'bul_plaster_brittle',
    'env_wind_sand_dune',
    'ent_amb_fbi_fire_lg',
    'fire_wrecked_tank_cockpit',
    'eject_sniper_amrifle',
    'bul_decal_mud',
    'bul_brick_heli',
    'scrape_blood_car',
    'wheel_spin_water',
    'ent_amb_water_drips_sm',
    'ent_amb_fbi_smoke_stair_gather',
    'wheel_decal_oil',
    'veh_faggio_exhaust',
    'td_blood_melee_blunt',
    'wheel_fric_mud',
    'lens_test',
    'ent_amb_floating_debris',
    'ent_col_gen_tree_dust',
    'weap_heist_flare_trail',
    'bang_hydraulics',
    'exp_air_plane_rpg_spawn',
    'ent_ray_heli_aprtmnt_silt',
    'ent_amb_smoke_foundry_white',
    'wheel_decal_blood_Bike',
    'wheel_decal_mud_Tank',
    'ent_amb_trev1_trailer_sp_f',
    'ent_amb_dry_ice_vent',
    'sp_foundry_sparks',
    'ent_amb_waterfall_pool',
    'muz_smg',
    'eject_pistol_fp',
    'scr_fbi_ground_debris',
    'env_stripclub_haze',
    'blood_stungun',
    'veh_wingtip_cargo',
    'bul_bushes',
    'bang_plastic',
    'ent_amb_stoner_falling_debris',
    'ent_sht_extinguisher_water',
    'fire_map',
    'ent_amb_fountain_pour',
    'weap_veh_turbulance_water',
    'weap_smoke_grenade',
    'water_splash_generic',
    'scrape_blood',
    'ent_amb_moths_cupboard',
    'bul_glass_heli',
    'ent_amb_smoke_factory_white',
    'muz_railgun',
    'exp_air_rpg',
    'eject_sniper',
    'veh_vent_plane_titan',
    'ent_sht_rubbish',
    'water_jetmax_exit',
    'wheel_fric_sand_Tank',
    'ent_amb_trevor_tap_drip',
    'veh_exhaust_cargo',
    'td_blood_pistol',
    'ent_amb_fbi_smoke_ramp_hvy',
    'veh_debris_trail',
    'wtr_rocks_rnd_splash',
    'ent_ray_fin_petrol_splash',
    'veh_exhaust_trailer_chimney',
    'fire_wrecked_bus',
    'veh_exhaust_afterburner',
    'ent_amb_fbi_smoke_ramp_med',
    'exp_grd_rpg_spawn',
    'ent_dst_snow_tombs',
    'exp_grd_rpg_plane',
    'ent_amb_steam_vent_open_hvy',
    'glass_shards',
    'ent_sht_telegraph_pole',
    'ent_dst_rocks',
    'ent_amb_steam_vent_rnd_hvy',
    'ent_amb_fbi_smoke_land_med',
    'ent_amb_smoke_factory',
    'eject_smg_fp',
    'ent_dst_box_noodle',
    'ent_amb_wind_litter_dust_swirl',
    'exp_air_grenade',
    'ent_amb_acid_bath',
    'blood_melee_blunt',
    'fire_petroltank_boat',
    'fire_ped_body',
    'blood_armour',
    'ent_dst_bread',
    'water_splash_veh_wade',
    'ent_amb_fbi_door_smoke',
    'ent_amb_fbi_smoke_door_hvy',
    'ped_wade_sand',
    'exp_air_blimp2',
    'veh_vent_bike',
    'veh_rotor_break_tail',
    'scrape_concrete',
    'muz_pistol',
    'water_boat_dinghy_bow',
    'ent_brk_sparking_wires_sp',
    'ped_breath',
    'ent_amb_stoner_landing',
    'ped_underwater_trails',
    'bul_sand_loose',
    'ped_foot_decal_blood',
    'water_splash_bicycle_in',
    'lens_water',
    'veh_wheel_puncture',
    'veh_wheel_puncture_rc',
    'wheel_spin_sandWet',
    'ent_amb_fbi_fire_sm',
    'water_splash_bike_trail',
    'ped_breath_scuba',
    'ent_ray_paleto_gas_window_fire',
    'water_splash_bicycle_trail',
    'blood_fall',
    'env_wind_debris_mountain',
    'ent_dst_pumpkin',
    'ent_amb_water_roof_pour_long',
    'sp_fire_trail_plane',
    'wheel_fric_dusty_LOD',
    'ent_amb_waterfall_runoff',
    'ent_dst_ceramics',
    'wheel_decal_sand_wet_deep',
    'veh_sub_leak',
    'ent_amb_water_roof_pour',
    'ent_dst_egg_mulch',
    'wheel_decal_puddle',
    'wheel_fric_hard_Bike',
    'ent_dst_gen_choc',
    'proj_molotov_flame',
    'env_smoke_fbi_thin',
    'ent_dst_litter',
    'water_splash_bicycle_wade',
    'scr_agency3b_sprinkler_on',
    'water_amph_car_bow_mounted',
    'veh_exhaust_boat',
    'veh_air_turbulance_water',
    'fire_extinguish',
    'wheel_fric_hard_dusty',
    'ped_blood_drips',
    'veh_air_turbulance_default',
    'ent_anim_blown_radiator',
    'bul_grass_heli',
    'ent_amb_fly_swarm',
    'exp_grd_rpg',
    'ent_amb_falling_leaves_s',
    'ent_anim_bbq',
    'veh_oil_leak',
    'ent_amb_rapid_dir_splash',
    'muz_smg_fp',
    'bul_dirt',
    'bul_decal_petrol',
    'bul_tarmac',
    'fire_petroltank_bike',
    'ent_amb_vent_haze_lg',
    'veh_downwash_water',
    'ped_foot_sand_wet_deep',
    'wheel_decal_blood',
    'env_fog',
    'blood_wheel',
    'veh_petrol_leak_bike',
    'ent_amb_int_waterfall_runoff',
    'ent_dst_glass_bulb',
    'env_dust_motes',
    'ent_sht_electrical_box',
    'ent_amb_fbi_smoke_edge_lip',
    'ent_amb_fbi_smoke_linger_lt',
    'ent_amb_water_roof_drips',
    'ent_dst_dust',
    'ent_amb_int_fireplace',
    'wheel_decal_water',
    'ent_amb_wind_leaves_swirl',
    'ent_dst_rocks_small',
    'fire_map_slow',
    'ent_amb_waterfall_splash',
    'ent_amb_dry_ice_area',
    'fire_petrol_pool',
    'water_splash_bike_in',
    'ent_anim_fish_flee_bubbles',
    'bang_sand',
    'fire_petrol_half',
    'ent_anim_cig_smoke_car',
    'ent_amb_fbi_fire_wall_sm',
    'veh_petrol_leak',
    'ent_dst_inflate_lilo',
    'eject_sniper_heavy',
    'exp_grd_petrol_pump_post',
    'env_smoke_grenade',
    'bul_water',
    'ent_sht_feathers',
    'ent_brk_champagne_case',
    'ent_anim_fish_breath_bubbles',
    'wheel_fric_grass_Tank',
    'glass_side_window',
    'ent_ray_prologue_elec_crackle_sp',
    'trail_splash_petrol',
    'muz_minigun',
    'ped_wade_sand_wet',
    'wheel_decal_puddle_Bike',
    'water_boat_Marques_bow',
    'veh_exhaust_car',
    'ent_amb_snow_mist_base',
    'ped_parachute_canopy_trail',
    'ent_amb_foundry_arc_heat',
    'veh_rotor_break',
}

local Particl = nil

RegisterCommand("particles", function()
    if p:getPermission() < 3 then return end
    RageUI.Visible(menu, true)
    
    while true do 
        Wait(1)
        RageUI.IsVisible(menu, function()
            for k,v in pairs(Particles) do 
                RageUI.Button(v, nil, {}, true, {
                    onSelected = function()
                        if Particl then
                            StopParticleFxLooped(Particl, 0)
                            RemoveParticleFx(Particl, 0)
                        end
                        RequestNamedPtfxAsset("core")
                        UseParticleFxAssetNextCall("core")
                
                        while not HasNamedPtfxAssetLoaded("core") do
                            Wait(100)
                        end
                        local coords, forward = GetEntityCoords(p:ped()), GetEntityForwardVector(p:ped())
                        local particleCoords = (coords + forward * 1.5)
                        Particl = StartParticleFxLoopedAtCoord(v, particleCoords, 0.0, 0.0, 0.0, 1.0, 0, 0, 0)
                    end,
                })
            end
        end)
    end
end)

-- "ent_brk_sparking_wires"