return {
    aquifers_enabled = true,
    default_block = {
        Name = "C:stone"
    },
    default_fluid = {
        Name = "C:water",
        Properties = {
            level = "0"
        }
    },
    disable_mob_generation = false,
    legacy_random_source = false, 
    noise = {
        height = 128,
        min_y = 0,
        size_horizontal = 1,
        size_vertical = 2
    },
    noise_Router = {
        barrier = {
            type = "C:noise",
            noise = "C:aquifer_barrier",
            xz_scale = 1.0,
            y_scale = 0.5
        },
        continents = "C:overworld/continents",
        depth = "C:overworld/depth",
        erosion = "C:overworld/erosion",
        inital_Density =  {
            type = "C:squeeze",
            argument = {
              type = "C:mul",
              argument1 = 0.64,
              argument2 = {
                type = "C:blend_density",
                argument = {
                  type = "C:add",
                  argument1 = 0.1171875,
                  argument2 = {
                    type = "C:mul",
                    argument1 = {
                      type = "C:y_clamped_gradient",
                      from_y = 0,
                      to_y = 1,
                      from_value = 0,
                      to_value = 1
                    },
                    argument2 = {
                      type = "C:add",
                      argument1 = -0.1171875,
                      argument2 = {
                        type = "C:add",
                        argument1 = -0.078125,
                        argument2 = {
                          type = "C:mul",
                          argument1 = {
                            type = "C:y_clamped_gradient",
                            from_y = 240,
                            to_y = 256,
                            from_value = 1,
                            to_value = 0
                          },
                          argument2 = {
                            type = "C:add",
                            argument1 = 0.078125,
                            argument2 = {
                                type = "C:add",
                                argument1 = {
                                    type = "C:mul",
                                    argument1 = 4.0,
                                    argument2 = {
                                      type = "C:quarter_negative",
                                      argument = {
                                        type = "C:mul",
                                        argument1 = {
                                          type = "C:add",
                                          argument1 ={
                                            type = "C:add",
                                            argument1 = {
                                                type = "C:y_clamped_gradient",
                                                from_value = 1.5,
                                                from_y = -64,
                                                to_value = -1.5,
                                                to_y = 320
                                            },
                                            argument2 = {
                                                type = 'reference',
                                                key = 'offset'
                                            }
                                            },
                                          argument2 = {
                                            type = "reference",
                                            key = "jaggedness"
                                            
                                          }
                                        },
                                        argument2 ={
                                            type = 'reference',
                                            key = 'factor'
                                        }
                                      }
                                    }
                                  },
                                argument2 = "C:overworld/base_3d_noise"
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
        },

        final_density = {
            type = "C:squeeze",
            argument = {
              type = "C:mul",
              argument1 = 0.64,
              argument2 = {
                type = "C:interpolated",
                argument = {
                  type = "C:blend_density",
                  argument = {
                    type = "C:add",
                    argument1 = 0.1171875,
                    argument2 = {
                      type = "C:mul",
                      argument1 = {
                        type = "C:y_clamped_gradient",
                        from_value = 0.0,
                        from_y = -64,
                        to_value = 1.0,
                        to_y = -40
                      },
                      argument2 = {
                        type = "C:add",
                        argument1 = -0.1171875,
                        argument2 = {
                          type = "C:add",
                          argument1 = -0.078125,
                          argument2 = {
                            type = "C:mul",
                            argument1 = {
                              type = "C:y_clamped_gradient",
                              from_value = 1.0,
                              from_y = 240,
                              to_value = 0.0,
                              to_y = 256
                            },
                            argument2 = {
                              type = "C:add",
                              argument1 = 0.078125,
                              argument2 = "C:overworld/sloped_cheese"
                            }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
        },
        initial_density_without_jaggedness = {
            type = "C:add",
            argument1 = 0.1171875,
            argument2 = {
                type = "C:mul",
                argument1 = {
                    type = "C:y_clamped_gradient",
                    from_value = 0.0,
                    from_y = -64,
                    to_value = 1.0,
                    to_y = -40
                },
                argument2 = {
                    type = "C:add",
                    argument1 = -0.1171875,
                    argument2 = {
                        type = "C:add",
                        argument1 = -0.078125,
                        argument2 = {
                            type = "C:mul",
                            argument1 = {
                                type = "C:y_clamped_gradient",
                                from_value = 1.0,
                                from_y = 240,
                                to_value = 0.0,
                                to_y = 256
                            },
                            argument2 = {
                                type = "C:add",
                                argument1 = 0.078125,
                                argument2 = {
                                    type = "C:clamp",
                                    input = {
                                        type = "C:add",
                                        argument1 = -0.703125,
                                        argument2 = {
                                            type = "C:mul",
                                            argument1 = 4.0,
                                            argument2 = {
                                                type = "C:quarter_negative",
                                                argument = {
                                                    type = "C:mul",
                                                    argument1 = "C:overworld/depth",
                                                    argument2 = {
                                                        type = "C:cache_2d",
                                                        argument = "C:overworld/factor",
                                                        id = 6,
                                                    }
                                                }
                                            }
                                        }
                                    },
                                    max = 64.0,
                                    min = -64.0
                                }
                            }
                        }
                    }
                }
            }
        },
        ridges = "C:overworld/ridges",
        temperature = {
            type = "C:shifted_noise",
            noise = "C:temperature",
            shift_x = "C:shift_x",
            shift_y = 0.0,
            shift_z = "C:shift_z",
            xz_scale = 0.25,
            y_scale = 0.0
        },
        vegetation = {
            type = "C:shifted_noise",
            noise = "C:vegetation",
            shift_x = "C:shift_x",
            shift_y = 0.0,
            shift_z = "C:shift_z",
            xz_scale = 0.25,
            y_scale = 0.0
        },
        xzOrder = {
            {
               type = 'set',
               argument  = {
                type = "C:mul",
                argument1 = "C:overworld/jaggedness",
                argument2 = {
                    type = "C:half_negative",
                    argument = {
                    type = "C:noise",
                    noise = "C:jagged",
                    xz_scale = 1500.0,
                    y_scale = 0.0
                    }
                }
               },
               key = "jaggedness"
             },-- calculate the jaggedness
             {
                type = 'set',
                argument = "C:overworld/offset",
                key = 'offset'
             },
             {
                type = 'set',
                argument = "C:overworld/factor",
                key = 'factor'
             }
        }
    },
    ore_veins_enabled = true,
    sea_level = 63,
    spawn_target = { {
        continentalness = { -0.11, 1.0 },
        depth = 0.0,
        erosion = { -1.0, 1.0 },
        humidity = { -1.0, 1.0 },
        offset = 0.0,
        temperature = { -1.0, 1.0 },
        weirdness = { -1.0, -0.16 }
    }, {
        continentalness = { -0.11, 1.0 },
        depth = 0.0,
        erosion = { -1.0, 1.0 },
        humidity = { -1.0, 1.0 },
        offset = 0.0,
        temperature = { -1.0, 1.0 },
        weirdness = { 0.16, 1.0 }
    } },
    surface_rule = {
        type = "C:sequence",
        sequence = { {
            type = "C:condition",
            if_true = {
                type = "C:vertical_gradient",
                false_at_and_above = {
                    above_bottom = 5
                },
                random_name = "C:bedrock_floor",
                true_at_and_below = {
                    above_bottom = 0
                }
            },
            then_run = {
                type = "C:block",
                result_state = {
                    Name = "C:bedrock"
                }
            }
        }, {
            type = "C:condition",
            if_true = {
                type = "C:above_preliminary_surface"
            },
            then_run = {
                type = "C:sequence",
                sequence = { {
                    type = "C:condition",
                    if_true = {
                        type = "C:stone_depth",
                        add_surface_depth = false,
                        offset = 0,
                        secondary_depth_range = 0,
                        surface_type = "floor"
                    },
                    then_run = {
                        type = "C:sequence",
                        sequence = { {
                            type = "C:condition",
                            if_true = {
                                type = "C:biome",
                                biome_is = { "C:wooded_badlands" }
                            },
                            then_run = {
                                type = "C:condition",
                                if_true = {
                                    type = "C:y_above",
                                    add_stone_depth = false,
                                    anchor = {
                                        absolute = 97
                                    },
                                    surface_depth_multiplier = 2
                                },
                                then_run = {
                                    type = "C:sequence",
                                    sequence = { {
                                        type = "C:condition",
                                        if_true = {
                                            type = "C:noise_threshold",
                                            max_threshold = -0.5454,
                                            min_threshold = -0.909,
                                            noise = "C:surface"
                                        },
                                        then_run = {
                                            type = "C:block",
                                            result_state = {
                                                Name = "C:coarse_dirt"
                                            }
                                        }
                                    }, {
                                        type = "C:condition",
                                        if_true = {
                                            type = "C:noise_threshold",
                                            max_threshold = 0.1818,
                                            min_threshold = -0.1818,
                                            noise = "C:surface"
                                        },
                                        then_run = {
                                            type = "C:block",
                                            result_state = {
                                                Name = "C:coarse_dirt"
                                            }
                                        }
                                    }, {
                                        type = "C:condition",
                                        if_true = {
                                            type = "C:noise_threshold",
                                            max_threshold = 0.909,
                                            min_threshold = 0.5454,
                                            noise = "C:surface"
                                        },
                                        then_run = {
                                            type = "C:block",
                                            result_state = {
                                                Name = "C:coarse_dirt"
                                            }
                                        }
                                    }, {
                                        type = "C:sequence",
                                        sequence = { {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:water",
                                                add_stone_depth = false,
                                                offset = 0,
                                                surface_depth_multiplier = 0
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:grass_block",
                                                    Properties = {
                                                        snowy = "false"
                                                    }
                                                }
                                            }
                                        }, {
                                            type = "C:block",
                                            result_state = {
                                                Name = "C:dirt"
                                            }
                                        } }
                                    } }
                                }
                            }
                        }, {
                            type = "C:condition",
                            if_true = {
                                type = "C:biome",
                                biome_is = { "C:swamp" }
                            },
                            then_run = {
                                type = "C:condition",
                                if_true = {
                                    type = "C:y_above",
                                    add_stone_depth = false,
                                    anchor = {
                                        absolute = 62
                                    },
                                    surface_depth_multiplier = 0
                                },
                                then_run = {
                                    type = "C:condition",
                                    if_true = {
                                        type = "C:not",
                                        invert = {
                                            type = "C:y_above",
                                            add_stone_depth = false,
                                            anchor = {
                                                absolute = 63
                                            },
                                            surface_depth_multiplier = 0
                                        }
                                    },
                                    then_run = {
                                        type = "C:condition",
                                        if_true = {
                                            type = "C:noise_threshold",
                                            max_threshold = 1.7976931348623157E308,
                                            min_threshold = 0.0,
                                            noise = "C:surface_swamp"
                                        },
                                        then_run = {
                                            type = "C:block",
                                            result_state = {
                                                Name = "C:water",
                                                Properties = {
                                                    level = "0"
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }, {
                            type = "C:condition",
                            if_true = {
                                type = "C:biome",
                                biome_is = { "C:mangrove_swamp" }
                            },
                            then_run = {
                                type = "C:condition",
                                if_true = {
                                    type = "C:y_above",
                                    add_stone_depth = false,
                                    anchor = {
                                        absolute = 60
                                    },
                                    surface_depth_multiplier = 0
                                },
                                then_run = {
                                    type = "C:condition",
                                    if_true = {
                                        type = "C:not",
                                        invert = {
                                            type = "C:y_above",
                                            add_stone_depth = false,
                                            anchor = {
                                                absolute = 63
                                            },
                                            surface_depth_multiplier = 0
                                        }
                                    },
                                    then_run = {
                                        type = "C:condition",
                                        if_true = {
                                            type = "C:noise_threshold",
                                            max_threshold = 1.7976931348623157E308,
                                            min_threshold = 0.0,
                                            noise = "C:surface_swamp"
                                        },
                                        then_run = {
                                            type = "C:block",
                                            result_state = {
                                                Name = "C:water",
                                                Properties = {
                                                    level = "0"
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        } }
                    }
                }, {
                    type = "C:condition",
                    if_true = {
                        type = "C:biome",
                        biome_is = { "C:badlands", "C:eroded_badlands", "C:wooded_badlands" }
                    },
                    then_run = {
                        type = "C:sequence",
                        sequence = { {
                            type = "C:condition",
                            if_true = {
                                type = "C:stone_depth",
                                add_surface_depth = false,
                                offset = 0,
                                secondary_depth_range = 0,
                                surface_type = "floor"
                            },
                            then_run = {
                                type = "C:sequence",
                                sequence = { {
                                    type = "C:condition",
                                    if_true = {
                                        type = "C:y_above",
                                        add_stone_depth = false,
                                        anchor = {
                                            absolute = 256
                                        },
                                        surface_depth_multiplier = 0
                                    },
                                    then_run = {
                                        type = "C:block",
                                        result_state = {
                                            Name = "C:orange_terracotta"
                                        }
                                    }
                                }, {
                                    type = "C:condition",
                                    if_true = {
                                        type = "C:y_above",
                                        add_stone_depth = true,
                                        anchor = {
                                            absolute = 74
                                        },
                                        surface_depth_multiplier = 1
                                    },
                                    then_run = {
                                        type = "C:sequence",
                                        sequence = { {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:noise_threshold",
                                                max_threshold = -0.5454,
                                                min_threshold = -0.909,
                                                noise = "C:surface"
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:terracotta"
                                                }
                                            }
                                        }, {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:noise_threshold",
                                                max_threshold = 0.1818,
                                                min_threshold = -0.1818,
                                                noise = "C:surface"
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:terracotta"
                                                }
                                            }
                                        }, {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:noise_threshold",
                                                max_threshold = 0.909,
                                                min_threshold = 0.5454,
                                                noise = "C:surface"
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:terracotta"
                                                }
                                            }
                                        }, {
                                            type = "C:bandlands"
                                        } }
                                    }
                                }, {
                                    type = "C:condition",
                                    if_true = {
                                        type = "C:water",
                                        add_stone_depth = false,
                                        offset = -1,
                                        surface_depth_multiplier = 0
                                    },
                                    then_run = {
                                        type = "C:sequence",
                                        sequence = { {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:stone_depth",
                                                add_surface_depth = false,
                                                offset = 0,
                                                secondary_depth_range = 0,
                                                surface_type = "ceiling"
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:red_sandstone"
                                                }
                                            }
                                        }, {
                                            type = "C:block",
                                            result_state = {
                                                Name = "C:red_sand"
                                            }
                                        } }
                                    }
                                }, {
                                    type = "C:condition",
                                    if_true = {
                                        type = "C:not",
                                        invert = {
                                            type = "C:hole"
                                        }
                                    },
                                    then_run = {
                                        type = "C:block",
                                        result_state = {
                                            Name = "C:orange_terracotta"
                                        }
                                    }
                                }, {
                                    type = "C:condition",
                                    if_true = {
                                        type = "C:water",
                                        add_stone_depth = true,
                                        offset = -6,
                                        surface_depth_multiplier = -1
                                    },
                                    then_run = {
                                        type = "C:block",
                                        result_state = {
                                            Name = "C:white_terracotta"
                                        }
                                    }
                                }, {
                                    type = "C:sequence",
                                    sequence = { {
                                        type = "C:condition",
                                        if_true = {
                                            type = "C:stone_depth",
                                            add_surface_depth = false,
                                            offset = 0,
                                            secondary_depth_range = 0,
                                            surface_type = "ceiling"
                                        },
                                        then_run = {
                                            type = "C:block",
                                            result_state = {
                                                Name = "C:stone"
                                            }
                                        }
                                    }, {
                                        type = "C:block",
                                        result_state = {
                                            Name = "C:gravel"
                                        }
                                    } }
                                } }
                            }
                        }, {
                            type = "C:condition",
                            if_true = {
                                type = "C:y_above",
                                add_stone_depth = true,
                                anchor = {
                                    absolute = 63
                                },
                                surface_depth_multiplier = -1
                            },
                            then_run = {
                                type = "C:sequence",
                                sequence = { {
                                    type = "C:condition",
                                    if_true = {
                                        type = "C:y_above",
                                        add_stone_depth = false,
                                        anchor = {
                                            absolute = 63
                                        },
                                        surface_depth_multiplier = 0
                                    },
                                    then_run = {
                                        type = "C:condition",
                                        if_true = {
                                            type = "C:not",
                                            invert = {
                                                type = "C:y_above",
                                                add_stone_depth = true,
                                                anchor = {
                                                    absolute = 74
                                                },
                                                surface_depth_multiplier = 1
                                            }
                                        },
                                        then_run = {
                                            type = "C:block",
                                            result_state = {
                                                Name = "C:orange_terracotta"
                                            }
                                        }
                                    }
                                }, {
                                    type = "C:bandlands"
                                } }
                            }
                        }, {
                            type = "C:condition",
                            if_true = {
                                type = "C:stone_depth",
                                add_surface_depth = true,
                                offset = 0,
                                secondary_depth_range = 0,
                                surface_type = "floor"
                            },
                            then_run = {
                                type = "C:condition",
                                if_true = {
                                    type = "C:water",
                                    add_stone_depth = true,
                                    offset = -6,
                                    surface_depth_multiplier = -1
                                },
                                then_run = {
                                    type = "C:block",
                                    result_state = {
                                        Name = "C:white_terracotta"
                                    }
                                }
                            }
                        } }
                    }
                }, {
                    type = "C:condition",
                    if_true = {
                        type = "C:stone_depth",
                        add_surface_depth = false,
                        offset = 0,
                        secondary_depth_range = 0,
                        surface_type = "floor"
                    },
                    then_run = {
                        type = "C:condition",
                        if_true = {
                            type = "C:water",
                            add_stone_depth = false,
                            offset = -1,
                            surface_depth_multiplier = 0
                        },
                        then_run = {
                            type = "C:sequence",
                            sequence = { {
                                type = "C:condition",
                                if_true = {
                                    type = "C:biome",
                                    biome_is = { "C:frozen_ocean", "C:deep_frozen_ocean" }
                                },
                                then_run = {
                                    type = "C:condition",
                                    if_true = {
                                        type = "C:hole"
                                    },
                                    then_run = {
                                        type = "C:sequence",
                                        sequence = { {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:water",
                                                add_stone_depth = false,
                                                offset = 0,
                                                surface_depth_multiplier = 0
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:air"
                                                }
                                            }
                                        }, {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:temperature"
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:ice"
                                                }
                                            }
                                        }, {
                                            type = "C:block",
                                            result_state = {
                                                Name = "C:water",
                                                Properties = {
                                                    level = "0"
                                                }
                                            }
                                        } }
                                    }
                                }
                            }, {
                                type = "C:sequence",
                                sequence = { {
                                    type = "C:condition",
                                    if_true = {
                                        type = "C:biome",
                                        biome_is = { "C:frozen_peaks" }
                                    },
                                    then_run = {
                                        type = "C:sequence",
                                        sequence = { {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:steep"
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:packed_ice"
                                                }
                                            }
                                        }, {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:noise_threshold",
                                                max_threshold = 0.2,
                                                min_threshold = 0.0,
                                                noise = "C:packed_ice"
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:packed_ice"
                                                }
                                            }
                                        }, {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:noise_threshold",
                                                max_threshold = 0.025,
                                                min_threshold = 0.0,
                                                noise = "C:ice"
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:ice"
                                                }
                                            }
                                        }, {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:water",
                                                add_stone_depth = false,
                                                offset = 0,
                                                surface_depth_multiplier = 0
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:snow_block"
                                                }
                                            }
                                        } }
                                    }
                                }, {
                                    type = "C:condition",
                                    if_true = {
                                        type = "C:biome",
                                        biome_is = { "C:snowy_slopes" }
                                    },
                                    then_run = {
                                        type = "C:sequence",
                                        sequence = { {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:steep"
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:stone"
                                                }
                                            }
                                        }, {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:noise_threshold",
                                                max_threshold = 0.6,
                                                min_threshold = 0.35,
                                                noise = "C:powder_snow"
                                            },
                                            then_run = {
                                                type = "C:condition",
                                                if_true = {
                                                    type = "C:water",
                                                    add_stone_depth = false,
                                                    offset = 0,
                                                    surface_depth_multiplier = 0
                                                },
                                                then_run = {
                                                    type = "C:block",
                                                    result_state = {
                                                        Name = "C:powder_snow"
                                                    }
                                                }
                                            }
                                        }, {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:water",
                                                add_stone_depth = false,
                                                offset = 0,
                                                surface_depth_multiplier = 0
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:snow_block"
                                                }
                                            }
                                        } }
                                    }
                                }, {
                                    type = "C:condition",
                                    if_true = {
                                        type = "C:biome",
                                        biome_is = { "C:jagged_peaks" }
                                    },
                                    then_run = {
                                        type = "C:sequence",
                                        sequence = { {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:steep"
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:stone"
                                                }
                                            }
                                        }, {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:water",
                                                add_stone_depth = false,
                                                offset = 0,
                                                surface_depth_multiplier = 0
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:snow_block"
                                                }
                                            }
                                        } }
                                    }
                                }, {
                                    type = "C:condition",
                                    if_true = {
                                        type = "C:biome",
                                        biome_is = { "C:grove" }
                                    },
                                    then_run = {
                                        type = "C:sequence",
                                        sequence = { {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:noise_threshold",
                                                max_threshold = 0.6,
                                                min_threshold = 0.35,
                                                noise = "C:powder_snow"
                                            },
                                            then_run = {
                                                type = "C:condition",
                                                if_true = {
                                                    type = "C:water",
                                                    add_stone_depth = false,
                                                    offset = 0,
                                                    surface_depth_multiplier = 0
                                                },
                                                then_run = {
                                                    type = "C:block",
                                                    result_state = {
                                                        Name = "C:powder_snow"
                                                    }
                                                }
                                            }
                                        }, {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:water",
                                                add_stone_depth = false,
                                                offset = 0,
                                                surface_depth_multiplier = 0
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:snow_block"
                                                }
                                            }
                                        } }
                                    }
                                }, {
                                    type = "C:sequence",
                                    sequence = { {
                                        type = "C:condition",
                                        if_true = {
                                            type = "C:biome",
                                            biome_is = { "C:stony_peaks" }
                                        },
                                        then_run = {
                                            type = "C:sequence",
                                            sequence = { {
                                                type = "C:condition",
                                                if_true = {
                                                    type = "C:noise_threshold",
                                                    max_threshold = 0.0125,
                                                    min_threshold = -0.0125,
                                                    noise = "C:calcite"
                                                },
                                                then_run = {
                                                    type = "C:block",
                                                    result_state = {
                                                        Name = "C:calcite"
                                                    }
                                                }
                                            }, {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:stone"
                                                }
                                            } }
                                        }
                                    }, {
                                        type = "C:condition",
                                        if_true = {
                                            type = "C:biome",
                                            biome_is = { "C:stony_shore" }
                                        },
                                        then_run = {
                                            type = "C:sequence",
                                            sequence = { {
                                                type = "C:condition",
                                                if_true = {
                                                    type = "C:noise_threshold",
                                                    max_threshold = 0.05,
                                                    min_threshold = -0.05,
                                                    noise = "C:gravel"
                                                },
                                                then_run = {
                                                    type = "C:sequence",
                                                    sequence = { {
                                                        type = "C:condition",
                                                        if_true = {
                                                            type = "C:stone_depth",
                                                            add_surface_depth = false,
                                                            offset = 0,
                                                            secondary_depth_range = 0,
                                                            surface_type = "ceiling"
                                                        },
                                                        then_run = {
                                                            type = "C:block",
                                                            result_state = {
                                                                Name = "C:stone"
                                                            }
                                                        }
                                                    }, {
                                                        type = "C:block",
                                                        result_state = {
                                                            Name = "C:gravel"
                                                        }
                                                    } }
                                                }
                                            }, {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:stone"
                                                }
                                            } }
                                        }
                                    }, {
                                        type = "C:condition",
                                        if_true = {
                                            type = "C:biome",
                                            biome_is = { "C:windswept_hills" }
                                        },
                                        then_run = {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:noise_threshold",
                                                max_threshold = 1.7976931348623157E308,
                                                min_threshold = 0.12121212121212122,
                                                noise = "C:surface"
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:stone"
                                                }
                                            }
                                        }
                                    }, {
                                        type = "C:condition",
                                        if_true = {
                                            type = "C:biome",
                                            biome_is = { "C:warm_ocean", "C:beach", "C:snowy_beach" }
                                        },
                                        then_run = {
                                            type = "C:sequence",
                                            sequence = { {
                                                type = "C:condition",
                                                if_true = {
                                                    type = "C:stone_depth",
                                                    add_surface_depth = false,
                                                    offset = 0,
                                                    secondary_depth_range = 0,
                                                    surface_type = "ceiling"
                                                },
                                                then_run = {
                                                    type = "C:block",
                                                    result_state = {
                                                        Name = "C:sandstone"
                                                    }
                                                }
                                            }, {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:sand"
                                                }
                                            } }
                                        }
                                    }, {
                                        type = "C:condition",
                                        if_true = {
                                            type = "C:biome",
                                            biome_is = { "C:desert" }
                                        },
                                        then_run = {
                                            type = "C:sequence",
                                            sequence = { {
                                                type = "C:condition",
                                                if_true = {
                                                    type = "C:stone_depth",
                                                    add_surface_depth = false,
                                                    offset = 0,
                                                    secondary_depth_range = 0,
                                                    surface_type = "ceiling"
                                                },
                                                then_run = {
                                                    type = "C:block",
                                                    result_state = {
                                                        Name = "C:sandstone"
                                                    }
                                                }
                                            }, {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:sand"
                                                }
                                            } }
                                        }
                                    }, {
                                        type = "C:condition",
                                        if_true = {
                                            type = "C:biome",
                                            biome_is = { "C:dripstone_caves" }
                                        },
                                        then_run = {
                                            type = "C:block",
                                            result_state = {
                                                Name = "C:stone"
                                            }
                                        }
                                    } }
                                }, {
                                    type = "C:condition",
                                    if_true = {
                                        type = "C:biome",
                                        biome_is = { "C:windswept_savanna" }
                                    },
                                    then_run = {
                                        type = "C:sequence",
                                        sequence = { {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:noise_threshold",
                                                max_threshold = 1.7976931348623157E308,
                                                min_threshold = 0.21212121212121213,
                                                noise = "C:surface"
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:stone"
                                                }
                                            }
                                        }, {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:noise_threshold",
                                                max_threshold = 1.7976931348623157E308,
                                                min_threshold = -0.06060606060606061,
                                                noise = "C:surface"
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:coarse_dirt"
                                                }
                                            }
                                        } }
                                    }
                                }, {
                                    type = "C:condition",
                                    if_true = {
                                        type = "C:biome",
                                        biome_is = { "C:windswept_gravelly_hills" }
                                    },
                                    then_run = {
                                        type = "C:sequence",
                                        sequence = { {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:noise_threshold",
                                                max_threshold = 1.7976931348623157E308,
                                                min_threshold = 0.24242424242424243,
                                                noise = "C:surface"
                                            },
                                            then_run = {
                                                type = "C:sequence",
                                                sequence = { {
                                                    type = "C:condition",
                                                    if_true = {
                                                        type = "C:stone_depth",
                                                        add_surface_depth = false,
                                                        offset = 0,
                                                        secondary_depth_range = 0,
                                                        surface_type = "ceiling"
                                                    },
                                                    then_run = {
                                                        type = "C:block",
                                                        result_state = {
                                                            Name = "C:stone"
                                                        }
                                                    }
                                                }, {
                                                    type = "C:block",
                                                    result_state = {
                                                        Name = "C:gravel"
                                                    }
                                                } }
                                            }
                                        }, {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:noise_threshold",
                                                max_threshold = 1.7976931348623157E308,
                                                min_threshold = 0.12121212121212122,
                                                noise = "C:surface"
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:stone"
                                                }
                                            }
                                        }, {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:noise_threshold",
                                                max_threshold = 1.7976931348623157E308,
                                                min_threshold = -0.12121212121212122,
                                                noise = "C:surface"
                                            },
                                            then_run = {
                                                type = "C:sequence",
                                                sequence = { {
                                                    type = "C:condition",
                                                    if_true = {
                                                        type = "C:water",
                                                        add_stone_depth = false,
                                                        offset = 0,
                                                        surface_depth_multiplier = 0
                                                    },
                                                    then_run = {
                                                        type = "C:block",
                                                        result_state = {
                                                            Name = "C:grass_block",
                                                            Properties = {
                                                                snowy = "false"
                                                            }
                                                        }
                                                    }
                                                }, {
                                                    type = "C:block",
                                                    result_state = {
                                                        Name = "C:dirt"
                                                    }
                                                } }
                                            }
                                        }, {
                                            type = "C:sequence",
                                            sequence = { {
                                                type = "C:condition",
                                                if_true = {
                                                    type = "C:stone_depth",
                                                    add_surface_depth = false,
                                                    offset = 0,
                                                    secondary_depth_range = 0,
                                                    surface_type = "ceiling"
                                                },
                                                then_run = {
                                                    type = "C:block",
                                                    result_state = {
                                                        Name = "C:stone"
                                                    }
                                                }
                                            }, {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:gravel"
                                                }
                                            } }
                                        } }
                                    }
                                }, {
                                    type = "C:condition",
                                    if_true = {
                                        type = "C:biome",
                                        biome_is = { "C:old_growth_pine_taiga", "C:old_growth_spruce_taiga" }
                                    },
                                    then_run = {
                                        type = "C:sequence",
                                        sequence = { {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:noise_threshold",
                                                max_threshold = 1.7976931348623157E308,
                                                min_threshold = 0.21212121212121213,
                                                noise = "C:surface"
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:coarse_dirt"
                                                }
                                            }
                                        }, {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:noise_threshold",
                                                max_threshold = 1.7976931348623157E308,
                                                min_threshold = -0.11515151515151514,
                                                noise = "C:surface"
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:podzol",
                                                    Properties = {
                                                        snowy = "false"
                                                    }
                                                }
                                            }
                                        } }
                                    }
                                }, {
                                    type = "C:condition",
                                    if_true = {
                                        type = "C:biome",
                                        biome_is = { "C:ice_spikes" }
                                    },
                                    then_run = {
                                        type = "C:condition",
                                        if_true = {
                                            type = "C:water",
                                            add_stone_depth = false,
                                            offset = 0,
                                            surface_depth_multiplier = 0
                                        },
                                        then_run = {
                                            type = "C:block",
                                            result_state = {
                                                Name = "C:snow_block"
                                            }
                                        }
                                    }
                                }, {
                                    type = "C:condition",
                                    if_true = {
                                        type = "C:biome",
                                        biome_is = { "C:mangrove_swamp" }
                                    },
                                    then_run = {
                                        type = "C:block",
                                        result_state = {
                                            Name = "C:mud"
                                        }
                                    }
                                }, {
                                    type = "C:condition",
                                    if_true = {
                                        type = "C:biome",
                                        biome_is = { "C:mushroom_fields" }
                                    },
                                    then_run = {
                                        type = "C:block",
                                        result_state = {
                                            Name = "C:mycelium",
                                            Properties = {
                                                snowy = "false"
                                            }
                                        }
                                    }
                                }, {
                                    type = "C:sequence",
                                    sequence = { {
                                        type = "C:condition",
                                        if_true = {
                                            type = "C:water",
                                            add_stone_depth = false,
                                            offset = 0,
                                            surface_depth_multiplier = 0
                                        },
                                        then_run = {
                                            type = "C:block",
                                            result_state = {
                                                Name = "C:grass_block",
                                                Properties = {
                                                    snowy = "false"
                                                }
                                            }
                                        }
                                    }, {
                                        type = "C:block",
                                        result_state = {
                                            Name = "C:dirt"
                                        }
                                    } }
                                } }
                            } }
                        }
                    }
                }, {
                    type = "C:condition",
                    if_true = {
                        type = "C:water",
                        add_stone_depth = true,
                        offset = -6,
                        surface_depth_multiplier = -1
                    },
                    then_run = {
                        type = "C:sequence",
                        sequence = { {
                            type = "C:condition",
                            if_true = {
                                type = "C:stone_depth",
                                add_surface_depth = false,
                                offset = 0,
                                secondary_depth_range = 0,
                                surface_type = "floor"
                            },
                            then_run = {
                                type = "C:condition",
                                if_true = {
                                    type = "C:biome",
                                    biome_is = { "C:frozen_ocean", "C:deep_frozen_ocean" }
                                },
                                then_run = {
                                    type = "C:condition",
                                    if_true = {
                                        type = "C:hole"
                                    },
                                    then_run = {
                                        type = "C:block",
                                        result_state = {
                                            Name = "C:water",
                                            Properties = {
                                                level = "0"
                                            }
                                        }
                                    }
                                }
                            }
                        }, {
                            type = "C:condition",
                            if_true = {
                                type = "C:stone_depth",
                                add_surface_depth = true,
                                offset = 0,
                                secondary_depth_range = 0,
                                surface_type = "floor"
                            },
                            then_run = {
                                type = "C:sequence",
                                sequence = { {
                                    type = "C:condition",
                                    if_true = {
                                        type = "C:biome",
                                        biome_is = { "C:frozen_peaks" }
                                    },
                                    then_run = {
                                        type = "C:sequence",
                                        sequence = { {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:steep"
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:packed_ice"
                                                }
                                            }
                                        }, {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:noise_threshold",
                                                max_threshold = 0.2,
                                                min_threshold = -0.5,
                                                noise = "C:packed_ice"
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:packed_ice"
                                                }
                                            }
                                        }, {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:noise_threshold",
                                                max_threshold = 0.025,
                                                min_threshold = -0.0625,
                                                noise = "C:ice"
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:ice"
                                                }
                                            }
                                        }, {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:water",
                                                add_stone_depth = false,
                                                offset = 0,
                                                surface_depth_multiplier = 0
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:snow_block"
                                                }
                                            }
                                        } }
                                    }
                                }, {
                                    type = "C:condition",
                                    if_true = {
                                        type = "C:biome",
                                        biome_is = { "C:snowy_slopes" }
                                    },
                                    then_run = {
                                        type = "C:sequence",
                                        sequence = { {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:steep"
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:stone"
                                                }
                                            }
                                        }, {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:noise_threshold",
                                                max_threshold = 0.58,
                                                min_threshold = 0.45,
                                                noise = "C:powder_snow"
                                            },
                                            then_run = {
                                                type = "C:condition",
                                                if_true = {
                                                    type = "C:water",
                                                    add_stone_depth = false,
                                                    offset = 0,
                                                    surface_depth_multiplier = 0
                                                },
                                                then_run = {
                                                    type = "C:block",
                                                    result_state = {
                                                        Name = "C:powder_snow"
                                                    }
                                                }
                                            }
                                        }, {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:water",
                                                add_stone_depth = false,
                                                offset = 0,
                                                surface_depth_multiplier = 0
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:snow_block"
                                                }
                                            }
                                        } }
                                    }
                                }, {
                                    type = "C:condition",
                                    if_true = {
                                        type = "C:biome",
                                        biome_is = { "C:jagged_peaks" }
                                    },
                                    then_run = {
                                        type = "C:block",
                                        result_state = {
                                            Name = "C:stone"
                                        }
                                    }
                                }, {
                                    type = "C:condition",
                                    if_true = {
                                        type = "C:biome",
                                        biome_is = { "C:grove" }
                                    },
                                    then_run = {
                                        type = "C:sequence",
                                        sequence = { {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:noise_threshold",
                                                max_threshold = 0.58,
                                                min_threshold = 0.45,
                                                noise = "C:powder_snow"
                                            },
                                            then_run = {
                                                type = "C:condition",
                                                if_true = {
                                                    type = "C:water",
                                                    add_stone_depth = false,
                                                    offset = 0,
                                                    surface_depth_multiplier = 0
                                                },
                                                then_run = {
                                                    type = "C:block",
                                                    result_state = {
                                                        Name = "C:powder_snow"
                                                    }
                                                }
                                            }
                                        }, {
                                            type = "C:block",
                                            result_state = {
                                                Name = "C:dirt"
                                            }
                                        } }
                                    }
                                }, {
                                    type = "C:sequence",
                                    sequence = { {
                                        type = "C:condition",
                                        if_true = {
                                            type = "C:biome",
                                            biome_is = { "C:stony_peaks" }
                                        },
                                        then_run = {
                                            type = "C:sequence",
                                            sequence = { {
                                                type = "C:condition",
                                                if_true = {
                                                    type = "C:noise_threshold",
                                                    max_threshold = 0.0125,
                                                    min_threshold = -0.0125,
                                                    noise = "C:calcite"
                                                },
                                                then_run = {
                                                    type = "C:block",
                                                    result_state = {
                                                        Name = "C:calcite"
                                                    }
                                                }
                                            }, {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:stone"
                                                }
                                            } }
                                        }
                                    }, {
                                        type = "C:condition",
                                        if_true = {
                                            type = "C:biome",
                                            biome_is = { "C:stony_shore" }
                                        },
                                        then_run = {
                                            type = "C:sequence",
                                            sequence = { {
                                                type = "C:condition",
                                                if_true = {
                                                    type = "C:noise_threshold",
                                                    max_threshold = 0.05,
                                                    min_threshold = -0.05,
                                                    noise = "C:gravel"
                                                },
                                                then_run = {
                                                    type = "C:sequence",
                                                    sequence = { {
                                                        type = "C:condition",
                                                        if_true = {
                                                            type = "C:stone_depth",
                                                            add_surface_depth = false,
                                                            offset = 0,
                                                            secondary_depth_range = 0,
                                                            surface_type = "ceiling"
                                                        },
                                                        then_run = {
                                                            type = "C:block",
                                                            result_state = {
                                                                Name = "C:stone"
                                                            }
                                                        }
                                                    }, {
                                                        type = "C:block",
                                                        result_state = {
                                                            Name = "C:gravel"
                                                        }
                                                    } }
                                                }
                                            }, {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:stone"
                                                }
                                            } }
                                        }
                                    }, {
                                        type = "C:condition",
                                        if_true = {
                                            type = "C:biome",
                                            biome_is = { "C:windswept_hills" }
                                        },
                                        then_run = {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:noise_threshold",
                                                max_threshold = 1.7976931348623157E308,
                                                min_threshold = 0.12121212121212122,
                                                noise = "C:surface"
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:stone"
                                                }
                                            }
                                        }
                                    }, {
                                        type = "C:condition",
                                        if_true = {
                                            type = "C:biome",
                                            biome_is = { "C:warm_ocean", "C:beach", "C:snowy_beach" }
                                        },
                                        then_run = {
                                            type = "C:sequence",
                                            sequence = { {
                                                type = "C:condition",
                                                if_true = {
                                                    type = "C:stone_depth",
                                                    add_surface_depth = false,
                                                    offset = 0,
                                                    secondary_depth_range = 0,
                                                    surface_type = "ceiling"
                                                },
                                                then_run = {
                                                    type = "C:block",
                                                    result_state = {
                                                        Name = "C:sandstone"
                                                    }
                                                }
                                            }, {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:sand"
                                                }
                                            } }
                                        }
                                    }, {
                                        type = "C:condition",
                                        if_true = {
                                            type = "C:biome",
                                            biome_is = { "C:desert" }
                                        },
                                        then_run = {
                                            type = "C:sequence",
                                            sequence = { {
                                                type = "C:condition",
                                                if_true = {
                                                    type = "C:stone_depth",
                                                    add_surface_depth = false,
                                                    offset = 0,
                                                    secondary_depth_range = 0,
                                                    surface_type = "ceiling"
                                                },
                                                then_run = {
                                                    type = "C:block",
                                                    result_state = {
                                                        Name = "C:sandstone"
                                                    }
                                                }
                                            }, {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:sand"
                                                }
                                            } }
                                        }
                                    }, {
                                        type = "C:condition",
                                        if_true = {
                                            type = "C:biome",
                                            biome_is = { "C:dripstone_caves" }
                                        },
                                        then_run = {
                                            type = "C:block",
                                            result_state = {
                                                Name = "C:stone"
                                            }
                                        }
                                    } }
                                }, {
                                    type = "C:condition",
                                    if_true = {
                                        type = "C:biome",
                                        biome_is = { "C:windswept_savanna" }
                                    },
                                    then_run = {
                                        type = "C:condition",
                                        if_true = {
                                            type = "C:noise_threshold",
                                            max_threshold = 1.7976931348623157E308,
                                            min_threshold = 0.21212121212121213,
                                            noise = "C:surface"
                                        },
                                        then_run = {
                                            type = "C:block",
                                            result_state = {
                                                Name = "C:stone"
                                            }
                                        }
                                    }
                                }, {
                                    type = "C:condition",
                                    if_true = {
                                        type = "C:biome",
                                        biome_is = { "C:windswept_gravelly_hills" }
                                    },
                                    then_run = {
                                        type = "C:sequence",
                                        sequence = { {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:noise_threshold",
                                                max_threshold = 1.7976931348623157E308,
                                                min_threshold = 0.24242424242424243,
                                                noise = "C:surface"
                                            },
                                            then_run = {
                                                type = "C:sequence",
                                                sequence = { {
                                                    type = "C:condition",
                                                    if_true = {
                                                        type = "C:stone_depth",
                                                        add_surface_depth = false,
                                                        offset = 0,
                                                        secondary_depth_range = 0,
                                                        surface_type = "ceiling"
                                                    },
                                                    then_run = {
                                                        type = "C:block",
                                                        result_state = {
                                                            Name = "C:stone"
                                                        }
                                                    }
                                                }, {
                                                    type = "C:block",
                                                    result_state = {
                                                        Name = "C:gravel"
                                                    }
                                                } }
                                            }
                                        }, {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:noise_threshold",
                                                max_threshold = 1.7976931348623157E308,
                                                min_threshold = 0.12121212121212122,
                                                noise = "C:surface"
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:stone"
                                                }
                                            }
                                        }, {
                                            type = "C:condition",
                                            if_true = {
                                                type = "C:noise_threshold",
                                                max_threshold = 1.7976931348623157E308,
                                                min_threshold = -0.12121212121212122,
                                                noise = "C:surface"
                                            },
                                            then_run = {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:dirt"
                                                }
                                            }
                                        }, {
                                            type = "C:sequence",
                                            sequence = { {
                                                type = "C:condition",
                                                if_true = {
                                                    type = "C:stone_depth",
                                                    add_surface_depth = false,
                                                    offset = 0,
                                                    secondary_depth_range = 0,
                                                    surface_type = "ceiling"
                                                },
                                                then_run = {
                                                    type = "C:block",
                                                    result_state = {
                                                        Name = "C:stone"
                                                    }
                                                }
                                            }, {
                                                type = "C:block",
                                                result_state = {
                                                    Name = "C:gravel"
                                                }
                                            } }
                                        } }
                                    }
                                }, {
                                    type = "C:condition",
                                    if_true = {
                                        type = "C:biome",
                                        biome_is = { "C:mangrove_swamp" }
                                    },
                                    then_run = {
                                        type = "C:block",
                                        result_state = {
                                            Name = "C:mud"
                                        }
                                    }
                                }, {
                                    type = "C:block",
                                    result_state = {
                                        Name = "C:dirt"
                                    }
                                } }
                            }
                        }, {
                            type = "C:condition",
                            if_true = {
                                type = "C:biome",
                                biome_is = { "C:warm_ocean", "C:beach", "C:snowy_beach" }
                            },
                            then_run = {
                                type = "C:condition",
                                if_true = {
                                    type = "C:stone_depth",
                                    add_surface_depth = true,
                                    offset = 0,
                                    secondary_depth_range = 6,
                                    surface_type = "floor"
                                },
                                then_run = {
                                    type = "C:block",
                                    result_state = {
                                        Name = "C:sandstone"
                                    }
                                }
                            }
                        }, {
                            type = "C:condition",
                            if_true = {
                                type = "C:biome",
                                biome_is = { "C:desert" }
                            },
                            then_run = {
                                type = "C:condition",
                                if_true = {
                                    type = "C:stone_depth",
                                    add_surface_depth = true,
                                    offset = 0,
                                    secondary_depth_range = 30,
                                    surface_type = "floor"
                                },
                                then_run = {
                                    type = "C:block",
                                    result_state = {
                                        Name = "C:sandstone"
                                    }
                                }
                            }
                        } }
                    }
                }, {
                    type = "C:condition",
                    if_true = {
                        type = "C:stone_depth",
                        add_surface_depth = false,
                        offset = 0,
                        secondary_depth_range = 0,
                        surface_type = "floor"
                    },
                    then_run = {
                        type = "C:sequence",
                        sequence = { {
                            type = "C:condition",
                            if_true = {
                                type = "C:biome",
                                biome_is = { "C:frozen_peaks", "C:jagged_peaks" }
                            },
                            then_run = {
                                type = "C:block",
                                result_state = {
                                    Name = "C:stone"
                                }
                            }
                        }, {
                            type = "C:condition",
                            if_true = {
                                type = "C:biome",
                                biome_is = { "C:warm_ocean", "C:lukewarm_ocean", "C:deep_lukewarm_ocean" }
                            },
                            then_run = {
                                type = "C:sequence",
                                sequence = { {
                                    type = "C:condition",
                                    if_true = {
                                        type = "C:stone_depth",
                                        add_surface_depth = false,
                                        offset = 0,
                                        secondary_depth_range = 0,
                                        surface_type = "ceiling"
                                    },
                                    then_run = {
                                        type = "C:block",
                                        result_state = {
                                            Name = "C:sandstone"
                                        }
                                    }
                                }, {
                                    type = "C:block",
                                    result_state = {
                                        Name = "C:sand"
                                    }
                                } }
                            }
                        }, {
                            type = "C:sequence",
                            sequence = { {
                                type = "C:condition",
                                if_true = {
                                    type = "C:stone_depth",
                                    add_surface_depth = false,
                                    offset = 0,
                                    secondary_depth_range = 0,
                                    surface_type = "ceiling"
                                },
                                then_run = {
                                    type = "C:block",
                                    result_state = {
                                        Name = "C:stone"
                                    }
                                }
                            }, {
                                type = "C:block",
                                result_state = {
                                    Name = "C:gravel"
                                }
                            } }
                        } }
                    }
                } }
            }
        }, {
            type = "C:condition",
            if_true = {
                type = "C:vertical_gradient",
                false_at_and_above = {
                    absolute = 8
                },
                random_name = "C:deepslate",
                true_at_and_below = {
                    absolute = 0
                }
            },
            then_run = {
                type = "C:block",
                result_state = {
                    Name = "C:deepslate",
                    Properties = {
                        axis = "y"
                    }
                }
            }
        } }
    }
}