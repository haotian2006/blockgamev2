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
        height = 256,
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
        depth = {
            type = "reference",
            key = "depth"
          },
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
                                            argument1 = "C:overworld/depth"
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
        weirdness  = "C:overworld/ridges",
        temperature = {
            type = "C:shifted_noise",
            noise = "C:temperature",
            shift_x = "C:shift_x",
            shift_y = 0.0,
            shift_z = "C:shift_z",
            xz_scale = 0.25,
            y_scale = 0.0
        },
        humidity = {
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
}